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
            new AmountMatcher (
                "(\\d+)\\s+([\\x{00BC}-\\x{00BE}\\x{2150}-\\x{215E}])\\s*(.*)",
                mi => double.parse (mi.fetch (1)) +
                    unicode_char_to_fraction (mi.fetch (2)),
                mi => mi.fetch (3)
            ),
            // proper fraction (5/6)
            new AmountMatcher (
                "(\\d+)\\s*/\\s*(\\d+)\\s*(.*)",
                mi => double.parse (mi.fetch (1)) / double.parse (mi.fetch (2)),
                mi => mi.fetch (3)
            ),
            // proper fraction with unicode vulgar fraction (⅚)
            new AmountMatcher (
                "([\\x{00BC}-\\x{00BE}\\x{2150}-\\x{215E}])\\s*(.*)",
                mi => unicode_char_to_fraction (mi.fetch (1)),
                mi => mi.fetch (2)
            ),
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
            ),
            // no amount value
            new AmountMatcher (
                "\\s*(.*)",
                mi => 1.0,
                mi => mi.fetch (1)
            )
        };
    }

    private static double unicode_char_to_fraction (string? s) throws ParsingError {
        switch (s) {
            case null: return 0.0;
            case "¼": return 0.25;
            case "½": return 0.5;
            case "¾": return 0.75;
            case "⅐": return 1.0/7;
            case "⅑": return 1.0/9;
            case "⅒": return 0.1;
            case "⅓": return 1.0/3;
            case "⅔": return 2.0/3;
            case "⅕": return 0.2;
            case "⅖": return 0.4;
            case "⅗": return 0.6;
            case "⅘": return 0.8;
            case "⅙": return 1.0/6;
            case "⅚": return 5.0/6;
            case "⅛": return 1.0/8;
            case "⅜": return 3.0/8;
            case "⅝": return 5.0/8;
            case "⅞": return 7.0/8;
            default:
                var err_tmpl = "Expected a fraction character, but it was %s";
                var err_msg = err_tmpl.printf (s);
                throw new ParsingError.INVALID (err_msg);
        }
    }

    public Amount parse () throws ParsingError {
        if (raw_amount == null) {
            var err_msg = "Expected an amount, but it was empty";
            throw new ParsingError.INVALID (err_msg);
        }

        var cleaned_amount = raw_amount.chomp ().chug ();
        if (cleaned_amount.length == 0) {
            var err_msg = "Expected an amount, but it was empty";
            throw new ParsingError.INVALID (err_msg);
        }

        foreach (var matcher in matchers) {
            try {
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
            } catch (RegexError regexp_err) {
                warning ("Regex error %s while parsing an amout `%s`".printf (
                    regexp_err.message,
                    raw_amount
                ));
            }
        }

        var err_msg = "Expected an amount, but got %s".printf (raw_amount);
        throw new ParsingError.INVALID (err_msg);
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

    public double? get_value() throws ParsingError {
        if (match_info != null) {
            return value_extractor (match_info);
        } else {
            return null;
        }
    }

    public string? get_unit_name() throws ParsingError {
        if (match_info != null) {
            var extracted = unit_name_extractor (match_info);
            var cleaned = extracted?.chomp ()?.chug () ?? "";
            return cleaned == "" ? null : cleaned;
        } else {
            return null;
        }
    }
}

private delegate double Souschef.ValueExtractor (
    MatchInfo match_info
) throws ParsingError;
private delegate string Souschef.UnitNameExtractor (
    MatchInfo match_info
) throws ParsingError;
