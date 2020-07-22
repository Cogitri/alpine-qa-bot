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
    var test_soup_session = TestLib.get_test_soup_session (mock_server);
    var loop = new MainLoop ();

    poller.poll.begin (19765543, test_soup_session, tmp_dir.file_path, new GLib.DateTime.from_iso8601 ("2020-07-20T19:57:00Z", null), (obj, res) => {
        Gee.ArrayList<AlpineQaBot.Job> jobs;
        try {
            jobs = ((AlpineQaBot.Poller)obj).poll.end (res);
        } catch (GLib.Error e) {
            error (e.message);
        }

        assert_nonnull (jobs);
        assert (jobs.size == 4);
        jobs.get (0).process.begin (test_soup_session, () => {
            jobs.get (1).process.begin (test_soup_session, () => {
                jobs.get (2).process.begin (test_soup_session, () => {
                    jobs.get (3).process.begin (test_soup_session, () => {
                        loop.quit ();
                    });
                });
            });
        });
    });

    loop.run ();
    mock_server.end_trace ();
}

void test_poller_poll_unmark_failed_ci () {
    try {
        mock_server.start_trace ("poller_poll_unmark_failed_ci");
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
    var test_soup_session = TestLib.get_test_soup_session (mock_server);
    var loop = new MainLoop ();

    poller.poll.begin (19765543, test_soup_session, tmp_dir.file_path, new GLib.DateTime.from_iso8601 ("2020-07-20T11:33:20+0200", null), (obj, res) => {
        Gee.ArrayList<AlpineQaBot.Job> jobs;
        try {
            jobs = ((AlpineQaBot.Poller)obj).poll.end (res);
        } catch (GLib.Error e) {
            error (e.message);
        }

        assert_nonnull (jobs);
        assert (jobs.size == 3);
        jobs.get (0).process.begin (test_soup_session, () => {
            jobs.get (1).process.begin (test_soup_session, () => {
                jobs.get (2).process.begin (test_soup_session, () => {
                    loop.quit ();
                });
            });
        });
    });

    loop.run ();
    mock_server.end_trace ();
}

void test_poller_poll_unmark_stale () {
    try {
        mock_server.start_trace ("poller_poll_unmark_stale");
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
    var test_soup_session = TestLib.get_test_soup_session (mock_server);
    var loop = new MainLoop ();

    poller.poll.begin (19765543, test_soup_session, tmp_dir.file_path, new GLib.DateTime.from_iso8601 ("2020-07-20T11:33:20+0200", null), (obj, res) => {
        Gee.ArrayList<AlpineQaBot.Job> jobs;
        try {
            jobs = ((AlpineQaBot.Poller)obj).poll.end (res);
        } catch (GLib.Error e) {
            error (e.message);
        }

        assert_nonnull (jobs);
        assert (jobs.size == 4);
        jobs.get (0).process.begin (test_soup_session, () => {
            jobs.get (1).process.begin (test_soup_session, () => {
                jobs.get (2).process.begin (test_soup_session, () => {
                    jobs.get (3).process.begin (test_soup_session, () => {
                        loop.quit ();
                    });
                });
            });
        });
    });

    loop.run ();
    mock_server.end_trace ();
}

public void main (string[] args) {
    Test.init (ref args);

    mock_server = new Uhm.Server ();
    TestLib.init_mock_server (mock_server, mock_serve_test_mode, "traces/poller");

    Test.add_func ("/test/poller/poll", test_poller_poll);
    Test.add_func ("/test/poller/poll/unmark_failed_ci ", test_poller_poll_unmark_failed_ci);
    Test.add_func ("/test/poller/poll/unmark_stale ", test_poller_poll_unmark_stale);
    Test.run ();
}
