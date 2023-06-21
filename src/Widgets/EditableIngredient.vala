/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.EditableIngredient : Gtk.Widget {

    public ConverterService converter_service { private get; construct; }
    public Ingredient ingredient { private get; set construct; }

    public bool mouse_over { get; private set; default = false; }
    public bool editing { get; private set; default = false; }

    public signal void changed ();

    private Gtk.Stack stack;

    private Gtk.Label display_label;
    private Gtk.SpinButton value_entry;
    private Gtk.DropDown unit_picker;
    private Gtk.Entry name_entry;

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

    construct {
        set_up_controllers ();
        stack = create_stack ();
        update_widget_states ();
        listen_to_property_changes ();
    }

    private Gtk.Stack create_stack () {
        var stack = new Gtk.Stack () {
            hhomogeneous = false,
            interpolate_size = true,
        };
        stack.set_parent (this);

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
        var row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);

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
        var row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);

        value_entry = new Gtk.SpinButton.with_range (0.0, double.MAX, 0.1) {
            numeric = true,
            climb_rate = 1.0,
        };
        row.append (value_entry);

        var unit_type = typeof (Unit);
        var units_store = new ListStore (unit_type);
        units_store.append (Units.NONE);
        for (var i = 0; i < Units.ALL.size; i++) {
            var unit = Units.ALL[i];
            units_store.append (unit);
        }
        var expression = new Gtk.PropertyExpression (unit_type, null, "name");
        unit_picker = new Gtk.DropDown (units_store, expression) {
            enable_search = true,
        };
        row.append (unit_picker);

        name_entry = new Gtk.Entry ();
        name_entry.buffer.set_text (ingredient.name.data);
        row.append (name_entry);

        var accept = new Gtk.Button.from_icon_name ("object-select-symbolic") {
            tooltip_text = _("Accept changes"),
            halign = Gtk.Align.END,
            hexpand = true,
        };
        accept.clicked.connect (() => {
            debug ("accept.clicked.connect");
            editing = false;
        });
        row.append (accept);

        var dismiss = new Gtk.Button.from_icon_name ("window-close-symbolic") {
            tooltip_text = _("Dismiss changes"),
            halign = Gtk.Align.END,
        };
        dismiss.clicked.connect (() => {
            debug ("dismiss.clicked.connect");
            editing = false;
        });
        row.append (dismiss);

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
    }

    public override void dispose () {
        stack.unparent ();
    }
}
