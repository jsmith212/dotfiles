{
  description = "JSLaptop NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprdynamicmonitors.url = "github:fiffeek/hyprdynamicmonitors";
  };

  outputs = { self, nixpkgs, hyprdynamicmonitors, ... }@inputs:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations."JSLaptop" = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs system; };
      modules = [ 
        hyprdynamicmonitors.nixosModules.default
        ./configuration.nix 
      ];
    };
  };
}
