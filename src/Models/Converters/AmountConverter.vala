/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public interface Souschef.AmountConverter : Object {

    // Returns true if specific converter can be applied to the starting_amount
    public abstract bool can_convert (Amount starting_amount);

    // Return converted amount or null if converter cannot convert starting_amount
    public abstract Amount? convert (Amount starting_amount);

    // Return converted amount or starting_amount if it cannot be converted
    public abstract Amount convert_if_you_can (Amount starting_amount);

    // Return an inverse converters if it exists, null otherwise
    public abstract AmountConverter? inverse ();

}
