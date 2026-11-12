# Dell XPS 13 7390
{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "JSLaptop";

  # Fix lid switch
  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=0"
    "button.lid_init_state=open"
  ];

  # NixOS release this machine was first installed with. Do not change.
  system.stateVersion = "25.11";
}
