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
        var end_window_controls = new Gtk.WindowControls (Gtk.PackType.END) {
            valign = Gtk.Align.START,
            margin_end = 3,
            margin_top = 3,
        };

        var title = new EditableTitle () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.BASELINE,
            margin_start = 16,
            margin_top = 9,
            margin_bottom = 9,
        };
        recipes_service.notify["currently-open"].connect (() => {
            title.text = recipes_service.currently_open?.title ?? "";
        });
        title.add_css_class (Granite.STYLE_CLASS_H1_LABEL);

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
            fill_content (content, recipe);
        });

        return content;
    }

    private void fill_content (Gtk.Box container, Recipe? recipe) {
        clear (container);
        if (recipe == null) {
            return;
        }

        if (recipe.tags != null && !recipe.tags.is_empty) {
            container.append (create_tags_row (recipe.tags));
        }

        if (recipe.description != null && recipe.description.length > 0) {
            container.append (create_description (recipe.description));
        }

        if (recipe.yields != null && !recipe.yields.is_empty) {
            container.append (create_yields (recipe.yields));
        }

        if (recipe.ingredient_groups != null && !recipe.ingredient_groups.is_empty) {
            container.append (create_ingredient_groups (recipe.ingredient_groups));
        }

    }

    private void clear (Gtk.Box container) {
        var row = container.get_first_child ();
        while (row != null) {
            var next = row.get_next_sibling ();
            container.remove (row);
            row.unparent ();
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
        var tags_row = new Gtk.FlowBox () {
            column_spacing = 16,
            margin_bottom = 8,
        };

        foreach (var tag in tags) {
            if (tag.length == 0) {
                continue;
            }

            var tag_pill = new TagPill (tag);
            tag_pill.on_removed.connect (() => {
                tag_pill.unparent ();
            });
            tags_row.append (tag_pill);
        }
        return tags_row;
    }

    private Gtk.Widget create_yields (Gee.List<Amount> yields) {
        var yields_view = new Gtk.TextView () {
            editable = false,
            cursor_visible = false,
            wrap_mode = Gtk.WrapMode.WORD_CHAR,
        };

        var sb = new StringBuilder (_("Yields "));
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

    private Gtk.Widget create_ingredient_groups (
        Gee.List<IngredientGroup> ingredient_groups
    ) {
        var groups = new Gtk.Box (Gtk.Orientation.VERTICAL, 16);
        var is_first = true;
        foreach (var group in ingredient_groups) {
            string? title = null;
            if (group.title != null && group.title.length > 0) {
                title = group.title;

            } else if (is_first) {
                title = _("Ingredients");
            }
            is_first = false;

            if (title != null) {
                var title_label = new Gtk.Label (title) {
                    halign = Gtk.Align.START,
                    wrap = true,
                };
                title_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);
                groups.append (title_label);
            }

            groups.append (create_ingredients (group.ingredients));
        }
        return groups;
    }

    private Gtk.Widget create_ingredients (
        Gee.List<Ingredient> ingredients
    ) {
        var list = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.NONE,
        };

        var store = convert_to_store (ingredients);
        list.bind_model (store, (element) => {
            var ingredient = (Ingredient) element;
            var unit_name = "";

            if (ingredient.amount != null) {
                var unit = ingredient.amount.unit;
                if (unit != null) {
                    if (unit.symbol != null) {
                        unit_name = _("%s of").printf (unit.symbol);
                    } else {
                        unit_name = _(" %s of").printf (unit.name);
                    }
                }
            }

            var txt = "• %g%s %s".printf (
                ingredient.amount?.value ?? 1.0,
                unit_name,
                ingredient.name
            );

            return new Gtk.Label (txt) {
                halign = Gtk.Align.START,
                selectable = true,
                wrap = true,
            };
        });

        return list;
    }

    private ListStore convert_to_store (Gee.List<Ingredient> source) {
        var store = new ListStore (typeof (Ingredient));
        foreach (var ingredient in source) {
            store.append (ingredient);
        }
        return store;
    }

    public override void dispose () {
        header.unparent ();
        scrolled_content.unparent ();
    }

}
