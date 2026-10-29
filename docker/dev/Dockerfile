# Digest-pinned (resolved from :latest on 2026-10-25); tag kept for readability.
FROM cameronx/aws-deployer:latest@sha256:fdebad0c0ae22c670429350301d4f5ee03cc273bbc15de60dd7422151eabf253

RUN set -eux \
    && apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      jq \
      less \
      make \
      shellcheck \
      tree \
      unzip \
      vim \
      zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG GO_VERSION=1.27.3
ARG GO_SHA256=65efbc80fdc1fa2cd2631cad5b481777a68e8725f34e89f50fc6ac714e379b40
ARG GOPLS_VERSION=v0.24.0
ARG GOIMPORTS_VERSION=v0.52.0
ARG GOVULNCHECK_VERSION=v1.9.0
ARG DLV_VERSION=v1.27.2
ARG GOLANGCI_LINT_VERSION=v2.15.0
ARG GORELEASER_VERSION=v2.19.0
ARG ACTIONLINT_VERSION=v1.7.12
ARG OPENCODE_VERSION=1.19.4

ENV PATH="/root/go/bin:/usr/local/go/bin:$PATH"

WORKDIR /tmp

# Go toolchain + pinned Go dev tools (each installed standalone: go install
# requires one module per invocation, and gopls must not share a module
# graph with other x/tools binaries)
RUN set -eux \
    && curl -fsSL -o "go${GO_VERSION}.linux-amd64.tar.gz" "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
    && echo "${GO_SHA256}  go${GO_VERSION}.linux-amd64.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" \
    && rm -f "go${GO_VERSION}.linux-amd64.tar.gz" \
    && go version \
    # Install goimports
    && GOBIN=/usr/local/bin go install "golang.org/x/tools/cmd/goimports@${GOIMPORTS_VERSION}" \
    # Install govulncheck
    && GOBIN=/usr/local/bin go install "golang.org/x/vuln/cmd/govulncheck@${GOVULNCHECK_VERSION}" \
    # Install Delve
    && GOBIN=/usr/local/bin go install "github.com/go-delve/delve/cmd/dlv@${DLV_VERSION}" \
    # Install gopls (standalone: needs its own x/tools version)
    && GOBIN=/usr/local/bin go install "golang.org/x/tools/gopls@${GOPLS_VERSION}" \
    # Install golangci-lint (direct release asset, checksum-verified — the
    # upstream install.sh checksum verification is flaky)
    && curl -fsSLO "https://github.com/golangci/golangci-lint/releases/download/${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION#v}-linux-amd64.tar.gz" \
    && curl -fsSL "https://github.com/golangci/golangci-lint/releases/download/${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION#v}-checksums.txt" | grep 'linux-amd64.tar.gz$' | sha256sum -c - \
    && tar -C /usr/local/bin --strip-components=1 -xzf "golangci-lint-${GOLANGCI_LINT_VERSION#v}-linux-amd64.tar.gz" "golangci-lint-${GOLANGCI_LINT_VERSION#v}-linux-amd64/golangci-lint" \
    # Install GoReleaser
    && curl -fsSLO "https://github.com/goreleaser/goreleaser/releases/download/${GORELEASER_VERSION}/goreleaser_Linux_x86_64.tar.gz" \
    && curl -fsSL "https://github.com/goreleaser/goreleaser/releases/download/${GORELEASER_VERSION}/checksums.txt" | grep 'goreleaser_Linux_x86_64.tar.gz$' | sha256sum -c - \
    && tar -C /usr/local/bin -xzf goreleaser_Linux_x86_64.tar.gz goreleaser \
    # Install actionlint (GitHub Actions workflow linter; also shellchecks
    # embedded run: blocks)
    && curl -fsSLO "https://github.com/rhysd/actionlint/releases/download/${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION#v}_linux_amd64.tar.gz" \
    && curl -fsSL "https://github.com/rhysd/actionlint/releases/download/${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION#v}_checksums.txt" | grep 'linux_amd64.tar.gz$' | sha256sum -c - \
    && tar -C /usr/local/bin -xzf "actionlint_${ACTIONLINT_VERSION#v}_linux_amd64.tar.gz" actionlint \
    && gopls version \
    && golangci-lint version \
    && goreleaser --version \
    && actionlint -version \
    && govulncheck -version \
    && rm -rf /tmp/*

# OpenCode (agent CLI), version-pinned via the installer's --version flag.
# Upstream publishes no release checksums (only electron-updater metadata),
# so pinning is by version only.
ENV PATH="/root/.opencode/bin:$PATH"

RUN set -eux \
    && curl -fsSL https://opencode.ai/install | bash -s -- --version "${OPENCODE_VERSION}" --no-modify-path \
    && opencode --version \
    && rm -rf /tmp/*
