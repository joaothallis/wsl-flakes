{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
  };

  outputs =
    inputs@{
      nixpkgs,
      nixos-wsl,
      home-manager,
      nix-ai-tools,
      ...
    }:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixos-wsl.nixosModules.default
            home-manager.nixosModules.home-manager
            ({ pkgs, ... }: {
              system.stateVersion = "25.05";
              wsl.enable = true;

              environment.variables = {
                EDITOR = "vim";
              };

	      environment.systemPackages = with inputs.nix-ai-tools.packages.${pkgs.system}; [gemini-cli];

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nixos = ./home.nix;
            })
          ];
        };
      };
    };
}
