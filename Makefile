#!/usr/bin/make -f

SHELL := /bin/bash
SCRIPTS_DIR := ./scripts
PATH_SCRIPT := ./unix/.path.sh
NIX := nix --extra-experimental-features 'nix-command flakes'
LANGS := rust nim
SHELL_FILES := $(shell find . -type f | grep -E -e "\.sh$$" -e "\.bash(_aliases|_profile|rc)")
NIX_FILES := $(shell find . -type f | grep -e "\.nix$$")
.DEFAULT_GOAL := help

# init ----------------------------------------------------------------------------------------------------

.PHONY: init/user
init/user: add-tools/user install # Set up all languages & packages for user environment

.PHONY: init/darwin
init/darwin: add-tools/darwin install # Set up all languages & packages for dawrin

# tools ----------------------------------------------------------------------------------------------------

.PHONY: add-tools/user
add-tools/user: add-tools/nix apply/user # Add developing tools

.PHONY: add-tools/darwin
add-tools/darwin: add-tools/nix apply/darwin # Add developing tools

.PHONY: add-tools/nix
add-tools/nix: _print-airplane # Install nix
	@if type "nix" >/dev/null 2>&1; then \
		echo "✅ Nix is already installed."; \
	else \
		curl -L https://nixos.org/nix/install | bash; \
		echo "✅ Nix has been installed successfully!"; \
	fi

.PHONY: add-tools/wsl-hello-sudo
add-tools/wsl-hello-sudo: _print-airplane # Add WSL-Hello-sudo
	$(SCRIPTS_DIR)/install-wsl-sudo-hello.sh

.PHONY: remove-tools
remove-tools: remove-tools/nix # Remove developing tools

.PHONY: remove-tools/nix/user
remove-tools/nix/user: _print-goodbye # Uninstall nix for user environment (See https://nixos.org/manual/nix/stable/installation/uninstall.html#uninstalling-nix)
	$(NIX) shell github:nix-community/home-manager/release-23.11 \
		--command sh -c "home-manager uninstall"
	rm -rf ~/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs,.config/nix,.config/home-manager}
	sudo rm -rf /nix /etc/profiles/per-users
	@echo "✅ Nix has been uninstalled successfully!"

.PHONY: ls
remove-tools/nix/darwin: _print-goodbye # Uninstall nix for darwin (See https://nixos.org/manual/nix/stable/installation/uninstall.html#macos)
	$(NIX) shell github:LnL7/nix-darwin#darwin-uninstaller \
		--command darwin-uninstaller
	$(NIX) shell github:nix-community/home-manager/release-23.11 \
		--command sh -c "yes | sudo home-manager uninstall"
	sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist;
	sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist;
	sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist;
	sudo rm /Library/LaunchDaemons/org.nixos.darwin-store.plist;
	sudo dscl . -delete /Groups/nixbld;
	for u in $(sudo dscl . -list /Users | grep _nixbld); do sudo dscl . -delete /Users/$u; done;
	sudo vifs;
	sudo sed -E -i -e '/^nix/d' /etc/synthetic.conf;
	sudo rm -rf /etc/{nix,profiles} /var/root/.nix-profile /var/root/.nix-defexpr /var/root/.nix-channels ~/{.nix-profile,.nix-defexpr,.nix-channels}
	sudo diskutil apfs deleteVolume /nix;
	find /etc/ -maxdepth 1 -type f | \
		grep .backup-before-nix | \
		sed -E -e 'p;s/\.backup-before-nix//' | \
    xargs -n 2 sudo mv -v;
	@echo "✅ Nix has been uninstalled successfully!"

.PHONY: remove-tools/wsl-hello-sudo
remove-tools/wsl-hello-sudo: _print-goodbye # Remove WSL-Hello-sudo
	if [[ -f ~/Downloads/wsl-hello-sudo/uninstall.sh ]]; then \
		~/Downloads/wsl-hello-sudo/uninstall.sh; \
		rm -rf ~/Downloads/wsl-hello-sudo; \
	fi
	@echo "✅ WSL-Hello-sudo has been uninstalled successfully!"

.PHONY: _add-tools/bash-it
_add-tools/bash-it: _print-airplane # (Deprecated) Add bash-it
	rm -rf ~/.bash-it
	git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash-it
# keep your .bashrc and append bash-it templates at the end
	yes | ~/.bash-it/install.sh
	@echo "✅ bash-it has been installed successfully!"

.PHONY: remove-tools/bash-it
_remove-tools/bash-it: _print-goodbye # (Deprecated) Remove bash-it
	rm -rf ~/.bash-it
	@echo "✅ bash-it has been uninstalled successfully!"

# languages ----------------------------------------------------------------------------------------------------

.PHONY: install
install: install/asdf-langs # Install all languages (runs scripts starting with `intall-` prefix)

.PHONY: install/asdf-langs
install/asdf-langs: # Install languages by asdf
	$(SCRIPTS_DIR)/asdf-install.sh nodejs node
	$(SCRIPTS_DIR)/asdf-install.sh yarn
	$(SCRIPTS_DIR)/asdf-install.sh pnpm
	$(SCRIPTS_DIR)/asdf-install.sh terraform
	asdf install

.PHONY: $(addprefix install/,$(LANGS))
$(addprefix install/,$(LANGS)): _print-airplane # Install each language
	$(eval lang=$(subst install/,,$@))
	source ${PATH_SCRIPT}; \
	$(SCRIPTS_DIR)/$(lang)/install-$(lang).sh;

.PHONY: uninstall
uninstall: $(addprefix uninstall/,$(LANGS)) # Uninstall all languages (runs scripts starting with `unintall-` prefix)

.PHONY: $(addprefix uninstall/,$(LANGS))
$(addprefix uninstall/,$(LANGS)): _print-goodbye # Uninstall each language
	$(eval lang=$(subst uninstall/,,$@))
	$(SCRIPTS_DIR)/$(lang)/uninstall-$(lang).sh;

# packages ----------------------------------------------------------------------------------------------------

.PHONY: apply/user
apply/user: _apply/backup-home-files _apply/path # Run `home-manager switch` for user environment
	$(NIX) run \
		home-manager/release-23.11 -- switch --flake .
	@echo "✅ home-manager has been applied successfully!"

.PHONY: apply/user-wsl
apply/user-wsl: _apply/backup-home-files _apply/path # Run `home-manager switch` for WSL user environment
	$(NIX) run \
		home-manager/release-23.11 -- switch --flake .#wsl
	@echo "✅ home-manager has been applied successfully!"

.PHONY: apply/darwin
apply/darwin: _apply/backup-home-files _apply/path # Run `nix-darwin switch`
	$(NIX) run \
		nix-darwin -- switch --flake .#aarch64-darwin
	@echo "✅ nix-darwin has been applied successfully!"

.PHONY: _apply/backup-home-files
_apply/backup-home-files:
	$(SCRIPTS_DIR)/backup.sh ./modules/files/files.txt

.PHONY: _apply/path
_apply/path:
	source "$(PATH_SCRIPT)"

# update ----------------------------------------------------------------------------------------------------

.PHONY: update/nix
update/nix: # Update Nix package manager
	nix-channel --update && nix upgrade-nix
	nix flake update

.PHONY: update/npm-packages-list
update/npm-packages-list: # Generate Nix packages list for npm packages
	cd ./modules/node; \
	nix-shell -p nodePackages.node2nix \
    -p nixpkgs-fmt \
    --command 'node2nix -i ./packages.json -o ./packages.nix --nodejs-18 && find . -type f | grep -e "\.nix$$" | xargs nixpkgs-fmt' && exit

# deploy & restore dotfiles ----------------------------------------------------------------------------------------------------

.PHONY: _deploy
_deploy: # (Deprecated) Make symbolic links to dotfiles & back up original files if exists
	$(SCRIPTS_DIR)/_deploy/unix.sh

.PHONY: deploy/windows
deploy/windows: # Make symbolic links to dotfiles & back up original files if exists in Windows
	$(SCRIPTS_DIR)/_deploy/windows.sh

.PHONY: _restore
_restore: # (Deprecated) Restore backed-up files of dotfiles
	$(SCRIPTS_DIR)/_restore/unix.sh

.PHONY: restore/windows
restore/windows: # Restore backed-up files of dotfiles in Windows
	$(SCRIPTS_DIR)/_restore/windows.sh

# utilities ----------------------------------------------------------------------------------------------------

.PHONY: check
check: check/shellcheck check/shfmt check/nixpkgs-fmt # Check by all `check/*` tasks

.PHONY: check/shellcheck
check/shellcheck: # Check schell scripts
	shellcheck $(SHELL_FILES)

.PHONY: check/shfmt
check/shfmt: # Check wheter schell scripts are formatted
	shfmt --diff $(SHELL_FILES)

.PHONY: check/nixpkgs-fmt
check/nixpkgs-fmt: # Check `.nix` files
	nixpkgs-fmt $(NIX_FILES) --check

.PHONY: fix
fix: fix/shellcheck fix/shfmt fix/nixpkgs-fmt # Fix by all `fix/*` tasks

.PHONY: fix/shellcheck
fix/shellcheck: # Fix schell scripts if possible
	shellcheck --format diff $(SHELL_FILES) \
		| patch -p1

.PHONY: fix/shfmt
fix/shfmt: # Format schell scripts
	shfmt --write $(SHELL_FILES)

.PHONY: fix/nixpkgs-fmt
fix/nixpkgs-fmt: # Format `.nix` files
	nixpkgs-fmt $(NIX_FILES)

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
# コマンド一覧 (`_`始まりのコマンドは除く) → `:`から｀＃｀または行末までの文字列を削除する → column で整形
	@grep -E '^[a-zA-Z]\S+(\s\S+)*:.*' ./Makefile \
		| sed -E -e 's/:.*#(.*)$$/:\1/' \
		| column -s ":" -t
