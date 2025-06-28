FROM ubuntu:24.04

ARG HELM_VERSION=v3.18.3
ARG GIT_CHGLOG_VERSION=v0.15.4
ARG CHART_RELEASER_VERSION=v1.7.0
ARG COSIGN_VERSION=v2.5.1

RUN apt-get update && \
    apt-get install -y curl git ca-certificates jq && \
    rm -rf /var/lib/apt/lists/*

# Install Helm
RUN curl -fsSL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -xz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf linux-amd64

# Install git-chglog
RUN curl -fsSL https://github.com/git-chglog/git-chglog/releases/download/${GIT_CHGLOG_VERSION}/git-chglog_${GIT_CHGLOG_VERSION#v}_linux_amd64.tar.gz | \
    tar -xz -C /usr/local/bin git-chglog

# Install chart-releaser
RUN curl -fsSL https://github.com/helm/chart-releaser/releases/download/${CHART_RELEASER_VERSION}/chart-releaser_${CHART_RELEASER_VERSION#v}_linux_amd64.tar.gz | \
    tar -xz -C /usr/local/bin cr

# Install Helm plugins
RUN helm plugin install https://github.com/chartmuseum/helm-push.git

# Install cosign
RUN curl -fsSL https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign-linux-amd64 -o /usr/local/bin/cosign && \
    chmod +x /usr/local/bin/cosign

WORKDIR /charts

ENTRYPOINT ["bash"]
