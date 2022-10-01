/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.LibraryView : Gtk.Widget {

    private Gtk.WindowHandle header_handle;
    private Gtk.ScrolledWindow scrolled_list;

    public LibraryView () {
        Object (
            layout_manager: new Gtk.BoxLayout (Gtk.Orientation.VERTICAL)
        );
    }

    construct {
        add_css_class (Granite.STYLE_CLASS_VIEW);

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

        var header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header.add_css_class ("titlebar");
        header.add_css_class (Granite.STYLE_CLASS_FLAT);
        header.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);
        header.append (start_window_controls);
        header.append (search_entry);
        header.append (add_recipe_button);

        header_handle = new Gtk.WindowHandle () {
            child = header
        };
        header_handle.insert_after (this, null);

        var list = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };

        scrolled_list = new Gtk.ScrolledWindow () {
            child = list
        };
        scrolled_list.insert_after (this, header_handle);
    }

    public override void dispose () {
        header_handle.unparent ();
        scrolled_list.unparent ();
    }
}
