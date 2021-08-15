#!/usr/bin/make -f

SHELL := /bin/bash
SCRIPTS_DIR := ./scripts
PATH_FILE := ~/.path.sh
ANYENV_LANGS := node go
LANGS := deno rust elm nim
.DEFAULT_GOAL := help


# ------------------------------ init ------------------------------

.PHONY: init
init: deploy update-apt packages-apt add-tools install-anyenv install-langs; # Install all languages & their packages.

# ------------------------------ tools ------------------------------

.PHONY: add-tools
add-tools: add-nix add-home-manager add-dein-vim add-bash-it add-wsl-hello-sudo; # Add developing tools.

.PHONY: remove-tools
remove-tools: remove-nix remove-dein-vim remove-bash-it remove-wsl-hello-sudo; # Remove developing tools.

.PHONY: add-nix
add-nix: _print-airplane # Install nix.
	@if type "nix-env" >/dev/null 2>&1; then \
		echo "✅ nix is already installed."; \
	else \
		curl -L https://nixos.org/nix/install | sh; \
		source /home/nokazn/.nix-profile/etc/profile.d/nix.sh \
		source $(PATH_FILE); \
		echo "✅ nix has been installed successfully!"; \
	fi

.PHONY: remove-nix
remove-nix: _print-goodbye # Uninstall nix.
	sudo rm -rf ~/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs}
	sudo rm -rf /nix
	@echo "✅ nix has been uninstalled successfully!"


.PHONY: add-home-manager
add-home-manager: _print-airplane # Add home-manager
	~/.nix-profile/bin/nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager; \
	~/.nix-profile/bin/nix-channel --update; \
	source ${PATH_FILE}; \
	~/.nix-profile/bin/nix-shell '<home-manager>' -A install

.PHONY: add-dein-vim
add-dein-vim: _print-airplane # Add dein.vim.
	curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh | sh -s ~/.vim/dein
	@echo "✅ dein.vim has been installed successfully!"

.PHONY: remove-dein-vim
remove-dein-vim: _print-goodbye # Remove dein.vim.
	sudo rm -rf ~/.vim/dein
	@echo "✅ dein.vim has been uninstalled successfully!"


.PHONY: add-bash-it
add-bash-it: _print-airplane # Add bash-it.
	rm -rf ~/.bash-it
	git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash-it
	~/.bash-it/install.sh
	@echo "✅ bash-it has been installed successfully!"

.PHONY: remove-bash-it
remove-bash-it: _print-goodbye # Remove bash-it.
	sudo rm -rf ~/.bash-it


.PHONY: add-wsl-hello-sudo
add-wsl-hello-sudo: # Add WSL-Hello-sudo
	mkdir -p ~/downloads
	cd ~/downloads; \
	if [[ ! -f ~/downloads/wsl-hello-sudo/install.sh ]]; then \
		if [[ ! -e ~/downloads/wsl-hello-sudo.tar.gz ]]; then \
			wget http://github.com/nullpo-head/WSL-Hello-sudo/releases/latest/download/release.tar.gz -O wsl-hello-sudo.tar.gz; \
		fi; \
		mkdir -p ~/downloads/wsl-hello-sudo; \
		tar -xvf ~/downloads/wsl-hello-sudo.tar.gz -C ~/downloads/wsl-hello-sudo --strip-components 1; \
	fi
	cd ~/downloads/wsl-hello-sudo; \
	./install.sh
	@echo "✅ WSL-Hello-sudo has been installed successfully!"
	@echo "👉 You need to add 'auth sufficient pam_wsl_hello.so' to the top line of your '/etc/pam.d/sudo'. See also https://github.com/nullpo-head/WSL-Hello-sudo/#configuration."

.PHONY: remove-wsl-hello-sudo
remove-wsl-hello-sudo: # Remove WSL-Hello-sudo
	if [[ -f ~/downloads/wsl-hello-sudo/uninstall.sh ]]; then \
		~/downloads/wsl-hello-sudo/uninstall.sh; \
		sudo rm -rf ~/downloads/wsl-hello-sudo; \
	fi
	@echo "✅ WSL-Hello-sudo has been uninstalled successfully!"

# ------------------------------ languages ------------------------------

.PHONY: install
install: install-anyenv $(addprefix install-,$(ANYENV_LANGS)) $(addprefix install-,$(LANGS)); # Install all languages & tools. (runs scripts starting with 'intall-' prefix.)

.PHONY: uninstall
uninstall: uninstall-anyenv $(addprefix uninstall-,$(LANGS)); # Uninstall all languages & tools. (runs scripts starting with 'unintall-' prefix.)

.PHONY: install-anyenv
install-anyenv: # Install anyenv
	$(SCRIPTS_DIR)/anyenv/install_anyenv.sh; \
	~/.anyenv/bin/anyenv install nodenv; \
	~/.anyenv/bin/anyenv install goenv

.PHONY: uninstall-anyenv
uninstall-anyenv: # Install anyenv
	$(SCRIPTS_DIR)/anyenv/uninstall_anyenv.sh

.PHONY: install-anyenv-langs
install-anyenv-langs: $(addprefix install-,$(ANYENV_LANGS)); # Install languages by anyenv.

.PHONY: install-node install-go install-python
install-node install-go install-python: _print-airplane # Install each language.
	$(eval lang=$(subst install-,,$@))
	$(SCRIPTS_DIR)/$(lang)/install_$(lang).sh;

.PHONY: install-langs
install-langs: $(addprefix install-,$(LANGS)); # Install languages except ones installed by anyenv.

.PHONY: install-deno install-rust install-elm install-nim
install-deno install-rust install-elm install-nim: _print-airplane # Install each language.
	$(eval lang=$(subst install-,,$@))
	$(SCRIPTS_DIR)/$(lang)/install_$(lang).sh;

.PHONY: uninstall-deno uninstall-rust uninstall-elm uninstall-nim
uninstall-deno uninstall-rust uninstall-elm uninstall-nim: _print-goodbye # Uninstall each language.
	$(eval lang=$(subst uninstall-,,$@))
	$(SCRIPTS_DIR)/$(lang)/uninstall_$(lang).sh;

# ------------------------------ packages ------------------------------

.PHONY: packages
packages: generate-npm-packages-list packages-go; # Get all packages except the ones from apt.

.PHONY: packagegs-apt
packages-apt: # Install apt packages.
	sudo apt update -y && sudo apt upgrade -y
	sudo apt install -y \
		xsel \
		zsh \
		tshark
# TODO: リポジトリ追加
# mysql-server
# postgresql-12

.PHONY: packages-apt-for-pyenv
packages-apt-for-pyenv: # Install apt packages for building pyenv.
	sudo apt update -y ; \
	sudo apt install -y \
		make \
		gcc \
		build-essential \
		libssl-dev \
		zlib1g-dev \
		libbz2-dev \
		libreadline-dev \
		libsqlite3-dev \
		wget \
		curl \
		llvm \
		libncurses5-dev \
		xz-utils \
		tk-dev \
		libxml2-dev \
		libxmlsec1-dev \
		libffi-dev \
		liblzma-dev

.PHONY: generate-npm-packages-list
generate-npm-packages-list: # Install npm packages.
	cd ./.config/nixpkgs/node; \
	nix-shell -p nodePackages.node2nix --command "node2nix -i ./packages.json -o ./packages.nix"

.PHONY: packages-go
packages-go: # Install Go packages.
	go get -u -v golang.org/x/tools/cmd/goimports;
	goenv rehash

.PHONY: home-manager-switch
home-manager-switch: generate-npm-packages-list # Run 'home-manager switch'
	home-manager switch

# ------------------------------ update ------------------------------

.PHONY: update
update: update-apt update-go; # Update all packages.

.PHONY: update-apt
update-apt: # Update apt packages.
	sudo apt update -y; \
	if [[ $$(apt list --upgradable 2>/dev/null | grep upgradable | wc -l) -gt 0 ]]; then \
		sudo apt upgrade -y; \
	fi;

.PHONY: update-go
update-go: install-go; # Update Go packages.

# ------------------------------ deploy & restore dotfiles ------------------------------

.PHONY: deploy
deploy: # Make symbolic links to dotfiles & back up original files if exists.
	$(SCRIPTS_DIR)/deploy.sh

# TODO: 別のスクリプトに分ける
.PHONY: deploy-gitconfig
deploy-gitconfig: # Copy .gitconfig file.
	cp ./.gitconfig ~/.gitconfig

.PHONY: restore
restore: # Restore backed-up files of dotfiles.
	$(SCRIPTS_DIR)/restore.sh

# ------------------------------ utilities ------------------------------

.PHONY: shellcheck
shellcheck: # Check schell scripts.
	find ./scripts/ -type f | grep -e "\.sh$$" | xargs shellcheck

.PHONY: shellcheck-fix
shellcheck-fix: # Check & fix schell scripts.
	find ./scripts/ -type f | grep -e "\.sh$$" | xargs shellcheck --format diff | patch -p1

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
		| sed --regexp-extended -e "s/:/:\n/" \
		| sed --regexp-extended -e "/:/ s/\s/, /g" -e "s/^.*[#|;]+\s*//" \
		| sed --regexp-extended -e "N" -e "s/:\n/:/g;" -e "s/^/  /" \
		| column -s ":" -t
