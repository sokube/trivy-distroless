FROM registry.redhat.io/ubi8/ubi as source
LABEL maintainer="quentin.henneaux@sokube.ch" \
      name="Trivy" \
      version="v0.14.0" \
      build_date="04-12-2020"

ENV TRIVY_RELEASE="v0.14.0"
ENV OS="linux"
ENV ARCH="amd64"

RUN dnf install -y ca-certificates git \
    && git clone --depth 1 --branch ${TRIVY_RELEASE} https://github.com/aquasecurity/trivy.git \
    && update-ca-trust

FROM golang:1.15.6 as builder
COPY --from=source /trivy /tmp/trivy
WORKDIR /tmp/trivy/cmd/trivy
RUN CGO_ENABLED=0 GOOS=${OS} GOARCH=${ARCH} go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/trivy

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/bin/trivy /go/bin/trivy
COPY --from=builder --chown=1001:0 /tmp/trivy/ /tmp/trivy/

USER 1001
ENTRYPOINT ["/go/bin/trivy"]