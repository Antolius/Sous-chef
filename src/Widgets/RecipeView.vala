/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.RecipeView : Gtk.Widget {

    public RecipesService recipes_service { private get; construct; }

    private Gtk.WindowHandle header;
    private Gtk.ScrolledWindow scrolled_content;

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
        scrolled_content = new Gtk.ScrolledWindow () {
            child = create_recipe_content (),
        };
        scrolled_content.insert_after (this, header);
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

    private Gtk.Widget create_recipe_content () {
        var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 8) {
            margin_start = 16,
            margin_top = 16,
            margin_end = 16,
            vexpand = true,
        };

        recipes_service.notify["currently-open"].connect (() => {
            var recipe = recipes_service?.currently_open;
            render (content, recipe);
        });

        return content;
    }

    private void render (Gtk.Box container, Recipe? recipe) {
        clean_up (container);
        if (recipe == null) {
            return;
        }

        if (recipe.tags != null && !recipe.tags.is_empty) {
            container.append (create_tags_row (recipe.tags));
        }

        if (recipe.description != null) {
            container.append (create_description (recipe.description));
        }

        if (recipe.yields != null && !recipe.yields.is_empty) {
            container.append (create_yields (recipe.yields));
        }
    }

    private void clean_up (Gtk.Box container) {
        var row = container.get_first_child ();
        while (row != null) {
            var next = row.get_next_sibling ();
            container.remove (row);
            row = next;
        }
    }

    private Gtk.Widget create_description (string description) {
        var desc_view = new Gtk.TextView () {
            hexpand = true,
            editable = false,
            cursor_visible = false,
            wrap_mode = Gtk.WrapMode.WORD_CHAR,
        };
        desc_view.buffer.set_text (description + "\n");
        return desc_view;
    }

    private Gtk.Widget create_tags_row (Gee.List<string> tags) {
        var tags_row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 16) {
            margin_bottom = 8,
        };

        foreach (var tag in tags) {
            if (tag.length == 0) {
                continue;
            }

            var tag_view = new Gtk.Label (tag);
            tag_view.add_css_class (Granite.STYLE_CLASS_CARD);
            tag_view.add_css_class (Granite.STYLE_CLASS_ROUNDED);
            tag_view.add_css_class ("souschef-tag");
            tags_row.append (tag_view);
        }
        return tags_row;
    }

    private Gtk.Widget create_yields (Gee.List<Amount> yields) {
        var yields_view = new Gtk.TextView () {
            hexpand = true,
            editable = false,
            cursor_visible = false,
            wrap_mode = Gtk.WrapMode.WORD_CHAR,
        };

        var sb = new StringBuilder (_("Yields: "));
        for (var i = 0; i < yields.size; i++) {
            if (i > 0) {
                sb.append (", ");
            }
            var yld = yields[i];
            sb.append ("%g".printf (yld.value));
            if (yld.unit != null) {
                sb.append (" ");
                sb.append (yld.unit?.symbol ?? yld.unit?.name);
            }
        }

        sb.append ("\n");
        yields_view.buffer.set_text (sb.str);
        return yields_view;
    }

    public override void dispose () {
        header.unparent ();
        scrolled_content.unparent ();
    }

}
