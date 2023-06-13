/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.Unit : Object {

    public UnitKind kind { get; set; default = UnitKind.QUANTITY; }
    public UnitSystem system { get; set; default = UnitSystem.UNIVERSAL; }
    public string name { get; set; }
    public string? symbol { get; set; default = null; }
    public Unit? referent_unit { get; set; default = null; }
    public double ratio_to_referent_unit { get; set; default = 1.0; }

    public virtual double to_referent_unit (double value_in_this_unit) {
        return ratio_to_referent_unit * value_in_this_unit;
    }

    public virtual double from_referent_unit (double value_in_referent_unit) {
        return value_in_referent_unit / ratio_to_referent_unit;
    }

}

public enum Souschef.UnitKind {
    TIME,
    MASS,
    LENGTH,
    VOLUME,
    QUANTITY,
    TEMPERATURE,
}

public enum Souschef.UnitSystem {
    METRIC,
    CHINESE,
    IMPERIAL,
    UNIVERSAL,
}

