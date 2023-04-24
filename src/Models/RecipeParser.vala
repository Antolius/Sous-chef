/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.RecipeParser : Object {

    public int id { get; construct; }
    public string raw_md { get; construct; }

    private Gee.Queue<unowned CMark.Node> _blocks;

    public RecipeParser (int id, string raw_md) {
        Object (id: id, raw_md: raw_md);
    }

    public Recipe parse () throws ParsingError {
        var root = CMark.Node.parse_document (raw_md.data, CMark.OPT.DEFAULT);
        _blocks = split_blocks (root);

        var title = parse_title ();
        var description = parse_description ();
        Gee.List<string> tags;
        Gee.List<Amount> yields;
        parse_tags_and_yields (out tags, out yields);

        return new Recipe () {
            id = id,
            title = title,
            description = description,
            tags = tags,
            yields = yields,
        };
    }

    private Gee.Queue<unowned CMark.Node> split_blocks (
        CMark.Node doc_root
    ) throws ParsingError {
        if (doc_root.get_type () != CMark.NODE_TYPE.DOCUMENT) {
            var msg_tmpl = "Expected to parse entire document, but got %s";
            var err_msg = msg_tmpl.printf (doc_root.get_type_string ());
            throw new ParsingError.INVALID (err_msg);
        }

        var blocks = new Gee.ArrayQueue <unowned CMark.Node> ();
        unowned CMark.Node node = doc_root.first_child ();
        if (node == null) {
            var err_msg = "Expected document not to be empty but it was";
            throw new ParsingError.INVALID (err_msg);
        }

        do {
            blocks.add (node);
        } while ((node = node.next()) != null);

        return blocks;
    }

    private string parse_title () throws ParsingError {
        unowned var h1_node = _blocks.poll ();
        if (h1_node.get_type () != CMark.NODE_TYPE.HEADING) {
            var msg_tmpl = "Expected document to start with heading, but got %s";
            var err_msg = msg_tmpl.printf (h1_node.get_type_string ());
            throw new ParsingError.INVALID (err_msg);
        }

        if (h1_node.get_heading_level () != 1) {
            var msg_tmpl = "Expected document to start with h1, but got h%d";
            var err_msg = msg_tmpl.printf (h1_node.get_heading_level ());
            throw new ParsingError.INVALID (err_msg);
        }

        return serialize_inline (h1_node);
    }

    private string parse_description () throws ParsingError {
        unowned var node = _blocks.peek ();
        var sb = new StringBuilder ();
        while (node != null
            && node.get_type () != CMark.NODE_TYPE.THEMATIC_BREAK
            && !is_yields_line (node)
            && !is_tags_line (node)
        ) {
            if (sb.len > 0) {
                sb.append ("\n\n");
            }
            sb.append (serialize_inline (node));
            _blocks.poll ();
            node = _blocks.peek ();
        }
        return sb.str;
    }

    private void parse_tags_and_yields (
        out Gee.List<string>? tags,
        out Gee.List<Amount>? yields
    ) {
        tags = null;
        yields = null;
        unowned var node = _blocks.peek ();
        while (node != null
            && node.get_type () != CMark.NODE_TYPE.THEMATIC_BREAK
        ) {
            if (is_tags_line (node)) {
                if (tags != null) {
                    var err_msg = "Expected tags line to appear only once";
                    throw new ParsingError.INVALID (err_msg);
                }
                tags = parse_tags (node);
            }

            if (is_yields_line (node)) {
                if (yields != null) {
                    var err_msg = "Expected yields line to appear only once";
                    throw new ParsingError.INVALID (err_msg);
                }
                yields = parse_yields (node);
            }

            _blocks.poll ();
            node = _blocks.peek ();
        }

        tags = tags ?? new Gee.ArrayList<string> ();
        yields = yields ?? new Gee.ArrayList<Amount> ();
    }

    private Gee.List<string>? parse_tags (CMark.Node node) {
        var joined_tags = serialize_inline (node.first_child ());
        if (joined_tags.length == 0) {
            return null;
        }

        var tags = new Gee.ArrayList<string> ();
        foreach (var raw_tag in joined_tags.split (",")) {
            tags.add (raw_tag.chomp ().chug ());
        }

        return tags;
    }

    private Gee.List<Amount>? parse_yields (CMark.Node node) {
        var joined_yields = serialize_inline (node.first_child ());
        if (joined_yields.length == 0) {
            return null;
        }

        var yields = new Gee.ArrayList<Amount> ();
        string? raw_yield = null;
        var split_yields = joined_yields.split (",");
        for (var i = 0; i < split_yields.length; i++) {
            var potential_raw_yield = split_yields[i];
            if (potential_raw_yield.length == 0) {
                if (raw_yield != null) {
                    var parser = new AmountParser (raw_yield);
                    yields.add (parser.parse ());
                    raw_yield = null;
                }
                continue;
            }

            if (raw_yield != null) {
                if (potential_raw_yield[0].isdigit ()) {
                    raw_yield += "," + potential_raw_yield;
                    var parser = new AmountParser (raw_yield);
                    yields.add (parser.parse ());
                    raw_yield = null;
                } else {
                    var parser = new AmountParser (raw_yield);
                    yields.add (parser.parse ());
                    raw_yield = potential_raw_yield;
                }
            } else {
                raw_yield = potential_raw_yield;
            }
        }
        if (raw_yield != null) {
            var parser = new AmountParser (raw_yield);
            yields.add (parser.parse ());
        }

        return yields;
    }

    private string serialize_inline (CMark.Node? root) throws ParsingError {
        if (root == null) {
            return "";
        }

        unowned CMark.Node node = root.first_child ();
        if (node == null) {
            return (root.get_literal () ?? "")._chomp ();
        }

        var sb = new StringBuilder ();
        do {
            switch (node.get_type ()) {
                case TEXT: {
                    sb.append (node.get_literal () ?? "");
                    break;
                }
                case SOFTBREAK: {
                    sb.append_c (' ');
                    break;
                }
                case LINEBREAK: {
                    sb.append_c ('\n');
                    break;
                }
                case CODE: {
                    sb.append_c ('`');
                    sb.append (node.get_literal () ?? "");
                    sb.append_c ('`');
                    break;
                }
                case EMPH: {
                    sb.append_c ('*');
                    sb.append (serialize_inline (node));
                    sb.append_c ('*');
                    break;
                }
                case STRONG: {
                    sb.append ("**");
                    sb.append (serialize_inline (node));
                    sb.append ("**");
                    break;
                }
                case HTML_INLINE:
                case CUSTOM_INLINE:
                case LINK:
                case IMAGE:
                default: {
                    var msg_tmpl = "TODO: support %s ndoe type serialization";
                    var err_msg = msg_tmpl.printf (node.get_type_string ());
                    // throw new ParsingError.NOT_IMPLEMENTED (err_msg);
                    sb.append (err_msg);
                    break;
                }
            }
        } while ((node = node.next()) != null);
        return sb.str;
    }

    private bool is_yields_line (CMark.Node? node) {
        return is_line_wrapped_in (node, CMark.NODE_TYPE.STRONG);
    }

   private bool is_tags_line (CMark.Node? node) {
       return is_line_wrapped_in (node, CMark.NODE_TYPE.EMPH);
   }

   private bool is_line_wrapped_in (CMark.Node? node, CMark.NODE_TYPE type) {
       if (node == null) {
           return false;
       }
       if (node.first_child () != node.last_child ()) {
           return false;
       }
       unowned var child = node.first_child ();
       if (child == null) {
           return false;
       }
       var res = child.get_type () == type;

       return res;
   }

}
