/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.IngredientGroup : Object {

    public string? title { get; set; }
    public Gee.List<Ingredient> ingredients { get; set; }

    public string to_string () {
        var sb = new StringBuilder ();
        for (var i = 0; i < ingredients.size; i++) {
            sb.append ("- ");
            sb.append (ingredients[i].to_string ());
            if (i < ingredients.size - 1) {
                sb.append ("\n");
            }
        }
        if (title == null) {
            return sb.str;
        } else {
            return "## %s\n\n%s".printf (title, sb.str);
        }
    }
}
