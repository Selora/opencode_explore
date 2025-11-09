{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.system;
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
  has_pyproject = builtins.pathExists ./pyproject.toml;
  has_package_json = builtins.pathExists ./package.json;

  basePkgs = with pkgs; [
    uv
    jq
    yq
  ];
  devExtras = with pkgs; [
    git
    just
    pre-commit
  ];
  devLSPs = with pkgs; [
    nixfmt-rfc-style
    nil
    luarocks-nix
  ];
  #agentPkgs = with pkgs; [ coreutils gnugrep ] ++ [ pkgs-unstable.codex ];
  agentPkgs = [
    # pkgs-unstable.codex
  ];

  # Common enter shell steps used by all profiles (small, self-contained)
  enterShellCommon = ''
    pre-commit install --hook-type pre-commit --hook-type pre-push >/dev/null 2>&1 || true

    # Initialize agent worktree (delegated to .scripts/init_agent.sh)
    bash .scripts/init_agent.sh || true

    # Ensure project name is set (delegated to script)
    if [ -f .project_name ]; then
      echo ".project_name exists; skipping project initialization."
    else
      bash .scripts/ensure_project_name.sh
    fi
  '';
 in
{
  # base (always)
  packages = basePkgs;

  languages.python = {
    enable = true;
    package = pkgs.python313;
    venv.enable = true;
  };

  languages.rust = {
    enable = true;
    channel = "stable";
    components = [
      "rustc"
      "cargo"
      "clippy"
      "rustfmt"
    ];
  };

  # scripts moved to .scripts/ (see .scripts/init_agent.sh and .scripts/ensure_project_name.sh)

  profiles = {
    dev.module = {
      packages = devExtras ++ devLSPs;

       # Enable Python uv sync when pyproject.toml exists
       languages.python.uv = lib.mkIf has_pyproject {
         enable = true;
         sync.enable = true;
         sync.allGroups = true;
       };

       # Enable Bun in dev when package.json exists at project root
       languages.javascript = lib.mkIf has_package_json {
         enable = true;
         bun.enable = true;
         bun.install.enable = true;
       };
      env = {
        # VAR = myvar
      };

      enterShell = enterShellCommon;
    };

    agent = {
      extends = [ "dev" ];
      module = {
        packages = agentPkgs;

        enterShell = ''${enterShellCommon}
          # per-worktree git guardrails
          git config extensions.worktreeConfig true || true
          git config --worktree credential.helper ""  || true
          git config --worktree remote.origin.pushurl DISABLED || true

          echo "[agent] Auth stripped, pushes disabled. Ready."
        '';
        scripts.init-agents = {
          description = "Initialize OpenSpec + OpenCode environment";
          exec = ''
            openspec init --tools opencode
            opencode auth login
            opencode /init
          '';
        };
      };
    };
  };
}
