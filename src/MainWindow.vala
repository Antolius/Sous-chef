/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.MainWindow : Gtk.ApplicationWindow {

    public Application sous_chef_app { private get; construct; }

    public MainWindow (Application application) {
        Object (
            sous_chef_app: application,
            application: application,
            title: _("Sous-chef")
        );
    }

    construct {
        hide_default_titlebar ();

        var library = new LibraryView (sous_chef_app.recipes_service);
        var recipe = new RecipeView (sous_chef_app.recipes_service);
        child = create_paned_for (library, recipe);

        bind_window_state_to_settings ();
    }

    private void bind_window_state_to_settings () {
        var settings = new Settings (Consts.PROJECT_NAME);
        settings.bind ("window-height", this, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", this, "default-width", SettingsBindFlags.DEFAULT);
        settings.bind ("window-maximized", this, "maximized", SettingsBindFlags.DEFAULT);
    }

    private Gtk.Widget create_paned_for (Gtk.Widget start, Gtk.Widget end) {
        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            start_child = start,
            resize_start_child = false,
            shrink_start_child = false,
            end_child = end,
            resize_end_child = true,
            shrink_end_child = false,
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
