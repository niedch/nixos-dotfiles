{ config, ... }:

{
  sops.defaultSopsFile = ./../../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets = {
    mock_secret = {};
    example_api_key = {};
    OPENCODE_API_KEY = {
      owner = "nic";
      group = "users";
      mode = "0440";
    };
  };
}
