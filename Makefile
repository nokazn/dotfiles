SCRIPTS_DIR := ./scripts
MAKEFILE := ./Makefile
.DEFAULT_GOAL := help

.PHONY: all deploy install node go python rust

install: node go python rust; ## install all languages.

node go python rust: ## install each language and its packages.
	@echo
	@echo "        Λ„,Λ"
	@echo "      (・ω・\`)  Л"
	@echo "  ／‾‾<Γ‾‾‾‾二ニ] ≡=-💨   run a script to install $@ at '$(SCRIPTS_DIR)/$@/install_$@.sh'"
	@echo "  ‾‾‾‾‾‾＼_ ＼"
	@echo
	@$(SCRIPTS_DIR)/$@/install_$@.sh

deploy:
	$(SCRIPTS_DIR)/deploy.sh

restore:
	$(SCRIPTS_DIR)/restore.sh
