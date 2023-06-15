/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.PreferenceBasedAmountConverter : AmountConverter, Object {

    public Gee.Map<Unit, Unit> preferences { get; construct; }

    public PreferenceBasedAmountConverter (Gee.Map<Unit, Unit> preferences) {
        // TODO: validate that unit conversions in preferences are possible.
        Object (preferences: preferences);
    }

    public PreferenceBasedAmountConverter.to_imperial () {
        var pref = new Gee.HashMap<Unit, Unit> (
            unit_hash,
            unit_equal
        );

        pref[Units.GRAM] = Units.DRAM;
        pref[Units.DECIGRAM] = Units.GRAIN;
        pref[Units.CENTIGRAM] = Units.GRAIN;
        pref[Units.MILLIGRAM] = Units.GRAIN;
        pref[Units.DEKAGRAM] = Units.OUNCE;
        pref[Units.HECTOGRAM] = Units.POUND;
        pref[Units.KILOGRAM] = Units.POUND;
        pref[Units.MACE] = Units.OUNCE;
        pref[Units.CANDAREEN] = Units.GRAIN;
        pref[Units.CASH] = Units.DRAM;
        pref[Units.METER] = Units.YARD;
        pref[Units.DECIMETER] = Units.FOOT;
        pref[Units.CENTIMETER] = Units.INCH;
        pref[Units.MILLIMETER] = Units.INCH;
        pref[Units.DEKAMETER] = Units.YARD;
        pref[Units.HECTOMETER] = Units.YARD;
        pref[Units.KILOMETER] = Units.MILE;
        pref[Units.CUN] = Units.INCH;
        pref[Units.CHI] = Units.YARD;
        pref[Units.LI] = Units.MILE;
        pref[Units.LITER] = Units.PINT;
        pref[Units.DECILITER] = Units.CUP;
        pref[Units.CENTILITER] = Units.TABLESPOON;
        pref[Units.MILLILITER] = Units.TEASPOON;
        pref[Units.DEKALITER] = Units.GALLON;
        pref[Units.HECTOLITER] = Units.GALLON;
        pref[Units.KILOLITER] = Units.GALLON;
        pref[Units.CUBIC_METER] = Units.GALLON;
        pref[Units.CUBIC_DECIMETER] = Units.PINT;
        pref[Units.CUBIC_CENTIMETER] = Units.TEASPOON;
        pref[Units.CUBIC_MILLIMETER] = Units.DROP;
        pref[Units.CELSIUS] = Units.FAHRENHEIT;

        this (pref);
    }

    public PreferenceBasedAmountConverter.to_metric () {
        var pref = new Gee.HashMap<Unit, Unit> (
            unit_hash,
            unit_equal
        );

        pref[Units.HUNDERWEIGHT] = Units.KILOGRAM;
        pref[Units.QUARTER] = Units.KILOGRAM;
        pref[Units.STONE] = Units.KILOGRAM;
        pref[Units.POUND] = Units.KILOGRAM;
        pref[Units.OUNCE] = Units.DEKAGRAM;
        pref[Units.DRAM] = Units.GRAM;
        pref[Units.GRAIN] = Units.MILLIGRAM;
        pref[Units.PICUL] = Units.KILOGRAM;
        pref[Units.CATTY] = Units.KILOGRAM;
        pref[Units.TAEL] = Units.DEKAGRAM;
        pref[Units.MACE] = Units.DEKAGRAM;
        pref[Units.CANDAREEN] = Units.GRAM;
        pref[Units.CASH] = Units.MILLIGRAM;
        pref[Units.INCH] = Units.CENTIMETER;
        pref[Units.FOOT] = Units.DECIMETER;
        pref[Units.YARD] = Units.METER;
        pref[Units.MILE] = Units.KILOMETER;
        pref[Units.CUN] = Units.CENTIMETER;
        pref[Units.CHI] = Units.METER;
        pref[Units.LI] = Units.KILOMETER;
        pref[Units.DROP] = Units.MILLILITER;
        pref[Units.SMIDGEN] = Units.MILLILITER;
        pref[Units.PINCH] = Units.MILLILITER;
        pref[Units.DASH] = Units.MILLILITER;
        pref[Units.SALTSPOON] = Units.MILLILITER;
        pref[Units.SCRUPLE] = Units.MILLILITER;
        pref[Units.COFFEESPOON] = Units.MILLILITER;
        pref[Units.FLUID_DRAM] = Units.MILLILITER;
        pref[Units.TEASPOON] = Units.MILLILITER;
        pref[Units.DESSERTSPOON] = Units.MILLILITER;
        pref[Units.TABLESPOON] = Units.DECILITER;
        pref[Units.FLUID_OUNCE] = Units.DECILITER;
        pref[Units.WINEGLASS] = Units.DECILITER;
        pref[Units.GILL] = Units.DECILITER;
        pref[Units.TEACUP] = Units.DECILITER;
        pref[Units.CUP] = Units.DECILITER;
        pref[Units.PINT] = Units.LITER;
        pref[Units.QUART] = Units.LITER;
        pref[Units.GALLON] = Units.LITER;
        pref[Units.FAHRENHEIT] = Units.CELSIUS;
        pref[Units.KELVIN] = Units.CELSIUS;

        this (pref);
    }

    public bool can_convert (Amount starting_amount) {
        var starting_unit = starting_amount.unit;
        if (starting_unit == null) {
            return false;
        }

        return preferences.has_key (starting_unit);
    }

    public Amount? convert (Amount starting_amount) {
        if (!can_convert (starting_amount)) {
            return null;
        }

        var starting_unit = starting_amount.unit;
        var prefered_unit = preferences[starting_unit];
        return starting_amount.to_unit (prefered_unit);
    }

    public Amount convert_if_you_can (Amount starting_amount) {
        return convert (starting_amount) ?? starting_amount;
    }

    private static uint unit_hash (Unit u) {
        if (u == null) {
            return (uint)0xdeadbeef;
        } else {
            return str_hash (u.name);
        }
    }

    private static bool unit_equal (Unit u1, Unit u2) {
        if (u1 == u2) {
            return true;
        } else if (u1 == null || u2 == null) {
            return false;
        } else {
            return str_equal (u1.name, u2.name);
        }
    }
}
