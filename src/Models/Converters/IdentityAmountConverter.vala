/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.IdentityAmountConverter : AmountConverter, Object {

    public bool can_convert (Amount starting_amount) {
        return true;
    }

    public Amount? convert (Amount starting_amount) {
        return starting_amount;
    }

    public Amount convert_if_you_can (Amount starting_amount) {
        return starting_amount;
    }

    public AmountConverter? inverse () {
        return this;
    }

}
