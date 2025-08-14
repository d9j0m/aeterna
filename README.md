# Aeterna Linux

The Aeterna Linux installation scripts will configure a minimal Fedora installation with Hyprland, associated dotfiles, and various utilities and applications for a ready to use desktop environment.

Starting with a clean installation using the Fedora Everything ISO, configure networking:

nmcli connection modify <connection_name> ipv4.method auto

nmcli connection up <connection_name>

Begin the Aeterna installation:

Install wget:

sudo dnf install wget

Launch the Aeterna installation:

wget -qO- https://raw.githubusercontent.com/d9j0m/aeterna/refs/heads/main/bootstrap.sh | bash
