#!/bin/sh

# Путь к директории zapret
ZAPRET_BASE="/opt/zapret"
ZAPRET_INITD="/etc/init.d/zapret"
ZAPRET_CONFIG="$ZAPRET_BASE/config"

# URL репозитория GitHub
GITHUB_REPO="remittor/zapret-openwrt"

# Функция для определения архитектуры
get_architecture() {
    local arch=$(opkg print-architecture | awk '{print $2}' | head -n 1)
    if [ -z "$arch" ]; then
        arch=$(uname -m)
    fi
    echo "$arch"
}

# Получить текущую установленную версию zapret
get_current_version() {
    local current_version=""
    if [ -f "$ZAPRET_CONFIG" ]; then
        current_version=$(grep "PKG_VERSION" "$ZAPRET_CONFIG" | cut -d'=' -f2 | tr -d '"')
    fi
    echo "$current_version"
}

# Основная логика обновления
main() {
    local current_arch=$(get_architecture)
    echo "Текущая архитектура роутера: $current_arch"

    local current_version=$(get_current_version)
    echo "Текущая установленная версия Zapret: $current_version"

    # Получить информацию о последнем релизе с GitHub
    echo "Получение информации о последнем релизе с GitHub..."
    local latest_release_info=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest")
    
    local latest_version=$(echo "$latest_release_info" | grep -oP '"tag_name": "\K[^"]+')
    echo "Последняя доступная версия на GitHub: $latest_version"

    if [ -z "$latest_version" ]; then
        echo "Не удалось получить информацию о последней версии с GitHub. Возможно, проблема с сетью или API."
        exit 1
    fi

    # Сравнение версий
    if [ "$latest_version" = "$current_version" ]; then
        echo "Установлена последняя версия Zapret. Обновление не требуется."
        exit 0
    fi

    echo "Доступна новая версия: $latest_version. Начинаю обновление..."

    # Поиск URL для загрузки пакета для текущей архитектуры
    local download_url=$(echo "$latest_release_info" | grep -oP "\"browser_download_url\": \"https://[^\"\\n]*zapret_${latest_version}_${current_arch}\.zip\"" | head -n 1 | cut -d'"' -f4)

    if [ -z "$download_url" ]; then
        echo "Не удалось найти пакет для архитектуры '$current_arch' в последнем релизе."
        echo "Попытка найти пакет .ipk"
        download_url=$(echo "$latest_release_info" | grep -oP "\"browser_download_url\": \"https://[^\"\\n]*zapret_${latest_version}_${current_arch}\.ipk\"" | head -n 1 | cut -d'"' -f4)
    fi

    if [ -z "$download_url" ]; then
        echo "Не удалось найти подходящий пакет (.zip или .ipk) для архитектуры '$current_arch'."
        exit 1
    fi

    echo "URL для загрузки: $download_url"

    local temp_dir="/tmp/zapret_update"
    mkdir -p "$temp_dir"
    
    local package_name=$(basename "$download_url")
    local package_path="$temp_dir/$package_name"

    echo "Загрузка пакета: $package_name..."
    curl -L -o "$package_path" "$download_url"

    if [ ! -f "$package_path" ]; then
        echo "Ошибка: Не удалось загрузить пакет."
        rm -rf "$temp_dir"
        exit 1
    fi

    echo "Остановка сервиса Zapret..."
    "$ZAPRET_INITD" stop

    echo "Распаковка пакета..."
    if echo "$package_name" | grep -q "\.zip$"; then
        unzip -o "$package_path" -d "$temp_dir"
    elif echo "$package_name" | grep -q "\.ipk$"; then
        # Для .ipk пакетов, нужно извлечь данные
        # ipkg-unbuild - это не всегда доступно, попробуем tar
        # Сначала извлекаем data.tar.gz из ipk
        ar x "$package_path" -o "$temp_dir"
        if [ -f "$temp_dir/data.tar.gz" ]; then
            tar -xzf "$temp_dir/data.tar.gz" -C "$temp_dir"
        else
            echo "Ошибка: Не удалось извлечь data.tar.gz из .ipk пакета."
            rm -rf "$temp_dir"
            exit 1
        fi
    else
        echo "Ошибка: Неподдерживаемый формат пакета: $package_name"
        rm -rf "$temp_dir"
        exit 1
    fi

    echo "Установка новой версии..."
    # Копирование файлов из распакованного архива
    # Предполагаем, что распакованные файлы находятся в поддиректории, например, /tmp/zapret_update/opt/zapret
    # или /tmp/zapret_update/usr/lib/opkg/info/zapret.control
    # Для OpenWrt пакетов, обычно файлы находятся в ./opt/zapret или ./usr/bin и т.д.
    # Нужно определить, куда распаковались файлы.
    # Простой способ - скопировать все из temp_dir/opt/zapret в /opt/zapret
    # Или из temp_dir/usr/share/luci/app/zapret в /usr/share/luci/app/zapret
    # Это может быть сложным, так как структура пакета может отличаться.
    # Лучше использовать opkg install, если это ipk.

    if echo "$package_name" | grep -q "\.ipk$"; then
        echo "Установка .ipk пакета с помощью opkg..."
        opkg install "$package_path"
        if [ "$?" -ne "0" ]; then
            echo "Ошибка: Не удалось установить .ipk пакет с помощью opkg."
            rm -rf "$temp_dir"
            exit 1
        fi
    else # Предполагаем, что это zip-архив, содержащий структуру файлов OpenWrt
        echo "Копирование файлов из ZIP-архива..."
        # Это может быть опасно, если структура архива не соответствует.
        # Лучше всего, если zip содержит уже готовую структуру /opt/zapret, /etc/init.d и т.д.
        # Проверим, есть ли директория 'opt' или 'etc' в распакованном архиве
        if [ -d "$temp_dir/opt/zapret" ]; then
            cp -rf "$temp_dir/opt/zapret/"* "$ZAPRET_BASE/"
        else
            echo "Предупреждение: Директория 'opt/zapret' не найдена в архиве. Копирование может быть неполным."
            # Попытка скопировать все из корневой директории архива, если она содержит файлы zapret
            cp -rf "$temp_dir/"* "/" # Опасно, но может сработать для некоторых архивов
        fi
        # Также нужно обновить LuCI-приложение, если оно есть в архиве
        if [ -d "$temp_dir/usr/lib/lua/luci/controller/zapret" ]; then
            cp -rf "$temp_dir/usr/lib/lua/luci/controller/zapret/"* "/usr/lib/lua/luci/controller/zapret/"
        fi
        if [ -d "$temp_dir/usr/lib/lua/luci/view/zapret" ]; then
            cp -rf "$temp_dir/usr/lib/lua/luci/view/zapret/"* "/usr/lib/lua/luci/view/zapret/"
        fi
        if [ -d "$temp_dir/usr/share/luci-app-zapret" ]; then
            cp -rf "$temp_dir/usr/share/luci-app-zapret/"* "/usr/share/luci-app-zapret/"
        fi
    fi

    echo "Запуск сервиса Zapret..."
    "$ZAPRET_INITD" start

    echo "Очистка временных файлов..."
    rm -rf "$temp_dir"

    echo "Обновление Zapret завершено успешно до версии $latest_version."
}

main "$@"
