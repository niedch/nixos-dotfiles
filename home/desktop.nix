{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./chromium
    ./ghostty
    ./hyprland
    ./media
    ./menu
    ./waybar
    ./themes
    ./walker
    ./tmux
    ./mux-session
    ./nvim
    ./zsh
    ./mise
    ./opencode
    ./git
    ./ssh
    ./obsidian
  ];

  home.username = "nic";
  home.homeDirectory = "/home/nic";
  home.stateVersion = "26.05";

  home.nvim.lsp.enable = true;
  programs.home-manager.enable = true;

  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # documents
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "application/epub+zip" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "image/svg+xml" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "image/tiff" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "application/vnd.comicbook+zip" = "org.pwmt.zathura-cb.desktop";
      "image/vnd.djvu" = "org.pwmt.zathura-djvu.desktop";
    };
  };

  programs.btop = {
    enable = true;
    package = pkgs.btop.override {cudaSupport = true;};
    settings = {
      color_theme = "btop";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.keyFile = "/home/nic/.config/sops/age/keys.txt";

  home.packages = with pkgs;
    [
      docker-compose
      lazydocker
      localsend
      nixfmt
      bluetui
      wiremix
      inputs.wlctl.packages.${pkgs.stdenv.hostPlatform.system}.default
      fd
      unzip
      jetbrains.idea
      zathura
      weathr
      signal-desktop
    ]
    ++ [
      # AWT dependency for the eddi project
      libX11
      libxext
      libxrender
      libxi
      libxtst
    ]
    ++ [
      # Programming languages
      nodejs
      python3
      gnumake
    ];

  xdg.configFile."comd/config.toml".text = ''
    [global]
    system_prompt = """
    You are a helper Bot for Bash! Only responded with a single line of bash. Only bash! No Backticks!
    """
    model = "gemini-2.5-flash"
  '';
}
