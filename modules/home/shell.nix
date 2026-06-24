# Fish shell configuration.
{ ... }:
{
  hm.modules.shell = { pkgs, ... }: {
    programs.fish = {
      enable = true;
      interactiveShellInit = "fastfetch --logo small";
      shellInit            = "set -gx NH_FLAKE $HOME/nixos-config-d";
      shellAliases.v       = "nvim";
      functions.vpn = {
        description = "Connect to Microsoft corp VPN (GlobalProtect + sso-mib)";
        body = "vpn-connect";
      };
      functions.nos = {
        description = "Sync config bidirectionally, then switch";
        body = ''
          git -C $NH_FLAKE fetch
          set behind (git -C $NH_FLAKE rev-list HEAD..@{u} --count)
          if test $behind -gt 0
            echo "↓ $behind new commit(s) — pulling"
            git -C $NH_FLAKE pull --rebase
            or return
          end
          git -C $NH_FLAKE diff --quiet HEAD
          or begin
            git -C $NH_FLAKE commit -am "config: update"
            or return
          end
          nh os switch $argv
          or return
          set ahead (git -C $NH_FLAKE rev-list @{u}..HEAD --count)
          if test $ahead -gt 0
            echo "↑ $ahead commit(s) — pushing"
            git -C $NH_FLAKE push
          end
        '';
      };
      functions.nou = {
        description = "Update flake inputs, switch, and push";
        body = ''
          nh os switch -u $argv
          or return
          git -C $NH_FLAKE diff --quiet flake.lock
          and return
          git -C $NH_FLAKE add flake.lock
          and git -C $NH_FLAKE commit -m "flake: update inputs"
          and git -C $NH_FLAKE push
        '';
      };
      functions.y = {
        description = "yazi with cwd handoff";
        body = ''
          set tmp (mktemp -t "yazi-cwd.XXXXXX")
          command yazi $argv --cwd-file="$tmp"
          if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
            builtin cd -- "$cwd"
          end
          command rm -f -- "$tmp"
        '';
      };
      plugins = [
        { name = "tide"; src = pkgs.fishPlugins.tide.src; }
      ];
    };

    programs.yazi = {
      enable = true;
      shellWrapperName = "yy"; # keep "yy"; "y" is already a custom fish function above
      settings = {
        opener = {
          browser = [
            { run = "brave %*";   desc = "Brave";   orphan = true; }
            { run = "firefox %*"; desc = "Firefox"; orphan = true; }
          ];
        };
        open.rules = [
          { mime = "text/html";             use = "browser"; }
          { mime = "application/xhtml+xml"; use = "browser"; }
        ];
      };
    };
  };
}
