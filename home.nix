{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

    programs = {
    git = {
      enable = true;
      settings = {
        commit = {
          verbose = true;
        };
      user.name = "João Thallis";
      user.email = "joaothallis.developer@gmail.com";
    };
     ignores = [
        ".direnv"
        ".envrc"
        "**/.claude/settings.local.json"
      ];
    };
    gh = {
      enable = true;
    };
     direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
        bash.enable = true; 
    tmux = {enable= true; escapeTime= 10; focusEvents=true; terminal="screen-256color";
          extraConfig = ''
          set-option -a terminal-features 'xterm-256color:RGB'
	  '';
    };
    neovim = {enable= true;defaultEditor=true;
      extraLuaConfig = ''
        local o = vim.o

        o.clipboard = "unnamedplus"
      '';
    };
  };


  home.packages = [pkgs.nodePackages.nodejs pkgs.nixfmt-rfc-style];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
