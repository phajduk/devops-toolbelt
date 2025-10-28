FROM docker

ARG TARGETARCH

ENV PYTHONUNBUFFERED=1

# Base tooling, languages, and MongoDB client utilities
RUN apk --update --no-cache upgrade \
    && apk --update --no-cache add \
        bash \
        busybox-extras \
        ca-certificates \
        curl \
        git \
        g++ \
        jq \
        make \
        groff \
        nodejs \
        npm \
        python3 \
        py3-pip \
        mongodb-tools \
        kubectl \
        openssl \
        unzip \
    && ln -sf python3 /usr/bin/python \
    && pip3 install --break-system-packages --no-cache awscli \
    && npm install -g mongosh \
    && rm -rf /var/cache/apk/*

# Helm & kubectl via Alpine packages to avoid external scripts
RUN apk add --no-cache \
        helm \
    && ln -sf /usr/bin/kubectl /usr/local/bin/kubectl

# Basic sanity checks
RUN docker --version \
    && aws --version \
    && kubectl version --client --output=yaml \
    && helm version --short

CMD ["/bin/bash"]
