#!/bin/bash

echo "Начинаю настройку окружения..."

# Обновление системы
echo "Обновляю список пакетов..."
apt-get update

# Установка системных пакетов
echo "Устанавливаю системные пакеты..."
xargs -a /tmp/packages.list apt-get install -y --no-install-recommends

# Установка Python-пакетов
if [ -f /tmp/requirements.txt ]; then
    echo "Устанавливаю Python-пакеты..."
    pip3 install --no-cache-dir -r /tmp/requirements.txt
fi

# Настройка Git (если нужны глобальные настройки)
if [ -f /root/.gitconfig ]; then
    echo "Настраиваю Git..."
    git config --global init.defaultBranch main
fi

# Создание полезных директорий
mkdir -p /workspace/{data,scripts,output,temp}

echo "Настройка завершена!"