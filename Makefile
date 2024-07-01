#!/usr/bin/make -f

SHELL := /bin/bash
SCRIPTS_DIR := ./scripts
PATH_SCRIPT := ./unix/.path.sh
NIX := nix --extra-experimental-features 'nix-command flakes'
SHELL_FILES := $(shell find . -type f | grep -E -e "\.sh$$" -e "\.bash(_aliases|_profile|rc)")
NIX_FILES := $(shell find . -type f | grep -e "\.nix$$")
.DEFAULT_GOAL := help

# init ----------------------------------------------------------------------------------------------------

.PHONY: init/user
init/user: add-tools/nix apply/user install/proto-langs # Set up all languages & packages for user environment

.PHONY: init/darwin
init/darwin: add-tools/nix apply/darwin install/proto-langs # Set up all languages & packages for dawrin

# tools ----------------------------------------------------------------------------------------------------

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
	$(SCRIPTS_DIR)/add-wsl-sudo-hello.sh

.PHONY: remove-tools/nix/user
remove-tools/nix/user: _print-goodbye # Uninstall nix for user environment (See https://nixos.org/manual/nix/stable/installation/uninstall.html#uninstalling-nix)
	$(NIX) shell github:nix-community/home-manager/release-23.11 \
		--command sh -c "home-manager uninstall"
	rm -rf ~/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs,.config/nix,.config/home-manager}
	sudo rm -rf /nix /etc/profiles/per-users
	@echo "✅ Nix has been uninstalled successfully!"

.PHONY: ls
remove-tools/nix/darwin: _print-goodbye # Uninstall nix for darwin (See https://nixos.org/manual/nix/stable/installation/uninstall.html#macos)
	$(SCRIPTS_DIR)/remove-nix-darwin.sh

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

.PHONY: install/proto-langs
install/proto-langs: # Install languages by proto
	source $(PATH_SCRIPT) && proto use

.PHONY: uninstall/proto-langs
uninstall/proto-langs: # Uninstall languages by proto
	proto uninstall node || : && \
		proto uninstall yarn || : && \
		proto uninstall pnpm || : && \
		proto uninstall terraform

.PHONY: _install/asdf-langs
_install/asdf-langs: # Install languages by asdf
	mkdir -p ~/.asdf
	$(SCRIPTS_DIR)/asdf/install.sh nodejs node || :
	$(SCRIPTS_DIR)/asdf/install.sh yarn || :
	$(SCRIPTS_DIR)/asdf/install.sh pnpm || :
	$(SCRIPTS_DIR)/asdf/install.sh terraform || :

.PHONY: _uninstall/asdf-langs
_uninstall/asdf-langs: # Uninstall languages by asdf
	$(SCRIPTS_DIR)/asdf/uninstall.sh

# packages ----------------------------------------------------------------------------------------------------

.PHONY: apply/user
apply/user: # Run `home-manager switch` for user environment
	$(SCRIPTS_DIR)/backup.sh ./modules/files/files.txt
	if [[ $$(uname -r) =~ microsoft ]]; then \
		source $(PATH_SCRIPT) && $(NIX) run \
			home-manager -- switch --flake .#"\"$${USER}-wsl"\"; \
	else \
		source $(PATH_SCRIPT) && $(NIX) run \
			home-manager -- switch --flake .; \
	fi
	@echo "✅ home-manager has been applied successfully!"

.PHONY: apply/darwin
apply/darwin: # Run `nix-darwin switch`
	$(SCRIPTS_DIR)/backup.sh ./modules/files/files.txt --absolute
	if [[ $$(arch) =~ arm64 ]]; then \
		source $(PATH_SCRIPT) && $(NIX) run \
			nix-darwin -- switch --flake .#"\"aarch64-darwin-$${USER}\""; \
	else \
		source $(PATH_SCRIPT) && $(NIX) run \
			nix-darwin -- switch --flake .#"\"x86_64-darwin-$${USER}"\"; \
	fi
	$(SCRIPTS_DIR)/writable-files.sh ./modules/files/files.txt
	@echo "✅ nix-darwin has been applied successfully!"

.PHONY: apply/windows
apply/windows: # Make symbolic links to dotfiles & back up original files if exists in Windows
	$(SCRIPTS_DIR)/apply/windows.sh

.PHONY: _apply/unix
_apply/unix: # (Deprecated) Make symbolic links to dotfiles & back up original files if exists
	$(SCRIPTS_DIR)/apply/unix.sh

.PHONY: restore/windows
restore/windows: # Restore backed-up files of dotfiles in Windows
	$(SCRIPTS_DIR)/restore/windows.sh

.PHONY: _restore/unix
_restore/unix: # (Deprecated) Restore backed-up files of dotfiles
	$(SCRIPTS_DIR)/restore/unix.sh

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

.PHONY: update/vscode-settings/darwin
update/vscode-settings/darwin: # Update VSCode settings.json & keybindings.json for Darwin
	echo 'Library/Application\ Support/Code/User/'{settings,keybindings}.json \
		| xargs -n 1 \
		| xargs -I {} cp {~,./unix}/{}

.PHONY: update/vscode-settings/linux
update/vscode-settings/linux: # Update VSCode settings.json & keybindings.json for Linux
	echo '.config/Code/User/'{settings,keybindings}.json \
		| xargs -n 1 \
		| xargs -I {} cp --verbose {~,./unix}/{}

.PHONY: update/vscode-settings/windows
update/vscode-settings/windows: # Update VSCode settings.json & keybindings.json for Windows through WSL environment
	username=$$(wslvar USERNAME) && \
	echo 'AppData/Roaming/Code/User/'{settings,keybindings}.json \
		| xargs -n 1 \
		| xargs -I {} cp --verbose /mnt/c/Users/$${username}/{} ./windows/{}

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

.PHONY: check/dprint
check/dprint: # Check by dprint
	dprint check

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

.PHONY: fix/dprint
fix/dprint: # Format by dprint
	dprint fmt

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
		| sed -E -e 's/:.*\s+#\s+(.*)$$/;;\1/' \
		| column -s ";;" -t
