/*
 * SPDX-FileCopyrightText: 2020 Rasmus Thomsen <oss@cogitri.dev>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
namespace AlpineQaBot {
    public class MergeRequestInfo : GLib.Object, Json.Serializable {
        public MergeRequestInfo (PipelineStatus pipeline_status) {
            this.pipeline_status = pipeline_status;
        }

        public string to_string () {
            return Json.gobject_to_data (this, null);
        }

        public PipelineStatus pipeline_status { get; set; }
    }

    public errordomain DatabaseError {
        OPEN_FAILED,
        SETUP_FAILED,
        SAVE_FAILED,
        GET_FAILED,
        DATA_MALFORMED,
        UNKNOWN_ID,
    }

    public interface Database {
        public abstract void open(string filename) throws DatabaseError;

        public abstract void save_merge_request_info(int64 id, MergeRequestInfo merge_request_info) throws DatabaseError;

        public abstract void save_all_merge_request_info(Gee.HashMap<int64? , MergeRequestInfo> merge_request_info) throws DatabaseError;

        public abstract MergeRequestInfo get_merge_request_info(int64 id) throws DatabaseError;

        public abstract Gee.HashMap<int64? , MergeRequestInfo> get_all_merge_request_info() throws DatabaseError;

    }

    public class SqliteDatabase : GLib.Object, Database {
        public void open (string filename) throws DatabaseError {
            int rc;
            const string setup_query = """
                CREATE TABLE MR_Info (
                    id      PRIMARY_KEY     INT     NOT NULL,
                    mr_info                 TEXT    NOT NULL
                );
            """;
            string errmsg;
            bool db_exists_already = FileUtils.test (filename, FileTest.IS_REGULAR);

            if ((rc = Sqlite.Database.open_v2 (filename, out this.db)) != 0) {
                throw new DatabaseError.OPEN_FAILED ("Opening the SQLite database failed to error %s", db.errmsg ());
            }

            if (!db_exists_already) {
                if ((rc = this.db.exec (setup_query, null, out errmsg)) != Sqlite.OK) {
                    throw new DatabaseError.SETUP_FAILED ("Failed to setup SQLite database due to error %s", errmsg);
                }
            }

        }

        public void save_merge_request_info (int64 id, MergeRequestInfo merge_request_info) throws DatabaseError {
            string query = "INSERT INTO MR_Info (id, mr_info) VALUES (%lld, '%s')\n".printf (id, Json.gobject_to_data (merge_request_info, null));
            int rc;
            string errmsg;

            if ((rc = db.exec (query, null, out errmsg)) != Sqlite.OK) {
                throw new DatabaseError.SAVE_FAILED ("Failed to save MR Info to SQLite database due to error %s", errmsg);
            }
        }

        public void save_all_merge_request_info (Gee.HashMap<int64? , MergeRequestInfo> merge_request_info) throws DatabaseError {
            int rc;
            string errmsg;
            string query = "";

            foreach (var id in merge_request_info.keys) {
                query += "INSERT INTO MR_Info (id, mr_info) VALUES (%lld, '%s')\n".printf (id, Json.gobject_to_data (merge_request_info.get (id), null));
            }

            if ((rc = this.db.exec (query, null, out errmsg)) != Sqlite.OK) {
                throw new DatabaseError.SAVE_FAILED ("Failed to save MR Info to SQLite database due to error %s", errmsg);
            }
        }

        public MergeRequestInfo get_merge_request_info (int64 id) throws DatabaseError {
            int rc;
            Sqlite.Statement stmt;
            string query = "SELECT * FROM MR_Info WHERE id = %lld".printf (id);

            if ((rc = this.db.prepare_v2 (query, -1, out stmt, null)) == 1) {
                throw new DatabaseError.GET_FAILED ("Failed to get MR Info from SQLite database due to error %s", db.errmsg ());
            }

            stmt.step ();
            MergeRequestInfo? info;
            try {
                var data = stmt.column_text (1);
                if (data == null) {
                    throw new DatabaseError.UNKNOWN_ID ("Couldn't find MergeRequestInfo for id %lld", id);
                }
                info = Json.gobject_from_data (typeof (MergeRequestInfo), data) as MergeRequestInfo;
            } catch (GLib.Error e) {
                throw new DatabaseError.DATA_MALFORMED ("Failed to parse data due to error %s", e.message);
            }

            assert_nonnull (info);
            return info;
        }

        public Gee.HashMap<int64? , MergeRequestInfo> get_all_merge_request_info () throws DatabaseError {
            int rc, cols;
            Sqlite.Statement stmt;
            const string query = "SELECT * FROM MR_Info";
            Gee.HashMap<int64? , MergeRequestInfo> map = new Gee.HashMap<int64? , MergeRequestInfo>();

            if ((rc = this.db.prepare_v2 (query, -1, out stmt, null)) == 1) {
                throw new DatabaseError.GET_FAILED ("Failed to get MR Info from SQLite database due to error %s", db.errmsg ());
            }


            cols = stmt.column_count ();

            while (stmt.step () == Sqlite.ROW) {
                int64 id = stmt.column_int64 (0);
                try {
                    var info = Json.gobject_from_data (typeof (MergeRequestInfo), stmt.column_text (1)) as MergeRequestInfo;
                    assert_nonnull (info);
                    map.set (id, info);
                } catch (GLib.Error e) {
                    throw new DatabaseError.DATA_MALFORMED ("Failed to parse data due to error %s", e.message);
                }
            }

            return map;
        }

        Sqlite.Database db;
    }
}
