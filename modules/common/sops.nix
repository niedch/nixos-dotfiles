{config, ...}: {
  # Add a secret:
  #   $ nix shell nixpkgs#sops -c bash -c 'cd /home/nic/Projects/nixos-dotfiles && sops set secrets/secrets.yaml "[\"<name>\"]" "$(jq -Rs . < <file>)"'
  sops.defaultSopsFile = ./../../secrets/secrets.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  sops.secrets = {
    GEMINI_API_KEY = {
      owner = "nic";
      group = "users";
      mode = "0440";
    };

    GITHUB_TOKEN = {
      owner = "nic";
      group = "users";
      mode = "0440";
    };

    GOOGLE_GENERATIVE_AI_API_KEY = {
      owner = "nic";
      group = "users";
      mode = "0440";
    };

    OPENCODE_GO = {
      owner = "nic";
      group = "users";
      mode = "0440";
    };

    NPM_TOKEN = {
      owner = "nic";
      group = "users";
      mode = "0440";
    };

    rclone-config = {
      owner = "root";
      group = "root";
      mode = "0400";
    };

    id_ed25519 = {
      owner = "nic";
      group = "users";
      mode = "0600";
    };

    id_ed25519_pub = {
      owner = "nic";
      group = "users";
      mode = "0644";
    };

    harmonia-secret = {
      owner = "root";
      group = "root";
      mode = "0400";
    };

    harmonia-pub = {
      owner = "root";
      group = "root";
      mode = "0444";
    };
  };
}
