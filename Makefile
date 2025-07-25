PROJECT ?= radxa-system-config
PREFIX ?= /usr
ETCDIR ?= /etc
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib
SHAREDIR ?= $(PREFIX)/share
MANDIR ?= $(SHAREDIR)/man

.DEFAULT_GOAL := all
.PHONY: all
all: build

.PHONY: devcontainer_setup
devcontainer_setup:
	sudo dpkg --add-architecture arm64
	sudo apt-get update
	sudo apt-get build-dep . -y

#
# Test
#
.PHONY: test
test:

#
# Build
#
.PHONY: build
build: build-man build-kernel-cmdline

SRC-MAN		:=	man
SRCS-MAN	:=	$(wildcard $(SRC-MAN)/*.md)
MANS		:=	$(SRCS-MAN:.md=)
.PHONY: build-man
build-man: $(MANS)

$(SRC-MAN)/%: $(SRC-MAN)/%.md
	pandoc "$<" -o "$@" --from markdown --to man -s

SRC-KCMD	:=	radxa-system-config-kernel-cmdline/etc/kernel
KCMD		:=	$(SRC-KCMD)/cmdline.ttyFIQ0 $(SRC-KCMD)/cmdline.ttyFIQ0.115200 \
				$(SRC-KCMD)/cmdline.ttyAML0 $(SRC-KCMD)/cmdline.ttyS2 \
				$(SRC-KCMD)/cmdline.ttyS0 $(SRC-KCMD)/cmdline.ttyAMA2 \
				$(SRC-KCMD)/cmdline.ttyMSM0 \
				$(SRC-KCMD)/cmdline.ttyAS0
.PHONY: build-kernel-cmdline
build-kernel-cmdline: $(KCMD)

$(SRC-KCMD)/cmdline.ttyFIQ0: $(SRC-KCMD)/cmdline
	echo "console=ttyFIQ0,1500000n8 $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

$(SRC-KCMD)/cmdline.ttyFIQ0.115200: $(SRC-KCMD)/cmdline
	echo "console=ttyFIQ0,115200n8 $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

$(SRC-KCMD)/cmdline.ttyAML0: $(SRC-KCMD)/cmdline
	echo "console=ttyAML0,115200n8 $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

$(SRC-KCMD)/cmdline.ttyMSM0: $(SRC-KCMD)/cmdline
	echo "console=ttyMSM0,115200n8 $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

$(SRC-KCMD)/cmdline.ttyS2: $(SRC-KCMD)/cmdline
	echo "console=ttyS2,1500000n8 $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

$(SRC-KCMD)/cmdline.ttyS0: $(SRC-KCMD)/cmdline
	echo "console=ttyS0,1500000n8 $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

$(SRC-KCMD)/cmdline.ttyAMA2: $(SRC-KCMD)/cmdline
	echo "console=ttyAMA2,115200n8 efi=noruntime acpi=force $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

$(SRC-KCMD)/cmdline.ttyAS0: $(SRC-KCMD)/cmdline
	echo "console=ttyAS0,115200n8 rootwait clk_ignore_unused mac_addr=\$${mac} mac1_addr=\$${mac1} $(shell cat $(SRC-KCMD)/cmdline)" > "$@"

#
# Clean
#
.PHONY: distclean
distclean: clean

.PHONY: clean
clean: clean-man clean-kernel-cmdline clean-deb

.PHONY: clean-man
clean-man:
	rm -rf $(MANS)

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
	gbp dch --ignore-branch --multimaint-merge --release --spawn-editor=never \
	--git-log='--no-merges --perl-regexp --invert-grep --grep=^(chore:\stemplates\sgenerated)' \
	--dch-opt=--upstream --commit --commit-msg="feat: release %(version)s"

.PHONY: deb
deb: debian
	debuild --no-lintian --lintian-hook "lintian --fail-on error,warning --suppress-tags-from-file $(PWD)/debian/common-lintian-overrides -- %p_%v_*.changes" --no-sign -b

.PHONY: release
release:
	gh workflow run .github/workflows/new_version.yml --ref $(shell git branch --show-current)
