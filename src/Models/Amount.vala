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

    public bool equals (Amount? other) {
        if (other == null) {
            return false;
        }

        if (value != other.value) {
            return false;
        }

        if (unit != null) {
            return unit.equals (other.unit);
        }

        return true;
    }

    public string to_string () {
        // TODO: implement fractions etc.
        var val_str = "%g".printf (round(value));
        if (unit != null) {
            return "%s %s".printf (val_str, unit.to_string ());
        } else {
            return val_str;
        }
    }

    private double round (double original) {
        if (original >= 15) {
            return Math.round (original);
        }

        double int_part;
        var frac_part = Math.modf (original, out int_part);
        double[] supported_fractions = {
            0.25,
            0.5,
            0.75,
            1.0/7,
            1.0/9,
            0.1,
            1.0/3,
            2.0/3,
            0.2,
            0.4,
            0.6,
            0.8,
            1.0/6,
            5.0/6,
            1.0/8,
            3.0/8,
            5.0/8,
            7.0/8
        };

        foreach (var supported in supported_fractions) {
            if (supported == frac_part) {
                return original;
            }
        }

        if (int_part >= 1.0) {
            return int_part;
        }

        if (frac_part >= 0.5) {
            return 1.0;
        }

        return frac_part;
    }
}
