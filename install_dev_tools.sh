#!/bin/bash

# Назва скрипта: install_dev_tools.sh
# Опис: Автоматично встановлює Docker, Docker Compose, Python 3.9+ та Django.
# Працює з: Debian/Ubuntu

# Перевірка, чи запущено скрипт з правами root
if [[ $EUID -ne 0 ]]; then
   echo "Цей скрипт потрібно запускати з правами root (наприклад, за допомогою sudo)."
   exit 1
fi

echo "🚀 Починаємо встановлення інструментів для розробки..."
echo "--------------------------------------------------------"

# Функція для перевірки наявності команди
command_exists () {
  command -v "$1" >/dev/null 2>&1
}

# 1. ВСТАНОВЛЕННЯ PYTHON (3.9+)
##
install_python() {
    echo "🐍 Перевірка наявності Python (потрібна версія 3.9 або новіша)..."
    
    # Спроба знайти версію Python 3
    PYTHON_CMD=""
    if command_exists python3; then
        PYTHON_CMD="python3"
    elif command_exists python; then
        PYTHON_CMD="python"
    fi

    if [ -n "$PYTHON_CMD" ]; then
        PYTHON_VERSION=$($PYTHON_CMD -c 'import sys; print(".".join(map(str, sys.version_info[:2])))' 2>/dev/null)
        if [ $? -eq 0 ] && [ $(echo "$PYTHON_VERSION >= 3.9" | bc -l) -eq 1 ]; then
            echo "✅ Python $PYTHON_VERSION (3.9+) вже встановлено. Пропускаємо встановлення."
            return 0
        fi
    fi

    echo "❌ Python 3.9+ не знайдено або версія застаріла. Встановлюємо..."
    
    # Додавання репозиторію deadsnakes для нових версій Python (типово для Ubuntu)
    apt update
    apt install -y software-properties-common
    add-apt-repository -y ppa:deadsnakes/ppa
    apt update
    
    # Встановлення найновішої доступної версії Python 3.12 (або іншої, яку ви хочете)
    # Змінюйте 'python3.12' на потрібну версію, якщо 3.12 недоступна
    PYTHON_TO_INSTALL="python3.12"
    if ! apt install -y $PYTHON_TO_INSTALL; then
        echo "Помилка при встановленні $PYTHON_TO_INSTALL. Спробуйте іншу версію (наприклад, python3.11, python3.10 або python3.9)."
        PYTHON_TO_INSTALL="python3.9"
        if ! apt install -y $PYTHON_TO_INSTALL; then
            echo "Критична помилка: Не вдалося встановити Python 3.9+. Продовження може бути неможливим."
            exit 1
        fi
    fi
    
    # Встановлення pip для цієї версії
    apt install -y python3-pip
    
    # Встановлюємо, що команда 'python3' вказує на встановлену версію
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/$PYTHON_TO_INSTALL 1
    
    echo "✅ Python ($PYTHON_TO_INSTALL) та pip встановлено."
}

# 2. ВСТАНОВЛЕННЯ DJANGO
##
install_django() {
    echo "✨ Перевірка наявності Django..."
    if python3 -c "import django" 2>/dev/null; then
        DJANGO_VERSION=$(python3 -c "import django; print(django.get_version())" 2>/dev/null)
        echo "✅ Django $DJANGO_VERSION вже встановлено. Пропускаємо встановлення."
        return 0
    fi

    echo "❌ Django не знайдено. Встановлюємо через pip..."
    # Використовуємо python3 -m pip, щоб бути впевненими у правильному pip
    python3 -m pip install django
    echo "✅ Django встановлено."
}

# 3. ВСТАНОВЛЕННЯ DOCKER
##
install_docker() {
    echo "🐳 Перевірка наявності Docker Engine..."
    if command_exists docker; then
        echo "✅ Docker Engine вже встановлено. Пропускаємо встановлення."
        return 0
    fi

    echo "❌ Docker Engine не знайдено. Встановлюємо..."
    
    # Оновлення apt та встановлення необхідних пакетів
    apt update
    apt install -y ca-certificates curl gnupg
    
    # Додавання офіційного GPG ключа Docker
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Додавання репозиторію до apt
    echo \
      "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Оновлення пакетів та встановлення Docker Engine
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    echo "✅ Docker Engine встановлено."
    echo "ℹ️ Додавання поточного користувача ($SUDO_USER) до групи docker..."
    
    # Додавання користувача до групи docker (потрібно для запуску без sudo)
    # Зверніть увагу: зміни групи набудуть чинності після перезаходу користувача
    if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
        usermod -aG docker $SUDO_USER
        echo "⚠️ Потрібно вийти та знову увійти в систему, щоб зміни групи 'docker' набули чинності для користувача $SUDO_USER."
    fi
}

# 4. ВСТАНОВЛЕННЯ DOCKER COMPOSE (Plugin - v2)
##
install_docker_compose() {
    echo "📦 Перевірка наявності Docker Compose (v2 Plugin)..."
    # Docker Compose V2 встановлюється як плагін командою 'docker compose'
    if docker compose version 2>/dev/null; then
        echo "✅ Docker Compose (v2 Plugin) вже встановлено."
        return 0
    fi
    
    # Якщо Docker був встановлений через 'apt install docker-compose-plugin' у попередньому кроці,
    # він вже має бути тут. Ця частина є резервною або для Linux систем, де Docker
    # встановлювався іншим способом.
    echo "❌ Docker Compose (v2 Plugin) не знайдено. Перевіряємо v1..."

    if command_exists docker-compose; then
        echo "⚠️ Знайдено застарілий Docker Compose (v1). Рекомендується використовувати v2 (docker compose)."
        # Можна видалити v1 і встановити v2, але для безпеки просто повідомляємо
        return 0
    fi

    # Спроба встановити як плагін apt (якщо це не було зроблено разом з docker-ce)
    if apt install -y docker-compose-plugin; then
        echo "✅ Docker Compose (v2 Plugin) встановлено через apt."
    else
        echo "Не вдалося встановити Docker Compose (v2 Plugin). Можливо, потрібне ручне встановлення."
    fi
}

# ВИКОНАННЯ ВСІХ ФУНКЦІЙ
##
install_python
echo "--------------------------------------------------------"

install_django
echo "--------------------------------------------------------"

install_docker
echo "--------------------------------------------------------"

install_docker_compose
echo "--------------------------------------------------------"

echo "🎉 Усі інструменти розробки (Docker, Docker Compose, Python 3.9+, Django) встановлено (або перевірено)!"
echo "☝️ Якщо ви бачили повідомлення про необхідність вийти/увійти, зробіть це, щоб використовувати 'docker' без 'sudo'."
