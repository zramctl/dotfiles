import { Astal, Gtk, App, Gdk } from "astal/gtk3";
import { exec, timeout, Variable } from "astal";
import Hyprland from "gi://AstalHyprland";
import { style } from "lib/style";
import css from "inline:./launcher.scss";
import Apps from "gi://AstalApps?version=0.1";
import { ListBox, ListBoxRow } from "widget/utils";

const hyprland = Hyprland.get_default();
const apps = new Apps.Apps({
  nameMultiplier: 2,
  entryMultiplier: 0,
  executableMultiplier: 2,
});

export function Launcher() {
  style(css);

  const appList = apps.fuzzy_query("");

  const search = Variable(false);

  function Entry() {
    return (
      <entry
        isFocus
        className={"flat"}
        halign={Gtk.Align.FILL}
        hexpand
        primaryIconName={"preferences-system-search-symbolic"}
        placeholder_text={"Search..."}
        onChanged={(self) => {
          const text = self.get_text();
          filterList(text);
        }}
        onActivate={(self) => {
          const selectedApp = appButtons.find((appButton) => appButton.visible);
          // Launch the selected app
          selectedApp?.activate();
          self.text = "";
        }}
        setup={(self) => {
          self.hook(App, "window-toggled", (self) => {
            // Retakes focus when lauching app for next search
            self.grab_focus();
            // reset text on app launch
            if (App.get_window("launcher")?.is_visible()) self.text = "";
          });

          search.subscribe((value) => {
            if (value == true) self.grab_focus();
          });
        }}
      />
    );
  }

  function AppButton({ app }: { app: Apps.Application }) {
    return (
      <ListBoxRow
        tooltipText={app.name}
        className={"launcher-item"}
        name={app.name}
        onButtonReleaseEvent={(self) => {
          app.launch();
          App.toggle_window("launcher");
          if (self.is_selected()) self.set_state(Gtk.StateType.NORMAL);
        }}
        onActivate={(self) => {
          app.launch();
          App.toggle_window("launcher");
          if (self.is_selected()) self.set_state(Gtk.StateType.NORMAL);
        }}
        onFocusOutEvent={(self) => {
          self.set_state(Gtk.StateType.NORMAL);
        }}
      >
        <box hexpand>
          <icon css="font-size: 24px;" icon={app.get_icon_name() || ""} />
          <label label={`  ${app.get_name()}`} />
        </box>
      </ListBoxRow>
    );
  }

  const appButtons = appList.map((app) => {
    return <AppButton app={app} />;
  });

  function filterList(text: string) {
    appButtons.forEach((appButton) => {
      const appName = appButton.name.toLowerCase();
      const isVisible = appName.includes(text.toLowerCase());
      appButton.set_visible(isVisible);
    });
  }

  return (
    <window
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      keymode={Astal.Keymode.EXCLUSIVE}
      name={`launcher`}
      heightRequest={512}
      widthRequest={512}
      layer={Astal.Layer.TOP}
      className={"launcher"}
      visible={false}
      monitor={hyprland.get_focused_monitor().id}
      application={App}
      onKeyPressEvent={(window, event) => {
        const keycode = event.get_keycode()[1];

        if (keycode == 9) window.hide();
        else if (
          keycode !== 111 &&
          keycode !== 113 &&
          keycode !== 116 &&
          keycode !== 114
        )
          search.set(true);
        else if (
          keycode === 111 ||
          keycode === 113 ||
          keycode == 116 ||
          keycode == 114
        )
          search.set(false);

        if (search.get() == true && keycode == 116) search.set(false);
      }}
      setup={(self) => {
        // Moves to screen with mouse focus
        self.hook(hyprland, "notify", (self) => {
          if (self.monitor != hyprland.get_focused_monitor().id)
            self.monitor = hyprland.get_focused_monitor().id;
        });
      }}
    >
      <box className={"launcher-container"} vertical >
        <Entry />
        <scrollable vexpand className="scrollable" marginTop={2}>
          <ListBox
            className={"launcher-items"}
            valign={Gtk.Align.FILL}
            halign={Gtk.Align.FILL}
            setup={(self) =>
              search.subscribe((v) => {
                if (v == false) {
                  self.get_children()[0].grab_focus();
                }
              })
            }
          >
            {appButtons}
          </ListBox>
        </scrollable>
      </box>
    </window>
  );
}
