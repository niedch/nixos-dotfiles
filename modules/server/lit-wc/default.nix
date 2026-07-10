{ config, pkgs, inputs, ... }: {
  imports = [ inputs.lit-wc.nixosModules.default ];

  services.lit-wc = {
    enable = true;
    package = inputs.lit-wc.packages.${pkgs.system}.default;
    geminiApiKeyFile = config.sops.secrets.GEMINI_API_KEY.path;
    openFirewall = true;
  };
}
