/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.CompositeAmountConverter : AmountConverter, Object {

    public Gee.List<AmountConverter> delegates { get; construct; }

    public CompositeAmountConverter (Gee.List<AmountConverter> delegates) {
        Object (delegates: delegates);
    }

    public bool can_convert (Amount starting_amount) {
        return delegates.any_match (c => c.can_convert (starting_amount));
    }

    public Amount? convert (Amount starting_amount) {
        if (!can_convert (starting_amount)) {
            return null;
        }

        return delegates.filter (c => c.can_convert (starting_amount))
            .fold<Amount> ((c, a) => c.convert(a), starting_amount);
    }

    public Amount convert_if_you_can (Amount starting_amount) {
        return convert (starting_amount) ?? starting_amount;
    }

}
