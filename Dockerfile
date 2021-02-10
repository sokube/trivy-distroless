FROM registry.redhat.io/ubi8/ubi as source

ENV TRIVY_RELEASE="v0.16.0"
ENV OS="linux"
ENV ARCH="amd64"

RUN dnf install -y ca-certificates git \
    && git clone --depth 1 --branch ${TRIVY_RELEASE} https://github.com/aquasecurity/trivy.git \
    && update-ca-trust

FROM golang:1.15.6 as builder
COPY --from=source /trivy /tmp/trivy
WORKDIR /.cache/trivy
WORKDIR /tmp/trivy/cmd/trivy
RUN CGO_ENABLED=0 GOOS=${OS} GOARCH=${ARCH} go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/trivy

FROM scratch

LABEL maintainer="quentin.henneaux@sokube.ch, fabrice.vergnenegre@sokube.ch" \
      name="Trivy" \
      version="v0.16.0" \
      build_date="10-02-2021"
      
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /go/bin/trivy /go/bin/trivy
COPY --from=builder --chown=1001:0 /tmp/trivy/contrib/*.tpl /contrib/
COPY --from=builder --chown=1001:0 /.cache/trivy /.cache/trivy

USER 1001

ENTRYPOINT ["/go/bin/trivy"]
