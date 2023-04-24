/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.AmountParser : Object {

    public string raw_amount { get; construct; }

    private AmountMatcher[] matchers;

    public AmountParser (string raw_amount) {
        Object (raw_amount: raw_amount);
    }

    construct {
        // Adapted from the reference implementation:
        matchers = {
            // improper fraction (1 1/2)
            new AmountMatcher (
                "(\\d+)\\s+(\\d+)\\s*/\\s*(\\d+)\\s*(.*)",
                mi => double.parse (mi.fetch (1)) +
                    (double.parse (mi.fetch (2)) / double.parse (mi.fetch (3))),
                mi => mi.fetch (4)
            ),
            // improper fraction with unicode vulgar fraction (1 ½)
            // new AmountMatcher (
            //     "(\\d+)\\s+([\\u00BC-\\u00BE\\u2150-\\u215E])\\s*(.*)",
            //     mi => double.parse (mi.fetch (1)) +
            //         unicode_char_to_fraction (mi.fetch (2)),
            //     mi => mi.fetch (3)
            // ),
            // proper fraction (5/6)
            new AmountMatcher (
                "(\\d+)\\s*/\\s*(\\d+)\\s*(.*)",
                mi => double.parse (mi.fetch (1)) / double.parse (mi.fetch (2)),
                mi => mi.fetch (3)
            ),
            // proper fraction with unicode vulgar fraction (⅚)
            // new AmountMatcher (
            //     "([\\u00BC-\\u00BE\\u2150-\\u215E])\\s*(.*)",
            //     mi => unicode_char_to_fraction (mi.fetch (1)),
            //     mi => mi.fetch (2)
            // ),
            // decimal (5,4 or 5.6)
            new AmountMatcher (
                "(\\d*)[.,](\\d+)\\s*(.*)",
                mi => double.parse (mi.fetch (1) + "." + mi.fetch (2)),
                mi => mi.fetch (3)
            ),
            // integer (4)
            new AmountMatcher (
                "(\\d+)\\s*(.*)",
                mi => double.parse (mi.fetch (1)),
                mi => mi.fetch (2)
            )
        };
    }

    private static double unicode_char_to_fraction (string? s) {
        return 0.0;
    }

    public Amount parse () {
        if (raw_amount == null) {
            return new Amount () {
                @value = 0,
            };
        }

        var cleaned_amount = raw_amount.chomp ().chug ();
        if (cleaned_amount.length == 0) {
            return new Amount () {
                @value = 0,
            };
        }

        foreach (var matcher in matchers) {
            if (matcher.match (cleaned_amount)) {
                var val = matcher.get_value ();
                var unit_name = matcher.get_unit_name ();
                var unit = unit_name != null ? new Unit () {
                    name = unit_name,
                } : null;
                return new Amount () {
                    value = val,
                    unit = unit,
                };
            }
        }

        // TODO: actually parse value and unit!
        return new Amount () {
            @value = 0,
        };
    }

}

private class Souschef.AmountMatcher : Object {

    private string pattern;
    private ValueExtractor value_extractor;
    private UnitNameExtractor unit_name_extractor;

    private MatchInfo? match_info;

    public AmountMatcher (
        string pattern,
        ValueExtractor value_extractor,
        UnitNameExtractor unit_name_extractor
    ) {
        this.pattern = pattern;
        this.value_extractor = (mi) => value_extractor (mi);
        this.unit_name_extractor = (mi) => unit_name_extractor (mi);
    }

    public bool match (string raw_amount) throws RegexError {
        var regex = new Regex (pattern);
        return regex.match (raw_amount, 0, out match_info);
    }

    public double? get_value() {
        if (match_info != null) {
            return value_extractor (match_info);
        } else {
            return null;
        }
    }

    public string? get_unit_name() {
        if (match_info != null) {
            var extracted = unit_name_extractor (match_info);
            var cleaned = extracted?.chomp ()?.chug () ?? "";
            return cleaned == "" ? null : cleaned;
        } else {
            return null;
        }
    }
}

private delegate double ValueExtractor (MatchInfo match_info);
private delegate string UnitNameExtractor (MatchInfo match_info);
