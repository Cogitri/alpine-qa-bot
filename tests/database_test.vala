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

void test_database_get_set_merge_request_info () {
    var db = new AlpineQaBot.SqliteDatabase ();
    var tmp_dir = new TestLib.TestTempFile ();

    try {
        db.open ("%s/test_get_set_merge_request_info.db".printf (tmp_dir.file_path));
    } catch (AlpineQaBot.DatabaseError e) {
        error (e.message);
    }
    var merge_request_info = new AlpineQaBot.MergeRequestInfo (AlpineQaBot.PipelineStatus.Success);
    try {
        db.save_merge_request_info (0, merge_request_info);
    } catch (AlpineQaBot.DatabaseError e) {
        error (e.message);
    }

    try {
        var new_info = db.get_merge_request_info (0);
        assert (new_info.pipeline_status == merge_request_info.pipeline_status);
    } catch (AlpineQaBot.DatabaseError e) {
        error (e.message);
    }
}

void test_database_get_set_merge_request_info_existing_db () {
    var tmp_dir = new TestLib.TestTempFile ();
    var merge_request_info = new AlpineQaBot.MergeRequestInfo (AlpineQaBot.PipelineStatus.Success);

    {
        var db = new AlpineQaBot.SqliteDatabase ();
        try {
            db.open ("%s/test_get_set_merge_request_info.db".printf (tmp_dir.file_path));
        } catch (AlpineQaBot.DatabaseError e) {
            error (e.message);
        }
        try {
            db.save_merge_request_info (0, merge_request_info);
        } catch (AlpineQaBot.DatabaseError e) {
            error (e.message);
        }
    }

    {
        var db = new AlpineQaBot.SqliteDatabase ();
        try {
            db.open ("%s/test_get_set_merge_request_info.db".printf (tmp_dir.file_path));
        } catch (AlpineQaBot.DatabaseError e) {
            error (e.message);
        }
        try {
            var new_info = db.get_merge_request_info (0);
            assert (new_info.pipeline_status == merge_request_info.pipeline_status);
        } catch (AlpineQaBot.DatabaseError e) {
            error (e.message);
        }
    }
}

void test_database_get_nonexistant_mr () {
    var tmp_dir = new TestLib.TestTempFile ();

    var db = new AlpineQaBot.SqliteDatabase ();
    try {
        db.open ("%s/test_get_set_merge_request_info.db".printf (tmp_dir.file_path));
    } catch (AlpineQaBot.DatabaseError e) {
        error (e.message);
    }
    try {
        var mr_info = db.get_merge_request_info (0);
        assert_null (mr_info);
    } catch (AlpineQaBot.DatabaseError e) {
        error (e.message);
    }
}

public void main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/test/database/init", test_database_init);
    Test.add_func ("/test/database/get_set_merge_request_info", test_database_get_set_merge_request_info);
    Test.add_func ("/test/database/get_set_merge_request_info_existing_db", test_database_get_set_merge_request_info_existing_db);
    Test.add_func ("/test/database/get_nonexistant_mr", test_database_get_nonexistant_mr);
    Test.run ();
}
