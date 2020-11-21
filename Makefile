# VERSION
# If no version is specified as a parameter of make, the last git hash
# value is taken.
VERSION?=$(shell git describe --abbrev=0)+$(shell date +'%Y%m%d%H%I%S')

# GOPROXY settings
# If no GOPROXY environment variable available, the pre-defined GOPROXY from go
# env to download and validate go modules is used. Exclude downloading and
# validation of all private modules which are pre-defined in GOPRIVATE. If no
# GOPRIVATE variable defined, the variable of go env is used.
GOPROXY?=$(shell go env GOPROXY)
GOPRIVATE?=$(shell go env GOPRIVATE)

# CONTAINER_RUNTIME
# The CONTAINER_RUNTIME variable will be used to specified the path to a
# container runtime. This is needed to start and run a container images.
CONTAINER_RUNTIME?=$(shell which docker)
CONTAINER_IMAGE_VERSION?=latest

# EXECUTABLE
EXECUTABLE=container-logs

# BUILD
# ==============================================================================
${EXECUTABLE}: bin/tmp/${EXECUTABLE}

all: ${EXECUTABLE_TARGETS}

bin/linux/amd64/${EXECUTABLE}:
	GOOS=linux \
	GOARCH=amd64 \
	GOPROXY=${GOPROXY} \
	GOPRIVATE=${GOPRIVATE} \
		go build -ldflags "-X main.version=${VERSION:v%=%}" -o ${@} main.go

bin/tmp/${EXECUTABLE}:
	GOPROXY=${GOPROXY} \
	GOPRIVATE=${GOPRIVATE} \
		go build -ldflags "-X main.version=${VERSION:v%=%}" -o ${@} main.go

# CLEAN
# ==============================================================================
PHONY+=clean
clean:
	rm --force --recursive ${EXECUTABLE}
	rm --force --recursive bin

# PHONY
# ==============================================================================
.PHONY: ${PHONY}
