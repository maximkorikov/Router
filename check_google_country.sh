#!/bin/bash

# Проверка наличия curl и jq
if ! command -v curl &> /dev/null; then
    echo "❌ Установите curl: sudo apt install curl"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ Установите jq: sudo apt install jq"
    exit 1
fi

echo "🌍 Получаем внешний IP, с которым Google видит ваш VPS..."
IP=$(curl -s https://ifconfig.me)

echo "🌐 Внешний IP: $IP"
echo "🔎 Получаем геолокацию IP..."

# Используем ipinfo.io (можно заменить на другой, например, ipapi.co)
GEO_DATA=$(curl -s ipinfo.io/$IP)

# Извлекаем страну и регион
COUNTRY=$(echo "$GEO_DATA" | jq -r .country)
REGION=$(echo "$GEO_DATA" | jq -r .region)
CITY=$(echo "$GEO_DATA" | jq -r .city)
ORG=$(echo "$GEO_DATA" | jq -r .org)

echo "📍 Google вероятно определяет вашу страну как: $COUNTRY"
echo "📍 Регион: $REGION"
echo "🏙️ Город: $CITY"
echo "🏢 Организация (провайдер): $ORG"
