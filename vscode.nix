{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    extensions = with pkgs.vscode-extensions; [
      bbenoist.Nix
      vscodevim.vim
    ];

    userSettings = {
      editor = {
        tabSize = 2;
        fontFamily = "JetBrains Mono";
        fontLigatures = true;
      };

      workbench.colorTheme = "GitHub Dark";
    };
  };
}
