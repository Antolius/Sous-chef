/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.Amount : Object {

    public double @value { get; set; }
    public Unit? unit { get; set; }

    public Amount to_referent_unit () {
        if (unit != null && unit.referent_unit != null) {
            return new Amount () {
                value = unit.to_referent_unit (this.value),
                unit = unit.referent_unit,
            };
        } else {
            return this;
        }
    }
}
