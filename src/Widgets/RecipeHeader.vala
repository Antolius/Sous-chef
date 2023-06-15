/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.RecipeHeader : Gtk.Widget {

    public Gtk.Widget title { get; construct; }
    public Recipe? recipe { get; set; default = null; }

    private Gtk.WindowHandle header;

    public RecipeHeader () {
        Object (
            layout_manager: new Gtk.BoxLayout (Gtk.Orientation.VERTICAL)
        );
    }

    construct {
        header = create_header ();
        header.insert_after (this, null);
    }

    private Gtk.WindowHandle create_header () {
        var title = create_title ();
        var unit_system_btn = create_unit_system_switcher ();
        var yield_btn = create_yield_switcher ();
        var end_window_controls = new Gtk.WindowControls (Gtk.PackType.END) {
            valign = Gtk.Align.START,
            margin_end = 3,
            margin_top = 3,
        };

        var row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        row.add_css_class ("titlebar");
        row.add_css_class (Granite.STYLE_CLASS_FLAT);
        row.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);

        row.append (title);
        row.append (unit_system_btn);
        row.append (yield_btn);
        row.append (end_window_controls);

        return new Gtk.WindowHandle () {
            child = row
        };
    }


    private EditableTitle create_title () {
        var title = new EditableTitle () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.BASELINE,
            margin_start = 16,
            margin_top = 9,
            margin_bottom = 9,
        };
        title.add_css_class (Granite.STYLE_CLASS_H1_LABEL);
        notify["recipe"].connect (() => {
            title.text = recipe?.title ?? "";
        });
        return title;
    }

    private Gtk.MenuButton create_unit_system_switcher () {
        var any_check_btn = new Gtk.CheckButton.with_label (_("Original")) {
            tooltip_text = _("Shouw amounts using original units"),
            active = true,
            action_name = "recipe.change-unit-system",
            action_target = new Variant.string ("original"),
        };
        any_check_btn.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var metric_check_btn = new Gtk.CheckButton.with_label (_("Metric")) {
            tooltip_text = _("Show amounts using metric units"),
            group = any_check_btn,
            action_name = "recipe.change-unit-system",
            action_target = new Variant.string ("metric"),
        };
        metric_check_btn.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var imperial_check_btn = new Gtk.CheckButton.with_label (_("Imperial")) {
            tooltip_text = _("Show amounts using imperial units"),
            group = any_check_btn,
            action_name = "recipe.change-unit-system",
            action_target = new Variant.string ("imperial"),
        };
        imperial_check_btn.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var column = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
        column.append (any_check_btn);
        column.append (metric_check_btn);
        column.append (imperial_check_btn);

        var unit_system_popover = new Gtk.Popover () {
            child = column,
        };
        unit_system_popover.add_css_class (Granite.STYLE_CLASS_MENU);

        return new Gtk.MenuButton () {
            icon_name = "applications-science-symbolic",
            popover = unit_system_popover,
            valign = Gtk.Align.START,
            margin_end = 3,
            margin_top = 3,
        };
    }

    private Gtk.MenuButton create_yield_switcher () {
        var column = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
        add_yield_options (column);
        notify["recipe"].connect (() => add_yield_options (column));

        var yield_popover = new Gtk.Popover () {
            child = column,
        };
        yield_popover.add_css_class (Granite.STYLE_CLASS_MENU);

        return new Gtk.MenuButton () {
            icon_name = "zoom-in-symbolic",
            popover = yield_popover,
            valign = Gtk.Align.START,
            margin_end = 3,
            margin_top = 3,
        };
    }

    private void add_yield_options (Gtk.Box column) {
        clear (column);

        var fitting_yield = extract_most_fitting_yield ();
        if (fitting_yield == null || fitting_yield.unit == null) {
            var half_btn = new Gtk.CheckButton.with_label (_("Half yield")) {
                tooltip_text = _("Shouw amounts for half the yield"),
                action_name = "recipe.change-yield",
                action_target = new Variant.double (0.5),
            };
            half_btn.add_css_class (Granite.STYLE_CLASS_MENUITEM);
            column.append (half_btn);

            var original_btn = new Gtk.CheckButton.with_label (_("Original yield")) {
                tooltip_text = _("Show amounts for the original recipe yield"),
                active = true,
                group = half_btn,
                action_name = "recipe.change-yield",
                action_target = new Variant.double (1.0),
            };
            original_btn.add_css_class (Granite.STYLE_CLASS_MENUITEM);
            column.append (original_btn);

            var double_btn = new Gtk.CheckButton.with_label (_("Double yield")) {
                tooltip_text = _("Show amounts for double the yield"),
                group = half_btn,
                action_name = "recipe.change-yield",
                action_target = new Variant.double (2.0),
            };
            double_btn.add_css_class (Granite.STYLE_CLASS_MENUITEM);
            column.append (double_btn);
        } else {
            var halver = new MultiplierBasedAmountConverter (0.5);
            var half_yield = halver.convert_if_you_can (fitting_yield);
            var half_btn = new Gtk.CheckButton.with_label (half_yield.to_string ()) {
                tooltip_text = _("Shouw amounts for %s").printf (half_yield.to_string ()),
                action_name = "recipe.change-yield",
                action_target = new Variant.double (0.5),
            };
            half_btn.add_css_class (Granite.STYLE_CLASS_MENUITEM);
            column.append (half_btn);

            var original_btn = new Gtk.CheckButton.with_label (fitting_yield.to_string ()) {
                tooltip_text = _("Show amounts for %s").printf (fitting_yield.to_string ()),
                active = true,
                group = half_btn,
                action_name = "recipe.change-yield",
                action_target = new Variant.double (1.0),
            };
            original_btn.add_css_class (Granite.STYLE_CLASS_MENUITEM);
            column.append (original_btn);

            var doubler = new MultiplierBasedAmountConverter (2.0);
            var double_yield = doubler.convert_if_you_can (fitting_yield);
            var double_btn = new Gtk.CheckButton.with_label (double_yield.to_string ()) {
                tooltip_text = _("Show amounts for %s").printf (double_yield.to_string ()),
                group = half_btn,
                action_name = "recipe.change-yield",
                action_target = new Variant.double (2.0),
            };
            double_btn.add_css_class (Granite.STYLE_CLASS_MENUITEM);
            column.append (double_btn);
        }
    }

    private void clear (Gtk.Box container) {
        var el = container.get_first_child ();
        while (el != null) {
            var next = el.get_next_sibling ();
            container.remove (el);
            el.unparent ();
            el = next;
        }
    }

    private Amount? extract_most_fitting_yield () {
        if (recipe == null || recipe.yields == null || recipe.yields.is_empty) {
            return null;
        }
        var yields = recipe.yields;

        var unitless = yields.first_match ((a) => a.unit == null);
        if (unitless != null) {
            return unitless;
        }

        var quantity = yields.first_match ((a) => a.unit.kind == UnitKind.QUANTITY);
        if (quantity != null) {
            return quantity;
        }

        return yields[0];
    }

    public override void dispose () {
        header.unparent ();
    }

}
