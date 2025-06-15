#!/bin/sh

# Скрипт для удаления всего, что устанавливает install_podkop_awg.sh

# Удаление cron-задачи
printf "\033[32;1mRemoving cron job...\033[0m\n"
crontab -l | grep -v "update_awg_key.sh" | crontab -

# Удаление Stubby
printf "\033[32;1mRemoving Stubby...\033[0m\n"
opkg remove stubby
uci delete dhcp.@dnsmasq[0].noresolv
uci delete dhcp.@dnsmasq[0].filter_aaaa
uci delete dhcp.@dnsmasq[0].server
uci commit dhcp
service dnsmasq restart

# Удаление AmneziaWG
printf "\033[32;1mRemoving AmneziaWG...\033[0m\n"
opkg remove luci-app-amneziawg amneziawg-tools kmod-amneziawg

# Удаление интерфейса awg10 и связанных правил файрвола
INTERFACE_NAME="awg10"
ZONE_NAME="awg"

printf "\033[32;1mRemoving network interface and firewall rules...\033[0m\n"
uci delete network.${INTERFACE_NAME}
uci delete firewall.@zone[name=$ZONE_NAME]
uci delete firewall.@forwarding[dest=$ZONE_NAME]
uci commit network
uci commit firewall

# Удаление Podkop
printf "\033[32;1mRemoving Podkop...\033[0m\n"
opkg remove luci-app-podkop podkop

printf "\033[32;1mCleaning up...\033[0m\n"
rm -f /root/update_awg_key.sh

printf "\033[32;1mUninstallation completed...\033[0m\n"

exit 0
