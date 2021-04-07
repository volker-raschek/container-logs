# VERSION
# If no version is specified as a parameter of make, the last git hash
# value is taken.
VERSION?=$(shell git describe --abbrev=0)+$(shell date +'%Y%m%d%H%I%S')

# DESTDIR,PREFIX
DESTDIR?=
PREFIX?=/usr/local

# EXECUTABLE
EXECUTABLE=container-logs
EXECUTABLE_TARGETS= \
	bin/linux/amd64/${EXECUTABLE} \
	bin/tmp/${EXECUTABLE}

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

# COMPLETIONS
# ==============================================================================
$(addsuffix .sh,${EXECUTABLE_TARGETS}): $(basename ${@})
	$(basename ${@}) completion bash > ${@}

$(addsuffix .fish,${EXECUTABLE_TARGETS}): $(basename ${@})
	$(basename ${@}) completion fish > ${@}

$(addsuffix .zsh,${EXECUTABLE_TARGETS}): $(basename ${@})
	$(basename ${@}) completion zsh > ${@}

# INSTALL
# ==============================================================================
install: clean bin/tmp/${EXECUTABLE} bin/tmp/${EXECUTABLE}.sh bin/tmp/${EXECUTABLE}.fish bin/tmp/${EXECUTABLE}.zsh
	install --directory ${DESTDIR}${PREFIX}/bin/
	install --mode 755 bin/tmp/${EXECUTABLE} ${DESTDIR}${PREFIX}/bin/${EXECUTABLE}
	install --directory ${DESTDIR}/etc/bash_completion.d/
	install --directory --mode 755 bin/tmp/${EXECUTABLE}.sh ${DESTDIR}/etc/bash_completion.d/${EXECUTABLE}.sh
	install --directory ${DESTDIR}/usr/share/fish/vendor_functions.d/
	install --directory --mode 755 bin/tmp/${EXECUTABLE}.fish ${DESTDIR}/usr/share/fish/vendor_functions.d/${EXECUTABLE}.fish

# CLEAN
# ==============================================================================
PHONY+=clean
clean:
	rm --force --recursive ${EXECUTABLE}
	rm --force --recursive bin

# PHONY
# ==============================================================================
.PHONY: ${PHONY}
