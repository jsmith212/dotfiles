# Everything shared by all machines. Per-machine settings live in hosts/<name>/.
{ config, lib, pkgs, inputs ? {}, ... }:

{
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Add a swap file
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 4*1024;
  } ];

  # Enable networking
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";
  environment.etc."timezone".text = config.time.timeZone;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable greetd with autologin for hyprland
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "uwsm start hyprland-uwsm.desktop";
        user = "smitj";
      };
      default_session = initial_session;
    };
  };

  # Enable Hyprland window manager
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # ydotool for input
  programs.ydotool.enable = true;
  boot.kernelModules = [ "uinput" ];
  services.gnome.at-spi2-core.enable = true;

  # resolved to play nice with Tailscale DNS
  services.resolved.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # 3D Mouse support
  hardware.spacenavd.enable = true;

  # Compat fixes for paths
  services.envfs.enable = true; # Workaround for /bin/bash shebangs
  programs.nix-ld.enable = true; # Workaround for ld
  programs.nix-ld.libraries = with pkgs; [
    gcc_latest.cc.lib  # libstdc++.so.6
    zlib
    openssl
    curl
    libGL
    glib
    ncurses
  ];
  environment.sessionVariables.LD_LIBRARY_PATH = [
    "/run/current-system/sw/share/nix-ld/lib"                                                   
  ];
  environment.extraInit = ''
    export PATH="$PATH:/usr/bin:/bin"
  '';

  # Shell
  programs.bash.enable = true;

  programs.zsh = {
    enable = true;
    shellAliases = {
      nrs = "nixos-rebuild switch --sudo --flake $HOME/.dotfiles/nix#$(hostname)";
      ngc = "sudo nix-collect-garbage -d";
      nup = "nix flake update --flake $HOME/.dotfiles/nix && nixos-rebuild boot --sudo --flake $HOME/.dotfiles/nix#$(hostname)";
      fpu = "flatpak update -y";
      update = "ngc && nup && fpu";
    };
  };
  users.defaultUserShell = pkgs.zsh;

  # Docker
  virtualisation.docker.enable = true;

  # AppImage support (fuck you OpenCloud)
  programs.appimage = {
    enable = true;
    binfmt = true;
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.smitj = {
    isNormalUser = true;
    description = "Jackson Smith";
    extraGroups = [ "networkmanager" "wheel" "docker" "dialout" "ydotool" ];
    packages = with pkgs; [
      casync
      cbonsai
      dig
      gh
      google-cloud-sdk
      picocom
      pwgen
      rauc
      segger-jlink
      squashfsTools
      steam-devices-udev-rules
    ];
  };

  # Tailscale
  services.tailscale = {
    # Enable tailscale at startup
    enable = true;
    useRoutingFeatures = "client";

    # If you would like to use a preauthorized key, set
    # authKeyFile = "/run/secrets/tailscale_key";
    # Note: maximum expire time is 90 days
  };

  # Fix STLink permissions issue
  services.udev.packages = [ pkgs.stlink ];

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Git config
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
    config = {
      credential.helper = "libsecret";
      user.name = "jsmith212";
      user.email = "29954021+jsmith212@users.noreply.github.com";
      init.defaultBranch = "main";
      push = { autoSetupRemote = true; };
      pull.rebase = false;
      core.excludesFile = "${pkgs.writeText "gitignore-global" ''
        **/.claude/settings.local.json
      ''}";
    };
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = 34560000;
      max-cache-ttl = 34560000;
    };
  };

  programs.xfconf.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [ thunar-archive-plugin thunar-volman ];
  };

  # Fuck you JLink.
  nixpkgs.config.permittedInsecurePackages = [
    "segger-jlink-qt4-970"
  ];
  # nixpkgs.config.allowInsecurePredicate = pkg: builtins.match "segger-jlink-qt4-.*" (lib.getName pkg) != null;
  # Automatically authorize all Dell WD19TB docks.
  nixpkgs.config.segger-jlink.acceptLicense = true;
  services.udev.extraRules = ''
    ATTR{idVendor}=="1366", MODE="0666"
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6014", MODE="0666", GROUP="dialout"
    ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{vendor}=="0xd4", ATTR{device}=="0xb070", ATTR{authorized}=="0", ATTR{authorized}="1"
    SUBSYSTEM=="usb", ATTR{idVendor}=="21a9", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0925", ATTR{idProduct}=="3881", MODE="0666"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="0487", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="5487", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="0413", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="5413", ATTR{power/control}="on"
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    btop
    cifs-utils
    cmake
    docker-compose
    docker-credential-helpers
    fastfetch
    file
    fzf
    gcc
    gfortran
    glib
    gnumake
    gnupg
    jq
    libsecret
    nfs-utils
    ninja
    openblas
    pass
    pinentry-curses
    python3
    rar
    samba
    smbclient-ng
    tmux
    unrar
    unzip
    vim
    vscode-fhs
    wget
    wtype
    yazi
    yq
    zip

    # FPGA
    icestorm
    nextpnr
    #surfer
    yosys

    # SpaceNav
    spnavcfg

    # Hyprland
    bluetui
    brightnessctl
    grimblast
    hyprcursor
    hypridle
    hyprlock
    hyprpicker
    hyprpolkitagent
    hyprsunset
    imagemagick
    impala
    imv
    libnotify
    matugen
    nwg-look
    pamixer
    playerctl
    pulsemixer
    rofi
    swaynotificationcenter
    swayosd
    awww
    tumbler
    waybar
    wf-recorder
    wireplumber
    wl-clipboard

    # Not in nixpkgs yet
    inputs.hyprdynamicmonitors.packages.${stdenv.hostPlatform.system}.default
  ];
  
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    nerd-fonts.fira-code
    meslo-lgs-nf
    font-awesome
    fira-code
  ];

  # Default applications
  xdg = {
    mime = {
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "image/*" = "imv.desktop";
        "application/pdf" = "firefox.desktop";
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.acpid.enable = true;
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  services.upower.enable = true;
  services.pcscd.enable = true;
  services.tlp.enable = true;
  services.tlp.pd.enable = true;
  services.passSecretService.enable = true;
  services.hardware.bolt.enable = true;
  services.hyprdynamicmonitors = {
    enable = true;
    mode = "user";
    extraFlags = [ "--enable-lid-events" ];
    configPath = "/home/smitj/.config/hyprdynamicmonitors/config.toml";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

}
