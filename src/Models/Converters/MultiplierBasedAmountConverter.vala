/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.MultiplierBasedAmountConverter : AmountConverter, Object {

    public double multiplier { get; construct; }

    public MultiplierBasedAmountConverter (double multiplier) {
        Object (multiplier: multiplier);
    }

    public bool can_convert (Amount starting_amount) {
        return true;
    }

    public Amount? convert (Amount starting_amount) {
        return new Amount () {
            value = starting_amount.value * multiplier,
            unit = starting_amount.unit,
        };
    }

    public Amount convert_if_you_can (Amount starting_amount) {
        return convert (starting_amount);
    }

    public AmountConverter? inverse () {
        if (multiplier == 0.0) {
            return this;
        }

        return new MultiplierBasedAmountConverter (1.0 / multiplier);
    }

}
