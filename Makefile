PROJECT ?= radxa-system-config
PREFIX ?= /usr
ETCDIR ?= /etc
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib
SHAREDIR ?= $(PREFIX)/share
MANDIR ?= $(SHAREDIR)/man

.PHONY: all
all: build

#
# Test
#
.PHONY: test
test:

#
# Build
#
.PHONY: build
build: build-man build-doc build-kernel-cmdline

SRC-MAN		:=	man
SRCS-MAN	:=	$(wildcard $(SRC-MAN)/*.md)
MANS		:=	$(SRCS-MAN:.md=)
.PHONY: build-man
build-man: $(MANS)

$(SRC-MAN)/%: $(SRC-MAN)/%.md
	pandoc "$<" -o "$@" --from markdown --to man -s

SRC-DOC		:=	.
DOCS		:=	$(SRC-DOC)/SOURCE
build-doc: $(DOCS)

$(SRC-DOC):
	mkdir -p $(SRC-DOC)

.PHONY: $(SRC-DOC)/SOURCE
$(SRC-DOC)/SOURCE: $(SRC-DOC)
	echo -e "git clone $(shell git remote get-url origin)\ngit checkout $(shell git rev-parse HEAD)" > "$@"

SRC-KCMD	:=	radxa-system-config-kernel-cmdline/etc/kernel
KCMD		:=	$(SRC-KCMD)/cmdline.ttyFIQ0 $(SRC-KCMD)/cmdline.ttyFIQ0.115200 \
				$(SRC-KCMD)/cmdline.ttyAML0 $(SRC-KCMD)/cmdline.ttyS2 \
				$(SRC-KCMD)/cmdline.ttyS0 $(SRC-KCMD)/cmdline.ttyAMA2 \
				$(SRC-KCMD)/cmdline.ttyAS0
.PHONY: build-kernel-cmdline
build-kernel-cmdline: $(KCMD)

$(SRC-KCMD)/cmdline.ttyFIQ0: $(SRC-KCMD)/cmdline
	echo "console=ttyFIQ0,1500000n8 $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

$(SRC-KCMD)/cmdline.ttyFIQ0.115200: $(SRC-KCMD)/cmdline
	echo "console=ttyFIQ0,115200n8 $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

$(SRC-KCMD)/cmdline.ttyAML0: $(SRC-KCMD)/cmdline
	echo "console=ttyAML0,115200n8 $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

$(SRC-KCMD)/cmdline.ttyS2: $(SRC-KCMD)/cmdline
	echo "console=ttyS2,1500000n8 $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

$(SRC-KCMD)/cmdline.ttyS0: $(SRC-KCMD)/cmdline
	echo "console=ttyS0,1500000n8 $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

$(SRC-KCMD)/cmdline.ttyAMA2: $(SRC-KCMD)/cmdline
	echo "console=ttyAMA2,115200n8 efi=noruntime acpi=force $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

$(SRC-KCMD)/cmdline.ttyAS0: $(SRC-KCMD)/cmdline
	echo "console=ttyAS0,115200n8 $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

#
# Clean
#
.PHONY: distclean
distclean: clean

.PHONY: clean
clean: clean-man clean-doc clean-kernel-cmdline clean-deb

.PHONY: clean-man
clean-man:
	rm -rf $(MANS)

.PHONY: clean-doc
clean-doc:
	rm -rf $(DOCS)

.PHONY: clean-kernel-cmdline
clean-kernel-cmdline:
	rm -rf $(KCMD)

.PHONY: clean-deb
clean-deb:
	rm -rf debian/.debhelper debian/${PROJECT} debian/task-*/ debian/radxa-system-config-*/ debian/tmp debian/debhelper-build-stamp debian/files debian/*.debhelper.log debian/*.postrm.debhelper debian/*.substvars

#
# Release
#
.PHONY: dch
dch: debian/changelog
	EDITOR=true gbp dch --ignore-branch --multimaint-merge --commit --release --dch-opt=--upstream

.PHONY: deb
deb: debian
	debuild --no-lintian --lintian-hook "lintian --fail-on error,warning --suppress-tags bad-distribution-in-changes-file -- %p_%v_*.changes" --no-sign -b

.PHONY: release
release:
	gh workflow run .github/workflows/new_version.yml --ref $(shell git branch --show-current)
