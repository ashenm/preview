SHELL:=/bin/bash

.PHONY: help
.SILENT: help
help: ## list make targets
	awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf " \033[36m%-20s\033[0m  %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: build
.SILENT: build
.ONESHELL: build
build: ## build preview sources

	declare -a _sites
	source sites.bash

	for site in "$${_sites[@]}"
	do
	  mkdir --parent $$(basename $${site%:*})
	  curl --location --output - https://github.com/$${site%:*}/archive/$${site#*:}.zip | \
	    bsdtar --extract --file - --strip-components 1 --directory $$(basename $${site%:*}) --exclude \.github
	done

.PHONY: list
.SILENT: list
.ONESHELL: list
list: ## list all sources

	declare -a _site
	source sites.bash

	for site in "$${_sites[@]}"
	do
	  echo $$site
	done

.PHONY: clean
clean: ## clean build artifacts
	find . -mindepth 1 -maxdepth 1 \! -name '.git' \! -name '.github' \! -name 'Makefile' -exec rm -rf {} \;

.PHONY: archive
archive:
	tar --xz --create --file previews.txz --exclude Makefile --exclude sites.bash *

.PHONY: install
install:
	sudo apt-get update && sudo apt-get install --yes bsdtar
