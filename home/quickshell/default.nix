{pkgs, ...}: {
  home.packages = [
    pkgs.cava
    (import ./package.nix {inherit pkgs;})
    (pkgs.writeShellScriptBin "quickshell-reload-theme" ''
      QSID=$(${pkgs.quickshell}/bin/quickshell list --all 2>/dev/null | awk '/^Instance / {print $2; exit}')
      if [ -n "$QSID" ]; then
        ${pkgs.quickshell}/bin/quickshell ipc -i "$QSID" call theme-reload reload >/dev/null 2>&1 || true
      fi
    '')
  ];
}
