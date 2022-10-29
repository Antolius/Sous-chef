/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.LibraryView : Gtk.Widget {

    public DatabaseService db_service { private get; construct; }
    private ListStore recipes_store {
        private get;
        default = new ListStore (typeof (Recipe));
    }
    public Gee.List<Recipe> all_recipes {
        get;
        set;
        default = new Gee.ArrayList<Recipe> ();
    }
    public string? search_term {
        get;
        set;
        default = null;
    }

    private Gtk.WindowHandle header;
    private Gtk.InfoBar error_bar;
    private Gtk.ListBox recipes_list;
    private Gtk.ScrolledWindow scrolled_list;

    public LibraryView (DatabaseService db_service) {
        Object (
            layout_manager: new Gtk.BoxLayout (Gtk.Orientation.VERTICAL),
            db_service: db_service
        );
    }

    construct {
        add_css_class (Granite.STYLE_CLASS_VIEW);

        header = create_header ();
        header.insert_after (this, null);
        error_bar = create_error_bar ();
        error_bar.insert_after (this, header);
        recipes_list = create_recipes_list ();
        scrolled_list = new Gtk.ScrolledWindow () {
            child = recipes_list
        };
        scrolled_list.insert_after (this, error_bar);

        connect_to_db ();
        notify["all-recipes"].connect (() => {
            recipes_store.remove_all ();
            foreach (var recipe in all_recipes) {
                recipes_store.append (recipe);
            }
        });
        notify["search-term"].connect (() => {
            recipes_store.remove_all ();
            if (search_term == null || search_term.length == 0) {
               foreach (var recipe in all_recipes) {
                    recipes_store.append (recipe);
                }
                return;
            }

            var lst = search_term.down ();
            foreach (var recipe in all_recipes) {
                if (recipe.title.down ().contains (lst)) {
                    recipes_store.append (recipe);
                }
            }
        });
    }

    private Gtk.WindowHandle create_header () {
        var window_controls = new Gtk.WindowControls (Gtk.PackType.START);

        var search_entry = new Gtk.SearchEntry () {
            placeholder_text = _("Search Recipes"),
            hexpand = true,
            margin_start = 16,
            margin_end = 24,
            margin_top = 4,
            margin_bottom = 4
        };

        search_entry.stop_search.connect (() => {
            search_term = null;
        });
        search_entry.search_changed.connect (() => {
            search_term = search_entry.text;
        });

        var add_recipe_button = new Gtk.Button.from_icon_name ("list-add");

        var header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header.add_css_class ("titlebar");
        header.add_css_class (Granite.STYLE_CLASS_FLAT);
        header.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);
        header.append (window_controls);
        header.append (search_entry);
        header.append (add_recipe_button);

        return new Gtk.WindowHandle () {
            child = header
        };
    }

    private Gtk.InfoBar create_error_bar () {
        return new Gtk.InfoBar () {
            message_type = Gtk.MessageType.ERROR,
            show_close_button = false,
            revealed = false
        };
    }

    private Gtk.ListBox create_recipes_list () {
        var list = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true,
            margin_top = 8
        };

        list.bind_model (recipes_store, (element) => {
            var recipe = (Recipe) element;
            var title_label = new Gtk.Label (recipe.title) {
                wrap = true,
                wrap_mode = Pango.WrapMode.WORD,
                halign = Gtk.Align.START,
                margin_start = 16,
                margin_end = 16
            };
            title_label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);
            return title_label;
        });

        return list;
    }

    private void connect_to_db () {
        var future_db = db_service.db_future;
        future_db.wait_async.begin ((obj, res) => {
            try {
                unowned Sqlite.Database db = future_db.wait_async.end (res);
                load_all_recipes (db);
            } catch (Gee.FutureError e) {
                string err_msg = _("Failed to load recipes");
                if (e is Gee.FutureError.EXCEPTION) {
                    err_msg += "\n" + future_db.exception.message;
                }
                error_bar.add_child (new Gtk.Label (err_msg) {
                    wrap = true,
                    wrap_mode = Pango.WrapMode.WORD
                });
                error_bar.revealed = true;
            }
        });
    }

    private void load_all_recipes (Sqlite.Database db) {
        var query = "SELECT * FROM Recipes";
        string err_msg;
        var loaded_recepies = new Gee.ArrayList<Recipe> ();
        var ec = db.exec (query, (ignored, values) => {
            var recipe = new Recipe () {
                id = int.parse (values[0]),
                title = values[1],
            };
            loaded_recepies.add (recipe);
            return 0;
        }, out err_msg);
        if (ec != Sqlite.OK) {
            err_msg = "Failed to load recepies\n" + err_msg;
            error_bar.add_child (new Gtk.Label (err_msg) {
                wrap = true,
                wrap_mode = Pango.WrapMode.WORD
            });
            error_bar.revealed = true;
        } else {
            all_recipes = loaded_recepies;
        }
    }

    public override void dispose () {
        header.unparent ();
        error_bar.unparent ();
        scrolled_list.unparent ();
    }
}
