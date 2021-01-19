SHELL := /bin/bash
SCRIPTS_DIR := ./scripts
MAKEFILE := ./Makefile
LANGS := node go python rust
.DEFAULT_GOAL := help

.PHONY: all deploy install node go python rust


# ------------------------------ init ------------------------------

init: install packaes deploy; # Install all languages and their packages.

# ------------------------------ install ------------------------------

install: $(addprefix install-,$(LANGS)); # Install all languages.

# $(addprefix install-,$(LANGS)): # Install each language and its packages.
install-node install-go install-python install-rust: _print-airplane # Install each language and its packages.
	$(eval lang=$(subst install-,,$@))
	$(SCRIPTS_DIR)/$(lang)/install_$(lang).sh;


uninstall: uninstall-nix $(addprefix uninstall-,$(LANGS)); # Uninstall all languages.

# $(addprefix uninstall-,$(LANGS)): # Uninstall each language and its packages.
uninstall-node uninstall-go uninstall-python uninstall-rust: _print-goodbye # Uninstall each language and its packages.
	$(eval lang=$(subst uninstall-,,$@))
	$(SCRIPTS_DIR)/$(lang)/uninstall_$(lang).sh;


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

packages-npm: ;
# TODO: vue の next が stable になったら @next を外す
	npm i -g \
    @nestjs/cli \
		@octokit/core \
    @vue/cli@next \
    elm \
    elm-format \
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

# ------------------------------ deploy & clean dotfiles ------------------------------

deploy: # Make symbolic links to dotfiles and back up original files if exists.
	$(SCRIPTS_DIR)/deploy.sh

clean: # Restore backed-up files of dotfiles.
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

HISTORY_LOG := /var/log/apt/history.log
apt-list:
	@echo "List of installed apt packages from '/var/log/apt/history.log'"
# ...apt|apt-get [options] install [options] を削除 -> 行中の options を削除 -> パッケージごとに改行
	@cat $(HISTORY_LOG) \
		| grep install \
		| sed -E -e "s/^.*apt(-get)?(\s--?\S+)*\sinstall(\s--?\S+)*\s//" \
		| sed -E -e "s/(^|\s)--?\S+/\1/g" -e "s/(\S)\s+(\S)/\1\n\2/g" \
		| sed -E -e "s/^/  - /g" \
		| sort \

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
		| sed --regexp-extended -e "N; s/:\n/:/g; s/^/  - /" \
		| column -s ":" -t
