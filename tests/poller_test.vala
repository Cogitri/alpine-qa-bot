/*
 * SPDX-FileCopyrightText: 2020 Rasmus Thomsen <oss@cogitri.dev>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

Uhm.Server mock_server = null;
TestLib.TestMode mock_serve_test_mode = TestLib.TestMode.Testing;
const string ONLINE_TEST_GITLAB_INSTANCE = "https://gitlab.com";
const string ONLINE_TEST_GITLAB_ACCESS_TOKEN = "PUTTOKENHERE"; // Only required for online tests (so when refreshing uhttp's trace)

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
    var poller = new AlpineQaBot.Poller (api_token, instance_url);
    Gee.ArrayList<AlpineQaBot.Job> jobs;
    try {
        jobs = poller.poll (19765543, TestLib.get_test_soup_session (mock_server), tmp_dir.file_path);
    } catch (GLib.Error e) {
        error (e.message);
    }
    assert_nonnull (jobs);
    assert (jobs.size == 4);
    foreach (var job in jobs) {
        job.process ();
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
