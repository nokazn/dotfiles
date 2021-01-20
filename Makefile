SHELL := /bin/bash
MAKEFILE := ./Makefile
SCRIPTS_DIR := ./scripts
PATH_FILE := ~/.path.sh
LANGS := node go python rust
.DEFAULT_GOAL := help

.PHONY: all deploy install node go python rust


# ------------------------------ init ------------------------------

init: install packaes deploy; # Install all languages and their packages.

# ------------------------------ install ------------------------------

install: install-nix $(addprefix install-,$(LANGS)); # Install all languages & tools. (runs scripts starting with 'intall-' prefix.)

install-nix: _print-airplane # Install nix.
	@if type "nix-env" > /dev/null 2>&1; then \
		echo "✅ nix is already installed."; \
	else \
		curl -L https://nixos.org/nix/install | sh; \
		source $(PATH_FILE); \
		echo "✅ nix has been installed successfully!"; \
	fi

install-node install-go install-python install-rust: _print-airplane # Install each language.
	$(eval lang=$(subst install-,,$@))
	$(SCRIPTS_DIR)/$(lang)/install_$(lang).sh;


uninstall: uninstall-nix $(addprefix uninstall-,$(LANGS)); # Uninstall all languages and tools. (runs scripts starting with 'unintall-' prefix.)

uninstall-node uninstall-go uninstall-python uninstall-rust: _print-goodbye # Uninstall each language.
	$(eval lang=$(subst uninstall-,,$@))
	$(SCRIPTS_DIR)/$(lang)/uninstall_$(lang).sh;

uninstall-nix: _print-goodbye # Uninstall nix.
	sudo rm -rf ~/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs}
	sudo rm -rf /nix
	@echo "✅ nix has been uninstalled successfully!"

# ------------------------------ packages ------------------------------

packages: packages-apt packages-npm packaes-pip; # Get all packages.

# TODO: pyenv
packages-apt: packages-apt-for-pyenv # Install apt packages.
	sudo apt install -y heroku \
    vim-gtk \
    xsel \
    postgres-12;
	# make packages-apt-for-pyenv
	sudo apt update -y && sudo apt upgrade -y

packages-apt-for-pyenv: # Install apt packages for building pyenv.
	sudo apt install --no-install-recommends -y \
		make \
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

packages-nix: # Install nix packages.
	nix-env --install vim \
		sl \
		neofetch \
		heroku

packages-npm: ;
# TODO: vue の next が stable になったら @next を外す
	npm i -g \
		@nestjs/cli \
		@octokit/core \
		@vue/cli@next \
		elm \
		elm-format \
		envinfo \
		eslint \
		elm-test \
		firebase-tools \
		http-server \
		netlify-cli \
		prettier \
		serverless \
		ts-node \
		typescript \
		vue@next \
		yarn;
	nodenv rehash

packages-go: # Install Go packages.
	go get -u -v github.com/motemen/ghq; \
	go get -u -v github.com/motemen/gore; \
	go get -u -v golang.org/x/tools/gopls; \
	go get -u -v golang.org/x/tools/cmd/goimports;
	goenv rehash

packages-pip: # Install pip packages.
	pip install --user \
		pipenv;
	pyenv rehash

# ------------------------------ update ------------------------------

update: update-apt update-npm update-go update-rust; # Update all packages.

update-apt: # Update apt packages.
	sudo apt update -y; \
	if [[ $$(apt list --upgradable 2>/dev/null | grep upgradable | wc -l) -gt 0 ]]; then \
		sudo apt upgrade -y; \
	fi;

update-npm: # Update global npm packages.
	npm update -g

update-go: install-go; # Update Go packages.

update-pip: # Update pip packages.
	pip install --upgrade pip
	pip list --user | tail -n +3 | cut -d " " -f 1 | xargs pip install --user --upgrade

# ------------------------------ deploy & restore dotfiles ------------------------------

deploy: # Make symbolic links to dotfiles and back up original files if exists.
	$(SCRIPTS_DIR)/deploy.sh

# TODO: 別のスクリプトに分ける
deploy-gitconfig: # Copy .gitconfig.
	cp ./.gitconfig ~/.gitconfig

restore: # Restore backed-up files of dotfiles.
	$(SCRIPTS_DIR)/restore.sh


# ------------------------------ utilities ------------------------------

# TODO: カテゴリごとにわかりやすくする
# TODO: コメントない行の処理
test-path: # Print paths.
	@echo "PATH:"
	@echo $$PATH | sed -E -e "s/:/\n/g" | sed -e "s/^/  /"
	@echo "GOROOT: "
	@echo "  " $$GOROOT
	@echo "GOPATH:"
	@echo "  " $$GOPATH

apt-list: # Show a list of installed apt packages.
	sudo apt list --installed | more

HISTORY_LOG := /var/log/apt/history.log
apt-history:
# tee でプロセス置換して、+ (緑) の場合と - (赤) の場合で色を分け、標準出力を捨てる
# プロセス置換内の標準出力がなされるまでシェルを待たせるために cat に渡している
	@cat /var/log/apt/history.log \
		| grep -e "install" -e "remove" \
		| sed -E -e "s/^.*apt(-get)?(\s--?\S+)*\s(install|remove)(\s--?\S+)*\s/\3:/" \
		| sed -E -e "s/(^|\s)--?\S+//g" -e "s/install:/+ /" -e "s/remove:/- /" \
		| tee >(xargs -I "{}" bash -c "[[ \"{}\" =~ ^\+ ]] && printf \"\033[32m{}\033[0m\n\"") \
			>(xargs -I "{}" bash -c "[[ \"{}\" =~ ^- ]] && printf \"\033[31m{}\033[0m\n\"") \
			> /dev/null \
		| cat

apt-history-installed:
	@echo "List of apt packages you have ever installed. (from '/var/log/apt/history.log')"
# ...apt|apt-get [options] install [options] を削除 -> 行中の options を削除 -> パッケージごとに改行
	@apt_list=$$(sudo apt list --installed); cat $(HISTORY_LOG) \
		| grep install \
		| sed -E -e "s/^.*apt(-get)?(\s--?\S+)*\sinstall(\s--?\S+)*\s//" \
		| sed -E -e "s/(^|\s)--?\S+//g" -e "s/(\S)\s+(\S)/\1\n\2/g" \
		| sort \
		| uniq \
		| xargs -I {} sh -c "echo \"$${apt_list}\" | grep -e '{}/'" \
		| column -t -s " " \
		| sed -E -e "s/^/  /g"

npm-list: # List of installed npm packages.
	npm list --depth=0 -g

_print-airplane:
	@echo
	@echo "          (*)"
	@echo "       γ‘´⌒ \`ヽ  ｷ―――ﾝ"
	@echo "      {########}"
	@echo "      (・ω・｀ )  Л"
	@echo "  ／‾‾<Γ‾‾‾‾二二ニ] ≡=-💨"
	@echo "  ‾‾‾‾‾‾＼_ ＼"
	@echo

_print-goodbye:
	@echo
	@echo "            (*)"
	@echo "       γ‘´⌒ \`ヽ  ｸﾞｯﾊﾞｲ"
	@echo "      {########}"
	@echo "  “ (\`(´・ω・｀)"
	@echo "     \`(ΞΞΞ：ΞΞΞ)"
	@echo

help: # Show all commands.
	@echo "📗 Displays help information for make commands."
	@echo "Commands:"
# コマンド一覧 -> ":" で改行 -> ":" を含む行 (前半) の \s を ", " に置換、"#" を含む行 (後半) からコメントを抽出 -> ":" で分けた個所を再連結 -> column で整形
	@grep -E '^[a-zA-Z]\S+(\s\S+)*:.*' ./Makefile \
		| sed --regexp-extended -e "s/:/:\n/" \
		| sed --regexp-extended -e "/:/ s/\s/, /g; s/^.*#+\s*(.+)$$/\1/" \
		| sed --regexp-extended -e "N" -e "s/:\n/:/g;" -e "s/^/  /" \
		| column -s ":" -t
