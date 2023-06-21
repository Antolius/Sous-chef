/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.TagsRow : Gtk.Widget {

    public signal void changed ();

    public Gee.List<string> tags { get; construct; }

    private Gtk.FlowBox flow_box;
    private Gtk.Stack tag_adder;

    public TagsRow (Gee.List<string> tags) {
        Object (
            layout_manager: new Gtk.BoxLayout (Gtk.Orientation.HORIZONTAL) {
                 homogeneous = false,
            },
            tags: tags
        );
    }

    construct {
        margin_bottom = 8;

        flow_box = new Gtk.FlowBox () {
            selection_mode = Gtk.SelectionMode.NONE,
            column_spacing = 16,
            hexpand = true,
        };
        flow_box.add_css_class ("souschef-unselectable-children");

        foreach (var tag in tags) {
            add_tag_pill (tag);
        }

        flow_box.set_parent (this);

        tag_adder = new Gtk.Stack () {
            hexpand = false,
            vexpand = false,
            hhomogeneous = false,
            halign = Gtk.Align.START,
            valign = Gtk.Align.BASELINE,
            transition_type = Gtk.StackTransitionType.CROSSFADE,
        };
        var add_btn = new Gtk.Button.from_icon_name ("list-add-symbolic") {
            tooltip_text = _("Add Tag"),
            hexpand = false,
        };
        tag_adder.add_child (add_btn);
        var new_tag_entry = new Gtk.Entry () {
            vexpand = false,
            valign = Gtk.Align.BASELINE,
            placeholder_text = _("Tag name"),
        };
        tag_adder.add_child (new_tag_entry);
        add_btn.clicked.connect (() => {
            tag_adder.visible_child = new_tag_entry;
            new_tag_entry.grab_focus ();
        });
        new_tag_entry.activate.connect (() => {
            tag_adder.visible_child = add_btn;
            var new_tag = new_tag_entry.buffer.get_text ();
            if (!tags.contains (new_tag)) {
                add_tag_pill (new_tag);
                tags.add (new_tag);
                changed ();
            }
            new_tag_entry.buffer.set_text ("".data);
        });
        var focus_ctrl = new Gtk.EventControllerFocus ();
        focus_ctrl.leave.connect (() => {
            new_tag_entry.activate ();
        });
        new_tag_entry.add_controller (focus_ctrl);
        tag_adder.set_parent (this);
    }

    private void add_tag_pill (string tag) {
        if (tag.length == 0) {
            return;
        }

        var tag_pill = new TagPill (tag);
        var hide_animation_duration = 200;
        var revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE,
            transition_duration = hide_animation_duration,
            reveal_child = true,
            child = tag_pill,
        };
        flow_box.append (revealer);

        tag_pill.on_removed.connect (() => {
            revealer.reveal_child = false;
            Timeout.add (hide_animation_duration, () => {
                flow_box.remove (revealer);
                tags.remove (tag);
                changed ();
                return Source.REMOVE;
            }, Priority.DEFAULT);
        });
    }

    public override void dispose () {
        flow_box.unparent ();
        tag_adder.unparent ();
    }
}
