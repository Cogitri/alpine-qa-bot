/*
 * SPDX-FileCopyrightText: 2020 Rasmus Thomsen <oss@cogitri.dev>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
namespace AlpineQaBot {
    public enum MergeRequestState {
        Closed,
        Locked,
        Merged,
        Opened,
    }

    public enum MergeRequestAction {
        Close,
        Create,
        Open,
        Update,
    }

    public enum PipelineStatus {
        Canceled,
        Created,
        Failed,
        Manual,
        Pending,
        Running,
        Skipped,
        Success,
    }

    public struct Project {
        public Project (int64 id, string name) {
            this.id = id;
            this.name = name;
        }

        public int64 id { get; private set; }
        public string name { get; private set; }
    }

    public struct MergeRequest {
        public MergeRequest (MergeRequestAction action, int64 id, int64 iid, MergeRequestState state, string target_branch, int64 target_project_id) {
            this.action = action;
            this.id = id;
            this.iid = iid;
            this.state = state;
            this.target_branch = target_branch;
            this.target_project_id = target_project_id;
        }

        public MergeRequest.from_json_object (Json.Object root_obj) {
            this.id = root_obj.get_int_member ("id");
            this.iid = root_obj.get_int_member ("iid");
            this.target_branch = root_obj.get_string_member ("target_branch");
            this.target_project_id = root_obj.get_int_member ("target_project_id");

            switch (root_obj.get_string_member ("state")) {
            case "closed":
                this.state = MergeRequestState.Closed;
                break;
            case "locked":
                this.state = MergeRequestState.Locked;
                break;
            case "merged":
                this.state = MergeRequestState.Merged;
                break;
            case "opened":
                this.state = MergeRequestState.Opened;
                break;
            default:
                error ("Unknown merge request state %s", root_obj.get_string_member ("state"));
            }

            if (root_obj.has_member ("action") && !root_obj.get_null_member ("action")) {
                switch (root_obj.get_string_member ("action")) {
                case "close":
                    this.action = MergeRequestAction.Close;
                    break;
                case "create":
                    this.action = MergeRequestAction.Create;
                    break;
                case "open":
                    this.action = MergeRequestAction.Open;
                    break;
                case "update":
                    this.action = MergeRequestAction.Update;
                    break;
                default:
                    error ("Unknown merge request action %s", root_obj.get_string_member ("action"));
                }
            }

            if (root_obj.has_member ("last_commit") && !root_obj.get_null_member ("last_commit")) {
                this.commit = Commit.from_json_object ((!)root_obj.get_object_member ("last_commit"));
            }
        }

        public MergeRequestAction? action { get; private set; }
        public Commit? commit { get; private set; }
        public int64 id { get; private set; }
        public int64 iid { get; private set; }
        public MergeRequestState state { get; private set; }
        public string target_branch { get; private set; }
        public int64 target_project_id { get; private set; }
    }

    public struct Commit {
        public Commit (string id, string message) {
            this.id = id;
            this.message = message;
        }

        public Commit.from_json_object (Json.Object root_obj) {
            this.id = root_obj.get_string_member ("id");
            this.message = root_obj.get_string_member ("message");
        }

        public string id { get; private set; }
        public string message { get; private set; }
    }

    public struct CommitSuggestion {
        public CommitSuggestion (Gee.ArrayList<string> offenders, string suggestion) {
            this.offenders = offenders;
            this.suggestion = suggestion;
        }

        public CommitSuggestion.from_json_object (Json.Object root_obj) {
            this.offenders = new Gee.ArrayList<string>();
            var offenders_arr = root_obj.get_array_member ("offenders").get_elements ();
            foreach (var offenders_element in offenders_arr) {
                this.offenders.add (offenders_element.get_string ());
            }
            this.suggestion = root_obj.get_string_member ("suggestion");
        }

        public string? match (string commit_message) {
            foreach (var offender in this.offenders) {
                try {
                    var regex = new GLib.Regex (offender);
                    if (regex.match (commit_message)) {
                        return this.suggestion;
                    }
                } catch (GLib.RegexError e) {
                    warning ("Failed to compile Regex due to error %s", e.message);
                }
            }

            return null;
        }

        public Gee.ArrayList<string> offenders;
        public string suggestion { get; private set; }
    }

    public class RequestSender : GLib.Object {
        public RequestSender (string query_url, string http_method, string api_authentication_token, uint8[]? data, Soup.Session? default_soup_session) {
            this.soup_session = default_soup_session ?? new Soup.Session ();
            this.soup_message = new Soup.Message (http_method, query_url);

            info ("Querying URL %s", query_url);
            assert_nonnull (soup_message);
            soup_message.request_headers.append ("Private-Token", api_authentication_token);
            if (data != null) {
                soup_message.set_request ("application/json", Soup.MemoryUse.COPY, data);
            }
        }

        public bool send () {
            try {
                soup_session.send (this.soup_message);
            } catch (GLib.Error e) {
                warning ("Failed to run REST API call: %s", e.message);
                return false;
            }

            if (this.soup_message.status_code != 200) {
                warning ("Got HTTP status code %u back from gitlab. Response: %s", this.soup_message.status_code, (string) this.soup_message.response_body.data);
                return false;
            }

            return true;
        }

        private Soup.Session soup_session;
        private Soup.Message soup_message;
    }

    public abstract class Job : GLib.Object {
        protected Job (Project? project, string? gitlab_instance_url, string? api_authentication_token) {
            this.project = project;
            this.gitlab_instance_url = gitlab_instance_url;
            this.api_authentication_token = api_authentication_token;
        }

        protected Job.from_json_object (Json.Object root_obj, string gitlab_instance_url, string? api_authentication_token) throws GLib.Error {
            this.project = Project (root_obj.get_int_member ("id"), root_obj.get_string_member ("name"));
            this.gitlab_instance_url = gitlab_instance_url;
            this.api_authentication_token = api_authentication_token;
        }

        public abstract bool process(Soup.Session? default_soup_session = null);

        public string? api_authentication_token { get; private set; }
        public string? gitlab_instance_url { get; private set; }
        public Project? project { get; private set; }
    }

    public class JobShutdown : Job {
        public JobShutdown () {
            base (null, null, null);
        }

        public override bool process (Soup.Session? default_soup_session = null) {
            return true;
        }

    }

    public class PipelineJob : Job {
        public PipelineJob (Project project, string source, string gitlab_instance_url, string api_authentication_token) {
            base (project, gitlab_instance_url, api_authentication_token);
            this.source = source;
        }

        public PipelineJob.from_json (string json, string gitlab_instance_url, string api_authentication_token) throws GLib.Error {
            var parser = new Json.Parser ();
            parser.load_from_data (json);
            var root_object = parser.get_root ().get_object ();

            base.from_json_object ((!)root_object.get_object_member ("project"), gitlab_instance_url, api_authentication_token);

            if (root_object.has_member ("merge_request") && !root_object.get_null_member ("merge_request")) {
                this.merge_request = MergeRequest.from_json_object ((!)root_object.get_object_member ("merge_request"));
            }

            this.source = root_object.get_object_member ("object_attributes").get_string_member ("source");

            var object_attributes = root_object.get_object_member ("object_attributes");
            switch (object_attributes.get_string_member ("status")) {
            case "canceled":
                this.status = PipelineStatus.Canceled;
                break;
            case "created":
                this.status = PipelineStatus.Created;
                break;
            case "failed":
                this.status = PipelineStatus.Failed;
                break;
            case "manual":
                this.status = PipelineStatus.Manual;
                break;
            case "pending":
                this.status = PipelineStatus.Pending;
                break;
            case "running":
                this.status = PipelineStatus.Running;
                break;
            case "skipped":
                this.status = PipelineStatus.Skipped;
                break;
            case "success":
                this.status = PipelineStatus.Success;
                break;
            default:
                error ("Unknown pipeline status %s", object_attributes.get_string_member ("status"));
            }
        }

        public override bool process (Soup.Session? default_soup_session = null) {
            if ((this.status == PipelineStatus.Failed || this.status == PipelineStatus.Success) && this.merge_request != null) {
                debug ("Querying Gitlab to add/remove status:mr-build-broken label to successfull/failing MR");

                var query_url = "%s/api/v4/projects/%lld/merge_requests/%lld".printf (this.gitlab_instance_url, this.project.id, this.merge_request.iid);

                string message = null;
                if (this.status == PipelineStatus.Failed) {
                    message = "{\"add_labels\": [\"status:mr-build-broken\"]}";
                } else {
                    message = "{\"remove_labels\": [\"status:mr-build-broken\"]}";
                }

                var request_sender = new RequestSender (query_url, "PUT", this.api_authentication_token, message.data, default_soup_session);

                if (!request_sender.send ()) {
                    return false;
                }
            }


            return true;
        }

        public string source { get; private set; }
        public PipelineStatus status { get; private set; }
        public MergeRequest? merge_request { get; private set; }
    }

    public class MergeRequestJob : Job {
        public MergeRequestJob (Project project, MergeRequest merge_request, string gitlab_instance_url, string api_authentication_token) {
            base (project, gitlab_instance_url, api_authentication_token);
            this.merge_request = merge_request;
        }

        public MergeRequestJob.from_json (string json, string gitlab_instance_url, string api_authentication_token) throws GLib.Error {
            var parser = new Json.Parser ();
            parser.load_from_data (json);
            var root_object = parser.get_root ().get_object ();

            base.from_json_object ((!)root_object.get_object_member ("project"), gitlab_instance_url, api_authentication_token);
            this.merge_request = MergeRequest.from_json_object ((!)root_object.get_object_member ("object_attributes"));
        }

        public override bool process (Soup.Session? default_soup_session = null) {
            string? commit_message_suggestion = null;
            try {
                commit_message_suggestion = this.get_commit_message_suggestion ();
            } catch (GLib.Error e) {
                warning ("Failed to get a suggestion for an alternative commit message due to error %s", e.message);
            }

            if (commit_message_suggestion != null) {
                debug ("Querying Gitlab to suggest better commit message for MR %lld", this.merge_request.iid);

                var query_url = "%s/api/v4/projects/%lld/merge_requests/%lld/notes".printf (this.gitlab_instance_url, this.project.id, this.merge_request.iid);
                var request_sender = new RequestSender (query_url, "POST", this.api_authentication_token, @"{\"body\": \"$commit_message_suggestion\"}".data, default_soup_session);
                if (!request_sender.send ()) {
                    return false;
                }
            }

            if (this.merge_request.state == MergeRequestState.Opened && this.merge_request.action == MergeRequestAction.Open) {
                debug ("Querying Gitlab to allow commit from maintainers for MR %lld", this.merge_request.iid);

                var query_url = "%s/api/v4/projects/%lld/merge_requests/%lld".printf (this.gitlab_instance_url, this.project.id, this.merge_request.iid);
                // FIXME: Gitlab API doesn't know allow_collaboration is a valid parameter and wants us to specify at least one valid param,
                // so we just specify an empty add_labels here.
                var request_sender = new RequestSender (query_url, "PUT", this.api_authentication_token, "{\"add_labels\": null,\"allow_collaboration\": true}".data, default_soup_session);
                if (!request_sender.send ()) {
                    return false;
                }
            }


            return true;
        }

        public string? get_commit_message_suggestion (string? suggestion_file_path = null) throws GLib.Error {
            var parser = new Json.Parser ();
            parser.load_from_file (suggestion_file_path ?? "%s/suggestions.json".printf (Config.SYSCONFIG_DIR));

            foreach (var commit_suggestion_obj in parser.get_root ().get_object ().get_array_member ("commit").get_elements ()) {
                var commit_suggestion = CommitSuggestion.from_json_object ((!)commit_suggestion_obj.get_object ());
                var match = commit_suggestion.match (this.merge_request.commit.message);
                if (match != null) {
                    return match;
                }
            }

            return null;
        }

        public MergeRequest merge_request { get; private set; }
    }
}
