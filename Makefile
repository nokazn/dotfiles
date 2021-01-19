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
install-node install-go install-python install-rust: # Install each language and its packages.
	$(eval lang=$(subst install-,,$@))
	@echo;
	@echo "          (*)";
	@echo "       γ‘´⌒ \`ヽ  ｷ―――ﾝ";
	@echo "      {########}";
	@echo "      (・ω・｀ )  Л";
	@echo "  ／‾‾<Γ‾‾‾‾二二ニ] ≡=-💨";
	@echo "  ‾‾‾‾‾‾＼_ ＼";
	@echo;
	$(SCRIPTS_DIR)/$(lang)/install_$(lang).sh;


uninstall: $(addprefix uninstall-,$(LANGS)); # Uninstall all languages.

# $(addprefix uninstall-,$(LANGS)): # Uninstall each language and its packages.
uninstall-node uninstall-go uninstall-python uninstall-rust: # Uninstall each language and its packages.
	$(eval lang=$(subst uninstall-,,$@))
	@echo;
	@echo "            (*)";
	@echo "       γ‘´⌒ \`ヽ  ｸﾞｯﾊﾞｲ";
	@echo "      {########}";
	@echo "  “ (\`(´・ω・｀)";
	@echo "     \`(ΞΞΞ：ΞΞΞ)";
	@echo;
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
	npm i -g \
    @nestjs/cli \
		@octokit/core \
    @vue/cli \
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
    vue \
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

help: # Show all commands.
	@echo "📗 Displays help information for make commands."
	@echo "Commands:"
	@ # コマンド一覧を表示 | ":" で改行 | ":" を含む行 (前半部) のスペースを ", " に置換し、"#" を含む行 (後半部) からコメントを抽出 | ":" で分けた個所を連結 | column で整形
	@grep -E '^[a-zA-Z]\S+(\s\S+)*:.*' ./Makefile \
		| sed --regexp-extended -e "s/:/:\n/" \
		| sed --regexp-extended -e "/:/ s/\s/, /g; s/^.*#+\s*(.+)$$/\1/" \
		| sed --regexp-extended -e "N; s/:\n/:/g; s/^/  - /" \
		| column -s ":" -t
