FROM python:3.7-slim-bullseye
WORKDIR /opt/CTFd
RUN mkdir -p /opt/CTFd /var/log/CTFd /var/uploads

# hadolint ignore=DL3008
RUN echo 'deb http://mirrors.aliyun.com/debian/ bullseye main non-free contrib \
 deb http://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib \
 deb http://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib \
 deb-src http://mirrors.aliyun.com/debian/ bullseye main non-free contrib \
 deb-src http://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib \
 deb-src http://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib \
 deb http://mirrors.aliyun.com/debian-security/ bullseye/updates main non-free contrib \
 deb-src http://mirrors.aliyun.com/debian-security/ bullseye/updates main non-free contrib'> /etc/apt/sources.list && \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        default-mysql-client \
        python3-dev \
        libffi-dev \
        libssl-dev \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /opt/CTFd/

RUN pip install -r requirements.txt -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com --no-cache-dir

COPY . /opt/CTFd

# hadolint ignore=SC2086
RUN for d in CTFd/plugins/*; do \
        if [ -f "$d/requirements.txt" ]; then \
            pip install -r $d/requirements.txt -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com --no-cache-dir; \
        fi; \
    done;

RUN adduser \
    --disabled-login \
    -u 1001 \
    --gecos "" \
    --shell /bin/bash \
    ctfd
RUN chmod +x /opt/CTFd/docker-entrypoint.sh \
    && chown -R 1001:1001 /opt/CTFd /var/log/CTFd /var/uploads

USER 1001
EXPOSE 8000
ENTRYPOINT ["/opt/CTFd/docker-entrypoint.sh"]
