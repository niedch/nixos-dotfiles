{ config, pkgs, ... }:

{
    home.packages = with pkgs; [
        fzf
    ];

    programs.zsh = {
        enable = true;
        oh-my-zsh = {
            enable = true;
            theme = "robbyrussell";
            plugins = [
                "git"
            ];
        };
        autosuggestion.enable = true;
        envExtra = ''
            export MANPATH="/usr/local/man:$MANPATH"
            export LANG=en_US.UTF-8
            if [[ -n $SSH_CONNECTION ]]; then
                export EDITOR='vim'
            else
                export EDITOR='nvim'
            fi
            export JDTLS_JVM_ARGS="-javaagent:$HOME/.config/nvim/lib/lombok.jar"
            export DISABLE_MAGIC_FUNCTIONS="true"
            export DISABLE_AUTO_TITLE="true"
            export DISABLE_UNTRACKED_FILES_DIRTY="true"
            export OPENCODE_API_KEY=$(cat /run/secrets/OPENCODE_API_KEY)
            export GEMINI_API_KEY=$(cat /run/secrets/GEMINI_API_KEY)
            export GOOGLE_GENERATIVE_AI_API_KEY=$(cat /run/secrets/GOOGLE_GENERATIVE_AI_API_KEY)
            export GITHUB_ENTERPRISE_API_KEY=$(cat /run/secrets/GITHUB_ENTERPRISE_API_KEY)
            export OPENCODE_GO=$(cat /run/secrets/OPENCODE_GO)
        '';
        initContent = ''
            source $HOME/.config/zsh/homes.sh
            for f in $HOME/.config/zsh/*.sh; do
                name=$(basename "$f")
                [[ $name == "install.sh" || $name == "ohmyzsh.sh" ]] && continue
                source "$f"
            done
            source <(fzf --zsh)
        '';
    };

    xdg.configFile."zsh".source = ./zsh-config;
}
