/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.RecipesService : Object {

   public DatabaseService db_service { private get; construct; }
   public Recipe? currently_open { get; set; default = null; }

   public RecipesService (DatabaseService db_service) {
      Object (db_service: db_service);
   }

   public async Gee.List<Recipe> load_all () throws ServiceError {
        unowned var db = yield open_db ();
        var query = "SELECT * FROM Recipes";
        string sql_err_msg;
        var loaded_recepies = new Gee.ArrayList<Recipe> ();
        var parsing_errors = new Gee.ArrayList<ParsingErrorDetails> ();
        var ec = db.exec (query, (n_columns, values) => {
            if (n_columns < 2) {
                parsing_errors.add (new ParsingErrorDetails () {
                    error_message = "missing data",
                });
                return 0;
            }

            var id = int.parse (values[0]);
            if (id == 0) {
                parsing_errors.add (new ParsingErrorDetails () {
                    error_message = "invalid recipe id `%s`".printf (values[0]),
                });
                return 0;
            }

            if (values[3] == null) {
                parsing_errors.add (new ParsingErrorDetails () {
                    error_message = "missing recipe content",
                });
                return 0;
            }

            try {
                var parser = new RecipeParser (id, values[3]);
                var recipe = parser.parse ();
                loaded_recepies.add (recipe);
            } catch (ParsingError err) {
                parsing_errors.add (new ParsingErrorDetails () {
                    recipe_title = values[1],
                    error_message = err.message,
                });
            }
            return 0;
        }, out sql_err_msg);
        if (ec != Sqlite.OK) {
            var err_msg = "SQL query `%s` with sqlite error code %d: %s"
                .printf (query, ec, sql_err_msg);
            throw new ServiceError.FAILED_QUERY (err_msg);
        }
        if (!parsing_errors.is_empty) {
            var err_msg_builder = new StringBuilder ();
            foreach (var err in parsing_errors) {
                if (err_msg_builder.len != 0) {
                    err_msg_builder.append (", ");
                }
                err_msg_builder.append ("recipe %s is incorrectly formatted".printf (err.recipe_title ?? ""));
                err_msg_builder.append (" specifically: %s".printf (err.error_message));
            }
            throw new ServiceError.INVALID_DATA (err_msg_builder.str);
        }

        return loaded_recepies;
   }

   private async unowned Sqlite.Database open_db () throws ServiceError {
        var future = db_service.db_future;
        if (future.ready && future.exception != null) {
            yield db_service.init ();
            future = db_service.db_future;
        }
        try {
            return yield future.wait_async ();
        } catch (Gee.FutureError e) {
            if (e is Gee.FutureError.ABANDON_PROMISE) {
                var err_msg = _("Database initialization was abandoned");
                throw new ServiceError.CANCELLED (err_msg);
            }

            var cause = future.exception;
            if (cause is ServiceError) {
                throw (ServiceError) cause;
            }

            var err_msg = "Database initialization failed because: ";
            err_msg += cause.message;
            throw new ServiceError.UNEXPECTED_ERROR (err_msg);
        }
    }
}

private class Souschef.ParsingErrorDetails : Object {
    public string? recipe_title { get; set; }
    public string error_message { get; set; }
}
