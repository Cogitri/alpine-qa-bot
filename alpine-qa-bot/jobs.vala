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
        public MergeRequest (int64 id, int64 iid, MergeRequestState state, string target_branch, int64 target_project_id) {
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
        }

        public int64 id { get; private set; }
        public int64 iid { get; private set; }
        public MergeRequestState state { get; private set; }
        public string target_branch { get; private set; }
        public int64 target_project_id { get; private set; }
    }

    public abstract class Job : GLib.Object {
        protected Job (Project? project, string? gitlab_instance_url) {
            this.project = project;
            this.gitlab_instance_url = gitlab_instance_url;
        }

        protected Job.from_json_object (Json.Object root_obj, string gitlab_instance_url) throws GLib.Error {
            this.project = Project (root_obj.get_int_member ("id"), root_obj.get_string_member ("name"));
            this.gitlab_instance_url = gitlab_instance_url;
        }

        public abstract bool process();

        public string? gitlab_instance_url { get; private set; }
        public Project? project { get; private set; }
    }

    public class JobShutdown : Job {
        public JobShutdown () {
            base (null, null);
        }

        public override bool process () {
            return true;
        }

    }

    public class PipelineJob : Job {
        public PipelineJob (Project project, string source, string gitlab_instance_url) {
            base (project, gitlab_instance_url);
            this.source = source;
        }

        public PipelineJob.from_json (string json, string gitlab_instance_url) throws GLib.Error {
            var parser = new Json.Parser ();            parser.load_from_data (json);
            var root_object = parser.get_root ().get_object ();

            base.from_json_object ((Json.Object)root_object.get_object_member ("project"), gitlab_instance_url);
            this.merge_request = MergeRequest.from_json_object ((Json.Object)root_object.get_object_member ("merge_request"));
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
            if (this.status == PipelineStatus.Failed || this.status == PipelineStatus.Success) {
                var rest_proxy = new Rest.Proxy ("%s/projects/%d/merge_requests/%d", true);
                rest_proxy.bind (this.gitlab_instance_url, this.project.id, this._merge_request.iid);
                var rest_proxy_call = rest_proxy.new_call ();

                if (this.status == PipelineStatus.Failed) {
                    rest_proxy_call.add_param ("add_labels", "status:mr-build-broken");
                } else {
                    rest_proxy_call.add_param ("remove_labels", "status:mr-build-broken");
                }

                try {
                    rest_proxy_call.run ();
                } catch (GLib.Error e) {
                    warning ("Failed to run REST API call: %s", e.message);
                    return false;
                }

                if (rest_proxy_call.get_status_code () != 200) {
                    warning ("Got HTTP status code %u back from gitlab", rest_proxy_call.get_status_code ());
                    return false;
                }
            }


            return true;
        }

        public string source { get; private set; }
        public PipelineStatus status { get; private set; }
        public MergeRequest merge_request { get; private set; }
    }
}
