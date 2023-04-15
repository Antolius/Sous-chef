/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.RecipeView : Gtk.Widget {

    public RecipesService recipes_service { private get; construct; }

    private Gtk.WindowHandle header;

    public RecipeView (RecipesService recipes_service) {
        Object (
            layout_manager: new Gtk.BoxLayout (Gtk.Orientation.VERTICAL),
            recipes_service: recipes_service
        );
    }

    construct {
        add_css_class (Granite.STYLE_CLASS_VIEW);

        header = create_header ();
        header.insert_after (this, null);
    }

    private Gtk.WindowHandle create_header () {
        var end_window_controls = new Gtk.WindowControls (Gtk.PackType.END);

        var title = new Granite.HeaderLabel ("") {
            hexpand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.BASELINE,
            margin_top = 9,
            margin_bottom = 9,
        };
        recipes_service.notify["currently-open"].connect (() => {
            title.label = recipes_service.currently_open?.title ?? "";
        });

        var header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header.add_css_class ("titlebar");
        header.add_css_class (Granite.STYLE_CLASS_FLAT);
        header.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);
        header.append (title);
        header.append (end_window_controls);

        return new Gtk.WindowHandle () {
            child = header
        };
    }

    public override void dispose () {
        header.unparent ();
    }

}
