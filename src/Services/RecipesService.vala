/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.RecipesService : Object {

   public DatabaseService db_service { private get; construct; }

   public RecipesService (DatabaseService db_service) {
      Object (db_service: db_service);
   }

   public async Gee.List<Recipe> load_all () throws ServiceError {
        unowned var db = yield open_db ();
        var query = "SELECT * FROM Recipes";
        string sql_err_msg;
        var loaded_recepies = new Gee.ArrayList<Recipe> ();
        var ec = db.exec (query, (n_columns, values) => {
            if (n_columns < 2) {
                return -1; // did not get needed columns
            }

            var id = int.parse (values[0]);
            if (id == 0) {
                return -1; // failed to parse id
            }

            var recipe = new Recipe () {
                id = id,
                title = values[1],
            };
            loaded_recepies.add (recipe);
            return 0;
        }, out sql_err_msg);
        if (ec != Sqlite.OK) {
            var err_msg = "SQL query `%s` with sqlite error code %d: %s"
                .printf (query, ec, sql_err_msg);
            throw new ServiceError.FAILED_QUERY (err_msg);
        }

        return loaded_recepies;
   }

   private async unowned Sqlite.Database open_db () throws ServiceError {
        var future = db_service.db_future;
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
