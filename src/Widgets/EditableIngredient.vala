/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.EditableIngredient : Gtk.Widget {

    public ConverterService converter_service { private get; construct; }
    public Ingredient ingredient { get; set construct; }

    public bool mouse_over { get; private set; default = false; }
    public bool editing { get; private set; default = false; }

    public signal void changed (Ingredient updated_ingredient);

    private Gtk.Stack stack;

    private Gtk.Label display_label;
    private Gtk.SpinButton value_entry;
    private Gtk.DropDown unit_picker;
    private Gtk.Entry name_entry;
    private Gtk.Button convert_btn;

    public Amount? edited_amount { get; private set; default = null; }

    public EditableIngredient (
        ConverterService converter_service,
        Ingredient ingredient
    ) {
        Object (
            layout_manager: new Gtk.BinLayout (),
            converter_service: converter_service,
            ingredient: ingredient,
            hexpand: true,
            halign: Gtk.Align.FILL
        );
    }

    static construct {
        new Density (); // Initialize static fields
    }

    construct {
        set_up_controllers ();
        stack = create_stack ();
        stack.set_parent (this);
        update_widget_states ();
        listen_to_property_changes ();
    }

    private Gtk.Stack create_stack () {
        var stack = new Gtk.Stack () {
            hhomogeneous = false,
            interpolate_size = true,
        };

        var display_row = create_display_row ();
        var editing_row = create_editing_row ();

        stack.add_named (display_row, "display");
        stack.add_named (editing_row, "editing");
        bind_property (
            "editing",
            stack,
            "visible_child_name",
            BindingFlags.SYNC_CREATE,
            (ignored, src, ref target) => {
                if (src.get_boolean ()) {
                    target.set_string ("editing");
                } else {
                    target.set_string ("display");
                }
                return true;
            }
        );

        return stack;
    }

    private void set_up_controllers () {
        var motion_ctrl = new Gtk.EventControllerMotion ();
        motion_ctrl.enter.connect (() => {
            if (!mouse_over) {
                mouse_over = true;
            }
        });
        motion_ctrl.leave.connect (() => {
            if (mouse_over) {
                mouse_over = false;
            }
        });
        add_controller (motion_ctrl);

        var focus_ctrl = new Gtk.EventControllerFocus ();
        focus_ctrl.leave.connect (() => {
            editing = false;
        });
        add_controller (focus_ctrl);
    }

    private Gtk.Box create_display_row () {
        var row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);

        display_label = new Gtk.Label (null) {
            hexpand = false,
            selectable = true,
            valign = Gtk.Align.BASELINE,
            ellipsize = Pango.EllipsizeMode.END,
        };
        row.append (display_label);

        var edit_btn = new Gtk.Button.from_icon_name ("edit-symbolic") {
            tooltip_text = _("Edit ingredient"),
        };
        edit_btn.add_css_class (Granite.STYLE_CLASS_FLAT);
        edit_btn.clicked.connect (() => {
            editing = true;
        });

        var btn_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE,
        };
        btn_revealer.set_child (edit_btn);
        bind_property (
            "mouse-over",
            btn_revealer,
            "reveal-child",
            BindingFlags.SYNC_CREATE
        );
        row.append (btn_revealer);

        return row;
    }

    private Gtk.Box create_editing_row () {
        var row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);

        value_entry = new Gtk.SpinButton.with_range (0.0, double.MAX, 0.1) {
            numeric = true,
            climb_rate = 1.0,
        };
        row.append (value_entry);

        var unit_type = typeof (Unit);
        var units_store = new ListStore (unit_type);
        units_store.append (Units.NONE);
        foreach (var u in Units.ALL) {
            units_store.append (u);
        }
        var expression = new Gtk.PropertyExpression (unit_type, null, "name");
        unit_picker = new Gtk.DropDown (units_store, expression) {
            tooltip_text = _("Change the unit"),
            enable_search = true,
        };
        row.append (unit_picker);

        convert_btn = new Gtk.Button.from_icon_name ("accessories-calculator-symbolic") {
            margin_start = 8,
            tooltip_text = _("Convert into a different unit"),
        };
        convert_btn.add_css_class ("text-button");
        convert_btn.clicked.connect (() => show_converter_dialog_for (ingredient));
        row.append (convert_btn);

        row.append (new Gtk.Separator (Gtk.Orientation.VERTICAL) {
            margin_start = 8,
            margin_end = 8,
        });

        name_entry = new Gtk.Entry ();
        name_entry.buffer.set_text (ingredient.name.data);
        row.append (name_entry);

        var apply = new Gtk.Button.from_icon_name ("object-select-symbolic") {
            tooltip_text = _("Apply changes"),
            halign = Gtk.Align.END,
            margin_start = 8,
            hexpand = true,
        };
        apply.clicked.connect (() => {
            editing = false;

            changed (new Ingredient () {
                name = name_entry.text,
                link = ingredient.link,
                amount = new Amount () {
                    value = value_entry.value,
                    unit = (Unit?) unit_picker.selected_item,
                },
            });
        });
        row.append (apply);

        var cancel = new Gtk.Button.from_icon_name ("window-close-symbolic") {
            tooltip_text = _("Cancel changes"),
            halign = Gtk.Align.END,
        };
        cancel.clicked.connect (() => {
            editing = false;
            update_widget_states ();
        });
        row.append (cancel);

        return row;
    }

    private void listen_to_property_changes () {
        notify["ingredient"].connect (update_widget_states);
        converter_service.notify["converter"].connect (update_widget_states);
    }

    private void update_widget_states () {
        if (ingredient == null) {
            display_label.label = "";
            value_entry.digits = 1;
            value_entry.value = 1.0;
            unit_picker.selected = 0;
            convert_btn.visible = false;
            name_entry.text = "";
            return;
        }

        var name = ingredient.name;
        name_entry.text = name;
        var amount = ingredient.amount;
        if (amount == null) {
            display_label.label = name;
            value_entry.digits = 1;
            value_entry.value = 1.0;
            unit_picker.selected = 0;
            convert_btn.visible = false;
            return;
        }

        amount = converter_service.converter.convert_if_you_can (amount);
        display_label.label = "%s %s".printf (amount.to_string (), name);

        double ignored;
        var frac = Math.modf (amount.value, out ignored);
        value_entry.digits = frac == 0.0 ? 1 : 4;
        value_entry.value = amount.value;

        var unit = amount.unit;
        if (unit == null) {
            unit_picker.selected = 0;
            convert_btn.visible = false;
            return;
        }

        var unit_idx = 0;
        for (var i = 0; i < Units.ALL.size; i++) {
            if (unit == Units.ALL[i]) {
                unit_idx = i + 1;
                break;
            }
        }
        unit_picker.selected = unit_idx;
        convert_btn.visible = true;
    }

    private void show_converter_dialog_for (Ingredient? ingredient) {
        if (ingredient?.amount?.unit == null) {
            return;
        }

        var dialog = new Granite.Dialog () {
            modal = true,
            default_width = 360,
            default_height = 240,
        };
        if (root != null && root is Gtk.Window) {
            dialog.transient_for = (Gtk.Window) root;
        }

        var layout = create_converter_layout (ingredient);
        dialog.get_content_area ().append (layout);
        dialog.add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        var apply = dialog.add_button (_("Convert"), Gtk.ResponseType.APPLY);
        apply.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        dialog.response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.APPLY && edited_amount != null) {
                changed (new Ingredient () {
                    name = ingredient.name,
                    link = ingredient.link,
                    amount = edited_amount,
                });
            }

            dialog.destroy ();
        });

        dialog.show ();
        editing = false;
    }

    private Gtk.Widget create_converter_layout (Ingredient ingredient) {
        var amount = ingredient.amount;
        var layout = new Gtk.Box (Gtk.Orientation.VERTICAL, 32) {
            margin_start = 16,
            margin_end = 16,
            margin_bottom = 16,
        };

        var stack = new Gtk.Stack () {
            hhomogeneous = true,
            vhomogeneous = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.START,
        };

        var metric_units = new Gee.ArrayList<Unit> (Unit.equal_func);
        var imperial_units = new Gee.ArrayList<Unit> (Unit.equal_func);
        var mass_to_volume_units = new Gee.ArrayList<Unit> (Unit.equal_func);
        var volume_to_mass_units = new Gee.ArrayList<Unit> (Unit.equal_func);

        foreach (var unit in Units.ALL) {
            if (unit == amount.unit) {
                continue;
            }

            if (unit.kind == amount.unit.kind) {
                if (unit.system == UnitSystem.METRIC) {
                    metric_units.add (unit);
                } else if (unit.system == UnitSystem.IMPERIAL) {
                    imperial_units.add (unit);
                }
            }

            if (unit.system == amount.unit.system) {
                if (unit.kind == UnitKind.VOLUME && amount.unit.kind == UnitKind.MASS) {
                    mass_to_volume_units.add (unit);
                } else if (unit.kind == UnitKind.MASS && amount.unit.kind == UnitKind.VOLUME) {
                    volume_to_mass_units.add (unit);
                }
            }
        }

        if (!metric_units.is_empty) {
            var name = "metric";
            var page = create_simple_converter_page (
                amount, metric_units, stack, name
            );
            stack.add_titled (page, name, _("Into Metric"));
        }

        if (!imperial_units.is_empty) {
            var name = "imperial";
            var page = create_simple_converter_page (
                amount, imperial_units, stack, name
            );
            stack.add_titled (page, name, _("Into Imperial"));
        }

        if (!mass_to_volume_units.is_empty) {
            var name = "mass-to-volume";
            var page = create_density_converter_page (
                ingredient, mass_to_volume_units, stack, name
            );
            stack.add_titled (page, name, "Mass to Volume");
        } else if (!volume_to_mass_units.is_empty) {
            var name = "volume-to-mass";
            var page = create_density_converter_page (
                ingredient, volume_to_mass_units, stack, name
            );
            stack.add_titled (page, name, "Volume to Mass");
        }

        layout.append (new Gtk.StackSwitcher () {
            stack = stack,
        });
        layout.append (stack);

        return layout;
    }

    private Gtk.Widget create_simple_converter_page (
        Amount amount,
        Gee.List<Unit> target_units,
        Gtk.Stack stack,
        string page_name
    ) {
        var page = new Gtk.Box (Gtk.Orientation.VERTICAL, 8) {
            halign = Gtk.Align.CENTER,
        };

        var prompt_txt = _("Converting %s into").printf (amount.to_string ());
        page.append (new Gtk.Label (prompt_txt) {
            halign = Gtk.Align.START,
        });

        var unit_type = typeof (Unit);
        var units_store = new ListStore (unit_type);
        units_store.append (Units.NONE);
        foreach (var u in target_units) {
            units_store.append (u);
        }
        var expression = new Gtk.PropertyExpression (unit_type, null, "name");
        var unit_picker = new Gtk.DropDown (units_store, expression) {
            halign = Gtk.Align.FILL,
            enable_search = true,
        };
        unit_picker.notify["selected"].connect (() => {
            perform_simple_conversion (amount, unit_picker.selected_item);
        });
        page.append (unit_picker);

        var result_preview = new Gtk.Label ("") {
            halign = Gtk.Align.START,
        };
        notify["edited-amount"].connect (() => {
            if (edited_amount == null) {
                result_preview.label = "";
                return;
            }

            var txt = edited_amount.to_string ();
            result_preview.label = _("results in %s").printf (txt);
        });
        page.append (result_preview);

        stack.notify["visible-child-name"].connect (() => {
            if (stack.visible_child_name == page_name) {
                perform_simple_conversion (amount, unit_picker.selected_item);
            }
        });

        return page;
    }

    private Gtk.Widget create_density_converter_page (
        Ingredient ingredient,
        Gee.List<Unit> target_units,
        Gtk.Stack stack,
        string page_name
    ) {
        var amount = ingredient.amount;
        var page = new Gtk.Box (Gtk.Orientation.VERTICAL, 8) {
            halign = Gtk.Align.CENTER,
        };

        var prompt_txt = _("Converting %s of %s into").printf (
            amount.to_string (),
            ingredient.name
        );
        page.append (new Gtk.Label (prompt_txt) {
            max_width_chars = 128,
            halign = Gtk.Align.START,
            ellipsize = Pango.EllipsizeMode.END,
        });

        var unit_type = typeof (Unit);
        var units_store = new ListStore (unit_type);
        units_store.append (Units.NONE);
        foreach (var u in target_units) {
            units_store.append (u);
        }
        var expression = new Gtk.PropertyExpression (unit_type, null, "name");
        var unit_picker = new Gtk.DropDown (units_store, expression) {
            halign = Gtk.Align.FILL,
            enable_search = true,
        };
        page.append (unit_picker);

        page.append (new Gtk.Label (_("based on the density of")) {
            halign = Gtk.Align.START,
        });

        var density_type = typeof (Density);
        var densities_store = new ListStore (density_type);
        densities_store.append (Density.NONE);
        foreach (var d in generate_densities_for (page_name)) {
            densities_store.append (d);
        }
        var density_expression = new Gtk.PropertyExpression (density_type, null, "name");
        var density_picker = new Gtk.DropDown (densities_store, density_expression) {
            halign = Gtk.Align.FILL,
            enable_search = true,
        };
        page.append (density_picker);

        unit_picker.notify["selected"].connect (() => {
            perform_density_conversion (
                amount,
                unit_picker.selected_item,
                density_picker.selected_item
            );
        });
        density_picker.notify["selected"].connect (() => {
            perform_density_conversion (
                amount,
                unit_picker.selected_item,
                density_picker.selected_item
            );
        });

        var result_preview = new Gtk.Label ("") {
            halign = Gtk.Align.START,
        };
        notify["edited-amount"].connect (() => {
            if (edited_amount == null) {
                result_preview.label = "";
                return;
            }

            var txt = edited_amount.to_string ();
            result_preview.label = _("results in %s").printf (txt);
        });
        page.append (result_preview);

        stack.notify["visible-child-name"].connect (() => {
            if (stack.visible_child_name == page_name) {
                perform_density_conversion (
                    amount,
                    unit_picker.selected_item,
                    density_picker.selected_item
                );
            }
        });

        return page;
    }

    private void perform_simple_conversion (Amount amount, Object? selected_unit) {
        var target_unit = (Unit) selected_unit;
        if (target_unit == null || target_unit == Units.NONE) {
            edited_amount = null;
            return;
        }

        edited_amount = amount.to_unit (target_unit);
    }

    private Density[] generate_densities_for (string page_name) {
        if (page_name == "volume-to-mass") {
            return Density.ALL;
        }

        Density[] volume_to_mass_densities = {};
        foreach (var d in Density.ALL) {
            volume_to_mass_densities += new Density () {
                name = d.name,
                ratio = 1.0 / d.ratio,
            };
        }
        return volume_to_mass_densities;
    }

    private void perform_density_conversion (
        Amount amount,
        Object? selected_unit,
        Object? selected_referent_unit_density
    ) {
        var target_unit = (Unit) selected_unit;
        if (target_unit == null || target_unit == Units.NONE) {
            edited_amount = null;
            return;
        }

        var density = (Density) selected_referent_unit_density;
        if (density == null || density == Density.NONE) {
            edited_amount = null;
            return;
        }

        var converter = new ReferentUnitRationBasedAmountConverter (
            density.ratio,
            target_unit
        );
        edited_amount = converter.convert (amount);
    }

    public override void dispose () {
        stack.unparent ();
    }
}

private delegate Unit? Souschef.ConvertFunc (Unit source);

public class Souschef.Density : Object {
    public string name { get; set; }
    public double ratio { get; set; }

    public Density () {
        Object ();
    }

    public static Density NONE = new Density () {
        name = "",
        ratio = 1.0,
    };

    public static Density[] ALL = {
        new Density () {
            name = _("Water"),
            ratio = 1000.0
        },
        new Density () {
            name = _("Milk"),
            ratio = 1030.0
        },
        new Density () {
            name = _("Wheat Flour"),
            ratio = 600.0
        },
        new Density () {
            name = _("Soy Flour"),
            ratio = 680.0
        },
        new Density () {
            name = _("Corn Starch Flour"),
            ratio = 650.0
        },
        new Density () {
            name = _("Shugar"),
            ratio = 845.0
        },
        new Density () {
            name = _("Brown Shugar"),
            ratio = 800.0
        },
        new Density () {
            name = _("Powdered Shugar"),
            ratio = 560.0
        },
        new Density () {
            name = _("Salt"),
            ratio = 1217.0
        },
        new Density () {
            name = _("Honey"),
            ratio = 1420.0
        },
        new Density () {
            name = _("Butter"),
            ratio = 959.0
        },
        new Density () {
            name = _("Sunflower oil"),
            ratio = 960.0
        },
        new Density () {
            name = _("Olive oil"),
            ratio = 918.0
        },
        new Density () {
            name = _("Raw Rice"),
            ratio = 850.0
        },
        new Density () {
            name = _("Light Cream"),
            ratio = 1030.0
        },
        new Density () {
            name = _("Heavy Cream"),
            ratio = 984.0
        }
    };
}
