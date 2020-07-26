/*
 * SPDX-FileCopyrightText: 2020 Rasmus Thomsen <oss@cogitri.dev>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
namespace AlpineQaBot {
    public errordomain DatabaseError {
        OPEN_FAILED,
        SETUP_FAILED,
        SAVE_FAILED,
        GET_FAILED,
        DATA_MALFORMED,
    }

    public interface Database {
        public abstract void open(string filename) throws DatabaseError;

        public abstract void delete_pipeline_status(int64 id) throws DatabaseError;

        public abstract PipelineStatus? get_pipeline_status (int64 id) throws DatabaseError;

        public abstract void save_pipeline_status(int64 id, PipelineStatus status) throws DatabaseError;

        public abstract void delete_stale_mark_time(int64 id) throws DatabaseError;

        public abstract GLib.DateTime? get_stale_mark_time (int64 id) throws DatabaseError;

        public abstract void save_stale_mark_time(int64 id, GLib.DateTime stale_mark_time) throws DatabaseError;

    }

    public class SqliteDatabase : GLib.Object, Database {
        public void open (string filename) throws DatabaseError {
            int rc;
            const string setup_query = """
                CREATE TABLE MR_Info (
                    id              PRIMARY_KEY     INT     NOT NULL,
                    pipeline_status                 INT,
                    stale_mark_time                 CHAR(25)
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

        public void save_pipeline_status (int64 id, PipelineStatus pipeline_status) throws DatabaseError {
            string query = "INSERT INTO MR_Info (id, pipeline_status) VALUES (%lld, %d);".printf (id, pipeline_status);
            int rc;
            string errmsg;

            if ((rc = db.exec (query, null, out errmsg)) != Sqlite.OK) {
                throw new DatabaseError.SAVE_FAILED ("Failed to save pipeline_status to SQLite database due to error %s", errmsg);
            }
        }

        public PipelineStatus? get_pipeline_status (int64 id) throws DatabaseError {
            int rc;
            Sqlite.Statement stmt;
            string query = "SELECT * FROM MR_Info WHERE id = %lld AND pipeline_status IS NOT NULL;".printf (id);

            if ((rc = this.db.prepare_v2 (query, -1, out stmt, null)) == 1) {
                throw new DatabaseError.GET_FAILED ("Failed to get pipeline_status from SQLite database due to error %s", db.errmsg ());
            }

            if (stmt.step () == Sqlite.ROW) {
                var data = stmt.column_int (1);
                return (PipelineStatus) data;
            }
            return null;
        }

        public void delete_pipeline_status (int64 id) throws DatabaseError {
            int rc;
            string query = "UPDATE MR_Info SET pipeline_status = NULL WHERE id = %lld".printf (id);
            string errmsg;

            if ((rc = db.exec (query, null, out errmsg)) != Sqlite.OK) {
                throw new DatabaseError.SAVE_FAILED ("Failed to set pipeline_status to NULL in SQLite database due to error %s", errmsg);
            }
            this.delete_null_entries ();
        }

        public void save_stale_mark_time (int64 id, GLib.DateTime stale_mark_time) throws DatabaseError {
            string query = "INSERT INTO MR_Info (id, stale_mark_time) VALUES (%lld, '%s');".printf (id, stale_mark_time.to_string ());
            int rc;
            string errmsg;

            if ((rc = db.exec (query, null, out errmsg)) != Sqlite.OK) {
                throw new DatabaseError.SAVE_FAILED ("Failed to save stale mark time to SQLite database due to error %s", errmsg);
            }
        }

        public GLib.DateTime? get_stale_mark_time (int64 id) throws DatabaseError {
            int rc;
            Sqlite.Statement stmt;
            string query = "SELECT * FROM MR_Info WHERE id = %lld AND stale_mark_time IS NOT NULL;".printf (id);

            if ((rc = this.db.prepare_v2 (query, -1, out stmt, null)) == 1) {
                throw new DatabaseError.GET_FAILED ("Failed to get stale mark time from SQLite database due to error %s", db.errmsg ());
            }

            if (stmt.step () == Sqlite.ROW) {
                return new GLib.DateTime.from_iso8601 (stmt.column_text (2), null);
            }

            return null;
        }

        public void delete_stale_mark_time (int64 id) throws DatabaseError {
            int rc;
            string query = "UPDATE MR_Info SET stale_mark_time = NULL WHERE id = %lld".printf (id);
            string errmsg;

            if ((rc = db.exec (query, null, out errmsg)) != Sqlite.OK) {
                throw new DatabaseError.SAVE_FAILED ("Failed to set stale_mark_time to NULL in SQLite database due to error %s", errmsg);
            }
            this.delete_null_entries ();
        }

        private void delete_null_entries () throws DatabaseError {
            int rc;
            string query = "DELETE FROM MR_Info WHERE pipeline_status IS NULL AND stale_mark_time IS NULL";
            string errmsg;

            if ((rc = db.exec (query, null, out errmsg)) != Sqlite.OK) {
                throw new DatabaseError.SAVE_FAILED ("Failed to delete obsolete entries from SQLite database due to error %s", errmsg);
            }
        }

        Sqlite.Database db;
    }
}
