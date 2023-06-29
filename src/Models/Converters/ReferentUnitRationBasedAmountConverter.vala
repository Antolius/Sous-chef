/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.ReferentUnitRationBasedAmountConverter : AmountConverter, Object {

    public double referent_unit_ratio { get; construct; }
    public Unit target_unit { get; construct; }

    public ReferentUnitRationBasedAmountConverter (
        double referent_unit_ratio,
        Unit target_unit
    ) {
        Object (
            referent_unit_ratio: referent_unit_ratio,
            target_unit: target_unit
        );
    }

    public bool can_convert (Amount starting_amount) {
        var starting_unit = starting_amount.unit;
        if (starting_unit == null) {
            return false;
        }

        return true;
    }

    public Amount? convert (Amount starting_amount) {
        if (!can_convert (starting_amount)) {
            return null;
        }

        var referent_source_amount = starting_amount.to_referent_unit ();
        var referent_target_amount = new Amount () {
            value = referent_source_amount.value * referent_unit_ratio,
            unit = target_unit.referent_unit ?? target_unit,
        };
        return referent_target_amount.to_unit (target_unit);
    }

    public Amount convert_if_you_can (Amount starting_amount) {
        return convert (starting_amount) ?? starting_amount;
    }

    public AmountConverter? inverse () {
        return null;
    }

}
