/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.EditableTitle : Gtk.Widget {

    public signal void changed ();

    public string text { get; set; default = ""; }

    private Gtk.Stack stack;

    public EditableTitle () {
        Object (
            layout_manager: new Gtk.BinLayout (),
            hexpand: true
        );
    }

    construct {
        stack = new Gtk.Stack ();
        stack.set_parent (this);

        var entry = new Gtk.Entry () {
            hexpand = true,
        };
        entry.buffer.set_text (text.data);

        var label = new Gtk.Label (text) {
            hexpand = true,
            ellipsize = Pango.EllipsizeMode.END,
        };

        var edit_btn = new Gtk.Button.from_icon_name ("edit-symbolic") {
            tooltip_text = _("Edit title"),
        };
        edit_btn.add_css_class (Granite.STYLE_CLASS_FLAT);
        edit_btn.clicked.connect (() => {
            stack.visible_child_name = "editing";
            entry.grab_focus ();
        });

        var btn_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE,
        };
        btn_revealer.set_reveal_child (false);
        btn_revealer.set_child (edit_btn);

        var static_row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        static_row.append (label);
        static_row.append (btn_revealer);

        entry.activate.connect (() => {
            stack.visible_child_name = "static";
            text = entry.buffer.get_text ();
            label.label = text;
            changed ();
        });

        stack.add_named (static_row, "static");
        stack.add_named (entry, "editing");
        stack.visible_child_name = "static";

        notify["text"].connect (() => {
            label.label = text;
            entry.buffer.set_text (text.data);
        });

        var mouse_in = false;
        var motion_ctrl = new Gtk.EventControllerMotion ();
        motion_ctrl.enter.connect (() => {
            mouse_in = true;
            if (stack.visible_child_name == "static" && text != "") {
                btn_revealer.set_reveal_child (true);
            }
        });
        motion_ctrl.leave.connect (() => {
            mouse_in = false;
            if (stack.visible_child_name == "static" && text != "") {
                btn_revealer.set_reveal_child (false);
            }
        });
        add_controller (motion_ctrl);

        var focus_ctrl = new Gtk.EventControllerFocus ();
        focus_ctrl.leave.connect (() => {
            entry.activate ();
        });
        entry.add_controller (focus_ctrl);
    }

    public override void dispose () {
        stack.unparent ();
    }
}
