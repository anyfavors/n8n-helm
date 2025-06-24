FROM ubuntu:22.04

ARG HELM_VERSION=v3.18.3
ARG HELM_DOCS_VERSION=v1.14.2
ARG KIND_NODE_IMAGES="v1.26.15 v1.27.16 v1.28.15"

RUN apt-get update && \
    apt-get install -y curl git ca-certificates jq python3 python3-pip skopeo && \
    rm -rf /var/lib/apt/lists/*

# Install pre-commit for linting
RUN pip3 install --no-cache-dir pre-commit

# Install Helm
RUN curl -fsSL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -xz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf linux-amd64

# Install helm-docs
RUN curl -fsSL https://github.com/norwoodj/helm-docs/releases/download/${HELM_DOCS_VERSION}/helm-docs_${HELM_DOCS_VERSION#v}_Linux_x86_64.tar.gz | \
    tar -xz -C /usr/local/bin helm-docs

# Install Helm plugins
RUN helm plugin install https://github.com/helm-unittest/helm-unittest && \
    helm plugin install https://github.com/karuppiah7890/helm-schema-gen.git

# Add Bitnami repo for dependencies
RUN helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo update

# Pre-download common kind node images
RUN mkdir -p /kind-images && \
    for version in $KIND_NODE_IMAGES; do \
        skopeo copy docker://kindest/node:${version} docker-archive:/kind-images/kind-node-${version}.tar:kindest/node:${version}; \
    done

WORKDIR /charts

ENTRYPOINT ["bash"]
