{ pkgs, config, lib, options, ... }: {
  home.packages = let unstable = import <nixos-unstable> { };
  in with pkgs; [
    wofi
    swaylock-effects
    swayidle
    swaybg
    grim
    slurp
    wl-clipboard
    wdisplays
    unstable.wlsunset
  ];

  wayland.windowManager.sway = {
    enable = true;

    wrapperFeatures.gtk = true;
    wrapperFeatures.base = true;
    systemdIntegration = false;

    config = rec {
      # Set keybindings and the modifier key
      modifier = "Mod1";
      keybindings = lib.mkOptionDefault {
        "XF86AudioMute" = "exec amixer set Master toggle";
        "XF86AudioLowerVolume" = "exec amixer set Master 4%-";
        "XF86AudioRaiseVolume" = "exec amixer set Master 4%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";
        "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -modi drun -show drun";
        "${modifier}+Shift+d" = "exec ${pkgs.rofi}/bin/rofi -show window";
        "${modifier}+Shift+x" = ''
          exec swaylock \
                        --screenshots \
                        --effect-blur 5x7 \
                        --effect-vignette 0.5:0.5 \
                        --ring-color 242424 \
                        --key-hl-color 696969 \
                        --fade-in 0.2 \
                        --line-color 00000000 \
                        --inside-color 00000088 \
                        --separator-color 00000000 \
                        --clock \
                        --indicator'';
        "${modifier}+Shift+s" = ''
          exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy'';
        "${modifier}+m" = "exec wdisplays";
      };

      # Set default terminal to alacritty
      terminal = "${pkgs.alacritty}/bin/alacritty";

      # Set up the gaps
      gaps = {
        inner = 10;
        outer = 10;
      };

      # Start waybar
      bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];

      # Set up the keyboard layouts
      input = {
        "*" = {
          xkb_layout = "us";
          xkb_variant = "intl";
        };
      };

      startup = [{ command = "swaybg -i /home/hl/.nixos.png -m fill"; }];
    };
  };

  # Sets up the waybar (equivalent to polybar)
  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "bottom";
      height = 30;
      modules-left = [ "sway/workspaces" "tray" "custom/performancemode" ];
      modules-center = [ ];
      modules-right = [
        "network"
        "cpu"
        "memory"
        "disk"
        "battery"
        "battery#bat2"
        "pulseaudio"
        "clock"
      ];
      modules = {
        "sway/workspaces" = {
          all-outputs = false;
          disable-scroll = true;
          format = "{icon} {name}";
          format-icons = {
            "1:www" = ""; # Icon: firefox-browser
            "8:mail" = ""; # Icon: mail
            "9:comm" = ""; # Icon: code
            "urgent" = "";
            "focused" = "";
            "default" = "";
          };
        };

        cpu = {
          format = " {usage}%";
          interval = 1;
          tooltip = false;
        };

        battery = {
          bat = "BAT2";
          interval = 30;
          states = {
            warning = 30;
            critical = 15;
          };
          format = " {capacity}%";
          format-charging = " {capacity}% ";
          format-plugged = " {capacity}% ";
          tooltip = true;
        };

        "battery#bat2" = {
          bat = "BAT1";
          interval = 30;
          states = {
            warning = 30;
            critical = 15;
          };
          format = " {capacity}%";
          format-charging = " {capacity}% ";
          format-plugged = " {capacity}% ";
          tooltip = true;
        };

        tray = {
          spacing = 5;
          icon-size = 14;
          tooltip = false;
        };

        pulseaudio = {
          tooltip = false;
          on-click = "pulsemixer";
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon}";
          format-muted = "";
          format-icons = {
            headphones = "";
            handsfree = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" ];
          };
        };

        clock = {
          format = " {:%d.%m.%Y %T}";
          interval = 5;
          tooltip = false;
        };

        disk = {
          interval = 180;
          format = " {free}";
          path = "/";
        };

        memory = {
          interval = 30;
          format = " {used:0.1f} GiB";
          tooltip = false;
        };

        network = {
          tooltip-format-wifi = " {essid} {ipaddr} at {signalStrength}%";
          format-wifi = " {essid}";
          format-ethernet = " {ipaddr}/{cidr}";
          format-disconnected = "";
          on-click = "nmtui";
        };
      };
    }];

    style = ''
      @keyframes blink-warning {
        70% {
          color: #FBFFFE;
        }
        to {
          color: #FBFFFE;
          background-color: #E6AF2E;
        }
      }
      @keyframes blink-critical {
        70% {
          color: #FBFFFE;
        }
        to {
          color: #FBFFFE;
          background-color: #A3320B;
        }
      }
      * {
        border: none;
        border-radius: 0;
        min-height: 0;
        margin: 0;
        padding: 0;
      }
      #waybar {
        background: #001514;
        font-family: sans-serif;
        font-size: 13px;
        color: #FBFFFE;
      }
      #battery,
      #clock,
      #cpu,
      #custom-keyboard-layout,
      #memory,
      #mode,
      #network,
      #pulseaudio,
      #temperature,
      #disk,
      #custom-performancemode,
      #tray {
        padding-left: 10px;
        padding-right: 10px;
      }
      #battery, battery.bat2 {
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
      #battery.warning, battery.bat2.warning {
        color: #E6AF2E;
      }
      #battery.critical, battery.bat2.critical {
        color: #A3320B;
      }
      #battery.warning.discharging, battery.bat2.warning.discharging {
        animation-name: blink-warning;
        animation-duration: 3s;
      }
      #battery.critical.discharging, battery.bat2.critical.discharging {
        animation-name: blink-critical;
        animation-duration: 2s;
      }
      #clock {
        font-weight: bold;
      }
      #cpu {
        /* No styles */
      }
      #cpu.warning {
        color: #E6AF2E;
      }
      #cpu.critical {
        color: #A3320B;
      }
      #memory {
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
      #memory.warning {
        color: #E6AF2E;
      }
      #memory.critical {
        color: #A3320B;
        animation-name: blink-critical;
        animation-duration: 2s;
      }
      #network.disconnected {
        color: #E6AF2E;
      }
      #workspaces button {
        border-top: 2px solid transparent;
        /* To compensate for the top border and still have vertical centering */
        padding-bottom: 2px;
        padding-left: 10px;
        padding-right: 10px;
        color: #888888;
      }
      #workspaces button.focused {
        border-color: #4c7899;
        color: #FBFFFE;
        background-color: #285577;
      }
      #workspaces button.urgent {
        border-color: #c9545d;
        color: #c9545d;
      }
    '';
  };
}
