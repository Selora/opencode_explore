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

  basePkgs = with pkgs; [
    opentofu
    uv
    jq
    yq
  ];
  devExtras = with pkgs; [
    git
    just
    pre-commit
    redli
  ];
  devLSPs = with pkgs; [
    tofu-ls
    nixfmt-rfc-style
    nil
    luarocks-nix
  ];
  #agentPkgs = with pkgs; [ coreutils gnugrep ] ++ [ pkgs-unstable.codex ];
  agentPkgs = [
    # pkgs-unstable.codex
  ];
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

  scripts.terraform.exec = ''tofu "$@"'';

  profiles = {
    dev.module = {
      packages = devExtras ++ devLSPs;

      languages.python.uv.enable = true;
      languages.python.uv.sync.enable = true;
      languages.python.uv.sync.allGroups = true;
      env = {
        ANSIBLE_LOCAL_TEMP = "${config.devenv.root}/Artifacts/Ansible/.ansible_local_tmp";
        ANSIBLE_REMOTE_TMP = "/tmp/.ansible_remote_tmp";
      };

      enterShell = ''
        mkdir -p ${config.devenv.root}/Artifacts/Ansible/.ansible_local_tmp
        pre-commit install --hook-type pre-commit --hook-type pre-push >/dev/null 2>&1 || true
      '';
    };

    agent = {
      extends = [ "dev" ];
      module = {
        packages = agentPkgs;

        # JS for opencode & openspec
        languages.javascript = {
          enable = true;
          bun.enable = true;
          bun.install.enable = true;
        };

        enterShell = ''
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
