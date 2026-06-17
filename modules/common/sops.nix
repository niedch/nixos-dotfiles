{config, ...}: {
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

    rclone-config = {
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };
}
