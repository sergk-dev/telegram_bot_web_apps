#!/bin/bash

# Проверка наличия аргумента с паролем
if [ -z "$1" ]; then
  echo "Пожалуйста, укажите пароль для пользователя skdev."
  exit 1
fi

# Создание пользователя skdev с правами sudo
useradd -m -G sudo -s /bin/bash skdev

# Установка указанного пароля для пользователя skdev
echo "skdev:$1" | chpasswd

# Разрешение авторизации ssh по публичному ключу
mkdir -p /home/skdev/.ssh
cp /root/.ssh/authorized_keys /home/skdev/.ssh/
chown -R skdev:skdev /home/skdev/.ssh
chmod 700 /home/skdev/.ssh
chmod 600 /home/skdev/.ssh/authorized_keys

# Отключение авторизации ssh по паролю
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PubkeyAuthentication yes$/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Запрет входа под root пользователем
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Перезапуск службы SSH
service ssh restart

# Установка обновлений безопасности
apt update
apt upgrade -y

# Установка Docker и Docker Compose
apt install -y docker
apt install -y docker-compose

# Настройка и запуск файрвола
ufw enable
ufw allow OpenSSH
ufw allow https

echo "Скрипт успешно выполнен."
