# Задаем базовый образ для контейнера
FROM python:3.11.9-slim

# Установка рабочего каталога внутри образа для последующих команд
WORKDIR /opt/tasklist

# Установка переменной среды для отключения проверки версии pip
# Отключение кэширования pip
# Установка переменной среды PYTHON_PATH для указания пути внутри образа
ENV PIP_DISABLE_PIP_VERSION_CHECK=on\
    PIP_ON_CACHE_DIR=off\
    PYTHON_PATH=/opt/tasklist

# Установка Poetry
RUN pip install "poetry==2.0.1"

# Создание системной группы и пользователя внутри образа
RUN groupadd --system service && useradd --system -g service api

# Копирование файлов poetry внутрь образа
COPY poetry.lock pyproject.toml ./

# Отключение создания виртуального окружения,
# установка зависимостей без dev-зависимостей,
# не устанавливать root package (project),
# отключить вывод ansi
RUN poetry config virtualenvs.create false && poetry install --only main --no-ansi --no-root

# Копирование каталога src (проекта) внутрь образа
COPY src/ ./
# Копирование скрипта entrypoint.sh внутрь образа
COPY entrypoint.sh ./entrypoint.sh

# Установка пользователя, от имени которого будет выполняться приложение в контейнере
USER api

# Установка точки входа для контейнера. Скрипт будет выполнен при запуске контейнера
ENTRYPOINT ["bash", "entrypoint.sh"]

# Задает команду по умолчанию для контейнера
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
# Открывает порт 8000 в контейнере
EXPOSE 8000