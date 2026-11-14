{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # J-Link only, pinned so system updates never touch it (see jlink.nix).
    nixpkgs-jlink.url = "github:NixOS/nixpkgs/177d0540942fb205af6993b1d5fa0b57799e09f8";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hyprdynamicmonitors.url = "github:fiffeek/hyprdynamicmonitors";
    hyprdynamicmonitors.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixos-hardware, hyprdynamicmonitors, ... }@inputs:
  let
    system = "x86_64-linux";
    mkHost = name: extraModules: nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs system; };
      modules = [
        hyprdynamicmonitors.nixosModules.default
        ./common.nix
        ./jlink.nix
        ./hosts/${name}
      ] ++ extraModules;
    };
  in
  {
    nixosConfigurations = {
      # Dell XPS 13 7390
      JSLaptop = mkHost "JSLaptop" [ ];

      # Framework Laptop 13 Pro (Intel Core Ultra Series 3)
      JSFramework = mkHost "JSFramework" [
        nixos-hardware.nixosModules.framework-intel-core-ultra-series3
      ];
    };
  };
}
