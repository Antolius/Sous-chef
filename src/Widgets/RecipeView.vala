/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.RecipeView : Gtk.Widget {

    public RecipesService recipes_service { private get; construct; }

    private Gtk.WindowHandle header;
    private Gtk.ScrolledWindow scrolled_recipe_text;

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
        scrolled_recipe_text = new Gtk.ScrolledWindow () {
            child = create_recipe_text (),
        };
        scrolled_recipe_text.insert_after (this, header);
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

    private Gtk.TextView create_recipe_text () {
        var recipe_text = new Gtk.TextView () {
            hexpand = true,
            vexpand = true,
            margin_start = 16,
            margin_end = 16,
        };
        recipes_service.notify["currently-open"].connect (() => {
            var instructions = recipes_service?.currently_open?.instructions ?? "";
            var final_txt = "";
            CMark.Node node = CMark.Node.parse_document(instructions.data, CMark.OPT.DEFAULT);
            CMark.Iter iter = new CMark.Iter(node);
            CMark.EVENT evt;
            while ((evt  = iter.next()) != CMark.EVENT.DONE) {
                unowned CMark.Node? cnode = iter.get_node();

                if (evt == CMark.EVENT.EXIT) {
                    final_txt += "</%s>\n".printf(cnode.get_type_string());
                }

                if (evt == CMark.EVENT.ENTER) {
                    final_txt += "<%s>\n".printf(cnode.get_type_string());
                    if (cnode.get_literal() != null) {
                        final_txt += "%s\n".printf(cnode.get_literal());
                    }
                }
            }
            recipe_text.buffer.text = final_txt;
        });
        return recipe_text;
    }

    public override void dispose () {
        header.unparent ();
        scrolled_recipe_text.unparent ();
    }

}
