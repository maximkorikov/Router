#!/bin/sh

# === СТРОГАЯ ФИКСАЦИЯ ВЕРСИИ PODKOP v0.2.5 ===
REPO="https://api.github.com/repos/itdoginfo/podkop/releases/tags/v0.2.5"

IS_SHOULD_RESTART_NETWORK=
DOWNLOAD_DIR="/tmp/podkop"
mkdir -p "$DOWNLOAD_DIR"

main() {
    check_system

    # Скачивание файлов Podkop v0.2.5 через API
    wget -qO- "$REPO" | grep -o 'https://[^"]*\.ipk' | while read -r url; do
        filename=$(basename "$url")
        echo "Download $filename..."
        wget -q -O "$DOWNLOAD_DIR/$filename" "$url"
    done

    echo "opkg update"
    opkg update

    if opkg list-installed | grep -q dnsmasq-full; then
        echo "dnsmasq-full already installed"
    else
        echo "Installed dnsmasq-full"
        cd /tmp/ && opkg download dnsmasq-full
        opkg remove dnsmasq && opkg install dnsmasq-full --cache /tmp/

        [ -f /etc/config/dhcp-opkg ] && cp /etc/config/dhcp /etc/config/dhcp-old && mv /etc/config/dhcp-opkg /etc/config/dhcp
    fi

    openwrt_release=$(cat /etc/openwrt_release | grep -Eo [0-9]{2}[.][0-9]{2}[.][0-9]* | cut -d '.' -f 1 | tail -n 1)
    if [ $openwrt_release -ge 24 ]; then
        if uci get dhcp.@dnsmasq[0].confdir | grep -q /tmp/dnsmasq.d; then
            echo "confdir already set"
        else
            printf "Setting confdir"
            uci set dhcp.@dnsmasq[0].confdir='/tmp/dnsmasq.d'
            uci commit dhcp
        fi
    fi
    
    if [ -f "/etc/init.d/podkop" ]; then
        printf "\033[32;1mPodkop is already installed. Just upgrade it? (y/n)\033[0m\n"
        printf "\033[32;1my - Only upgrade podkop\033[0m\n"
        printf "\033[32;1mn - Upgrade and install proxy or tunnels\033[0m\n"

        while true; do
            read -r -p '' UPDATE
            case $UPDATE in
            y)
                echo "Upgraded podkop..."
                break
                ;;

            n)
                add_tunnel
                break
                ;;

            *)
                echo "Please enter y or n"
                ;;
            esac
        done
    else
        echo "Installed podkop..."
        add_tunnel
    fi

    opkg install $DOWNLOAD_DIR/podkop*.ipk
    opkg install $DOWNLOAD_DIR/luci-app-podkop*.ipk

    echo "Русский язык интерфейса ставим? y/n (Need a Russian translation?)"
    while true; do
        read -r -p '' RUS
        case $RUS in
        y)
            opkg install $DOWNLOAD_DIR/luci-i18n-podkop-ru*.ipk
            break
            ;;

        n)
            break
            ;;

        *)
            echo "Please enter y or n"
            ;;
        esac
    done

    rm -f $DOWNLOAD_DIR/podkop*.ipk $DOWNLOAD_DIR/luci-app-podkop*.ipk $DOWNLOAD_DIR/luci-i18n-podkop-ru*.ipk

    if [ "$IS_SHOULD_RESTART_NETWORK" ]; then
        printf "\033[32;1mRestart network\033[0m\n"
        /etc/init.d/network restart
    fi
}

add_tunnel() {
    echo "What type of VPN or proxy will be used?"
    echo "1) VLESS, Shadowsocks (A sing-box will be installed)"
    echo "2) Wireguard"
    echo "3) AmneziaWG (Auto-selected)"
    echo "4) OpenVPN"
    echo "5) OpenConnect"
    echo "6) Skip this step"

    # === АВТОМАТИЗАЦИЯ: Сразу ставим 3 (AmneziaWG) ===
    echo "Automatically selecting option 3 (AmneziaWG)..."
    TUNNEL=3

    case $TUNNEL in

    1)
        opkg install sing-box
        ;;

    2)
        opkg install wireguard-tools luci-proto-wireguard luci-app-wireguard
        # ... старый код для Wireguard пропущен для краткости, так как мы выбрали 3 ...
        ;;

    3)
        install_awg_packages

        printf "\033[32;1mAutomatically configuring AmneziaWG interface...\033[0m\n"
        # === АВТОМАТИЗАЦИЯ: Пропускаем вопрос (y/n) и сразу запускаем настройку ===
        wg_awg_setup AmneziaWG
        ;;

    4)
        opkg install opkg install openvpn-openssl luci-app-openvpn
        printf "\e[1;32mUse these instructions to configure https://itdog.info/nastrojka-klienta-openvpn-na-openwrt/\e[0m\n"
        ;;

    5)
        opkg install opkg install openconnect luci-proto-openconnect
        printf "\e[1;32mUse these instructions to configure https://itdog.info/nastrojka-klienta-openconnect-na-openwrt/\e[0m\n"
        ;;

    6)
        echo "Skip. Use this if you're installing an upgrade."
        ;;

    *)
        echo "Choose from the following options"
        ;;
    esac
}

handler_network_restart() {
    IS_SHOULD_RESTART_NETWORK=true
}

install_awg_packages() {
    # Получение архитектуры
    PKGARCH=$(opkg print-architecture | awk 'BEGIN {max=0} {if ($3 > max) {max = $3; arch = $2}} END {print arch}')

    TARGET=$(ubus call system board | jsonfilter -e '@.release.target' | cut -d '/' -f 1)
    SUBTARGET=$(ubus call system board | jsonfilter -e '@.release.target' | cut -d '/' -f 2)
    
    # === СТРОГАЯ ФИКСАЦИЯ ВЕРСИИ AMNEZIA 24.10.4 ===
    VERSION="24.10.4"
    PKGPOSTFIX="_v${VERSION}_${PKGARCH}_${TARGET}_${SUBTARGET}.ipk"
    BASE_URL="https://github.com/Slava-Shchipunov/awg-openwrt/releases/download/v${VERSION}/"

    AWG_DIR="/tmp/amneziawg"
    mkdir -p "$AWG_DIR"
    
    # 1. KMOD
    if opkg list-installed | grep -q kmod-amneziawg; then
        echo "kmod-amneziawg already installed"
    else
        KMOD_AMNEZIAWG_FILENAME="kmod-amneziawg${PKGPOSTFIX}"
        echo "Downloading $KMOD_AMNEZIAWG_FILENAME..."
        wget -O "$AWG_DIR/$KMOD_AMNEZIAWG_FILENAME" "${BASE_URL}${KMOD_AMNEZIAWG_FILENAME}"

        if [ $? -eq 0 ]; then
            opkg install "$AWG_DIR/$KMOD_AMNEZIAWG_FILENAME"
        else
            echo "Error downloading kmod-amneziawg. Please check if your architecture exists in v24.10.4 release."
            exit 1
        fi
    fi

    # 2. TOOLS
    if opkg list-installed | grep -q amneziawg-tools; then
        echo "amneziawg-tools already installed"
    else
        AMNEZIAWG_TOOLS_FILENAME="amneziawg-tools${PKGPOSTFIX}"
        echo "Downloading $AMNEZIAWG_TOOLS_FILENAME..."
        wget -O "$AWG_DIR/$AMNEZIAWG_TOOLS_FILENAME" "${BASE_URL}${AMNEZIAWG_TOOLS_FILENAME}"

        if [ $? -eq 0 ]; then
            opkg install "$AWG_DIR/$AMNEZIAWG_TOOLS_FILENAME"
        else
            echo "Error downloading amneziawg-tools."
            exit 1
        fi
    fi
    
    # 3. LUCI-PROTO (Вместо LUCI-APP)
    if opkg list-installed | grep -q luci-proto-amneziawg; then
        echo "luci-proto-amneziawg already installed"
    else
        # Используем luci-proto, так как в v24.10.4 изменилось имя
        LUCI_PROTO_AMNEZIAWG_FILENAME="luci-proto-amneziawg${PKGPOSTFIX}"
        echo "Downloading $LUCI_PROTO_AMNEZIAWG_FILENAME..."
        wget -O "$AWG_DIR/$LUCI_PROTO_AMNEZIAWG_FILENAME" "${BASE_URL}${LUCI_PROTO_AMNEZIAWG_FILENAME}"

        if [ $? -eq 0 ]; then
            opkg install "$AWG_DIR/$LUCI_PROTO_AMNEZIAWG_FILENAME"
        else
            echo "Error downloading luci-proto-amneziawg."
            exit 1
        fi
    fi

    # 4. Русификация (по желанию, но раз она есть в релизе — ставим)
    LUCI_RU_FILENAME="luci-i18n-amneziawg-ru${PKGPOSTFIX}"
    wget -q -O "$AWG_DIR/$LUCI_RU_FILENAME" "${BASE_URL}${LUCI_RU_FILENAME}"
    if [ -s "$AWG_DIR/$LUCI_RU_FILENAME" ]; then
         opkg install "$AWG_DIR/$LUCI_RU_FILENAME"
    fi

    rm -rf "$AWG_DIR"
}

wg_awg_setup() {
    PROTOCOL_NAME=$1
    printf "\033[32;1mConfigure ${PROTOCOL_NAME}\033[0m\n"
    if [ "$PROTOCOL_NAME" = 'Wireguard' ]; then
        INTERFACE_NAME="wg0"
        CONFIG_NAME="wireguard_wg0"
        PROTO="wireguard"
        ZONE_NAME="wg"
    fi

    if [ "$PROTOCOL_NAME" = 'AmneziaWG' ]; then
        INTERFACE_NAME="awg0"
        CONFIG_NAME="amneziawg_awg0"
        PROTO="amneziawg"
        ZONE_NAME="awg"
        
        # === АВТОМАТИЗАЦИЯ: Сразу выбираем режим 2 (Obfuscation) ===
        echo "Automatically selecting config type: 2) Wireguard + automatic obfuscation"
        CONFIG_TYPE='2'
    fi

    read -r -p "Enter the private key (from [Interface]):"$'\n' WG_PRIVATE_KEY_INT

    while true; do
        read -r -p "Enter internal IP address with subnet, example 192.168.100.5/24 (from [Interface]):"$'\n' WG_IP
        if echo "$WG_IP" | egrep -oq '^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]+$'; then
            break
        else
            echo "This IP is not valid. Please repeat"
        fi
    done

    read -r -p "Enter the public key (from [Peer]):"$'\n' WG_PUBLIC_KEY_INT
    read -r -p "If use PresharedKey, Enter this (from [Peer]). If your don't use leave blank:"$'\n' WG_PRESHARED_KEY_INT
    read -r -p "Enter Endpoint host without port (Domain or IP) (from [Peer]):"$'\n' WG_ENDPOINT_INT

    read -r -p "Enter Endpoint host port (from [Peer]) [51820]:"$'\n' WG_ENDPOINT_PORT_INT
    WG_ENDPOINT_PORT_INT=${WG_ENDPOINT_PORT_INT:-51820}
    if [ "$WG_ENDPOINT_PORT_INT" = '51820' ]; then
        echo $WG_ENDPOINT_PORT_INT
    fi

    if [ "$PROTOCOL_NAME" = 'AmneziaWG' ]; then
        # Блок ручного ввода параметров удален, так как жестко выбран тип 2
        if [ "$CONFIG_TYPE" = '2' ]; then
            # Default values to wg automatic obfuscation
            AWG_JC=4
            AWG_JMIN=40
            AWG_JMAX=70
            AWG_S1=0
            AWG_S2=0
            AWG_H1=1
            AWG_H2=2
            AWG_H3=3
            AWG_H4=4
        fi
    fi
    
    uci set network.${INTERFACE_NAME}=interface
    uci set network.${INTERFACE_NAME}.proto=$PROTO
    uci set network.${INTERFACE_NAME}.private_key=$WG_PRIVATE_KEY_INT
    uci set network.${INTERFACE_NAME}.listen_port='51821'
    uci set network.${INTERFACE_NAME}.addresses=$WG_IP

    if [ "$PROTOCOL_NAME" = 'AmneziaWG' ]; then
        uci set network.${INTERFACE_NAME}.awg_jc=$AWG_JC
        uci set network.${INTERFACE_NAME}.awg_jmin=$AWG_JMIN
        uci set network.${INTERFACE_NAME}.awg_jmax=$AWG_JMAX
        uci set network.${INTERFACE_NAME}.awg_s1=$AWG_S1
        uci set network.${INTERFACE_NAME}.awg_s2=$AWG_S2
        uci set network.${INTERFACE_NAME}.awg_h1=$AWG_H1
        uci set network.${INTERFACE_NAME}.awg_h2=$AWG_H2
        uci set network.${INTERFACE_NAME}.awg_h3=$AWG_H3
        uci set network.${INTERFACE_NAME}.awg_h4=$AWG_H4
    fi

    if ! uci show network | grep -q ${CONFIG_NAME}; then
        uci add network ${CONFIG_NAME}
    fi

    uci set network.@${CONFIG_NAME}[0]=$CONFIG_NAME
    uci set network.@${CONFIG_NAME}[0].name="${INTERFACE_NAME}_client"
    uci set network.@${CONFIG_NAME}[0].public_key=$WG_PUBLIC_KEY_INT
    uci set network.@${CONFIG_NAME}[0].preshared_key=$WG_PRESHARED_KEY_INT
    uci set network.@${CONFIG_NAME}[0].route_allowed_ips='0'
    uci set network.@${CONFIG_NAME}[0].persistent_keepalive='25'
    uci set network.@${CONFIG_NAME}[0].endpoint_host=$WG_ENDPOINT_INT
    uci set network.@${CONFIG_NAME}[0].allowed_ips='0.0.0.0/0'
    uci set network.@${CONFIG_NAME}[0].endpoint_port=$WG_ENDPOINT_PORT_INT
    uci commit network

    if ! uci show firewall | grep -q "@zone.*name='${ZONE_NAME}'"; then
        printf "\033[32;1mZone Create\033[0m\n"
        uci add firewall zone
        uci set firewall.@zone[-1].name=$ZONE_NAME
        uci set firewall.@zone[-1].network=$INTERFACE_NAME
        uci set firewall.@zone[-1].forward='REJECT'
        uci set firewall.@zone[-1].output='ACCEPT'
        uci set firewall.@zone[-1].input='REJECT'
        uci set firewall.@zone[-1].masq='1'
        uci set firewall.@zone[-1].mtu_fix='1'
        uci set firewall.@zone[-1].family='ipv4'
        uci commit firewall
    fi

    if ! uci show firewall | grep -q "@forwarding.*name='${ZONE_NAME}'"; then
        printf "\033[32;1mConfigured forwarding\033[0m\n"
        uci add firewall forwarding
        uci set firewall.@forwarding[-1]=forwarding
        uci set firewall.@forwarding[-1].name="${ZONE_NAME}-lan"
        uci set firewall.@forwarding[-1].dest=${ZONE_NAME}
        uci set firewall.@forwarding[-1].src='lan'
        uci set firewall.@forwarding[-1].family='ipv4'
        uci commit firewall
    fi

    handler_network_restart
}

check_system() {
    # Get router model
    MODEL=$(cat /tmp/sysinfo/model)
    echo "Router model: $MODEL"

    # Check available space
    AVAILABLE_SPACE=$(df /tmp | awk 'NR==2 {print $4}')
    # Change after switch sing-box
    REQUIRED_SPACE=1024 # 20MB in KB

    echo "Available space: $((AVAILABLE_SPACE/1024))MB"
    echo "Required space: $((REQUIRED_SPACE/1024))MB"

    if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
        echo "Error: Insufficient space in /tmp"
        echo "Available: $((AVAILABLE_SPACE/1024))MB"
        echo "Required: $((REQUIRED_SPACE/1024))MB"
        exit 1
    fi
}

main
