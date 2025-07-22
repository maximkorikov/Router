#!/bin/sh

# Функция для применения конфигурации WARP
apply_warp_config() {
    local warp_config="$1"

    if [ -z "$warp_config" ]; then
        echo "Ошибка: Конфигурация WARP не предоставлена для применения."
        return 1
    fi

    # Парсинг .conf (секции [Interface], [Peer])
    local current_section=""
    while IFS= read -r line; do
        line=$(echo "$line" | tr -d '\r')  # удалить \r из Windows-формата
        [ -z "$line" ] && continue
        case "$line" in
            \[*\]) current_section=$(echo "$line" | tr -d '[]'); continue ;;
        esac

        local key=$(echo "$line" | cut -d '=' -f1 | xargs)
        local value=$(echo "$line" | cut -d '=' -f2- | xargs)

        case "$key" in
            PrivateKey) PrivateKey="$value" ;;
            PublicKey) PublicKey="$value" ;;
            Address) Address="$value" ;;
            AllowedIPs) AllowedIPs="$value" ;;
            Endpoint) Endpoint="$value" ;;
            DNS) DNS="$value" ;;
            MTU) MTU="$value" ;;
            S1) S1="$value" ;;
            S2) S2="$value" ;;
            Jc) Jc="$value" ;;
            Jmin) Jmin="$value" ;;
            Jmax) Jmax="$value" ;;
            H1) H1="$value" ;;
            H2) H2="$value" ;;
            H3) H3="$value" ;;
            H4) H4="$value" ;;
        esac
    done <<EOF
$warp_config
EOF

    # Обработка значений
    Address=$(echo "$Address" | cut -d',' -f1)
    DNS=$(echo "$DNS" | cut -d',' -f1)
    AllowedIPs=$(echo "$AllowedIPs" | cut -d',' -f1)
    EndpointIP=$(echo "$Endpoint" | cut -d':' -f1)
    EndpointPort=$(echo "$Endpoint" | cut -d':' -f2)

    printf "\033[32;1mCreate and configure tunnel AmneziaWG WARP...\033[0m\n"

    INTERFACE_NAME="awg10"
    CONFIG_NAME="amneziawg_awg10"
    PROTO="amneziawg"
    ZONE_NAME="awg"

    uci set network.${INTERFACE_NAME}=interface
    uci set network.${INTERFACE_NAME}.proto=$PROTO
    if ! uci show network | grep -q ${CONFIG_NAME}; then
        uci add network ${CONFIG_NAME}
    fi
    uci set network.${INTERFACE_NAME}.private_key=$PrivateKey
    uci del network.${INTERFACE_NAME}.addresses
    uci add_list network.${INTERFACE_NAME}.addresses=$Address
    uci set network.${INTERFACE_NAME}.mtu=$MTU
    uci set network.${INTERFACE_NAME}.awg_jc=$Jc
    uci set network.${INTERFACE_NAME}.awg_jmin=$Jmin
    uci set network.${INTERFACE_NAME}.awg_jmax=$Jmax
    uci set network.${INTERFACE_NAME}.awg_s1=$S1
    uci set network.${INTERFACE_NAME}.awg_s2=$S2
    uci set network.${INTERFACE_NAME}.awg_h1=$H1
    uci set network.${INTERFACE_NAME}.awg_h2=$H2
    uci set network.${INTERFACE_NAME}.awg_h3=$H3
    uci set network.${INTERFACE_NAME}.awg_h4=$H4
    uci set network.${INTERFACE_NAME}.nohostroute='1'
    uci set network.@${CONFIG_NAME}[-1].description="${INTERFACE_NAME}_peer"
    uci set network.@${CONFIG_NAME}[-1].public_key=$PublicKey
    uci set network.@${CONFIG_NAME}[-1].endpoint_host=$EndpointIP
    uci set network.@${CONFIG_NAME}[-1].endpoint_port=$EndpointPort
    uci set network.@${CONFIG_NAME}[-1].persistent_keepalive='25'
    uci set network.@${CONFIG_NAME}[-1].allowed_ips='0.0.0.0/0'
    uci set network.@${CONFIG_NAME}[-1].route_allowed_ips='0'
    uci commit network

    modprobe amneziawg
    /etc/init.d/netifd restart

    echo "Checking status of awg10 interface..."
    ip link show awg10 || echo "Interface awg10 not found or not active."

    if ! uci show firewall | grep -q "@zone.*name='${ZONE_NAME}'"; then
        echo "Zone Create"
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
        echo "Configured forwarding"
        uci add firewall forwarding
        uci set firewall.@forwarding[-1]=forwarding
        uci set firewall.@forwarding[-1].name="${ZONE_NAME}"
        uci set firewall.@forwarding[-1].dest=${ZONE_NAME}
        uci set firewall.@forwarding[-1].src='lan'
        uci set firewall.@forwarding[-1].family='ipv4'
        uci commit firewall
    fi

    ZONES=$(uci show firewall | grep "zone$" | cut -d'=' -f1)
    for zone in $ZONES; do
      CURR_ZONE_NAME=$(uci get $zone.name)
      if [ "$CURR_ZONE_NAME" = "$ZONE_NAME" ]; then
        if ! uci get $zone.network | grep -q "$INTERFACE_NAME"; then
          uci add_list $zone.network="$INTERFACE_NAME"
          uci commit firewall
        fi
      fi
    done

    local nameRule="option name 'Block_UDP_443'"
    local str=$(grep -i "$nameRule" /etc/config/firewall)
    if [ -z "$str" ] 
    then
      echo "Add block QUIC..."
      uci add firewall rule
      uci set firewall.@rule[-1].name='Block_UDP_80'
      uci add_list firewall.@rule[-1].proto='udp'
      uci set firewall.@rule[-1].src='lan'
      uci set firewall.@rule[-1].dest='wan'
      uci set firewall.@rule[-1].dest_port='80'
      uci set firewall.@rule[-1].target='REJECT'

      uci add firewall rule
      uci set firewall.@rule[-1].name='Block_UDP_443'
      uci add_list firewall.@rule[-1].proto='udp'
      uci set firewall.@rule[-1].src='lan'
      uci set firewall.@rule[-1].dest='wan'
      uci set firewall.@rule[-1].dest_port='443'
      uci set firewall.@rule[-1].target='REJECT'
      uci commit firewall
    fi

    echo "Restart service dnsmasq, odhcpd..."
    /etc/init.d/dnsmasq restart
    /etc/init.d/odhcpd restart

    echo "Restart firewall..."
    /etc/init.d/firewall restart

    # Установка и настройка Stubby
    echo "Installing and configuring Stubby..."
    opkg update && opkg install stubby
    uci set dhcp.@dnsmasq[0].noresolv="1"
    uci set dhcp.@dnsmasq[0].filter_aaaa="1"
    uci -q delete dhcp.@dnsmasq[0].server
    uci add_list dhcp.@dnsmasq[0].server="127.0.0.1#5453"
    uci commit dhcp
    /etc/init.d/dnsmasq restart
    echo -e "ntpd -q -p ptbtime1.ptb.de\nsleep 5\n/etc/init.d/stubby restart\nexit 0" > /etc/rc.local && chmod +x /etc/rc.local && /etc/init.d/stubby restart

    # Перезапуск всей сети
    echo "Restarting network services..."
    /etc/init.d/network restart

    echo "Restarting LuCI web server..."
    /etc/init.d/uhttpd restart
    /etc/init.d/dnsmasq restart
    /etc/init.d/odhcpd restart
    /etc/init.d/dnsmasq restart
    /etc/init.d/odhcpd restart
    /etc/init.d/podkop restart
}

# Основная логика скрипта
CONFIG_URL_FILE="/etc/config/warp_config_url"
CURRENT_CONFIG_FILE="/etc/config/amneziawg_current_config"

if [ "$1" = "--check-update" ]; then
    # Режим проверки обновления
    if [ ! -f "$CONFIG_URL_FILE" ]; then
        echo "URL файла конфигурации WARP не найден. Пропустите обновление."
        exit 0
    fi

    CONFIG_URL=$(cat "$CONFIG_URL_FILE")

    echo "Проверка новой конфигурации WARP с $CONFIG_URL..."
    NEW_WARP_CONFIG=$(curl -fsSL "$CONFIG_URL" || echo "Error")

    if [ "$NEW_WARP_CONFIG" = "Error" ] || [ -z "$NEW_WARP_CONFIG" ]; then
        echo "Не удалось загрузить новую конфигурацию WARP с $CONFIG_URL. Проверьте URL."
        exit 1
    fi

    # Сохраняем новую конфигурацию во временный файл и нормализуем ее
    echo "$NEW_WARP_CONFIG" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' > /tmp/new_warp_config_normalized.tmp

    if [ -f "$CURRENT_CONFIG_FILE" ]; then
        # Нормализуем старую конфигурацию и сохраняем во временный файл
        cat "$CURRENT_CONFIG_FILE" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' > /tmp/old_warp_config_normalized.tmp
    else
        # Если старого файла нет, создаем пустой временный файл для сравнения
        echo "" > /tmp/old_warp_config_normalized.tmp
    fi

    # Сравниваем нормализованные файлы с помощью cmp
    if cmp -s /tmp/new_warp_config_normalized.tmp /tmp/old_warp_config_normalized.tmp; then
        echo "Конфигурация WARP не изменилась. Ничего не делаем."
    else
        echo "Обнаружены новые данные конфигурации WARP. Применяем изменения..."
        # Перемещаем новую, нормализованную конфигурацию в постоянный файл
        mv /tmp/new_warp_config_normalized.tmp "$CURRENT_CONFIG_FILE"
        apply_warp_config "$(cat "$CURRENT_CONFIG_FILE")" # Передаем содержимое из файла
        echo "Конфигурация WARP обновлена."
    fi

    # Удаляем временные файлы
    rm -f /tmp/new_warp_config_normalized.tmp /tmp/old_warp_config_normalized.tmp
    printf "\033[32;1mUpdate check completed...\033[0m\n"
    exit 0
fi

# Режим первоначальной настройки
echo "Установка Podkop v0.2.5..."
(echo "3"; echo "n"; echo "y") | sh <(wget -O - https://raw.githubusercontent.com/itdoginfo/podkop/a6a171ef47d0ea91d046a9d613570b2a7c952b0d/install.sh | sed 's|https://api.github.com/repos/itdoginfo/podkop/releases/latest|https://api.github.com/repos/itdoginfo/podkop/releases/tags/v0.2.5|g')

# Получение готового конфигурационного файла
echo "Пожалуйста, введите URL для файла конфигурации WARP (например, прямая ссылка с Google Диска или другого веб-сервера):"
read -r config_url_interactive </dev/tty

if [ -n "$config_url_interactive" ]; then
    config_url="$config_url_interactive"
    echo "Используется URL, введенный вручную: $config_url"
elif [ -n "$1" ]; then # Fallback to argument if interactive input is empty
    config_url="$1"
    echo "Используется URL из аргумента командной строки (так как ручной ввод был пуст): $config_url"
else
    echo "Ошибка: URL не был введен. Пожалуйста, запустите скрипт снова, предоставив URL в качестве первого аргумента (например, sh 4cPAWG.py \"ВАШ_URL\") или введите его вручную."
    exit 1
fi

# Сохраняем URL для использования в фоновом скрипте
echo "$config_url" > "$CONFIG_URL_FILE"

echo "Загрузка конфигурации WARP с $config_url..."
warp_config=$(curl -fsSL "$config_url" || echo "Error")

if [ "$warp_config" = "Error" ] || [ -z "$warp_config" ]; then
	echo "Не удалось загрузить конфигурацию WARP с $config_url. Пожалуйста, проверьте URL и попробуйте снова."
	exit 1
fi

# Сохраняем текущую конфигурацию для сравнения в будущем (нормализованную)
echo "$warp_config" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' > "$CURRENT_CONFIG_FILE"

# Применение конфигурации WARP
apply_warp_config "$warp_config"

# Настройка cron-задачи для обновления конфигурации WARP каждые 30 минут
echo "Настройка cron-задачи для обновления конфигурации WARP каждые 30 минут..."
# Добавляем cron-задачу, вызывающую этот же скрипт с флагом --check-update
( crontab -l | grep -v "4C_PAWG_UPDATE.sh --check-update" ; echo "*/30 * * * * /bin/sh /root/4C_PAWG_UPDATE.sh --check-update" ) | crontab -

echo "Настройка завершена."
