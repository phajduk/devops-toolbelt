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
        zsh \
        python3 \
        py3-pip \
        mongodb-tools \
        kubectl \
        openssl \
        unzip \
    && ln -sf python3 /usr/bin/python \
    && pip3 install --break-system-packages --no-cache awscli \
    && npm install -g mongosh \
    && ZSH="/root/.oh-my-zsh" \
       RUNZSH=no \
       CHSH=no \
       sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && sed -i 's/^ZSH_THEME=.*$/ZSH_THEME="bira"/' /root/.zshrc \
    && sed -i 's/^plugins=(git)$/plugins=(git aws)/' /root/.zshrc \
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

ENV SHELL=/bin/zsh

CMD ["/bin/zsh"]
