{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
