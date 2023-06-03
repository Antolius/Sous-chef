/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.TagPill : Gtk.Widget {

    public signal void on_removed ();

    public string tag { get; construct; }

    private Gtk.Label label;
    private Gtk.Revealer btn_revealer;

    public TagPill (string tag) {
        Object (
            layout_manager: new Gtk.BoxLayout (Gtk.Orientation.HORIZONTAL) {
                spacing = 2,
            },
            tag: tag
        );
    }

    construct {
        add_css_class (Granite.STYLE_CLASS_CARD);
        add_css_class (Granite.STYLE_CLASS_ROUNDED);
        add_css_class ("souschef-tag");

        label = new Gtk.Label (tag) {
            margin_start = 26,
            hexpand = true,
            halign = Gtk.Align.CENTER,
            ellipsize = Pango.EllipsizeMode.END,
            tooltip_text = tag,
        };
        label.set_parent (this);

        var button = new Gtk.Button.from_icon_name ("application-exit-symbolic") {
            can_focus = false,
            tooltip_text = _("Remove Tag"),
        };
        button.clicked.connect (() => on_removed ());

        btn_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE,
        };
        btn_revealer.set_reveal_child (false);
        btn_revealer.set_child (button);
        btn_revealer.set_parent (this);

        var motion_ctrl = new Gtk.EventControllerMotion ();
        motion_ctrl.enter.connect (() => {
            btn_revealer.set_reveal_child (true);
        });
        motion_ctrl.leave.connect (() => {
            btn_revealer.set_reveal_child (false);
        });
        add_controller (motion_ctrl);
    }

    public override void dispose () {
        label.unparent ();
        btn_revealer.unparent ();
    }
}
