/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.EditableIngredientGroups : Gtk.Widget {

    public Gee.List<IngredientGroup> ingredient_groups { get; set construct; }
    public ConverterService converter_service { private get; construct; }

    private Gtk.Widget groups_box;
    private ListStore root_store;

    public EditableIngredientGroups (
        ConverterService converter_service,
        Gee.List<IngredientGroup> ingredient_groups
    ) {
        Object (
            layout_manager: new Gtk.BinLayout (),
            converter_service: converter_service,
            ingredient_groups: ingredient_groups
        );
    }

    construct {
        groups_box = create_groups_box ();
        groups_box.set_parent (this);
        update_root_store ();
        listen_to_property_changes ();
    }

    private Gtk.Widget create_groups_box () {
        var box = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.NONE,
        };
        box.add_css_class ("souschef-unselectable-children");

        root_store = new ListStore (typeof (IndexedModel));
        var model = new Gtk.TreeListModel (root_store, true, true, el => {
            if (!((el as IndexedModel<IngredientGroup>)?.model is IngredientGroup)) {
                return null;
            }

            var idx_model = (IndexedModel<IngredientGroup>) el;
            var ingredients = idx_model.model.ingredients;
            var store = new ListStore (typeof (IndexedModel));
            var group_max = ingredients.size;
            for (var i = 0; i < group_max; i++) {
                var ingredient = ingredients[i];
                store.append (new IndexedModel<Ingredient> (
                    ingredient, i, group_max, idx_model.idx, idx_model.max
                ));
            }

            return store;
        });

        box.bind_model (model, create_row);
        return box;
    }

    private Gtk.ListBoxRow create_row (Object model) {
        if ((model as IndexedModel<Ingredient>)?.model is Ingredient) {
            return create_ingredient_row ((IndexedModel<Ingredient>) model);
        } else if ((model as IndexedModel<IngredientGroup>)?.model is IngredientGroup) {
            return create_group_title_row ((IndexedModel<IngredientGroup>) model);
        } else {
            assert_not_reached ();
        }
    }

    private Gtk.ListBoxRow create_ingredient_row (IndexedModel<Ingredient> model) {
        var ingredient = model.model;
        var row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
        row.append (new Gtk.CheckButton () {
            valign = Gtk.Align.BASELINE,
        });
        var editable_ingredient = new EditableIngredient (
            converter_service,
            ingredient
        );
        row.append (editable_ingredient);
        var is_last_ingredient_in_a_group = model.idx == model.max - 1;
        if (!is_last_ingredient_in_a_group) {
            return new Gtk.ListBoxRow () {
                activatable = false,
                selectable = false,
                margin_bottom = 16,
                child = row,
            };
        } else {
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 16);
            box.append (row);
            var btn_row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);

            var add = new Gtk.Button.from_icon_name ("document-new-symbolic") {
                halign = Gtk.Align.START,
                tooltip_text = _("Add ingredient"),
            };
            add.add_css_class ("text-button");
            btn_row.append (add);

            var is_last_group = model.group_idx == model.group_max - 1;
            if (is_last_group) {
                var add_group = new Gtk.Button.from_icon_name ("folder-new-symbolic") {
                    halign = Gtk.Align.START,
                    tooltip_text = _("Add group of ingredients"),
                };
                add_group.add_css_class ("text-button");
                btn_row.append (add_group);
            }

            box.append (btn_row);
            return new Gtk.ListBoxRow () {
                activatable = false,
                selectable = false,
                margin_bottom = 16,
                child = box,
            };
        }
    }

    private Gtk.ListBoxRow create_group_title_row (IndexedModel<IngredientGroup> model) {
        var group = model.model;
        var title_label = new EditableLabel () {
            text = group.title ?? _("Ingredients"),
            halign = Gtk.Align.START,
        };
        title_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);
        return new Gtk.ListBoxRow () {
            activatable = false,
            selectable = false,
            margin_bottom = 16,
            child = title_label,
        };
    }

    private void listen_to_property_changes () {
        notify["ingredient-groups"].connect (update_root_store);
    }

    private void update_root_store () {
        root_store.remove_all ();
        var max = ingredient_groups.size;
        for (var i = 0; i < max; i++) {
            var g = ingredient_groups[i];
            root_store.append (new IndexedModel<IngredientGroup> (g, i, max));
        }
    }

    public override void dispose () {
        groups_box.unparent ();
    }

}

internal class Souschef.IndexedModel<T> : Object {
    public T model { get; construct; }
    public int idx { get; construct; }
    public int max { get; construct; }
    public int group_idx { get; construct; }
    public int group_max { get; construct; }

    internal IndexedModel (T model, int idx, int max, int group_idx = -1, int group_max = -1) {
        Object (model: model, idx: idx, max: max, group_idx: group_idx, group_max: group_max);
    }
}
