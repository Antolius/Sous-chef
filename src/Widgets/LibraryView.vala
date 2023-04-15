/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.LibraryView : Gtk.Widget {

    public RecipesService recipes_service { private get; construct; }
    public Gee.List<Recipe> all_recipes {
        get;
        private set;
        default = new Gee.ArrayList<Recipe> ();
    }
    public string? search_term {
        get;
        private set;
        default = null;
    }

    private ListStore recipes_store {
        private get;
        default = new ListStore (typeof (Recipe));
    }
    private Gtk.WindowHandle header;
    private Gtk.InfoBar error_bar;
    private Gtk.ListBox recipes_list;
    private Gtk.ScrolledWindow scrolled_list;

    public LibraryView (RecipesService recipes_service) {
        Object (
            layout_manager: new Gtk.BoxLayout (Gtk.Orientation.VERTICAL),
            recipes_service: recipes_service
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

        connect_to_notifications ();
        load_all_recipes ();
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

        var add_recipe_button = new Gtk.Button.from_icon_name ("list-add") {
            tooltip_text = _("Craft a new recipe")
        };

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

        list.add_css_class (Granite.STYLE_CLASS_RICH_LIST);
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
        list.row_selected.connect (row => {
            if (row == null) {
                recipes_service.currently_open = null;
            } else {
                recipes_service.currently_open = all_recipes[row.get_index ()];
            }
        });

        return list;
    }

    private void connect_to_notifications () {
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

    private void load_all_recipes () {
        recipes_service.load_all.begin ((obj, res) => {
            try {
                all_recipes = recipes_service.load_all.end (res);
            } catch (ServiceError e) {
                var err_title = new Gtk.Label (_("Failed to load recipes")) {
                    wrap = true,
                    wrap_mode = Pango.WrapMode.WORD,
                    halign = Gtk.Align.START
                };
                err_title.add_css_class (Granite.STYLE_CLASS_H4_LABEL);
                var err_txt = new Gtk.Label (e.message) {
                    wrap = true,
                    wrap_mode = Pango.WrapMode.WORD,
                    halign = Gtk.Align.START
                };
                var err_desc = new Gtk.Box (Gtk.Orientation.VERTICAL, 16);
                err_desc.append (err_title);
                err_desc.append (err_txt);
                error_bar.add_child (err_desc);
                var retry_btn = new Gtk.Button.from_icon_name ("view-refresh-symbolic") {
                    tooltip_text = _("Retry loading recipes")
                };
                retry_btn.add_css_class (Granite.STYLE_CLASS_ERROR);
                retry_btn.clicked.connect (() => {
                    error_bar.revealed = false;
                    error_bar.remove_child (err_desc);
                    error_bar.remove_action_widget (retry_btn);
                    load_all_recipes ();
                });
                error_bar.add_action_widget (retry_btn, 1);
                error_bar.revealed = true;
            }
        });
    }

    public override void dispose () {
        header.unparent ();
        error_bar.unparent ();
        scrolled_list.unparent ();
    }
}
