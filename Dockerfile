# syntax=docker/dockerfile:1.4
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow

# Принимаем UID и GID для синхронизации прав
ARG UID=1000
ARG GID=1000

# Создаем пользователя sandboxer и назначаем ему права
RUN groupadd -g ${GID} sandboxer && \
    useradd -u ${UID} -g ${GID} -m -s /bin/bash sandboxer

# Оптимизация установки системных пакетов
COPY packages.list /tmp/packages.list
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    xargs -a /tmp/packages.list apt-get install -y --no-install-recommends && \
    echo "sandboxer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sandboxer && \
    chmod 0440 /etc/sudoers.d/sandboxer

# Настройка виртуального окружения python
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Оптимизация установки python библиотек
COPY requirements.txt /tmp/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -U pip && \
    pip install -r /tmp/requirements.txt

COPY scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh && \
    chown -R ${UID}:${GID} /opt/venv

USER sandboxer
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]