/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.Application : Gtk.Application {
    public Application () {
        Object (
            application_id: Consts.PROJECT_NAME,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    public override void startup () {
        base.startup ();
        setup_localization ();
        add_icon_resources ();
        foce_elementary_style ();
        link_dark_mode_settings ();
    }

    public override void activate () {
        if (active_window == null) {
            var main_window = new MainWindow (this);
            link_to_gsettings (main_window);
        }

        active_window.present_with_time (Gdk.CURRENT_TIME);
    }

    private void setup_localization () {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Consts.PROJECT_NAME, Consts.LOCALEDIR);
        Intl.bind_textdomain_codeset (Consts.PROJECT_NAME, "UTF-8");
        Intl.textdomain (Consts.PROJECT_NAME);
    }

    private void add_icon_resources () {
        Gtk.IconTheme.get_for_display (Gdk.Display.get_default ())
            .add_resource_path (Consts.RESOURCE_BASE);
    }

    private void foce_elementary_style () {
        var settings = Gtk.Settings.get_default ();
        if (!settings.gtk_theme_name.has_prefix ("io.elementary.stylesheet")) {
            settings.gtk_theme_name = "io.elementary.stylesheet.blueberry";
        }

        if (settings.gtk_icon_theme_name != "elementary") {
            settings.gtk_icon_theme_name = "elementary";
        }
    }

    private void link_dark_mode_settings () {
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        var dark_mode = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        gtk_settings.gtk_application_prefer_dark_theme = dark_mode;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            var dm = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            gtk_settings.gtk_application_prefer_dark_theme = dm;
        });
    }

    private void link_to_gsettings (Gtk.ApplicationWindow window) {
        /*
        * This is very finicky. Bind size after present else set_titlebar gives us bad sizes
        * Set maximize after height/width else window is min size on unmaximize
        * Bind maximize as SET else get get bad sizes
        */
        var settings = new Settings (Consts.PROJECT_NAME);
        settings.bind ("window-height", window, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", window, "default-width", SettingsBindFlags.DEFAULT);

        if (settings.get_boolean ("window-maximized")) {
            window.maximize ();
        }

        settings.bind ("window-maximized", window, "maximized", SettingsBindFlags.SET);
    }
}
