/*
 * SPDX-FileCopyrightText: 2020 Rasmus Thomsen <oss@cogitri.dev>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */


Uhm.Server mock_server = null;
TestLib.TestMode mock_serve_test_mode = TestLib.TestMode.Testing;
const string MERGE_REQUEST_TEST_JSON = """{"object_kind":"merge_request","user":{"name":"Administrator","username":"root","avatar_url":"http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40&d=identicon"},"project":{"id":19765543,"name":"Gitlab Test","description":"Aut reprehenderit ut est.","web_url":"http://example.com/gitlabhq/gitlab-test","avatar_url":null,"git_ssh_url":"git@example.com:gitlabhq/gitlab-test.git","git_http_url":"http://example.com/gitlabhq/gitlab-test.git","namespace":"GitlabHQ","visibility_level":20,"path_with_namespace":"gitlabhq/gitlab-test","default_branch":"master","homepage":"http://example.com/gitlabhq/gitlab-test","url":"http://example.com/gitlabhq/gitlab-test.git","ssh_url":"git@example.com:gitlabhq/gitlab-test.git","http_url":"http://example.com/gitlabhq/gitlab-test.git"},"repository":{"name":"Gitlab Test","url":"http://example.com/gitlabhq/gitlab-test.git","description":"Aut reprehenderit ut est.","homepage":"http://example.com/gitlabhq/gitlab-test"},"object_attributes":{"id":99,"target_branch":"master","source_branch":"ms-viewport","source_project_id":14,"author_id":51,"assignee_id":6,"title":"MS-Viewport","created_at":"2013-12-03T17:23:34Z","updated_at":"2013-12-03T17:23:34Z","milestone_id":null,"state":"opened","merge_status":"unchecked","target_project_id":14,"iid":9,"description":"","source":{"name":"Awesome Project","description":"Aut reprehenderit ut est.","web_url":"http://example.com/awesome_space/awesome_project","avatar_url":null,"git_ssh_url":"git@example.com:awesome_space/awesome_project.git","git_http_url":"http://example.com/awesome_space/awesome_project.git","namespace":"Awesome Space","visibility_level":20,"path_with_namespace":"awesome_space/awesome_project","default_branch":"master","homepage":"http://example.com/awesome_space/awesome_project","url":"http://example.com/awesome_space/awesome_project.git","ssh_url":"git@example.com:awesome_space/awesome_project.git","http_url":"http://example.com/awesome_space/awesome_project.git"},"target":{"name":"Awesome Project","description":"Aut reprehenderit ut est.","web_url":"http://example.com/awesome_space/awesome_project","avatar_url":null,"git_ssh_url":"git@example.com:awesome_space/awesome_project.git","git_http_url":"http://example.com/awesome_space/awesome_project.git","namespace":"Awesome Space","visibility_level":20,"path_with_namespace":"awesome_space/awesome_project","default_branch":"master","homepage":"http://example.com/awesome_space/awesome_project","url":"http://example.com/awesome_space/awesome_project.git","ssh_url":"git@example.com:awesome_space/awesome_project.git","http_url":"http://example.com/awesome_space/awesome_project.git"},"last_commit":{"id":"da1560886d4f094c3e6c9ef40349f7d38b5d27d7","message":"testing/alpine-qa-bot: update to 0.2","timestamp":"2012-01-03T23:36:29+02:00","url":"http://example.com/awesome_space/awesome_project/commits/da1560886d4f094c3e6c9ef40349f7d38b5d27d7","author":{"name":"GitLab dev user","email":"gitlabdev@dv6700.(none)"}},"work_in_progress":false,"url":"http://example.com/diaspora/merge_requests/1","action":"open","assignee":{"name":"User1","username":"user1","avatar_url":"http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40&d=identicon"}},"labels":[{"id":206,"title":"API","color":"#ffffff","project_id":14,"created_at":"2013-12-03T17:15:43Z","updated_at":"2013-12-03T17:15:43Z","template":false,"description":"API related issues","type":"ProjectLabel","group_id":41}],"changes":{"updated_by_id":{"previous":null,"current":1},"updated_at":{"previous":"2017-09-15 16:50:55 UTC","current":"2017-09-15 16:52:00 UTC"},"labels":{"previous":[{"id":206,"title":"API","color":"#ffffff","project_id":14,"created_at":"2013-12-03T17:15:43Z","updated_at":"2013-12-03T17:15:43Z","template":false,"description":"API related issues","type":"ProjectLabel","group_id":41}],"current":[{"id":205,"title":"Platform","color":"#123123","project_id":14,"created_at":"2013-12-03T17:15:43Z","updated_at":"2013-12-03T17:15:43Z","template":false,"description":"Platform related issues","type":"ProjectLabel","group_id":41}]}}}""";
const string PIPELINE_TEST_JSON = """{"id":63768870,"iid":21,"project_id":19765543,"title":"WIP: Ci","description":"","state":"opened","created_at":"2020-07-07T19:10:35.093Z","updated_at":"2020-07-11T17:50:51.280Z","merged_by":null,"merged_at":null,"closed_by":null,"closed_at":null,"target_branch":"master","source_branch":"ci","user_notes_count":1,"upvotes":0,"downvotes":0,"assignee":null,"author":{"id":2263088,"name":"Rasmus Thomsen","username":"Cogitri","state":"active","avatar_url":"https://assets.gitlab-static.net/uploads/-/system/user/avatar/2263088/avatar.png","web_url":"https://gitlab.com/Cogitri"},"assignees":[],"source_project_id":19765591,"target_project_id":19765543,"labels":[],"work_in_progress":true,"milestone":null,"merge_when_pipeline_succeeds":false,"merge_status":"can_be_merged","sha":"c6070c1d33751bd3852ed2a2bf29544ae0f83f8e","merge_commit_sha":null,"squash_commit_sha":null,"discussion_locked":null,"should_remove_source_branch":null,"force_remove_source_branch":true,"allow_collaboration":true,"allow_maintainer_to_push":true,"reference":"!21","references":{"short":"!21","relative":"!21","full":"Cogitri/test-project-webhook!21"},"web_url":"https://gitlab.com/Cogitri/test-project-webhook/-/merge_requests/21","time_stats":{"time_estimate":0,"total_time_spent":0,"human_time_estimate":null,"human_total_time_spent":null},"squash":false,"task_completion_status":{"count":0,"completed_count":0},"has_conflicts":false,"blocking_discussions_resolved":true,"approvals_before_merge":null,"subscribed":true,"changes_count":"1","latest_build_started_at":null,"latest_build_finished_at":null,"first_deployed_to_production_at":null,"pipeline":null,"head_pipeline":{"id":164886879,"sha":"c6070c1d33751bd3852ed2a2bf29544ae0f83f8e","ref":"ci","status":"failed","created_at":"2020-07-09T15:44:58.231Z","updated_at":"2020-07-12T17:47:43.949Z","web_url":"https://gitlab.com/temptestgroupforwebhook/test-project-webhook/-/pipelines/164886879","before_sha":"136a0687c1234ad6052b762fd09bbb5fc468322a","tag":false,"yaml_errors":null,"user":{"id":2263088,"name":"Rasmus Thomsen","username":"Cogitri","state":"active","avatar_url":"https://assets.gitlab-static.net/uploads/-/system/user/avatar/2263088/avatar.png","web_url":"https://gitlab.com/Cogitri"},"started_at":"2020-07-09T15:44:59.481Z","finished_at":"2020-07-12T17:47:43.942Z","committed_at":null,"duration":12,"coverage":null,"detailed_status":{"icon":"status_failed","text":"failed","label":"failed","group":"failed","tooltip":"failed","has_details":true,"details_path":"/temptestgroupforwebhook/test-project-webhook/-/pipelines/164886879","illustration":null,"favicon":"https://gitlab.com/assets/ci_favicons/favicon_status_failed-41304d7f7e3828808b0c26771f0309e55296819a9beea3ea9fbf6689d9857c12.png"}},"diff_refs":{"base_sha":"02c1e09117585f7fc73d3c5ccd4c2d6700bbd307","head_sha":"c6070c1d33751bd3852ed2a2bf29544ae0f83f8e","start_sha":"02c1e09117585f7fc73d3c5ccd4c2d6700bbd307"},"merge_error":null,"first_contribution":false,"user":{"can_merge":true}}""";
const string ONLINE_TEST_GITLAB_INSTANCE = "https://gitlab.com";
const string ONLINE_TEST_GITLAB_ACCESS_TOKEN = "PUTTOKENHERE"; // Only required for online tests (so when refreshing uhttp's trace)

void test_pipeline_job_from_json () {
    try {
        var job = new AlpineQaBot.PipelineJob.from_json (PIPELINE_TEST_JSON, "https://gitlab.com", "token");
        assert (job != null);
        assert (job.status == AlpineQaBot.PipelineStatus.Failed);
    } catch (Error e) {
        assert (false);
    }
}

void test_merge_request_job_from_json () {
    try {
        var job = new AlpineQaBot.MergeRequestJob.from_json (MERGE_REQUEST_TEST_JSON, "https://gitlab.com", "token");
        assert (job != null);
        assert (job.merge_request.id == 99);
        assert (job.merge_request.iid == 9);
        assert (job.merge_request.state == AlpineQaBot.MergeRequestState.Opened);
        assert (job.merge_request.target_branch == "master");
        assert (job.merge_request.target_project_id == 14);
        assert (job.merge_request.action == AlpineQaBot.MergeRequestAction.Open);
    } catch (Error e) {
        assert (false);
    }
}

void test_merge_request_process () {
    try {
        mock_server.start_trace ("merge_request_job");
    } catch (Error e) {
        error ("%s", e.message);
    }

    string instance_url = null;
    string api_token = null;
    if (mock_server.enable_online) {
        instance_url = ONLINE_TEST_GITLAB_INSTANCE;
        api_token = ONLINE_TEST_GITLAB_ACCESS_TOKEN;
    } else {
        instance_url = "https://%s:%u".printf (mock_server.address, mock_server.port);
        api_token = "MOCK_TOKEN";
    }

    AlpineQaBot.MergeRequestJob merge_request_job = null;
    try {
        merge_request_job = new AlpineQaBot.MergeRequestJob.from_json (MERGE_REQUEST_TEST_JSON, instance_url, ONLINE_TEST_GITLAB_ACCESS_TOKEN);
    } catch (Error e) {
        error ("%s", e.message);
    }

    var soup_session = TestLib.get_test_soup_session (mock_server);

    Test.expect_message (null, GLib.LogLevelFlags.LEVEL_WARNING, "*Failed to get a suggestion for an alternative commit message due to error Failed to open file*");

    merge_request_job.process.begin (soup_session);

    var main_context = GLib.MainContext.default ();
    while (main_context.pending ()) {
        main_context.iteration (false);
    }

    Test.assert_expected_messages ();

    mock_server.end_trace ();
}

void test_merge_request_commit_message_suggestion () {
    try {
        var job = new AlpineQaBot.MergeRequestJob.from_json (MERGE_REQUEST_TEST_JSON, "https://gitlab.com", "token");
        assert (job != null);
        job.suggestion_file_path = Test.build_filename (Test.FileType.DIST, "../data/suggestions.json");
        assert (job.get_commit_message_suggestion () == "Please use the commit format: `$repository/$pkgname: upgrade to $pkgver`");
    } catch (Error e) {
        assert (false);
    }
}

void test_merge_request_actions () {
    try {
        var job = new AlpineQaBot.MergeRequestJob.from_json (MERGE_REQUEST_TEST_JSON.replace ("open\"", "close\""), "https://gitlab.com", "token");
        assert (job != null);
        assert (job.merge_request.action == AlpineQaBot.MergeRequestAction.Close);
        job = new AlpineQaBot.MergeRequestJob.from_json (MERGE_REQUEST_TEST_JSON.replace ("open\"", "create\""), "https://gitlab.com", "token");
        assert (job != null);
        assert (job.merge_request.action == AlpineQaBot.MergeRequestAction.Create);
        job = new AlpineQaBot.MergeRequestJob.from_json (MERGE_REQUEST_TEST_JSON.replace ("open\"", "update\""), "https://gitlab.com", "token");
        assert (job != null);
        assert (job.merge_request.action == AlpineQaBot.MergeRequestAction.Update);
    } catch (Error e) {
        assert (false);
    }
}

void test_merge_request_states () {
    try {
        var job = new AlpineQaBot.MergeRequestJob.from_json (MERGE_REQUEST_TEST_JSON.replace ("opened", "closed"), "https://gitlab.com", "token");
        assert (job != null);
        assert (job.merge_request.state == AlpineQaBot.MergeRequestState.Closed);
        job = new AlpineQaBot.MergeRequestJob.from_json (MERGE_REQUEST_TEST_JSON.replace ("opened", "locked"), "https://gitlab.com", "token");
        assert (job != null);
        assert (job.merge_request.state == AlpineQaBot.MergeRequestState.Locked);
        job = new AlpineQaBot.MergeRequestJob.from_json (MERGE_REQUEST_TEST_JSON.replace ("opened", "merged"), "https://gitlab.com", "token");
        assert (job != null);
        assert (job.merge_request.state == AlpineQaBot.MergeRequestState.Merged);
    } catch (Error e) {
        assert (false);
    }
}

void test_commit_suggestion_test_all () {
    var parser = new Json.Parser ();
    try {
        parser.load_from_file (Test.build_filename (Test.FileType.DIST, "../data/suggestions.json"));
    } catch (GLib.Error e) {
        error ("Failed to open suggestions file due to error %s", e.message);
    }
    var commit_suggestions = new Gee.ArrayList<AlpineQaBot.CommitSuggestion? >();

    foreach (var commit_suggestion_obj in parser.get_root ().get_object ().get_array_member ("commit").get_elements ()) {
        commit_suggestions.add (AlpineQaBot.CommitSuggestion.from_json_object ((!)commit_suggestion_obj.get_object ()));
    }

    // Add new suggestions here
    var value_map = new Gee.HashMap<string, string? >();
    value_map.set ("testing/alpine-qa-bot: update to 0.2", "Please use the commit format: `$repository/$pkgname: upgrade to $pkgver`");
    value_map.set ("testing/alpine-qa-bot: upgrade to 0.2", null);
    value_map.set ("testing/alpine-qa-bot: move to community", "Please use 'move from' instead of 'move to'");
    value_map.set ("community/alpine-qa-bot: import from testing", "Please use 'move from' instead of 'import from'");

    foreach (var bad_msg in value_map.keys) {
        string suggestion = null;
        foreach (var commit_suggestion in commit_suggestions) {
            suggestion = commit_suggestion.match (bad_msg);
            if (suggestion != null) {
                break;
            }
        }

        assert (value_map.get (bad_msg) == suggestion);
    }

}

void test_commit_suggestion_bad_regex () {
    var parser = new Json.Parser ();
    try {
        parser.load_from_data (
            """
            {
                "commit": [
                    {
                        "offenders": [
                            ")"
                        ],
                        "suggestion": "$repository/$pkgname: upgrade to $pkgver"
                    }
                ]
            }
            """
            );
    } catch (GLib.Error e) {
        error ("Failed to open suggestions file due to error %s", e.message);
    }

    Test.expect_message (null, GLib.LogLevelFlags.LEVEL_WARNING, "*Failed to compile Regex due to error*");

    foreach (var json_obj in parser.get_root ().get_object ().get_array_member ("commit").get_elements ()) {
        var suggestion = AlpineQaBot.CommitSuggestion.from_json_object ((!)json_obj.get_object ());
        assert (suggestion.match ("commit message") == null);
    }

    Test.assert_expected_messages ();
}

public void main (string[] args) {
    Test.init (ref args);

    mock_server = new Uhm.Server ();
    TestLib.init_mock_server (mock_server, mock_serve_test_mode, "traces/jobs");

    Test.add_func ("/test/jobs/pipeline_job/from_json", test_pipeline_job_from_json);
    Test.add_func ("/test/jobs/merge_request_job/from_json", test_merge_request_job_from_json);
    Test.add_func ("/test/jobs/merge_request_job/process", test_merge_request_process);
    Test.add_func ("/test/jobs/merge_request_job/merge_request_actions", test_merge_request_actions);
    Test.add_func ("/test/jobs/merge_request_job/merge_request_states", test_merge_request_states);
    Test.add_func ("/test/jobs/merge_request_job/commit_message_suggestion", test_merge_request_commit_message_suggestion);
    Test.add_func ("/test/jobs/commit_suggestion/test_all", test_commit_suggestion_test_all);
    Test.add_func ("/test/jobs/commit_suggestion/bad_regex", test_commit_suggestion_bad_regex);
    Test.run ();
}
