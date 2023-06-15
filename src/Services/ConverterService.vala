/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.ConverterService : Object {

    public DatabaseService db_service { private get; construct; }
    public RecipesService recipes_service { private get; construct; }

    public AmountConverter converter {
        get;
        private set;
        default = new IdentityAmountConverter ();
    }
    public PreferredUnitSystem preferred_unit_system {
        get;
        set;
        default = PreferredUnitSystem.ORIGINAL;
    }
    public double yield_factor { get; set; default = 1.0; }

    public ConverterService (
        DatabaseService db_service,
        RecipesService recipes_service
    ) {
        Object (
            db_service: db_service,
            recipes_service: recipes_service
        );
        connect_listeners ();
    }

    static construct {
        new Units (); // Initialize static units.
    }

    private void connect_listeners () {
        notify["preferred-unit-system"].connect (update_converter);
        notify["yield-factor"].connect (update_converter);
    }

    private void update_converter () {
        AmountConverter system_converter;
        switch (preferred_unit_system) {
            case METRIC:
                system_converter = new PreferenceBasedAmountConverter.to_metric ();
                break;
            case IMPERIAL:
                system_converter = new PreferenceBasedAmountConverter.to_imperial ();
                break;
            default:
                system_converter = new IdentityAmountConverter ();
                break;
        }

        AmountConverter scale_converter;
        if (yield_factor != 1.0) {
            scale_converter = new MultiplierBasedAmountConverter (yield_factor);
        } else {
            scale_converter = new IdentityAmountConverter ();
        }

        var converters = new Gee.ArrayList<AmountConverter>.wrap (
            { system_converter, scale_converter }
        );
        converter = new CompositeAmountConverter (converters);
    }

}

public enum Souschef.PreferredUnitSystem {
    METRIC,
    ORIGINAL,
    IMPERIAL,
}

