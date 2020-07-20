/*
 * SPDX-FileCopyrightText: 2020 Rasmus Thomsen <oss@cogitri.dev>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

Uhm.Server mock_server = null;
TestLib.TestMode mock_serve_test_mode = TestLib.TestMode.Testing;
const string ONLINE_TEST_GITLAB_INSTANCE = "https://gitlab.com";
const string ONLINE_TEST_GITLAB_ACCESS_TOKEN = "PUTTOKENHERE"; // Only required for online tests (so when refreshing uhttp's trace)

class TestPoller : AlpineQaBot.Poller {
    public TestPoller (string api_auth_token, string gitlab_instance_url) {
        base (api_auth_token, gitlab_instance_url);
    }

    public Gee.ArrayList<AlpineQaBot.Job> test_poll (uint project_id, Soup.Session? default_soup_session = null, string db_dir = Config.SHARED_STATE_DIR, GLib.DateTime? date = null) throws AlpineQaBot.DatabaseError {
        Gee.ArrayList<AlpineQaBot.Job> res = new Gee.ArrayList<AlpineQaBot.Job>();

        res.add_all (this.poll_stale_merge_requests (project_id, default_soup_session, db_dir, date) ?? new Gee.ArrayList<AlpineQaBot.Job>());
        res.add_all (this.poll_failed_merge_requests (project_id, default_soup_session, db_dir) ?? new Gee.ArrayList<AlpineQaBot.Job>());

        return res;
    }

}

void test_poller_poll () {
    try {
        mock_server.start_trace ("poller_poll");
    } catch (Error e) {
        error ("%s", e.message);
    }
    var tmp_dir = new TestLib.TestTempFile ();

    string instance_url = null;
    string api_token = null;
    if (mock_server.enable_online) {
        instance_url = ONLINE_TEST_GITLAB_INSTANCE;
        api_token = ONLINE_TEST_GITLAB_ACCESS_TOKEN;
    } else {
        instance_url = "https://%s:%u".printf (mock_server.address, mock_server.port);
        api_token = "MOCK_TOKEN";
    }
    var poller = new TestPoller (api_token, instance_url);
    Gee.ArrayList<AlpineQaBot.Job> jobs;
    var test_soup_session = TestLib.get_test_soup_session (mock_server);
    try {
        jobs = poller.test_poll (19765543, test_soup_session, tmp_dir.file_path, new GLib.DateTime.from_iso8601 ("2020-07-20T11:33:20+0200", null));
    } catch (GLib.Error e) {
        error (e.message);
    }
    assert_nonnull (jobs);
    assert (jobs.size == 4);
    foreach (var job in jobs) {
        job.process (test_soup_session);
    }

    mock_server.end_trace ();
}

public void main (string[] args) {
    Test.init (ref args);

    mock_server = new Uhm.Server ();
    TestLib.init_mock_server (mock_server, mock_serve_test_mode, "traces/poller");

    Test.add_func ("/test/poller/poll", test_poller_poll);
    Test.run ();
}
