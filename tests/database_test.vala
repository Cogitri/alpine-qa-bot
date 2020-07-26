/*
 * SPDX-FileCopyrightText: 2020 Rasmus Thomsen <oss@cogitri.dev>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

void test_database_init () {
    var db = new AlpineQaBot.SqliteDatabase ();
    var tmp_dir = new TestLib.TestTempFile ();

    try {
        db.open ("%s/test_init.db".printf (tmp_dir.file_path));
    } catch (AlpineQaBot.DatabaseError e) {
        error (e.message);
    }
}

void test_database_get_set_pipeline_status () {
    const AlpineQaBot.PipelineStatus PIPELINE_STATUS = AlpineQaBot.PipelineStatus.Success;
    var db = new AlpineQaBot.SqliteDatabase ();
    var tmp_dir = new TestLib.TestTempFile ();

    try {
        db.open ("%s/test_get_set_pipeline_status.db".printf (tmp_dir.file_path));
    } catch (AlpineQaBot.DatabaseError e) {
        error (e.message);
    }

    try {
        db.save_pipeline_status (0, PIPELINE_STATUS);
    } catch (AlpineQaBot.DatabaseError e) {
        error (e.message);
    }

    try {
        var new_status = db.get_pipeline_status (0);
        assert (new_status == PIPELINE_STATUS);
    } catch (AlpineQaBot.DatabaseError e) {
        error (e.message);
    }
}

void test_database_get_set_pipeline_status_existing_db () {
    const AlpineQaBot.PipelineStatus PIPELINE_STATUS = AlpineQaBot.PipelineStatus.Success;
    var tmp_dir = new TestLib.TestTempFile ();

    {
        var db = new AlpineQaBot.SqliteDatabase ();
        try {
            db.open ("%s/test_get_set_pipeline_status.db".printf (tmp_dir.file_path));
        } catch (AlpineQaBot.DatabaseError e) {
            error (e.message);
        }
        try {
            db.save_pipeline_status (0, PIPELINE_STATUS);
        } catch (AlpineQaBot.DatabaseError e) {
            error (e.message);
        }
    }

    {
        var db = new AlpineQaBot.SqliteDatabase ();
        try {
            db.open ("%s/test_get_set_pipeline_status.db".printf (tmp_dir.file_path));
        } catch (AlpineQaBot.DatabaseError e) {
            error (e.message);
        }
        try {
            var new_status = db.get_pipeline_status (0);
            assert (new_status == PIPELINE_STATUS);
        } catch (AlpineQaBot.DatabaseError e) {
            error (e.message);
        }
    }
}

void test_database_get_nonexistant_mr () {
    var tmp_dir = new TestLib.TestTempFile ();

    var db = new AlpineQaBot.SqliteDatabase ();
    try {
        db.open ("%s/test_get_set_pipeline_status.db".printf (tmp_dir.file_path));
    } catch (AlpineQaBot.DatabaseError e) {
        error (e.message);
    }
    try {
        var pipeline_status = db.get_pipeline_status (0);
        assert (pipeline_status == null);
    } catch (AlpineQaBot.DatabaseError e) {
        error (e.message);
    }
}

void test_database_clean () {
    const AlpineQaBot.PipelineStatus PIPELINE_STATUS = AlpineQaBot.PipelineStatus.Canceled;
    var date = new GLib.DateTime.from_iso8601 ("2020-07-20T11:33:20+0200", null);
    var db = new AlpineQaBot.SqliteDatabase ();
    var tmp_dir = new TestLib.TestTempFile ();

    try {
        db.open ("%s/test_database_clean.db".printf (tmp_dir.file_path));
        db.save_pipeline_status (0, PIPELINE_STATUS);
        db.save_stale_mark_time (0, date);
        assert (db.get_pipeline_status (0) == PIPELINE_STATUS);
        assert (db.get_stale_mark_time (0).compare (date) == 0);
        db.delete_pipeline_status (0);
        assert (db.get_pipeline_status (0) == null);
        assert (db.get_stale_mark_time (0).compare (date) == 0);
    } catch (AlpineQaBot.DatabaseError e) {
        error (e.message);
    }
}

public void main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/test/database/init", test_database_init);
    Test.add_func ("/test/database/get_set_pipeline_status", test_database_get_set_pipeline_status);
    Test.add_func ("/test/database/get_set_pipeline_status_existing_db", test_database_get_set_pipeline_status_existing_db);
    Test.add_func ("/test/database/get_nonexistant_mr", test_database_get_nonexistant_mr);
    Test.add_func ("/test/database/clean", test_database_clean);
    Test.run ();
}
