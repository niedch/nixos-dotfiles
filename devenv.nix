{pkgs, ...}: {
  packages = [pkgs.alejandra pkgs.jq pkgs.mise];

  files."mise.toml".toml = {
    tasks = {
      "update-nix-omarchy-theme" = {
        description = "Update the nix-omarchy-theme flake dependency to its latest commit";
        run = "nix flake update nix-omarchy-theme";
      };

      update = {
        description = "Update all flake inputs";
        run = "nix flake update";
      };

      format = {
        description = "Formats this project";
        run = "nix run nixpkgs#alejandra -- . 2>&1";
      };

      build = {
        description = "Build a NixOS configuration (e.g. laptop, desktop, dobby)";
        usage = ''arg "<host>" help="Host configuration name"'';
        run = "nix build .#nixosConfigurations.\${usage_host?}.config.system.build.toplevel";
      };

      switch = {
        description = "Switch to a NixOS configuration with sudo (e.g. laptop, desktop, dobby)";
        usage = ''arg "<host>" help="Host configuration name"'';
        run = "sudo nixos-rebuild switch --flake .#\${usage_host?}";
      };

      switch-all-hosts = {
        description = "Switch to a NixOS configuration with sudo (e.g. laptop, desktop, dobby)";
        run = ''
        mise build laptop
        mise remote-switch dobby nic@dobby
        mise remote-switch raspberry-pi nic@rpi
        '';
      };

      rebuild = {
        description = "Stage all changes, generate commit message, open editor to commit, and push";
        usage = ''arg "<host>" help="Host configuration name"'';
        run = ''
          git add .
          msg=$(mise run commit-with-gen)
          git commit -e -m "$msg"
          mise run switch ''${usage_host?}
        '';
      };

      "remote-switch" = {
        description = "Remote switch to a NixOS configuration via SSH (e.g. raspberry-pi)";
        usage = ''
          arg "<host>" help="Host configuration name"
          arg "<target>" help="SSH target (user@host)"
        '';
        run = "nixos-rebuild switch --flake .#\${usage_host?} --target-host \${usage_target?} --sudo --ask-sudo-password";
      };

      cleanup = {
        description = "Cleanup old NixOS Derivations";
        run = "sudo nix-collect-garbage -d";
      };

      "commit-with-gen" = {
        description = "Generate a commit message prepended with the next NixOS generation number using Gemini";
        run = ''
          current_gen=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations 2>/dev/null | grep -E '^\s*[0-9]' | tail -1 | awk '{print $1}')
          if [ -z "$current_gen" ]; then
            echo "Could not determine current NixOS generation" >&2
            exit 1
          fi
          next_gen=$((current_gen + 1))
          message=$(mise run commit-message 2>/dev/null)
          echo "generation ''${next_gen}: ''${message}"
        '';
      };

      "commit-message" = {
        description = "Summarize git diff into a commit message using Gemini API";
        run = ''
          diff=$(git diff --cached 2>/dev/null || git diff)
          if [ -z "$diff" ]; then
            echo "No diff found (staged or unstaged)" >&2
            exit 1
          fi
          curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=''${GEMINI_API_KEY}" \
            -H "Content-Type: application/json" \
            -d "$(jq -n --arg diff "$diff" '{
              contents: [{
                parts: [{
                  text: ("Write a concise conventional commit message summarizing the following git diff. Output only the commit message, no markdown formatting or code fences:\n\n" + $diff)
                }]
              }]
            }')" | jq -r '.candidates[0].content.parts[0].text'
        '';
      };
    };
  };

  enterShell = ''
    mise tasks ls
  '';
}
