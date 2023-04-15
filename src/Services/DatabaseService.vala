/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public class Souschef.DatabaseService : Object {

    public Gee.Future<weak Sqlite.Database> db_future { get {
        return _db_promise.future;
    } }

    private string _db_file_path;
    private Sqlite.Database? _db;
    private Gee.Promise<weak Sqlite.Database> _db_promise;

    public DatabaseService (string? db_file_path = null) {
        _db_file_path = db_file_path ?? default_db_file_path ();
        _db_promise = new Gee.Promise<weak Sqlite.Database> ();
    }

    private static string default_db_file_path () {
        return Path.build_filename (
            Environment.get_user_data_dir (),
            "recipes.db"
        );
    }

    public async void init (Cancellable? cancel = null) throws ServiceError {
        if (db_future.ready) {
            _db_promise = new Gee.Promise<weak Sqlite.Database> ();
        }
        try {
            var exists = yield db_file_exists (cancel);
            if (!exists) {
                yield create_empty_db_file (cancel);
            }

            yield open_database (cancel);
            yield initialize_database (cancel);
        } catch (ServiceError e) {
            _db_promise.set_exception (e);
            throw e;
        }

        _db_promise.set_value (_db);
    }


    private async bool db_file_exists (Cancellable? cancel) throws ServiceError {
        try {
            var db_file = File.new_for_path (_db_file_path);
            yield db_file.query_info_async (
                "standard",
                FileQueryInfoFlags.NONE,
                Priority.DEFAULT,
                cancel
            );
            return true;
        } catch (Error e) {
            if (e is IOError.CANCELLED) {
                throw cancel_error ();
            }
            return false;
        }
    }

    private async void create_empty_db_file (Cancellable? cancel) throws ServiceError {
        var db_file = File.new_for_path (_db_file_path);
        try {
            var ios = yield db_file.create_readwrite_async (
                FileCreateFlags.REPLACE_DESTINATION,
                Priority.DEFAULT,
                cancel
            );
            yield ios.close_async (Priority.DEFAULT, cancel);
        } catch (Error e) {
            if (e is IOError.EXISTS) {
                return;
            } else if (e is IOError.CANCELLED) {
                throw cancel_error ();
            }
            var err = _("Failed to create file %s because %s.")
                .printf (_db_file_path, e.message);
            throw new ServiceError.FAILED_TO_CREATE_DATABASE_FILE (err);
        }
    }

    private async void open_database (Cancellable? cancel) throws ServiceError {
        Idle.add (open_database.callback);
        yield;
        if (cancel.is_cancelled ()) {
            throw cancel_error ();
        }
        var ec = Sqlite.Database.open_v2 (_db_file_path, out _db);
        if (ec != Sqlite.OK) {
            var err = _("Failed to open database file %s with sqlite error code %d: %s")
                .printf (_db_file_path, _db.errcode (), _db.errmsg ());
            throw new ServiceError.FAILED_TO_INIT_DATABASE (err);
        }
    }

    private async void initialize_database (Cancellable? cancel) throws ServiceError {
        var scripts = yield read_init_scripts_from_resources (cancel);
        foreach (var query in scripts) {
            Idle.add (initialize_database.callback);
            yield;
            if (cancel.is_cancelled ()) {
                throw cancel_error ();
            }

            var ec = _db.exec (query);
            if (ec != Sqlite.OK) {
                var err = _("Failed to execute initialization query, sqlite error code %d: %s")
                    .printf (_db.errcode (), _db.errmsg ());
                throw new ServiceError.FAILED_TO_INIT_DATABASE (err);
            }
        }
    }

    private async Gee.List<string> read_init_scripts_from_resources (Cancellable? cancel) throws ServiceError {
        var scripts_path = "/" + Consts.RESOURCE_BASE + "/sql";
        try {
            var script_names = resources_enumerate_children (scripts_path, ResourceLookupFlags.NONE);
            var sorted_names = new Gee.ArrayList<string>.wrap (script_names);
            sorted_names.sort ();
            var scripts = new Gee.ArrayList<string> ();

            foreach (var script_name in sorted_names) {
                var path = scripts_path + "/" + script_name;
                var script = yield read_script_from_resource (path, cancel);
                scripts.add (script);
            }

            return scripts;
        } catch (Error e) {
            if (e is IOError.CANCELLED) {
                throw cancel_error ();
            }

            var err = _("Failed to read database initialization scripts from %s because: %s")
                .printf (scripts_path, e.message);
            throw new ServiceError.FAILED_TO_INIT_DATABASE (err);
        }
    }

    private async string read_script_from_resource (string path, Cancellable? cancel) throws Error {
        var @is = resources_open_stream (path, ResourceLookupFlags.NONE);
        var script = "";
        var buff_size = 32768;
        var buff = new uint8[buff_size];
        size_t read;
        while(yield @is.read_all_async (buff, Priority.DEFAULT, cancel, out read)) {
            script += (string) buff;
            if (read < buff_size) {
                break;
            }
        };

        return script;
    }

    private ServiceError cancel_error () {
        return new ServiceError.CANCELLED (_("Database initialization was caceled"));
    }
}
