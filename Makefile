#!/usr/bin/make -f

SHELL := /bin/bash
SCRIPTS_DIR := ./scripts
PATH_SCRIPT := ./.path.sh
LANGS := nim
.DEFAULT_GOAL := help

# init ----------------------------------------------------------------------------------------------------

.PHONY: init
init: add-tools install # Install all languages & their packages

# tools ----------------------------------------------------------------------------------------------------

.PHONY: add-tools
add-tools: add-nix add-home-manager # Add developing tools

.PHONY: remove-tools
remove-tools: remove-nix # Remove developing tools

.PHONY: add-nix
add-nix: _print-airplane # Install nix
	@if type "nix-env" >/dev/null 2>&1; then \
		echo "✅ Nix is already installed."; \
	else \
		curl -L https://nixos.org/nix/install | bash; \
		source ~/.nix-profile/etc/profile.d/nix.sh \
		echo "✅ Nix has been installed successfully!"; \
	fi

.PHONY: remove-nix
remove-nix: _print-goodbye # Uninstall nix
	home-manager uninstall
	rm -rf ~/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs,.config/nix,.config/home-manager}
	sudo rm -rf /nix
	@echo "✅ Nix has been uninstalled successfully!"

.PHONY: add-home-manager
add-home-manager: _print-airplane _prepare-home-manager # Add home-manager
# source ${PATH_SCRIPT} しないと nix-build のパスが通らない
	source ${PATH_SCRIPT}; \
	nix --extra-experimental-features "nix-command flakes" run home-manager/master -- init --switch ./.config/home-manager
	echo "✅ home-manager has been installed successfully!";


.PHONY: add-bash-it
add-bash-it: _print-airplane # Add bash-it
	rm -rf ~/.bash-it
	git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash-it
# keep your .bashrc and append bash-it templates at the end
	yes | ~/.bash-it/install.sh
	@echo "✅ bash-it has been installed successfully!"

.PHONY: remove-bash-it
remove-bash-it: _print-goodbye # Remove bash-it
	rm -rf ~/.bash-it
	@echo "✅ bash-it has been uninstalled successfully!"


.PHONY: add-wsl-hello-sudo
add-wsl-hello-sudo: _print-airplane # Add WSL-Hello-sudo
	$(SCRIPTS_DIR)/install-wsl-sudo-hello.sh

.PHONY: remove-wsl-hello-sudo
remove-wsl-hello-sudo: _print-goodbye # Remove WSL-Hello-sudo
	if [[ -f ~/Downloads/wsl-hello-sudo/uninstall.sh ]]; then \
		~/Downloads/wsl-hello-sudo/uninstall.sh; \
		rm -rf ~/Downloads/wsl-hello-sudo; \
	fi
	@echo "✅ WSL-Hello-sudo has been uninstalled successfully!"

# languages ----------------------------------------------------------------------------------------------------

.PHONY: install
install: install-asdf-langs install-langs # Install all languages (runs scripts starting with `intall-` prefix)

.PHONY: uninstall
uninstall: $(addprefix uninstall-,$(LANGS)) # Uninstall all languages (runs scripts starting with `unintall-` prefix)

.PHONY: install-asdf-langs
install-asdf-langs: # Install languages by asdf
	$(SCRIPTS_DIR)/asdf-install.sh nodejs node
	$(SCRIPTS_DIR)/asdf-install.sh yarn
	$(SCRIPTS_DIR)/asdf-install.sh pnpm
	$(SCRIPTS_DIR)/asdf-install.sh terraform
	asdf install

.PHONY: install-langs
install-langs: $(addprefix install-,$(LANGS)) # Install languages

.PHONY: $(addprefix install-,$(LANGS))
$(addprefix install-,$(LANGS)): _print-airplane # Install each language
	$(eval lang=$(subst install-,,$@))
	source ${PATH_SCRIPT}; \
	$(SCRIPTS_DIR)/$(lang)/$(@).sh;

.PHONY: $(addprefix uninstall-,$(LANGS))
$(addprefix uninstall-,$(LANGS)): _print-goodbye # Uninstall each language
	$(eval lang=$(subst uninstall-,,$@))
	$(SCRIPTS_DIR)/$(lang)/$(@).sh;

# packages ----------------------------------------------------------------------------------------------------

.PHONY: hms
hms: home-manager-switch # Run `home-manager switch`

.PHONY: home-manager-switch
home-manager-switch: _prepare-home-manager # Run `home-manager switch`
# source ${PATH_SCRIPT} しないと nix-build のパスが通らない
	source ${PATH_SCRIPT}; \
	export NIXPKGS_ALLOW_UNFREE=1; \
	~/.nix-profile/bin/home-manager switch --flake ./.config/home-manager/

.PHONY: generate-npm-packages-list
generate-npm-packages-list: # Generate Nix packages list for npm packages
	cd ./.config/home-manager/node; \
	NIX_PATH=~/.nix-defexpr/channels ~/.nix-profile/bin/nix-shell -p nodePackages.node2nix --command "node2nix -i ./packages.json -o ./packages.nix --nodejs-18"
	@if command -v nixpkgs-fmt >/dev/null 2>&1; then \
		find . -type f | grep -e "\.nix$$" | xargs nixpkgs-fmt; \
	else \
		echo "⚠️ nixpkgs-fmt is not found, so generated files have not been formatted."; \
	fi

.PHONY: packages-go
packages-go: # Install Go packages
	go install golang.org/x/tools/cmd/goimports@latest; \
	go install github.com/ktr0731/salias@latest;

# update ----------------------------------------------------------------------------------------------------

.PHONY: update-nix
update-nix: # Update Nix package manager
	nix-channel --update && nix upgrade-nix
	nix flake update ./.config/home-manager

.PHONY: update-apt
update-apt: # Update apt packages
	sudo apt update -y; \
	if [[ $$(apt list --upgradable 2>/dev/null | grep upgradable | wc -l) -gt 0 ]]; then \
		sudo apt upgrade -y; \
	fi;

# deploy & restore dotfiles ----------------------------------------------------------------------------------------------------

.PHONY: _deploy
_deploy: # Make symbolic links to dotfiles & back up original files if exists
	$(SCRIPTS_DIR)/_deploy/unix.sh

.PHONY: deploy-windows
deploy-windows: # Make symbolic links to dotfiles & back up original files if exists in Windows
	$(SCRIPTS_DIR)/_deploy/windows.sh

.PHONY: _restore
_restore: # Restore backed-up files of dotfiles
	$(SCRIPTS_DIR)/_restore/unix.sh

.PHONY: restore-windows
_restore-windows: # Restore backed-up files of dotfiles in Windows
	$(SCRIPTS_DIR)/_restore/windows.sh

# utilities ----------------------------------------------------------------------------------------------------

.PHONY: shellcheck
shellcheck: # Check schell scripts
	find . -type f \
		| grep -E -e "\.sh$$" -e "\.bash(_aliases|_profile|rc)" \
		| xargs shellcheck

.PHONY: shellcheck-fix
shellcheck-fix: # Check & fix schell scripts
	find . -type f \
		| grep -e "\.sh$$" \
		| xargs shellcheck --format diff \
		| patch -p1

.PHONY: nixpkgs-fmt
nixpkgs-fmt: # Check `.nix` files
	find ./.config/home-manager/ -type f \
		| grep -e "\.nix$$" \
		| xargs -I {} echo '"{}"' \
		| xargs nixpkgs-fmt

.PHONY: nixpkgs-fmt-check
nixpkgs-fmt-check: # Format `.nix` files
	find ./.config/home-manager/ -type f \
		| grep -e "\.nix$$" \
		| xargs -I {} echo '"{}"' \
		| xargs nixpkgs-fmt --check

.PHONY: _prepare-home-manager
_prepare-home-manager:
	$(SCRIPTS_DIR)/backup.sh ./.config/home-manager/home/files.txt
	if command -v starship >/dev/null 2>&1; then \
		test -f ~/.cache/starship/init.nu && rm -f ~/.cache/starship/init.nu; \
		mkdir -p ~/.cache/starship/; \
		starship init nu > ~/.cache/starship/init.nu; \
	fi

.PHONY: _print-airplane
_print-airplane:
	@echo
	@echo "          (*)"
	@echo "       γ‘´⌒ \`ヽ  ｷ―――ﾝ"
	@echo "      {########}"
	@echo "      (・ω・｀ )  Л"
	@echo "  ／‾‾<Γ‾‾‾‾二二ニ] ≡=-💨"
	@echo "  ‾‾‾‾‾‾＼_ ＼"
	@echo

.PHONY: _print-goodbye
_print-goodbye:
	@echo
	@echo "            (*)"
	@echo "       γ‘´⌒ \`ヽ  ｸﾞｯﾊﾞｲ"
	@echo "      {########}"
	@echo "  “ (\`(´・ω・｀)"
	@echo "     \`(ΞΞΞ：ΞΞΞ)"
	@echo

# TODO: カテゴリごとにわかりやすくする
.PHONY: help
help: # Show all commands
	@echo "📗 Displays help information for make commands."
	@echo "Commands:"
# コマンド一覧 -> ":" で改行 -> ":" を含む行 (前半) の \s を ", " に置換、"#" を含む行 (後半) からコメントを抽出 -> ":" で分けた個所を再連結 -> column で整形
	@grep -E '^[a-zA-Z]\S+(\s\S+)*:.*' ./Makefile \
		| sed -E -e "s/:/:\n/" \
		| sed -E -e "/:/ s/\s/, /g" -e "s/^.*[#|;]+\s*//" \
		| sed -E -e "N" -e "s/:\n/:/g;" -e "s/^/  /" \
		| column -s ":" -t
