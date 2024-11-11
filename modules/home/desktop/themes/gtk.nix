{ lib, pkgs, config, osConfig, ... }:
let
  inherit (lib) mkIf boolToNum;
  inherit (osConfig.modules) device;
  cfg = osConfig.modules.style;

  acceptedTypes = [ "laptop" "desktop" "hybrid" "lite" ];
in
{
  config =
    mkIf (builtins.elem device.type acceptedTypes && pkgs.stdenv.isLinux) {
      xdg.systemDirs.data =
        let schema = pkgs.gsettings-desktop-schemas;
        in [ "${schema}/share/gsettings-schemas/${schema.name}" ];

      home = {
        packages = with pkgs;
          [
            glib # gsettings
          ];

        # gtk applications should use xdg specified settings
        sessionVariables.GTK_USE_PORTAL =
          "${toString (boolToNum cfg.gtk.usePortal)}";
      };

      gtk = {
        enable = true;
        font = { inherit (cfg.gtk.font) name size; };

        gtk2 = {
          configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
          extraConfig = ''
            gtk-xft-antialias=1
            gtk-xft-hinting=1
            gtk-xft-hintstyle="hintslight"
            gtk-xft-rgba="rgb"
          '';
        };

        gtk3.extraConfig = {
          # make things look nice
          gtk-application-prefer-dark-theme = true;

          gtk-decoration-layout = "appmenu:none";

          gtk-xft-antialias = 1;
          gtk-xft-hinting = 1;
          gtk-xft-hintstyle = "hintslight";

          # stop annoying sounds
          gtk-enable-event-sounds = 0;
          gtk-enable-input-feedback-sounds = 0;
          gtk-error-bell = 0;

          # config that is not the same as gtk4
          gtk-toolbar-style = "GTK_TOOLBAR_BOTH";
          gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";

          gtk-button-images = 1;
          gtk-menu-images = 1;
        };

        gtk4 = {
          extraConfig = {
            # make things look nice
            gtk-application-prefer-dark-theme = true;

            gtk-decoration-layout = "appmenu:none";

            gtk-xft-antialias = 1;
            gtk-xft-hinting = 1;
            gtk-xft-hintstyle = "hintslight";

            # stop annoying sounds again
            gtk-enable-event-sounds = 0;
            gtk-enable-input-feedback-sounds = 0;
            gtk-error-bell = 0;
          };

          extraCss = ''
            @define-color surface-strongest rgb(10, 10, 10);
            @define-color surface-strong rgb(20, 20, 20);
            @define-color surface-moderate rgb(28, 28, 28);
            @define-color surface-weak rgb(34, 34, 34);
            @define-color surface-weakest rgb(40, 40, 40);

            @define-color white-strongest rgb(255, 255, 255);
            @define-color white-strong rgba(255, 255, 255, 0.87);
            @define-color white-moderate rgba(255, 255, 255, 0.34);
            @define-color white-weak rgba(255, 255, 255, 0.14);
            @define-color white-weakest rgba(255, 255, 255, 0.06);

            @define-color black-strongest rgb(0, 0, 0);
            @define-color black-strong rgba(0, 0, 0, 0.87);
            @define-color black-moderate rgba(0, 0, 0, 0.42);
            @define-color black-weak rgba(0, 0, 0, 0.15);
            @define-color black-weakest rgba(0, 0, 0, 0.06);

            @define-color red-tint rgba(218, 88, 88, 0.6);
            @define-color red-normal rgb(218, 88, 88);
            @define-color red-light rgb(227, 109, 109);
            @define-color orange-tint rgba(237, 148, 84, 0.6);
            @define-color orange-normal rgb(237, 148, 84);
            @define-color orange-light rgb(252, 166, 105);
            @define-color yellow-normal rgb(232, 202, 94);
            @define-color yellow-light rgb(250, 221, 117);
            @define-color green-tint rgba(63, 198, 97, 0.6);
            @define-color green-normal rgb(63, 198, 97);
            @define-color green-light rgb(97, 214, 126);
            @define-color cyan-normal rgb(92, 216, 230);
            @define-color cyan-light rgb(126, 234, 246);
            @define-color blue-normal rgb(73, 126, 233);
            @define-color blue-light rgb(93, 141, 238);
            @define-color purple-normal rgb(113, 84, 242);
            @define-color purple-light rgb(128, 102, 245);
            @define-color pink-normal rgb(213, 108, 195);
            @define-color pink-light rgb(223, 129, 207);

            @define-color accent_color @purple-light;
            @define-color accent_bg_color @purple-normal;
            @define-color accent_fg_color @white-strong;

            @define-color destructive_color @red-light;
            @define-color destructive_bg_color @red-tint;
            @define-color destructive_fg_color @white-strong;

            @define-color success_color @green-light;
            @define-color success_bg_color @green-tint;
            @define-color success_fg_color @white-strong;

            @define-color warning_color @orange-light;
            @define-color warning_bg_color @orange-tint;
            @define-color warning_fg_color @white-strong;

            @define-color error_color @red-light;
            @define-color error_bg_color @red-tint;
            @define-color error_fg_color @white-strong;

            @define-color window_bg_color @surface-strong;
            @define-color window_fg_color @white-strong;

            @define-color view_bg_color @surface-strong;
            @define-color view_fg_color @white-strong;

            @define-color headerbar_bg_color @surface-strongest;
            @define-color headerbar_fg_color @white-strong;
            @define-color headerbar_border_color @surface-moderate;
            @define-color headerbar_backdrop_color @surface-strongest;
            @define-color headerbar_shade_color transparent;

            @define-color card_bg_color @white-weakest;
            @define-color card_fg_color @white-strong;
            @define-color card_shade_color @white-weak;

            @define-color dialog_bg_color @surface-weak;
            @define-color dialog_fg_color @white-strong;

            @define-color popover_bg_color @surface-weakest;
            @define-color popover_fg_color @white-strong;

            @define-color shade_color @black-strongest;
            @define-color scrollbar_outline_color @white-weakest;

            @define-color borders transparent;

            @define-color sidebar_bg_color @surface-strongest;
            @define-color sidebar_fg_color @white-strong;
            @define-color sidebar_backdrop_color @surface-strongest;
            @define-color sidebar_shade_color @surface-strongest;


            /*
            window contents {
                background: @surface-strongest;
                box-shadow: none;
            }
            */

            popover contents, popover arrow {
            	background: @surface-weakest;
            }

            .solid-csd {
            	padding: 0;
            }

            headerbar {
                padding: 0.3em;
                padding-top: calc(0.3em + 3px);
            }
          '';
        };
      };
    };
}
