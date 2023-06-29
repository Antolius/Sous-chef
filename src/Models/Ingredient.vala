/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.Ingredient : Object {

    public string name { get; set; }
    public string? link { get; set; }
    public Amount? amount { get; set; }

    public string to_string () {
        string desc;
        if (link == null) {
            desc = name;
        } else {
            desc = "[%s](%s)".printf (name, link);
        }
        if (amount == null) {
            return desc;
        } else {
            return "*%s* %s".printf (amount.to_string (), desc);
        }
    }

}
