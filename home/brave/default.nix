{ pkgs, ... }:
{
  programs.brave = {
    enable = true;

    commandLineArgs = [
      "--enable-features=BraveVerticalTab"
    ];

    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }   # uBlock Origin
      { id = "nngceckbapebfimnlniiiahkandclblb"; }   # Bitwarden
    ];
  };
}
