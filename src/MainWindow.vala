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
        var catalog = create_catalog_view ();
        var recipe = create_recipe_view ();
        child = create_paned_for (catalog, recipe);
        hide_default_titlebar ();
    }

    private Gtk.Widget create_catalog_view () {
        var start_window_controls = new Gtk.WindowControls (Gtk.PackType.START);

        var search_entry = new Gtk.SearchEntry () {
            placeholder_text = _("Search Recipes"),
            hexpand = true,
            margin_start = 16,
            margin_end = 24,
            margin_top = 4,
            margin_bottom = 4
        };

        var add_recipe_button = new Gtk.Button.from_icon_name ("list-add");

        var catalog_heder = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        catalog_heder.add_css_class ("titlebar");
        catalog_heder.add_css_class (Granite.STYLE_CLASS_FLAT);
        catalog_heder.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);
        catalog_heder.append (start_window_controls);
        catalog_heder.append (search_entry);
        catalog_heder.append (add_recipe_button);

        var catalog_header_handle = new Gtk.WindowHandle () {
            child = catalog_heder
        };

        var catalog_list = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };

        var scrolled_catalog_list = new Gtk.ScrolledWindow () {
            child = catalog_list
        };

        var catalog = new Gtk.Grid ();
        catalog.add_css_class (Granite.STYLE_CLASS_VIEW);
        catalog.attach (catalog_header_handle, 0, 0);
        catalog.attach (scrolled_catalog_list, 0, 1);

        return catalog;
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
            end_child = end,
            resize_end_child = false,
            shrink_end_child = false,
            shrink_start_child = false
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
