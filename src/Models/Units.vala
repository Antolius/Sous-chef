/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.Units {

    public static Unit NONE = new Unit () {
        name = "",
    };

// Time units

    public static Unit SECOND = new Unit () {
        kind = UnitKind.TIME,
        system = UnitSystem.UNIVERSAL,
        name = "second",
        symbol = "s",
    };

    public static Unit MINUTE = new Unit () {
        kind = UnitKind.TIME,
        system = UnitSystem.UNIVERSAL,
        name = "minute",
        symbol = "min",
        referent_unit = SECOND,
        ratio_to_referent_unit = 60.0,
    };

    public static Unit HOUR = new Unit () {
        kind = UnitKind.TIME,
        system = UnitSystem.UNIVERSAL,
        name = "hour",
        symbol = "h",
        referent_unit = SECOND,
        ratio_to_referent_unit = 60.0 * 60.0,
    };

    public static Unit DAY = new Unit () {
        kind = UnitKind.TIME,
        system = UnitSystem.UNIVERSAL,
        name = "day",
        referent_unit = SECOND,
        ratio_to_referent_unit = 60.0 * 60.0 * 24.0,
    };

// Mass units

    public static Unit GRAM = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.METRIC,
        name = "gram",
        symbol = "g",
    };

    public static Unit DECIGRAM = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.METRIC,
        name = "decigram",
        symbol = "dg",
        referent_unit = GRAM,
        ratio_to_referent_unit = 1.0 / 10.0,
    };

    public static Unit CENTIGRAM = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.METRIC,
        name = "centigram",
        referent_unit = GRAM,
        symbol = "cg",
        ratio_to_referent_unit = 1.0 / 100.0,
    };

    public static Unit MILLIGRAM = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.METRIC,
        name = "milligram",
        referent_unit = GRAM,
        symbol = "mg",
        ratio_to_referent_unit = 1.0 / 1000.0,
    };

    public static Unit DEKAGRAM = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.METRIC,
        name = "dekagram",
        referent_unit = GRAM,
        symbol = "dag",
        ratio_to_referent_unit = 10.0,
    };

    public static Unit HECTOGRAM = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.METRIC,
        name = "hectogram",
        referent_unit = GRAM,
        symbol = "hg",
        ratio_to_referent_unit = 100.0,
    };

    public static Unit KILOGRAM = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.METRIC,
        name = "kilogram",
        referent_unit = GRAM,
        symbol = "kg",
        ratio_to_referent_unit = 1000.0,
    };

    public static Unit HUNDERWEIGHT = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.IMPERIAL,
        name = "hunderweight",
        referent_unit = GRAM,
        symbol = "cwt",
        ratio_to_referent_unit = 50800.0,
    };

    public static Unit QUARTER = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.IMPERIAL,
        name = "quarter",
        referent_unit = GRAM,
        symbol = "qtr",
        ratio_to_referent_unit = 12700.0,
    };

    public static Unit STONE = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.IMPERIAL,
        name = "stone",
        referent_unit = GRAM,
        symbol = "st",
        ratio_to_referent_unit = 6350.0,
    };

    public static Unit POUND = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.IMPERIAL,
        name = "pound",
        referent_unit = GRAM,
        symbol = "lb",
        ratio_to_referent_unit = 454.0,
    };

    public static Unit OUNCE = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.IMPERIAL,
        name = "ounce",
        referent_unit = GRAM,
        symbol = "oz",
        ratio_to_referent_unit = 28.350,
    };

    public static Unit DRAM = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.IMPERIAL,
        name = "dram",
        referent_unit = GRAM,
        symbol = "dr",
        ratio_to_referent_unit = 1.772,
    };

    public static Unit GRAIN = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.IMPERIAL,
        name = "grain",
        referent_unit = GRAM,
        symbol = "gr",
        ratio_to_referent_unit = 0.0648,
    };

    public static Unit PICUL = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.CHINESE,
        name = "picul",
        referent_unit = GRAM,
        symbol = "dàn",
        ratio_to_referent_unit = 50000,
    };

    public static Unit CATTY = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.CHINESE,
        name = "catty",
        referent_unit = GRAM,
        symbol = "jīn",
        ratio_to_referent_unit = 500,
    };

    public static Unit TAEL = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.CHINESE,
        name = "tael",
        referent_unit = GRAM,
        symbol = "liǎng",
        ratio_to_referent_unit = 50,
    };

    public static Unit MACE = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.CHINESE,
        name = "mace",
        referent_unit = GRAM,
        symbol = "qián",
        ratio_to_referent_unit = 5,
    };

    public static Unit CANDAREEN = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.CHINESE,
        name = "candareen",
        referent_unit = GRAM,
        symbol = "fēn",
        ratio_to_referent_unit = 0.5,
    };

    public static Unit CASH = new Unit () {
        kind = UnitKind.MASS,
        system = UnitSystem.CHINESE,
        name = "cash",
        referent_unit = GRAM,
        symbol = "lí",
        ratio_to_referent_unit = 0.05,
    };

// Length units

    public static Unit METER = new Unit () {
        kind = UnitKind.LENGTH,
        system = UnitSystem.METRIC,
        name = "meter",
        symbol = "m",
    };

    public static Unit DECIMETER = new Unit () {
        kind = UnitKind.LENGTH,
        system = UnitSystem.METRIC,
        name = "decimeter",
        symbol = "dm",
        referent_unit = METER,
        ratio_to_referent_unit = 1.0 / 10.0,
    };

    public static Unit CENTIMETER = new Unit () {
        kind = UnitKind.LENGTH,
        system = UnitSystem.METRIC,
        name = "centimeter",
        symbol = "cm",
        referent_unit = METER,
        ratio_to_referent_unit = 1.0 / 100.0,
    };

    public static Unit MILLIMETER = new Unit () {
        kind = UnitKind.LENGTH,
        system = UnitSystem.METRIC,
        name = "millimeter",
        symbol = "mm",
        referent_unit = METER,
        ratio_to_referent_unit = 1.0 / 1000.0,
    };

    public static Unit DEKAMETER = new Unit () {
        kind = UnitKind.LENGTH,
        system = UnitSystem.METRIC,
        name = "dekameter",
        symbol = "dam",
        referent_unit = METER,
        ratio_to_referent_unit = 10,
    };

    public static Unit HECTOMETER = new Unit () {
        kind = UnitKind.LENGTH,
        system = UnitSystem.METRIC,
        name = "hectometer",
        symbol = "hm",
        referent_unit = METER,
        ratio_to_referent_unit = 100,
    };

    public static Unit KILOMETER = new Unit () {
        kind = UnitKind.LENGTH,
        system = UnitSystem.METRIC,
        name = "kilometer",
        symbol = "km",
        referent_unit = METER,
        ratio_to_referent_unit = 1000,
    };

    public static Unit INCH = new Unit () {
        kind = UnitKind.LENGTH,
        system = UnitSystem.IMPERIAL,
        name = "inch",
        symbol = "in",
        referent_unit = METER,
        ratio_to_referent_unit = 0.0254,
    };

    public static Unit FOOT = new Unit () {
        kind = UnitKind.LENGTH,
        system = UnitSystem.IMPERIAL,
        name = "foot",
        symbol = "ft",
        referent_unit = METER,
        ratio_to_referent_unit = 30.48,
    };

    public static Unit YARD = new Unit () {
        kind = UnitKind.LENGTH,
        system = UnitSystem.IMPERIAL,
        name = "yard",
        symbol = "yd",
        referent_unit = METER,
        ratio_to_referent_unit = 91.44,
    };

    public static Unit MILE = new Unit () {
        kind = UnitKind.LENGTH,
        system = UnitSystem.IMPERIAL,
        name = "mile",
        symbol = "mi",
        referent_unit = METER,
        ratio_to_referent_unit = 160934.4,
    };

    public static Unit CUN = new Unit () {
        kind = UnitKind.LENGTH,
        system = UnitSystem.CHINESE,
        name = "cun",
        referent_unit = METER,
        ratio_to_referent_unit = 0.0371475,
    };

    public static Unit CHI = new Unit () {
        kind = UnitKind.LENGTH,
        system = UnitSystem.CHINESE,
        name = "chi",
        referent_unit = METER,
        ratio_to_referent_unit = 1.0 / 3.0,
    };

    public static Unit LI = new Unit () {
        kind = UnitKind.LENGTH,
        system = UnitSystem.CHINESE,
        name = "li",
        referent_unit = METER,
        ratio_to_referent_unit = 576,
    };

// Volume units

    public static Unit LITER = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.METRIC,
        name = "liter",
        symbol = "l",
    };

    public static Unit DECILITER = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.METRIC,
        name = "deciliter",
        symbol = "dL",
        referent_unit = LITER,
        ratio_to_referent_unit = 1.0 / 10.0,
    };

    public static Unit CENTILITER = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.METRIC,
        name = "centiliter",
        symbol = "cL",
        referent_unit = LITER,
        ratio_to_referent_unit = 1.0 / 100.0,
    };

    public static Unit MILLILITER = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.METRIC,
        name = "milliliter",
        symbol = "mL",
        referent_unit = LITER,
        ratio_to_referent_unit = 1.0 / 1000.0,
    };

    public static Unit DEKALITER = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.METRIC,
        name = "dekaliter",
        symbol = "daL",
        referent_unit = LITER,
        ratio_to_referent_unit = 10.0,
    };

    public static Unit HECTOLITER = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.METRIC,
        name = "hectoliter",
        symbol = "hL",
        referent_unit = LITER,
        ratio_to_referent_unit = 100.0,
    };

    public static Unit KILOLITER = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.METRIC,
        name = "kiloliter",
        symbol = "kL",
        referent_unit = LITER,
        ratio_to_referent_unit = 1000.0,
    };

    public static Unit CUBIC_METER = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.METRIC,
        name = "cubic meter",
        symbol = "m³",
        referent_unit = LITER,
        ratio_to_referent_unit = 1000.0,
    };

    public static Unit CUBIC_DECIMETER = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.METRIC,
        name = "cubic decimeter",
        symbol = "dm³",
        referent_unit = LITER,
        ratio_to_referent_unit = 1.0,
    };

    public static Unit CUBIC_CENTIMETER = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.METRIC,
        name = "cubic centimeter",
        symbol = "cm³",
        referent_unit = LITER,
        ratio_to_referent_unit = 1.0 / 1000.0,
    };

    public static Unit CUBIC_MILLIMETER = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.METRIC,
        name = "cubic millimeter",
        symbol = "mm³",
        referent_unit = LITER,
        ratio_to_referent_unit = 1.0 / 1000000.0,
    };

    public static Unit DROP = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "drop",
        symbol = "dr.",
        referent_unit = LITER,
        ratio_to_referent_unit = 0.0513429 / 1000.0,
    };

    public static Unit SMIDGEN = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "smidgen",
        symbol = "smdg.",
        referent_unit = LITER,
        ratio_to_referent_unit = 0.115522 / 1000.0,
    };

    public static Unit PINCH = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "pinch",
        symbol = "pn.",
        referent_unit = LITER,
        ratio_to_referent_unit = 0.231043 / 1000.0,
    };

    public static Unit DASH = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "dash",
        symbol = "ds.",
        referent_unit = LITER,
        ratio_to_referent_unit = 0.462086 / 1000.0,
    };

    public static Unit SALTSPOON = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "saltspoon",
        symbol = "ssp.",
        referent_unit = LITER,
        ratio_to_referent_unit = 0.924173 / 1000.0,
    };

    public static Unit SCRUPLE = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "scruple",
        referent_unit = LITER,
        ratio_to_referent_unit = 0.924173 / 1000.0,
    };

    public static Unit COFFEESPOON = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "coffeespoon",
        symbol = "csp.",
        referent_unit = LITER,
        ratio_to_referent_unit = 1.84835 / 1000.0,
    };

    public static Unit FLUID_DRAM = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "fluid dram",
        symbol = "fl.dr.",
        referent_unit = LITER,
        ratio_to_referent_unit = 3.69669 / 1000.0,
    };

    public static Unit TEASPOON = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "teaspoon",
        symbol = "tsp.",
        referent_unit = LITER,
        ratio_to_referent_unit = 4.92892 / 1000.0,
    };

    public static Unit DESSERTSPOON = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "dessertspoon",
        symbol = "dsp.",
        referent_unit = LITER,
        ratio_to_referent_unit = 9.85784 / 1000.0,
    };

    public static Unit TABLESPOON = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "tablespoon",
        symbol = "tbsp.",
        referent_unit = LITER,
        ratio_to_referent_unit = 14.7868 / 1000.0,
    };

    public static Unit FLUID_OUNCE = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "fluid ounce",
        symbol = "fl.oz.",
        referent_unit = LITER,
        ratio_to_referent_unit = 29.5735 / 1000.0,
    };

    public static Unit WINEGLASS = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "wineglass",
        symbol = "wgf.",
        referent_unit = LITER,
        ratio_to_referent_unit = 59.1471 / 1000.0,
    };

    public static Unit GILL = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "gill",
        referent_unit = LITER,
        ratio_to_referent_unit = 118.294 / 1000.0,
    };

    public static Unit TEACUP = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "teacup",
        symbol = "tcf.",
        referent_unit = LITER,
        ratio_to_referent_unit = 118.294 / 1000.0,
    };

    public static Unit CUP = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "cup",
        symbol = "C",
        referent_unit = LITER,
        ratio_to_referent_unit = 236.588 / 1000.0,
    };

    public static Unit PINT = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "pint",
        symbol = "pt.",
        referent_unit = LITER,
        ratio_to_referent_unit = 473.176 / 1000.0,
    };

    public static Unit QUART = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "quart",
        symbol = "qt.",
        referent_unit = LITER,
        ratio_to_referent_unit = 946.353 / 1000.0,
    };

    public static Unit GALLON = new Unit () {
        kind = UnitKind.VOLUME,
        system = UnitSystem.IMPERIAL,
        name = "gallon",
        symbol = "gal.",
        referent_unit = LITER,
        ratio_to_referent_unit = 3785.41 / 1000.0,
    };

// Temperature units

    public static Unit CELSIUS = new Unit () {
        kind = UnitKind.TEMPERATURE,
        system = UnitSystem.METRIC,
        name = "Celsius",
        symbol = "°C",
    };

    public static Unit KELVIN = new Kelvin () {
        kind = UnitKind.TEMPERATURE,
        system = UnitSystem.METRIC,
        name = "Kelvin",
        symbol = "K",
        referent_unit = CELSIUS
    };

    public static Unit FAHRENHEIT = new Fahrenheit () {
        kind = UnitKind.TEMPERATURE,
        system = UnitSystem.IMPERIAL,
        name = "Fahrenheit",
        symbol = "°F",
        referent_unit = CELSIUS
    };

// Collection of known units
    public static Gee.List<Unit> ALL = new Gee.ArrayList<Unit>.wrap ({
        GRAM, DECIGRAM, CENTIGRAM, MILLIGRAM, DEKAGRAM, HECTOGRAM, KILOGRAM,
        HUNDERWEIGHT, QUARTER, STONE, POUND, OUNCE, DRAM, GRAIN,
        PICUL, CATTY, TAEL, MACE, CANDAREEN, CASH,
        METER, DECIMETER, CENTIMETER, MILLIMETER, DEKAMETER, HECTOMETER, KILOMETER,
        INCH, FOOT, YARD, MILE,
        CUN, CHI, LI,
        LITER, DECILITER, CENTILITER, MILLILITER, DEKALITER, HECTOLITER, KILOLITER,
        CUBIC_METER, CUBIC_DECIMETER, CUBIC_CENTIMETER, CUBIC_MILLIMETER,
        DROP, SMIDGEN, PINCH, DASH, SALTSPOON, SCRUPLE, COFFEESPOON, FLUID_DRAM, TEASPOON, DESSERTSPOON, TABLESPOON, FLUID_OUNCE, WINEGLASS, GILL, TEACUP, CUP, PINT, QUART, GALLON,
        CELSIUS, KELVIN, FAHRENHEIT,
        SECOND, MINUTE, HOUR, DAY,
    });

}

private class Souschef.Kelvin : Unit {
    public override double to_referent_unit (double value_in_kelvin) {
        return value_in_kelvin - 273.15;
    }

    public override double from_referent_unit (double value_in_celsius) {
        return value_in_celsius + 273.15;
    }
}

private class Souschef.Fahrenheit : Unit {
    public override double to_referent_unit (double value_in_fahrenheit) {
        return (value_in_fahrenheit - 32.0) * 5.0 / 9.0;
    }

    public override double from_referent_unit (double value_in_celsius) {
        return value_in_celsius * 9.0 / 5.0 + 32.0;
    }
}
