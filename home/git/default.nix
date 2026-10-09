{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    git
    github-cli
    (pkgs.writeShellScriptBin "github-auth" ''
      ${lib.getExe pkgs.github-cli} auth login --with-token < /run/secrets/GITHUB_TOKEN
    '')
  ];

  # Authenticate the GitHub CLI with the sops-decrypted token after every
  # rebuild. Non-fatal: if the token is rejected (expired/revoked), log a
  # warning and continue so this can never block a rebuild.
  home.activation.githubAuth = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -r /run/secrets/GITHUB_TOKEN ]; then
      ${lib.getExe pkgs.github-cli} auth login --with-token < /run/secrets/GITHUB_TOKEN \
        || echo "githubAuth: GITHUB_TOKEN was rejected (expired or revoked?) — run 'github-auth' after rotating it" >&2
    fi
  '';

  programs.git = {
    enable = true;

    settings = {
      user.name = "nic";
      user.email = "christoph.niederer99@gmail.com";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };
}
