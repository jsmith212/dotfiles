# Framework Laptop 13 Pro (Intel Core Ultra Series 3)
#
# First-time setup on the new machine:
#   1. Install NixOS, clone the dotfiles.
#   2. cp /etc/nixos/hardware-configuration.nix ~/.dotfiles/nix/hosts/JSFramework/
#      and `git add` it (flakes only see files git knows about).
#   3. Set system.stateVersion below to the value in the installer's
#      /etc/nixos/configuration.nix.
#   4. sudo nixos-rebuild switch --flake ~/.dotfiles/nix#JSFramework
#
# Hardware quirks (fwupd, fingerprint reader, kernel params) come from the
# nixos-hardware module wired up in flake.nix.
{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "JSFramework";

  # NixOS release this machine was first installed with. Set once from the
  # installer's generated configuration.nix, then never change it.
  system.stateVersion = "26.11";
}
