SCRIPTS_DIR := ./scripts
MAKEFILE := ./Makefile
LANGS := node go python rust
.DEFAULT_GOAL := help

.PHONY: all deploy install node go python rust

install: $(addprefix install-,$(LANGS)); # Install all languages.

# $(addprefix install-,$(LANGS)): # Install each language and its packages.
install-node install-go install-python install-rust: # Install each language and its packages.
	$(eval lang=$(subst install-,,$@))
	@echo
	@echo "          (*)"
	@echo "       γ‘´⌒ \`ヽ  ｷ―――ﾝ"
	@echo "      {########}"
	@echo "      (・ω・｀ )  Л"
	@echo "  ／‾‾<Γ‾‾‾‾二二ニ] ≡=-💨"
	@echo "  ‾‾‾‾‾‾＼_ ＼"
	@echo
	$(SCRIPTS_DIR)/$(lang)/install_$(lang).sh

uninstall: $(addprefix uninstall-,$(LANGS)); # Uninstall all languages.

# $(addprefix uninstall-,$(LANGS)): # Uninstall each language and its packages.
uninstall-node uninstall-go uninstall-python uninstall-rust: # Uninstall each language and its packages.
	$(eval lang=$(subst uninstall-,,$@))
	@echo
	@echo "            (*)"
	@echo "       γ‘´⌒ \`ヽ  ｸﾞｯﾊﾞｲ"
	@echo "      {########}"
	@echo "  “ (\`(´・ω・｀)"
	@echo "     \`(ΞΞΞ：ΞΞΞ)"
	@echo
	$(SCRIPTS_DIR)/$(lang)/uninstall_$(lang).sh

update: update-apt update-npm update-rust; # Update all packages.

update-apt: # Update apt packages.
	sudo apt update && sudo apt upgrade

update-npm: # Update global npm packages.
	npm update -g

update-go: install-go;# Update global npm packages.

update-rust: # Update rust packages.
	cargo install-update -a

deploy: # Make symbolic links to dotfiles and back up original files if exists.
	$(SCRIPTS_DIR)/deploy.sh

clean: # Restore backed-up files of dotfiles.
	$(SCRIPTS_DIR)/restore.sh

test-path: # Print paths.
	@echo "PATH: "
	@echo $$PATH | sed -E -e "s/:/\n/g" | sed -e "s/^/  /"
	@echo "GOROOT: "
	@echo "  " $$GOROOT
	@echo "GOPATH: "
	@echo "  " $$GOPATH

help: # Show all commands.
	@echo "📗 Displays help information for make commands."
	@echo "Commands:"
	@ # コマンド一覧を表示 | ":" で改行 | ":" を含む行 (前半部) のスペースを ", " に置換し、"#" を含む行 (後半部) からコメントを抽出 | ":" で分けた個所を連結 | column で整形
	@grep -E '^[a-zA-Z]\S+(\s\S+)*:.*' ./Makefile \
		| sed --regexp-extended -e "s/:/:\n/" \
		| sed --regexp-extended -e "/:/ s/\s/, /g; s/^.*#+\s*(.+)$$/\1/" \
		| sed --regexp-extended -e "N; s/:\n/:/g; s/^/  - /" \
		| column -s ":" -t
