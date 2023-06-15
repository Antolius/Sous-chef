/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.Amount : Object {

    public double @value { get; set; }
    public Unit? unit { get; set; }

    public Amount? to_referent_unit () {
        if (unit != null) {
            return new Amount () {
                value = unit.to_referent_unit (this.value),
                unit = unit.referent_unit ?? unit,
            };
        } else {
            return null;
        }
    }

    public Amount? to_unit (Unit target_unit) {
        if (unit == null) {
            return null;
        }

        if (unit == target_unit) {
            return this;
        }

        if (unit.referent_unit == null && target_unit.referent_unit == null) {
            return null;
        }

        if (unit.referent_unit == target_unit) {
            return new Amount () {
                value = unit.to_referent_unit (value),
                unit = target_unit,
            };
        }

        if (unit == target_unit.referent_unit) {
            return new Amount () {
                value = target_unit.from_referent_unit (value),
                unit = target_unit,
            };
        }

        if (unit.referent_unit == target_unit.referent_unit) {
            return new Amount () {
                value = target_unit.from_referent_unit (
                    unit.to_referent_unit (value)
                ),
                unit = target_unit,
            };
        }

        return null;
    }

    public string to_string () {
        // TODO: implement fractions etc.
        var val_str = value.to_string ();
        if (unit != null) {
            return "%s %s".printf (val_str, unit.to_string ());
        } else {
            return val_str;
        }
    }
}
