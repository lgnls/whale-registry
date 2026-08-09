#!/bin/sh
# entrypoint.sh

# Запускаем Docker daemon в фоновом режиме
dockerd --host=unix:///var/run/docker.sock &

# Ждем, пока Docker daemon запустится
sleep 2

# Проверяем, что Docker работает
docker info > /dev/null 2>&1
while [ $? -ne 0 ]; do
    echo "Ожидание запуска Docker daemon..."
    sleep 1
    docker info > /dev/null 2>&1
done

echo "Docker daemon запущен!"

# Выполняем команды, переданные в CMD или запускаем shell
if [ $# -eq 0 ]; then
    exec /bin/bash
else
    exec "$@"
fi
