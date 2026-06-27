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
        description = "Manage Microsoft corp VPN (up/down)";
        body = ''
          switch $argv[1]
            case up
              vpn-connect
            case down
              nmcli connection down MSFT-CorpVPN
            case '*'
              echo "Usage: vpn [up|down]"
          end
        '';
      };
      functions.nos = {
        description = "NixOS switch — local or remote via deploy-rs";
        body = ''
          switch (count $argv)
            case 0
              # Local rebuild
              nh os switch $NH_FLAKE
              # Check if local reboot is needed
              if test (readlink /run/current-system) != (readlink /run/booted-system)
                echo "⚠️  Reboot needed (kernel or system changed)"
              end
            case '*'
              # Remote deploy via deploy-rs
              for target in $argv
                switch $target
                  case all
                    deploy --skip-checks $NH_FLAKE
                  case '*'
                    deploy --skip-checks $NH_FLAKE"#$target"
                end
                # Check if remote reboot is needed
                if test $status -eq 0
                  set -l host ""
                  switch $target
                    case enix
                      set host "192.168.1.34"
                    case onix
                      set host "192.168.1.53"
                    case inix
                      set host "localhost"
                  end
                  if test -n "$host"
                    set -l result (ssh kskvarci@$host 'test "$(readlink /run/current-system)" != "$(readlink /run/booted-system)" && echo reboot' 2>/dev/null)
                    if test "$result" = "reboot"
                      echo "⚠️  $target: Reboot needed (kernel or system changed)"
                    else
                      echo "✅ $target: No reboot needed"
                    end
                  end
                end
              end
          end
        '';
      };
      functions.nou = {
        description = "Update flake inputs and switch locally";
        body = ''
          nh os switch -u $NH_FLAKE $argv
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
