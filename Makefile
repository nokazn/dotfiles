#!/usr/bin/make -f

SHELL := /bin/bash
MAKEFILE := ./Makefile
SCRIPTS_DIR := ./scripts
PATH_FILE := ~/.path.sh
LANGS := node go python rust
.DEFAULT_GOAL := help


# ------------------------------ init ------------------------------

.PHONY: init
init: add-tools install packaes deploy; # Install all languages and their packages.

# ------------------------------ tools ------------------------------

.PHONY: add-tools
add-tools: add-nix add-prezto add-dein-vim add-mkcert; # Add developing tools.

.PHONY: remove-tools
remove-tools: remove-nix remove-prezto remove-dein-vim remove-mkcert; # Remove developing tools.


.PHONY: add-nix
add-nix: _print-airplane # Install nix.
	@if type "nix-env" >/dev/null 2>&1; then \
		echo "✅ nix is already installed."; \
	else \
		curl -L https://nixos.org/nix/install | sh; \
		source $(PATH_FILE); \
		echo "✅ nix has been installed successfully!"; \
	fi

.PHONY: remove-nix
remove-nix: _print-goodbye # Uninstall nix.
	sudo rm -rf ~/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs}
	sudo rm -rf /nix
	@echo "✅ nix has been uninstalled successfully!"


.PHONY: add-prezto
add-prezto: _print-airplane # Add Prezto for zsh.
	git clone --recursive https://github.com/sorin-ionescu/prezto.git ~/.zprezto
	ls $${ZDOTDIR:-$${HOME}}/.zprezto/runcoms --ignore README.md | xargs -I "{}" ln -s "$${HOME}/.zprezto/runcoms/{}" "$${HOME}/dotfiles/.{}"
	@echo "✅ prezto has been installed successfully!"

.PHONY: remove-prezto
remove-prezto: _print-goodbye # Remove Prezto for zsh.
	sudo rm -I -r ~/.zprezto
	@echo "✅ prezto has been uninstalled successfully!"


.PHONY: add-dein-vim
add-dein-vim: _print-airplane # Add dein.vim.
	curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh | sh -s ~/.vim/dein
	@echo "✅ dein.vim has been installed successfully!"

.PHONY: remove-dein-vim
remove-dein-vim: _print-goodbye # Remove dein.vim.
	sudo rm ~/.vim/dein -ri
	@echo "✅ dein.vim has been uninstalled successfully!"


.PHONY: add-mkcert
add-mkcert: # Add mkcert (locally trusted development certificates tool).
	sudo apt install libnss3-tools
	mkdir ~/.mkcert -p; \
	git clone https://github.com/FiloSottile/mkcert ~/.mkcert && cd ~/.mkcert; \
	go build -ldflags "-X main.Version=$(git describe --tags)"
	@echo "✅ mkcert has been installed successfully!"

.PHONY: remove-mkcert
remove-mkcert: # Remove mkcert.
	sudo rm -rI ~/.mkcert
	@echo "✅ mkcert has been installed successfully!"


.PHONY: add-bash-it
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

.PHONY: remove-bash-it
remove-bash-it: _print-goodbye # Remove bash-it.
	sudo rm -I -r ~/.bash-it


.PHONY: add-wsl-sudo-hello
add-wsl-sudo-hello: # Add WSL-Hello-sudo (https://github.com/nullpo-head/WSL-Hello-sudo).
	mkdir -p ~/downloads
	if [[ ! -f ~/downloads/wsl-hello-sudo/install.sh ]]; then \
		if [[ ! -e ~/downloads/wsl-hello-sudo.tar.gz ]]; then \
			wget http://github.com/nullpo-head/WSL-Hello-sudo/releases/latest/download/release.tar.gz -O wsl-hello-sudo; \
		fi; \
		mkdir -p ~/downloads/wsl-hello-sudo; \
		tar -xvf ~/downloads/wsl-hello-sudo.tar.gz -C ~/downloads/wsl-hello-sudo --strip-components 1; \
	fi
	cd ~/downloads/wsl-hello-sudo; \
	./install.sh
	@echo "✅ WSL-Hello-sudo has been installed successfully!"

.PHONY: remove-wsl-hello-sudo
remove-wsl-hello-sudo: # Remove WSL-Hello-sudo
	~/downloads/wsl-hello-sudo/uninstall.sh
	sudo rm -Ir ~/downloads/wsl-hello-sudo
	@echo "✅ WSL-Hello-sudo has been uninstalled successfully!"

# ------------------------------ languages ------------------------------

.PHONY: install
install: $(addprefix install-,$(LANGS)); # Install all languages & tools. (runs scripts starting with 'intall-' prefix.)

.PHONY: install-node install-go install-python install-rust install-elm install-nim
install-node install-go install-python install-rust install-elm install-nim: _print-airplane # Install each language.
	$(eval lang=$(subst install-,,$@))
	$(SCRIPTS_DIR)/$(lang)/install_$(lang).sh;

.PHONY: uninstall
uninstall: $(addprefix uninstall-,$(LANGS)); # Uninstall all languages and tools. (runs scripts starting with 'unintall-' prefix.)

.PHONY: uninstall-node uninstall-go uninstall-python uninstall-rust uninstall-elm uninstall-nim
uninstall-node uninstall-go uninstall-python uninstall-rust uninstall-elm uninstall-nim: _print-goodbye # Uninstall each language.
	$(eval lang=$(subst uninstall-,,$@))
	$(SCRIPTS_DIR)/$(lang)/uninstall_$(lang).sh;

# ------------------------------ packages ------------------------------

.PHONY: packages
packages: packages-apt packages-npm packaes-pip; # Get all packages.

.PHONY: packagegs-apt
packages-apt: packages-apt-for-pyenv # Install apt packages.
	sudo apt install -y \
		xsel \
		postgres-12 \
		mysql-server \
		zsh \
		tshark
	sudo apt update -y && sudo apt upgrade -y

.PHONY: packages-apt-for-pyenv
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

.PHONY: packages-nix
packages-nix: # Install nix packages.
	nix-env --install -A nixpkgs.git \
		nixpkgs.vimHugeX \
		nixpkgs.direnv \
		nixpkgs.sl \
		nixpkgs.neofetch \
		nixpkgs.heroku \
		nixpkgs.colordiff \
		nixpkgs.htop \
		nixpkgs.tree \
		nixpkgs.nkf \
		nixpkgs.tldr \
		nixpkgs.jq \
		nixpkgs.yq \
		nixpkgs.ncdu \
		nixpkgs.inetutils \
		nixpkgs.rsync \
		nixpkgs.gcc \
		nixpkgs.redis \
		nixpkgs.memcached \
		nixpkgs.gist \
		nixpkgs.gitAndTools.delta \
		nixpkgs.bat \
		nixpkgs.broot \
		nixpkgs.hyperfine \
		nixpkgs.tokei \
		nixpkgs.gping \
		nixpkgs.google-cloud-sdk \
		nixpkgs.shellcheck \
		nixpkgs.expect \
		nixpkgs.php \
		nixpkgs.php74Packages.composer

.PHONY: packages-npm
packages-npm: # Install npm packages.
# TODO: vue の next が stable になったら @next を外す
	npm i -g \
		aws-cdk \
		@nestjs/cli \
		@octokit/core \
		@vue/cli@next \
		envinfo \
		eslint \
		firebase-tools \
		http-server \
		lerna \
		netlify-cli \
		node-gyp \
		prettier \
		serverless \
		ts-node \
		typescript \
		vercel \
		vue@next \
		yarn;
	nodenv rehash

.PHONY: packages-go
packages-go: # Install Go packages.
	go get -u -v github.com/motemen/ghq; \
	go get -u -v github.com/motemen/gore; \
	go get -u -v golang.org/x/tools/gopls; \
	go get -u -v golang.org/x/tools/cmd/goimports;
	goenv rehash

.PHONY: packages-pip
packages-pip: # Install pip packages.
	pip install --user \
		awscli \
		pipenv;
	pyenv rehash

# ------------------------------ update ------------------------------

.PHONY: update
update: update-apt update-npm update-go update-rust; # Update all packages.

.PHONY: update-apt
update-apt: # Update apt packages.
	sudo apt update -y; \
	if [[ $$(apt list --upgradable 2>/dev/null | grep upgradable | wc -l) -gt 0 ]]; then \
		sudo apt upgrade -y; \
	fi;

.PHONY: update-npm
update-npm: # Update global npm packages.
	npm update -g

.PHONY: update-go
update-go: install-go; # Update Go packages.

.PHONY: update-pip
update-pip: # Update pip packages.
	pip install --upgrade pip
	pip list --user | tail -n +3 | cut -d " " -f 1 | xargs pip install --user --upgrade

# ------------------------------ deploy & restore dotfiles ------------------------------

.PHONY: deploy
deploy: # Make symbolic links to dotfiles and back up original files if exists.
	$(SCRIPTS_DIR)/deploy.sh

# TODO: 別のスクリプトに分ける
.PHONY: deploy-gitconfig
deploy-gitconfig: # Copy .gitconfig file.
	cp ./.gitconfig ~/.gitconfig

.PHONY: restore
restore: # Restore backed-up files of dotfiles.
	$(SCRIPTS_DIR)/restore.sh

# ------------------------------ docker ------------------------------

.PHONY: docker-nginx
docker-nginx: # Run nginx in Docker.
	docker run -d --name nginx -p 8080:80 nginx
	@echo "✅ Running nginx at port 8080 in 'nginx' container."

.PHONY: docker-postgresql
docker-postgresql: # Run PostgreSQL in Docker.
	docker run --rm -d \
		--name postgres \
		-e POSTGRES_PASSWORD=password \
		-p 5432:5432 \
		-v postgres-tmp:/var/lib/postgresql/data \
		postgres:12-alpine
	@echo "✅ Running PostgreSQL at port 5432 in 'postgresql' container. You can connect by executing 'psql -h localhost -p 5432 -U postgres'."

.PHONY: docker-mysql
docker-mysql: # Run MySQL in Docker/
	docker network create mysql-network
	docker run -d --rm \
			--name mysql \
			--network mysql-network \
			-e MYSQL_ROOT_PASSWORD=password \
			-p 3306:3306 \
			-v mysql-tmp-data:/var/lib/mysql \
			-v mysql-tmp-log:/var/log/mysql \
			mysql:5.7
	@echo "✅ Running MySQL at port 3306 in 'mysql' container."

.PHONY: docker-mysql-rm
docker-mysql-rm: # Remove MySql container./
	docker stop mysql; \
	docker network rm mysql-network
	@echo "✅ Removed 'mysql' container."

.PHONY: docker-redis
docker-redis: # Run Redis in Docker.
	docker network create redis-network
	docker run -d --rm \
		--name redis \
		--network redis-network \
		-p 6379:6379 \
		-v redis-tmp:/data \
		redis:6.0.10-alpine \
		redis-server --appendonly yes
	@echo "✅ Running Redis at port 6379 in 'redis' container."

.PHONY: docker-redis-rm
docker-redis-rm: # Remove Redis container.
	docker stop redis; \
	docker network rm redis-network
	@echo "✅ Removed 'redis' container."

.PHONY: docker-memcached
docker-memcached: # Run Memcached in Docker.
	docker network create memcached-network
	docker run -d --rm \
		--name memcached \
		--network memcached-network \
		-p 11211:11211 \
		memcached:1.6-alpine
	@echo "✅ Running Memcached at port 11211 in 'memcached' container."

.PHONY: docker-memcached-rm
docker-memcached-rm: # Remove Memcached container.
	docker stop memcached; \
	docker network rm memcached-network
	@echo "✅ Removed 'memcached' container."

.PHONY: docker-wordpress
docker-wordpress: docker-mysql # Run Wordpress & MySQL in Docker.
	docker run -d --rm --name wordpress \
		--network mysql-network \
		-e WORDPRESS_DB_PASSWORD=password \
		-p 8080:80 \
		wordpress
	@echo "✅ Running Wordpress at port 8080 in 'wordpress' container."

.PHONY: docker-rmi-untagged-images
docker-rmi-untagged-images: # Remove all untagged images.
	docker rmi $$(docker images -f "dangling=true" -q --no-trunc)

# ------------------------------ utilities ------------------------------

.PHONY: apt-list
apt-list: # Show a list of installed apt packages.
	sudo apt list --installed | more

.PHONY: apt-history
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
			>/dev/null \
		| cat

.PHONY: apt-history-installed
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

.PHONY: nix-list
nix-list: # List of installed nix packages.
	nix-env -qa --installed

.PHONY: npm-list
npm-list: # List of installed npm packages.
	npm list --depth=0 -g

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
