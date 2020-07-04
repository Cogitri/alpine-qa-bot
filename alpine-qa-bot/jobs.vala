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

            if (root_obj.has_member ("action")) {
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
        }

        public MergeRequestAction? action { get; private set; }
        public int64 id { get; private set; }
        public int64 iid { get; private set; }
        public MergeRequestState state { get; private set; }
        public string target_branch { get; private set; }
        public int64 target_project_id { get; private set; }
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

        public abstract bool process();

        public string? api_authentication_token { get; private set; }
        public string? gitlab_instance_url { get; private set; }
        public Project? project { get; private set; }
    }

    public class JobShutdown : Job {
        public JobShutdown () {
            base (null, null, null);
        }

        public override bool process () {
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

            base.from_json_object ((Json.Object)root_object.get_object_member ("project"), gitlab_instance_url, api_authentication_token);

            if (root_object.has_member ("merge_request")) {
                this.merge_request = MergeRequest.from_json_object ((Json.Object)root_object.get_object_member ("merge_request"));
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

        public override bool process () {
            if ((this.status == PipelineStatus.Failed || this.status == PipelineStatus.Success) && this.merge_request != null) {
                var soup_session = new Soup.Session ();
                var query_url = "%s/api/v4/projects/%lld/merge_requests/%lld".printf (this.gitlab_instance_url, this.project.id, this.merge_request.iid);
                info ("Querying URL %s", query_url);
                var soup_msg = new Soup.Message ("PUT", query_url);
                soup_msg.request_headers.append ("Private-Token", this.api_authentication_token);
                if (this.status == PipelineStatus.Failed) {
                    soup_msg.set_request ("application/json", Soup.MemoryUse.COPY, "{\"add_labels\": [\"status:mr-build-broken\"]}".data);
                } else {
                    soup_msg.set_request ("application/json", Soup.MemoryUse.COPY, "{\"remove_labels\": [\"status:mr-build-broken\"]}".data);
                }

                try {
                    soup_session.send (soup_msg);
                } catch (GLib.Error e) {
                    warning ("Failed to run REST API call: %s", e.message);
                    return false;
                }

                if (soup_msg.status_code != 200) {
                    warning ("Got HTTP status code %u back from gitlab. Response: %s", soup_msg.status_code, (string) soup_msg.response_body.data);
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

            base.from_json_object ((Json.Object)root_object.get_object_member ("project"), gitlab_instance_url, api_authentication_token);
            this.merge_request = MergeRequest.from_json_object ((Json.Object)root_object.get_object_member ("object_attributes"));
        }

        public override bool process () {
            if (this.merge_request.state == MergeRequestState.Opened && this.merge_request.action == MergeRequestAction.Open) {
                var soup_session = new Soup.Session ();
                var query_url = "%s/api/v4/projects/%lld/merge_requests/%lld".printf (this.gitlab_instance_url, this.project.id, this.merge_request.iid);
                info ("Querying URL %s", query_url);
                var soup_msg = new Soup.Message ("PUT", query_url);
                soup_msg.request_headers.append ("Private-Token", this.api_authentication_token);
                // FIXME: Gitlab API doesn't know allow_collaboration is a valid parameter and wants us to specify at least one valid param,
                // so we just specify an empty add_labels here.
                soup_msg.set_request ("application/json", Soup.MemoryUse.COPY, "{\"add_labels\": null,\"allow_collaboration\": true}".data);

                try {
                    soup_session.send (soup_msg);
                } catch (GLib.Error e) {
                    warning ("Failed to run REST API call: %s", e.message);
                    return false;
                }

                if (soup_msg.status_code != 200) {
                    warning ("Got HTTP status code %u back from gitlab. Response: %s", soup_msg.status_code, (string) soup_msg.response_body.data);
                    return false;
                }
            }


            return true;
        }

        public MergeRequest merge_request { get; private set; }
    }
}
