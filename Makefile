SHELL := /bin/bash
MAKEFILE := ./Makefile
SCRIPTS_DIR := ./scripts
PATH_FILE := ~/.path.sh
LANGS := node go python rust
.DEFAULT_GOAL := help

.PHONY: init add-tools remove-tools add-nix remove-nix add-prezto remove-prezto add-dein-vim remove-dein-vim add-mkcert remove-mkcert add-bash-it remove-bash-it install install-node, install-go, install-python, install-rust uninstall uninstall-node, uninstall-go, uninstall-python, uninstall-rust packages packages-apt packages-apt-for-pyenv packages-nix packages-npm packages-go packages-pip update update-apt update-npm update-go update-pip deploy deploy-gitconfig restore apt-list apt-history apt-history-installed npm-list help

# ------------------------------ init ------------------------------

init: add-tools install packaes deploy; # Install all languages and their packages.

# ------------------------------ tools ------------------------------

add-tools: add-nix add-prezto add-dein-vim add-mkcert; # Add developing tools.

remove-tools: remove-nix remove-prezto remove-dein-vim remove-mkcert; # Remove developing tools.

add-nix: _print-airplane # Install nix.
	@if type "nix-env" > /dev/null 2>&1; then \
		echo "✅ nix is already installed."; \
	else \
		curl -L https://nixos.org/nix/install | sh; \
		source $(PATH_FILE); \
		echo "✅ nix has been installed successfully!"; \
	fi

remove-nix: _print-goodbye # Uninstall nix.
	sudo rm -rf ~/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs}
	sudo rm -rf /nix
	@echo "✅ nix has been uninstalled successfully!"


add-prezto: _print-airplane # Add Prezto for zsh.
	git clone --recursive https://github.com/sorin-ionescu/prezto.git ~/.zprezto
	ls $${ZDOTDIR:-$${HOME}}/.zprezto/runcoms --ignore README.md | xargs -I "{}" ln -s "$${HOME}/.zprezto/runcoms/{}" "$${HOME}/dotfiles/.{}"
	@echo "✅ prezto has been installed successfully!"

remove-prezto: _print-goodbye # Remove Prezto for zsh.
	sudo rm -i -r ~/.zprezto
	@echo "✅ prezto has been uninstalled successfully!"

add-dein-vim: _print-airplane # Add dein.vim.
	curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh | sh -s ~/.vim/dein
	@echo "✅ dein.vim has been installed successfully!"

remove-dein-vim: _print-goodbye # Remove dein.vim.
	sudo rm ~/.vim/dein -ri
	@echo "✅ dein.vim has been uninstalled successfully!"

add-mkcert: # Add mkcert (locally trusted development certificates tool).
	sudo apt install libnss3-tools
	mkdir ~/.mkcert -p; \
	git clone https://github.com/FiloSottile/mkcert ~/.mkcert && cd ~/.mkcert; \
	go build -ldflags "-X main.Version=$(git describe --tags)"
	@echo "✅ mkcert has been installed successfully!"

remove-mkcert: # Remove mkcert.
	sudo rm -rI ~/.mkcert
	@echo "✅ mkcert has been installed successfully!"

add-bash-it: _print-airplane # Add bash-it.
	git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash-it
	~/.bash-it/install.sh
	bash-it enable completion bash-it
		cargo \
		docker-compose \
		docker \
		export \
		gcloud \
		git \
		go \
		lerna \
		makefile \
		npm \
		pip \
		pipenv \
		rustup \
		ssh \
		tmux
	exec $$SHELL -l
	@echo "✅ bash-it has been installed successfully!"

remove-bash-it: _print-goodbye # Remove bash-it.
	sudo rm -i -r ~/.bash-it

# ------------------------------ languages ------------------------------

install: $(addprefix install-,$(LANGS)); # Install all languages & tools. (runs scripts starting with 'intall-' prefix.)

install-node install-go install-python install-rust: _print-airplane # Install each language.
	$(eval lang=$(subst install-,,$@))
	$(SCRIPTS_DIR)/$(lang)/install_$(lang).sh;


uninstall: $(addprefix uninstall-,$(LANGS)); # Uninstall all languages and tools. (runs scripts starting with 'unintall-' prefix.)

uninstall-node uninstall-go uninstall-python uninstall-rust: _print-goodbye # Uninstall each language.
	$(eval lang=$(subst uninstall-,,$@))
	$(SCRIPTS_DIR)/$(lang)/uninstall_$(lang).sh;

# ------------------------------ packages ------------------------------

packages: packages-apt packages-npm packaes-pip; # Get all packages.

# TODO: pyenv
packages-apt: packages-apt-for-pyenv # Install apt packages.
	sudo apt install -y \
		xsel \
		postgres-12 \
		zsh
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

packages-npm: # Install npm packages.
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
deploy-gitconfig: # Copy .gitconfig file.
	cp ./.gitconfig ~/.gitconfig

restore: # Restore backed-up files of dotfiles.
	$(SCRIPTS_DIR)/restore.sh

# ------------------------------ utilities ------------------------------

apt-list: # Show a list of installed apt packages.
	sudo apt list --installed | more

HISTORY_LOG := /var/log/apt/history.log
apt-history: # Show apt packages installed/uninstalled history.
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

apt-history-installed: # Show a list of apt packages a user manually installed.
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

# TODO: カテゴリごとにわかりやすくする
help: # Show all commands.
	@echo "📗 Displays help information for make commands."
	@echo "Commands:"
# コマンド一覧 -> ":" で改行 -> ":" を含む行 (前半) の \s を ", " に置換、"#" を含む行 (後半) からコメントを抽出 -> ":" で分けた個所を再連結 -> column で整形
	@grep -E '^[a-zA-Z]\S+(\s\S+)*:.*' ./Makefile \
		| sed --regexp-extended -e "s/:/:\n/" \
		| sed --regexp-extended -e "/:/ s/\s/, /g" -e "s/^.*[#|;]+\s*//" \
		| sed --regexp-extended -e "N" -e "s/:\n/:/g;" -e "s/^/  /" \
		| column -s ":" -t
