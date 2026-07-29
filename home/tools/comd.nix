{ inputs, pkgs, ... }: {
  home.packages = [
    inputs.comd.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  xdg.configFile."comd/config.toml".text = ''
    [global]
    system_prompt = """
    You are a helper Bot for Bash! Only responded with a single line of bash. Only bash! No Backticks!
    """
    model = "gemini-2.5-flash"
  '';
}
