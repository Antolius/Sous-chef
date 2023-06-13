/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
*/

namespace Souschef.ConversionTests {

    public void add_funcs () {
        Test.add_func ("/Amount/conversions", test_conversions);
    }

    void test_conversions () {
        new Units ();
        assert_nonnull (Units.GRAM);
        assert_nonnull (Units.KILOGRAM.referent_unit);

        var given = new Amount () {
            value = 1.0,
        };
        assert_null (given.to_unit (Units.GRAM));

        given = new Amount () {
            value = 1.0,
            unit = Units.GRAM,
        };
        assert_true (given == given.to_unit (Units.GRAM));

        given = new Amount () {
            value = 1.0,
            unit = Units.KILOGRAM,
        };
        var actual = given.to_unit (Units.GRAM);
        assert_true (actual.unit == Units.GRAM);
        assert_true (actual.value == 1000.0);

        given = new Amount () {
            value = 1000.0,
            unit = Units.GRAM,
        };
        actual = given.to_unit (Units.KILOGRAM);
        assert_true (actual.unit == Units.KILOGRAM);
        assert_true (actual.value == 1.0);

        given = new Amount () {
            value = 10.0,
            unit = Units.DEKAGRAM,
        };
        actual = given.to_unit (Units.MILLIGRAM);
        assert_true (actual.unit == Units.MILLIGRAM);
        assert_true (actual.value == 100000.0);

        given = new Amount () {
            value = 1.0,
            unit = Units.GRAM,
        };
        assert_null (given.to_unit (Units.METER));

        given = new Amount () {
            value = 1.0,
            unit = Units.GRAM,
        };
        assert_null (given.to_unit (Units.MILLILITER));

        given = new Amount () {
            value = 1.0,
            unit = Units.KILOGRAM,
        };
        assert_null (given.to_unit (Units.LITER));

        given = new Amount () {
            value = 1.0,
            unit = Units.KILOGRAM,
        };
        assert_null (given.to_unit (Units.MILLILITER));

        given = new Amount () {
            value = 2.0,
            unit = Units.TABLESPOON,
        };
        actual = given.to_unit (Units.MILLILITER);
        assert_true (actual.unit == Units.MILLILITER);
        assert_true (actual.value == 29.5736);
    }

}
