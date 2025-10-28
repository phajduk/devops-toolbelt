FROM docker

ARG TARGETARCH

ENV PYTHONUNBUFFERED=1

# Base tooling, languages, and MongoDB client utilities
RUN apk --update --no-cache add \
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
        openssl \
        unzip \
    && ln -sf python3 /usr/bin/python \
    && pip3 install --break-system-packages --no-cache awscli \
    && npm install -g mongosh \
    && rm -rf /var/cache/apk/*

# Install kubectl matching the target architecture
RUN ARCH="${TARGETARCH:-$(uname -m)}" \
    && case "$ARCH" in \
         amd64|x86_64) KUBECTL_ARCH=amd64 ;; \
         arm64|aarch64) KUBECTL_ARCH=arm64 ;; \
         *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
       esac \
    && curl -fsSL "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/${KUBECTL_ARCH}/kubectl" -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# Install helm from Alpine packages to avoid external script flakiness
RUN apk add --no-cache helm

# Basic sanity checks
RUN docker --version \
    && aws --version \
    && kubectl version --client --output=yaml \
    && helm version --short

CMD ["/bin/bash"]
