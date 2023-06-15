/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.Application : Gtk.Application {

    public DatabaseService db_service { get; construct; }
    public RecipesService recipes_service { get; construct; }
    public ConverterService converter_service { get; construct; }

    public Application () {
        var db_service = new DatabaseService ();
        var recipes_service = new RecipesService (db_service);
        var converter_service = new ConverterService (
            db_service,
            recipes_service
        );

        Object (
            application_id: Consts.PROJECT_NAME,
            flags: ApplicationFlags.FLAGS_NONE,
            db_service: db_service,
            recipes_service: recipes_service,
            converter_service: converter_service
        );
    }

    public override void startup () {
        base.startup ();
        setup_localization ();
        add_icon_resources ();
        foce_elementary_style ();
        load_custom_app_style ();
        link_dark_mode_settings ();
        db_service.init.begin ();
    }

    public override void activate () {
        if (active_window != null) {
            active_window.present_with_time (Gdk.CURRENT_TIME);
            return;
        }

        var main_window = new MainWindow (this);
        main_window.present ();
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

    private void load_custom_app_style () {
        var provider = new Gtk.CssProvider ();
        var resource_path = "/" + Consts.RESOURCE_BASE + "/Application.css";
        provider.load_from_resource (resource_path);
        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
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
}
