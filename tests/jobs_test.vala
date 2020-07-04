/*
 * SPDX-FileCopyrightText: 2020 Rasmus Thomsen <oss@cogitri.dev>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
public void test_pipeline_job_from_json () {
    string test_json = """
      {
         "object_kind": "pipeline",
         "object_attributes":{
            "id": 31,
            "ref": "master",
            "tag": false,
            "sha": "bcbb5ec396a2c0f828686f14fac9b80b780504f2",
            "before_sha": "bcbb5ec396a2c0f828686f14fac9b80b780504f2",
            "source": "merge_request_event",
            "status": "success",
            "stages":[
               "build",
               "test",
               "deploy"
            ],
            "created_at": "2016-08-12 15:23:28 UTC",
            "finished_at": "2016-08-12 15:26:29 UTC",
            "duration": 63,
            "variables": [
               {
               "key": "NESTOR_PROD_ENVIRONMENT",
               "value": "us-west-1"
               }
            ]
         },
         "merge_request": {
            "id": 1,
            "iid": 1,
            "title": "Test",
            "source_branch": "test",
            "source_project_id": 1,
            "target_branch": "master",
            "target_project_id": 1,
            "state": "opened",
            "merge_status": "can_be_merged",
            "url": "http://192.168.64.1:3005/gitlab-org/gitlab-test/merge_requests/1"
         },
         "user":{
            "name": "Administrator",
            "username": "root",
            "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon",
            "email": "user_email@gitlab.com"
         },
         "project":{
            "id": 1,
            "name": "Gitlab Test",
            "description": "Atque in sunt eos similique dolores voluptatem.",
            "web_url": "http://192.168.64.1:3005/gitlab-org/gitlab-test",
            "avatar_url": null,
            "git_ssh_url": "git@192.168.64.1:gitlab-org/gitlab-test.git",
            "git_http_url": "http://192.168.64.1:3005/gitlab-org/gitlab-test.git",
            "namespace": "Gitlab Org",
            "visibility_level": 20,
            "path_with_namespace": "gitlab-org/gitlab-test",
            "default_branch": "master"
         },
         "commit":{
            "id": "bcbb5ec396a2c0f828686f14fac9b80b780504f2",
            "message": "test\n",
            "timestamp": "2016-08-12T17:23:21+02:00",
            "url": "http://example.com/gitlab-org/gitlab-test/commit/bcbb5ec396a2c0f828686f14fac9b80b780504f2",
            "author":{
               "name": "User",
               "email": "user@gitlab.com"
            }
         },
         "builds":[
            {
               "id": 380,
               "stage": "deploy",
               "name": "production",
               "status": "skipped",
               "created_at": "2016-08-12 15:23:28 UTC",
               "started_at": null,
               "finished_at": null,
               "when": "manual",
               "manual": true,
               "allow_failure": false,
               "user":{
                  "name": "Administrator",
                  "username": "root",
                  "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon"
               },
               "runner": null,
               "artifacts_file":{
                  "filename": null,
                  "size": null
               }
            },
            {
               "id": 377,
               "stage": "test",
               "name": "test-image",
               "status": "success",
               "created_at": "2016-08-12 15:23:28 UTC",
               "started_at": "2016-08-12 15:26:12 UTC",
               "finished_at": null,
               "when": "on_success",
               "manual": false,
               "allow_failure": false,
               "user":{
                  "name": "Administrator",
                  "username": "root",
                  "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon"
               },
               "runner": {
                  "id":380987,
                  "description":"shared-runners-manager-6.gitlab.com",
                  "active":true,
                  "is_shared":true
               },
               "artifacts_file":{
                  "filename": null,
                  "size": null
               }
            },
            {
               "id": 378,
               "stage": "test",
               "name": "test-build",
               "status": "success",
               "created_at": "2016-08-12 15:23:28 UTC",
               "started_at": "2016-08-12 15:26:12 UTC",
               "finished_at": "2016-08-12 15:26:29 UTC",
               "when": "on_success",
               "manual": false,
               "allow_failure": false,
               "user":{
                  "name": "Administrator",
                  "username": "root",
                  "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon"
               },
               "runner": {
                  "id":380987,
                  "description":"shared-runners-manager-6.gitlab.com",
                  "active":true,
                  "is_shared":true
               },
               "artifacts_file":{
                  "filename": null,
                  "size": null
               }
            },
            {
               "id": 376,
               "stage": "build",
               "name": "build-image",
               "status": "success",
               "created_at": "2016-08-12 15:23:28 UTC",
               "started_at": "2016-08-12 15:24:56 UTC",
               "finished_at": "2016-08-12 15:25:26 UTC",
               "when": "on_success",
               "manual": false,
               "allow_failure": false,
               "user":{
                  "name": "Administrator",
                  "username": "root",
                  "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon"
               },
               "runner": {
                  "id":380987,
                  "description":"shared-runners-manager-6.gitlab.com",
                  "active":true,
                  "is_shared":true
               },
               "artifacts_file":{
                  "filename": null,
                  "size": null
               }
            },
            {
               "id": 379,
               "stage": "deploy",
               "name": "staging",
               "status": "created",
               "created_at": "2016-08-12 15:23:28 UTC",
               "started_at": null,
               "finished_at": null,
               "when": "on_success",
               "manual": false,
               "allow_failure": false,
               "user":{
                  "name": "Administrator",
                  "username": "root",
                  "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon"
               },
               "runner": null,
               "artifacts_file":{
                  "filename": null,
                  "size": null
               }
            }
         ]
      }
   """;

    try {
        var job = new AlpineQaBot.PipelineJob.from_json (test_json, "https://gitlab.com");
        assert (job != null);
        assert (job.source == "merge_request_event");
        assert (job.status == AlpineQaBot.PipelineStatus.Success);
    } catch (Error e) {
        assert (false);
    }
}

void test_merge_request_job_from_json () {
    string test_json = """
      {
         "object_kind": "merge_request",
         "user": {
         "name": "Administrator",
         "username": "root",
         "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon"
         },
         "project": {
         "id": 1,
         "name":"Gitlab Test",
         "description":"Aut reprehenderit ut est.",
         "web_url":"http://example.com/gitlabhq/gitlab-test",
         "avatar_url":null,
         "git_ssh_url":"git@example.com:gitlabhq/gitlab-test.git",
         "git_http_url":"http://example.com/gitlabhq/gitlab-test.git",
         "namespace":"GitlabHQ",
         "visibility_level":20,
         "path_with_namespace":"gitlabhq/gitlab-test",
         "default_branch":"master",
         "homepage":"http://example.com/gitlabhq/gitlab-test",
         "url":"http://example.com/gitlabhq/gitlab-test.git",
         "ssh_url":"git@example.com:gitlabhq/gitlab-test.git",
         "http_url":"http://example.com/gitlabhq/gitlab-test.git"
         },
         "repository": {
         "name": "Gitlab Test",
         "url": "http://example.com/gitlabhq/gitlab-test.git",
         "description": "Aut reprehenderit ut est.",
         "homepage": "http://example.com/gitlabhq/gitlab-test"
         },
         "object_attributes": {
         "id": 99,
         "target_branch": "master",
         "source_branch": "ms-viewport",
         "source_project_id": 14,
         "author_id": 51,
         "assignee_id": 6,
         "title": "MS-Viewport",
         "created_at": "2013-12-03T17:23:34Z",
         "updated_at": "2013-12-03T17:23:34Z",
         "milestone_id": null,
         "state": "opened",
         "merge_status": "unchecked",
         "target_project_id": 14,
         "iid": 1,
         "description": "",
         "source": {
            "name":"Awesome Project",
            "description":"Aut reprehenderit ut est.",
            "web_url":"http://example.com/awesome_space/awesome_project",
            "avatar_url":null,
            "git_ssh_url":"git@example.com:awesome_space/awesome_project.git",
            "git_http_url":"http://example.com/awesome_space/awesome_project.git",
            "namespace":"Awesome Space",
            "visibility_level":20,
            "path_with_namespace":"awesome_space/awesome_project",
            "default_branch":"master",
            "homepage":"http://example.com/awesome_space/awesome_project",
            "url":"http://example.com/awesome_space/awesome_project.git",
            "ssh_url":"git@example.com:awesome_space/awesome_project.git",
            "http_url":"http://example.com/awesome_space/awesome_project.git"
         },
         "target": {
            "name":"Awesome Project",
            "description":"Aut reprehenderit ut est.",
            "web_url":"http://example.com/awesome_space/awesome_project",
            "avatar_url":null,
            "git_ssh_url":"git@example.com:awesome_space/awesome_project.git",
            "git_http_url":"http://example.com/awesome_space/awesome_project.git",
            "namespace":"Awesome Space",
            "visibility_level":20,
            "path_with_namespace":"awesome_space/awesome_project",
            "default_branch":"master",
            "homepage":"http://example.com/awesome_space/awesome_project",
            "url":"http://example.com/awesome_space/awesome_project.git",
            "ssh_url":"git@example.com:awesome_space/awesome_project.git",
            "http_url":"http://example.com/awesome_space/awesome_project.git"
         },
         "last_commit": {
            "id": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
            "message": "fixed readme",
            "timestamp": "2012-01-03T23:36:29+02:00",
            "url": "http://example.com/awesome_space/awesome_project/commits/da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
            "author": {
               "name": "GitLab dev user",
               "email": "gitlabdev@dv6700.(none)"
            }
         },
         "work_in_progress": false,
         "url": "http://example.com/diaspora/merge_requests/1",
         "action": "open",
         "assignee": {
            "name": "User1",
            "username": "user1",
            "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon"
         }
         },
         "labels": [{
         "id": 206,
         "title": "API",
         "color": "#ffffff",
         "project_id": 14,
         "created_at": "2013-12-03T17:15:43Z",
         "updated_at": "2013-12-03T17:15:43Z",
         "template": false,
         "description": "API related issues",
         "type": "ProjectLabel",
         "group_id": 41
         }],
         "changes": {
         "updated_by_id": {
            "previous": null,
            "current": 1
         },
         "updated_at": {
            "previous": "2017-09-15 16:50:55 UTC",
            "current":"2017-09-15 16:52:00 UTC"
         },
         "labels": {
            "previous": [{
               "id": 206,
               "title": "API",
               "color": "#ffffff",
               "project_id": 14,
               "created_at": "2013-12-03T17:15:43Z",
               "updated_at": "2013-12-03T17:15:43Z",
               "template": false,
               "description": "API related issues",
               "type": "ProjectLabel",
               "group_id": 41
            }],
            "current": [{
               "id": 205,
               "title": "Platform",
               "color": "#123123",
               "project_id": 14,
               "created_at": "2013-12-03T17:15:43Z",
               "updated_at": "2013-12-03T17:15:43Z",
               "template": false,
               "description": "Platform related issues",
               "type": "ProjectLabel",
               "group_id": 41
            }]
         }
         }
      }
   """;

    try {
        var job = new AlpineQaBot.MergeRequestJob.from_json (test_json, "https://gitlab.com");
        assert (job != null);
        assert (job.merge_request.id == 99);
        assert (job.merge_request.iid == 1);
        assert (job.merge_request.state == AlpineQaBot.MergeRequestState.Opened);
        assert (job.merge_request.target_branch == "master");
        assert (job.merge_request.target_project_id == 14);
    } catch (Error e) {
        assert (false);
    }
}

public void main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/test/jobs/pipeline_job/from_json", test_pipeline_job_from_json);
    Test.add_func ("/test/jobs/merge_request_job/from_json", test_merge_request_job_from_json);
    Test.run ();
}
