/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.Unit : Object {

    public string kind { get; set; }
    public string system { get; set; }
    public string name { get; set; }
    public string symbol { get; set; }
    public Unit? referentUnit { get; set; }
    public double ratioToReferentUnit { get; set; }

}
