#!/usr/bin/make -f

SHELL := /bin/bash
SCRIPTS_DIR := ./scripts
PATH_SCRIPT := ./.path.sh
ASDF_LANGS := node terraform
LANGS := deno rust elm nim
.DEFAULT_GOAL := help


# init ----------------------------------------------------------------------------------------------------

.PHONY: init
init: add-tools home-manager-switch install # Install all languages & their packages.

# tools ----------------------------------------------------------------------------------------------------

.PHONY: add-tools
add-tools: add-nix add-home-manager add-dein-vim add-bash-it add-wsl-hello-sudo # Add developing tools.

.PHONY: remove-tools
remove-tools: remove-nix remove-dein-vim remove-bash-it remove-wsl-hello-sudo # Remove developing tools.

.PHONY: add-nix
add-nix: _print-airplane # Install nix.
	@if type "nix-env" >/dev/null 2>&1; then \
		echo "✅ nix is already installed."; \
	else \
		curl -L https://nixos.org/nix/install | bash; \
		source ~/.nix-profile/etc/profile.d/nix.sh \
		echo "✅ nix has been installed successfully!"; \
	fi

.PHONY: remove-nix
remove-nix: _print-goodbye # Uninstall nix.
	rm -rf ~/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs}
	sudo rm -rf /nix
	@echo "✅ nix has been uninstalled successfully!"

.PHONY: add-home-manager
add-home-manager: _print-airplane # Add home-manager
# source ${PATH_SCRIPT} しないと nix-build のパスが通らない
	~/.nix-profile/bin/nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager; \
	~/.nix-profile/bin/nix-channel --update; \
	source ${PATH_SCRIPT}; \
	NIX_PATH=~/.nix-defexpr/channels ~/.nix-profile/bin/nix-shell '<home-manager>' -A install
	echo "✅ home-manager has been installed successfully!"; \


.PHONY: add-dein-vim
add-dein-vim: _print-airplane # Add dein.vim.
	curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh | bash -s ~/.vim/dein
	@echo "✅ dein.vim has been installed successfully!"

.PHONY: remove-dein-vim
remove-dein-vim: _print-goodbye # Remove dein.vim.
	sudo rm -rf ~/.vim/dein
	@echo "✅ dein.vim has been uninstalled successfully!"


.PHONY: add-bash-it
add-bash-it: _print-airplane # Add bash-it.
	rm -rf ~/.bash-it
	git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash-it
# keep your .bashrc and append bash-it templates at the end
	yes | ~/.bash-it/install.sh
	@echo "✅ bash-it has been installed successfully!"

.PHONY: remove-bash-it
remove-bash-it: _print-goodbye # Remove bash-it.
	rm -rf ~/.bash-it
	@echo "✅ bash-it has been uninstalled successfully!"


.PHONY: add-wsl-hello-sudo
add-wsl-hello-sudo: _print-airplane # Add WSL-Hello-sudo
	$(SCRIPTS_DIR)/wsl-sudo-hello/install-wsl-sudo-hello.sh

.PHONY: remove-wsl-hello-sudo
remove-wsl-hello-sudo: _print-goodbye # Remove WSL-Hello-sudo
	if [[ -f ~/downloads/wsl-hello-sudo/uninstall.sh ]]; then \
		~/downloads/wsl-hello-sudo/uninstall.sh; \
		rm -rf ~/downloads/wsl-hello-sudo; \
	fi
	@echo "✅ WSL-Hello-sudo has been uninstalled successfully!"

# languages ----------------------------------------------------------------------------------------------------

.PHONY: install
install: install-asdf-langs $(addprefix install-,$(LANGS)) # Install all languages & tools. (runs scripts starting with 'intall-' prefix.)

.PHONY: uninstall
uninstall:  $(addprefix uninstall-,$(LANGS)) # Uninstall all languages & tools. (runs scripts starting with 'unintall-' prefix.)

.PHONY: install-asdf-langs
install-asdf-langs: $(addprefix install-,$(ASDF_LANGS)) # Install languages by asdf.

.PHONY: install-node
install-node: _print-airplane # Install each language.
	$(eval lang=$(subst install-,,$@))
	$(SCRIPTS_DIR)/$(lang)/install_$(lang).sh;

.PHONY: install-langs
install-langs: $(addprefix install-,$(LANGS)) # Install languages except ones installed by anyenv.

.PHONY: install-deno install-rust install-elm install-nim
install-deno install-rust install-elm install-nim: _print-airplane # Install each language.
	$(eval lang=$(subst install-,,$@))
	$(SCRIPTS_DIR)/$(lang)/install_$(lang).sh;

.PHONY: uninstall-deno uninstall-rust uninstall-elm uninstall-nim
uninstall-deno uninstall-rust uninstall-elm uninstall-nim: _print-goodbye # Uninstall each language.
	$(eval lang=$(subst uninstall-,,$@))
	$(SCRIPTS_DIR)/$(lang)/uninstall_$(lang).sh;

.PHONY: _install-anyenv
_install-anyenv: _print-airplane # Install anyenv
	$(SCRIPTS_DIR)/anyenv/install_anyenv.sh;
	~/.anyenv/bin/anyenv install nodenv;
	@echo "✅ nodenv has been installed successfully!"

.PHONY: _uninstall-anyenv
_uninstall-anyenv: _print-goodbye # Uninstall anyenv
	$(SCRIPTS_DIR)/anyenv/uninstall_anyenv.sh

# packages ----------------------------------------------------------------------------------------------------

.PHONY: hms
hms: home-manager-switch # Run 'home-manager switch'

.PHONY: home-manager-switch
home-manager-switch: # Run 'home-manager switch'
	$(SCRIPTS_DIR)/backup.sh ./.config/nixpkgs/home/files.txt
# source ${PATH_SCRIPT} しないと nix-build のパスが通らない
	source ${PATH_SCRIPT}; \
	export NIXPKGS_ALLOW_UNFREE=1; \
	~/.nix-profile/bin/home-manager switch -f ./.config/nixpkgs/home.nix

.PHONY: generate-npm-packages-list
generate-npm-packages-list: # Generate Nix packages list for npm packages.
	cd ./.config/nixpkgs/node; \
	NIX_PATH=~/.nix-defexpr/channels ~/.nix-profile/bin/nix-shell -p nodePackages.node2nix --command "node2nix -i ./packages.json -o ./packages.nix"


.PHONY: packages-go
packages-go: # Install Go packages.
	go get -u -v golang.org/x/tools/cmd/goimports;

# update ----------------------------------------------------------------------------------------------------

.PHONY: update-apt
update-apt: # Update apt packages.
	sudo apt update -y; \
	if [[ $$(apt list --upgradable 2>/dev/null | grep upgradable | wc -l) -gt 0 ]]; then \
		sudo apt upgrade -y; \
	fi;

# deploy & restore dotfiles ----------------------------------------------------------------------------------------------------

.PHONY: _deploy
_deploy: # Make symbolic links to dotfiles & back up original files if exists.
	$(SCRIPTS_DIR)/_deploy/unix.sh

.PHONY: deploy-windows
_deploy-windows: # Make symbolic links to dotfiles & back up original files if exists in Windows.
	$(SCRIPTS_DIR)/_deploy/windows.sh

.PHONY: _restore
_restore: # Restore backed-up files of dotfiles.
	$(SCRIPTS_DIR)/_restore/unix.sh

.PHONY: restore-windows
_restore-windows: # Restore backed-up files of dotfiles in Windows.
	$(SCRIPTS_DIR)/_restore/windows.sh

# utilities ----------------------------------------------------------------------------------------------------

.PHONY: shellcheck
shellcheck: # Check schell scripts.
	find ./scripts/ -type f \
		| grep -e "\.sh$$" \
		| xargs shellcheck

.PHONY: shellcheck-fix
shellcheck-fix: # Check & fix schell scripts.
	find ./scripts/ -type f \
		| grep -e "\.sh$$" \
		| xargs shellcheck --format diff | patch -p1

.PHONY: nixpkgs-fmt
nixpkgs-fmt: # Check .nix files.
	find ./.config/nixpkgs/ -type f \
		| grep -e "\.nix$$" \
		| grep -v -e "/home/packages\.nix" \
		| xargs nixpkgs-fmt

.PHONY: nixpkgs-fmt-check
nixpkgs-fmt-check: # Format .nix files.
	find ./.config/nixpkgs/ -type f \
		| grep -e "\.nix$$" \
		| grep -v -e "/home/packages\.nix" \
		| xargs nixpkgs-fmt --check

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
help: # Show all commands.
	@echo "📗 Displays help information for make commands."
	@echo "Commands:"
# コマンド一覧 -> ":" で改行 -> ":" を含む行 (前半) の \s を ", " に置換、"#" を含む行 (後半) からコメントを抽出 -> ":" で分けた個所を再連結 -> column で整形
	@grep -E '^[a-zA-Z]\S+(\s\S+)*:.*' ./Makefile \
		| sed -E -e "s/:/:\n/" \
		| sed -E -e "/:/ s/\s/, /g" -e "s/^.*[#|;]+\s*//" \
		| sed -E -e "N" -e "s/:\n/:/g;" -e "s/^/  /" \
		| column -s ":" -t
