/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.Recipe : Object {

    public int id { get; set; }
    public string title { get; set; }
    public string? description { get; set; }
    public Gee.List<Tag> tags { get; set; }
    public Gee.List<Amount> @yields { get; set; }
    public Gee.Map<string, Gee.List<Ingredient>> ingredientGroups{ get; set; }
    public string? instructions { get; set; }

}
