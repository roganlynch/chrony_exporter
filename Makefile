DOCKER_IMAGE_NAME ?= chrony-exporter
DOCKER_REPO       ?= superq

include Makefile.common

# Debian packaging (see packaging/ and nfpm.yaml). Not part of `all`/`build`;
# invoke explicitly with `make deb`.
NFPM_VERSION ?= 2.39.0
NFPM         := $(FIRST_GOPATH)/bin/nfpm
PKG_VERSION  := $(shell cat VERSION)

.PHONY: nfpm
nfpm: $(NFPM)

$(NFPM):
	@echo ">> installing nfpm $(NFPM_VERSION)"
	mkdir -p $(FIRST_GOPATH)/bin
	$(eval NFPM_TMP := $(shell mktemp -d))
	curl -sL https://github.com/goreleaser/nfpm/releases/download/v$(NFPM_VERSION)/nfpm_$(NFPM_VERSION)_Linux_x86_64.tar.gz | tar -xzf - -C $(NFPM_TMP) nfpm
	cp $(NFPM_TMP)/nfpm $(NFPM)
	rm -r $(NFPM_TMP)

.PHONY: deb
deb: promu nfpm
	@echo ">> building linux/amd64 binary for packaging"
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 $(PROMU) build --prefix .build/linux-amd64
	@echo ">> building chrony-exporter_$(PKG_VERSION)_amd64.deb"
	PKG_VERSION=$(PKG_VERSION) $(NFPM) package --config nfpm.yaml --packager deb --target chrony-exporter_$(PKG_VERSION)_amd64.deb
