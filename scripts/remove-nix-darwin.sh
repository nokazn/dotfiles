#!/usr/bin/env bash

# それぞれの処理は独立しているため、エラーでも続行する
set -u -o pipefail

# See https://nixos.org/manual/nix/stable/installation/uninstall.html#uninstalling-nix
function remove_nix_darwin() {
    if command -v nix >/dev/null; then
        nix --extra-experimental-features 'nix-command flakes' shell github:LnL7/nix-darwin#darwin-uninstaller \
            --command darwin-uninstaller
        nix --extra-experimental-features 'nix-command flakes' shell github:nix-community/home-manager \
            --command sh -c "yes | sudo home-manager uninstall"
    else
        echo "⚠️ Nix is not installed."
    fi

    sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist &&
        sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist
    sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist &&
        sudo rm /Library/LaunchDaemons/org.nixos.darwin-store.plist

    for u in $(sudo dscl . -delete /Groups/nixbld | grep nixbld); do
        sudo dscl . -list "/Groups/${u}"
    done
    for u in $(sudo dscl . -list /Users | grep _nixbld); do
        sudo dscl . -delete "/Users/${u}"
    done

    printf "⚠️ Please remove the line mounting the Nix Store volume on /nix, which looks like \`UUID=<uuid> /nix apfs rw,noauto,nobrowse,suid,owners\` or \`LABEL=Nix\040Store /nix apfs rw,nobrowse\`.\n"
    sleep 3
    sudo vifs
    sudo sed -E -i -e '/^nix/d' /etc/synthetic.conf

    sudo rm -rf /etc/{nix,profiles} \
        /var/root/{.nix-profile,.nix-defexpr,.nix-channels} \
        ~/{.nix-profile,.nix-defexpr,.nix-channels}

    # See https://github.com/NixOS/nix/issues/8771#issuecomment-1662633816
    sudo rm -rf /etc/ssl/certs/ca-certificates.crt

    # restore the original files
    find /etc/ -maxdepth 1 -type f |
        grep -e .backup-before-nix -e .before-nix-darwin |
        sed -E -e 'p;s/\.(backup-before-nix|before-nix-darwin)//' |
        xargs -n 2 sudo mv -v

    local -r complete_message="✅ Nix has been uninstalled successfully!"
    read -rp "Do you want to reboot to unmount \`/Volumes/Nix Store\` instead of \`/nix\` now? (Y/n) " response </dev/tty
    if [[ ${response} =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo 'You should run the following command to unmount the Nix store volume. (See https://github.com/NixOS/nix/issues/458#issuecomment-1264906595)'
        echo 'sudo diskutil apfs deleteVolume /Volumes/Nix\ Store'
        echo 'After 5 seconds the system will reboot.'
        echo "${complete_message}"
        sleep 5
        sudo reboot
    else
        echo "${complete_message}"
    fi
}

remove_nix_darwin
