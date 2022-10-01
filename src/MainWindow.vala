/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.MainWindow : Gtk.ApplicationWindow {

    public MainWindow (Application application) {
        Object (
            application: application,
            title: _("Sous-chef")
        );
    }

    construct {
        hide_default_titlebar ();

        var library = new LibraryView ();
        var recipe = create_recipe_view ();
        child = create_paned_for (library, recipe);

        bind_window_state_to_settings ();
    }

    private void bind_window_state_to_settings () {
        var settings = new Settings (Consts.PROJECT_NAME);
        settings.bind ("window-height", this, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", this, "default-width", SettingsBindFlags.DEFAULT);
        settings.bind ("window-maximized", this, "maximized", SettingsBindFlags.DEFAULT);
    }

    private Gtk.Widget create_recipe_view () {
        var end_window_controls = new Gtk.WindowControls (Gtk.PackType.END) {
            halign = Gtk.Align.END,
            hexpand = true
        };

        var recipe_heder = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        recipe_heder.add_css_class ("titlebar");
        recipe_heder.add_css_class (Granite.STYLE_CLASS_FLAT);
        recipe_heder.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);
        recipe_heder.append (end_window_controls);

        var recipe_heder_handle = new Gtk.WindowHandle () {
            child = recipe_heder
        };

        var recipe_text = new Gtk.TextView () {
            hexpand = true,
            vexpand = true
        };

        var recipe = new Gtk.Grid ();
        recipe.add_css_class (Granite.STYLE_CLASS_VIEW);
        recipe.attach (recipe_heder_handle, 0, 0);
        recipe.attach (recipe_text, 0, 1);

        return recipe;
    }

    private Gtk.Widget create_paned_for (Gtk.Widget start, Gtk.Widget end) {
        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            start_child = start,
            resize_start_child = false,
            shrink_start_child = true,
            end_child = end,
            resize_end_child = true,
            shrink_end_child = false
        };

        var settings = new Settings (Consts.PROJECT_NAME);
        settings.bind ("pane-position", paned, "position", SettingsBindFlags.DEFAULT);

        return paned;
    }

    private void hide_default_titlebar () {
        set_titlebar (new Gtk.Grid () {
            visible = false
        });
    }
}
