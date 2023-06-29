/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.RecipeView : Gtk.Widget {

    public RecipesService recipes_service { private get; construct; }
    public ConverterService converter_service { private get; construct; }

    private Gtk.Widget header;
    private Gtk.ScrolledWindow scrolled_content;

    public RecipeView (
        RecipesService recipes_service,
        ConverterService converter_service
    ) {
        Object (
            layout_manager: new Gtk.BoxLayout (Gtk.Orientation.VERTICAL),
            recipes_service: recipes_service,
            converter_service: converter_service
        );
    }

    construct {
        add_css_class (Granite.STYLE_CLASS_VIEW);

        setup_actions ();

        header = create_header ();
        header.insert_after (this, null);
        scrolled_content = new Gtk.ScrolledWindow () {
            child = create_recipe_content (),
        };
        scrolled_content.insert_after (this, header);
    }

    private void setup_actions () {
        var change_unit_system_action = new SimpleAction.stateful (
            "change-unit-system",
            new VariantType ("s"),
            new Variant.string ("original")
        );
        change_unit_system_action.notify["state"].connect (() => {
            var preferred_system = change_unit_system_action.state.get_string ();
            PreferredUnitSystem system;
            switch (preferred_system) {
                case "metric":
                    system = PreferredUnitSystem.METRIC;
                    break;
                case "imperial":
                    system = PreferredUnitSystem.IMPERIAL;
                    break;
                default:
                    system = PreferredUnitSystem.ORIGINAL;
                    break;
            }
            converter_service.preferred_unit_system = system;
        });

        var change_yield_action = new SimpleAction.stateful (
            "change-yield",
            new VariantType ("d"),
            new Variant.double (1.0)
        );
        change_yield_action.notify["state"].connect (() => {
            var factor = change_yield_action.state.get_double ();
            converter_service.yield_factor = factor;
        });

        var group = new SimpleActionGroup ();
        group.add_action (change_unit_system_action);
        group.add_action (change_yield_action);
        insert_action_group ("recipe", group);
    }

    private Gtk.Widget create_header () {
        var header = new RecipeHeader ();
        recipes_service.bind_property (
            "currently-open",
            header,
            "recipe",
            BindingFlags.SYNC_CREATE
        );
        return header;
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
            container.append (new TagsRow (recipe.tags));
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
        var list = new Gtk.ListBox ();
        list.add_css_class ("souschef-unselectable-children");

        var store = convert_to_store (ingredients);
        list.bind_model (store, (element) => {
            var ingredient = (Ingredient) element;

            var row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4) {
                margin_bottom = 8,
            };

            row.append (new Gtk.CheckButton () {
                valign = Gtk.Align.BASELINE,
            });

            var editable_ingredient = new EditableIngredient (
                converter_service,
                ingredient
            );
            editable_ingredient.changed.connect (updated => {
                // TODO: implement proper change management
                editable_ingredient.ingredient = updated;
            });
            row.append (editable_ingredient);

            return new Gtk.ListBoxRow () {
                activatable = false,
                selectable = false,
                child = row,
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
