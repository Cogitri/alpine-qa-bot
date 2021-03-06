namespace AlpineQaBot {
    public class Poller : GLib.Object {
        public Poller (string api_auth_token, string gitlab_instance_url) {
            this.api_auth_token = api_auth_token;
            this.gitlab_instance_url = gitlab_instance_url;
        }

        public async Gee.ArrayList<Job> poll (uint project_id, Soup.Session? default_soup_session = null, string db_dir = Config.SHARED_STATE_DIR, GLib.DateTime? default_date = null) throws DatabaseError {
            debug ("Starting to poll");

            Gee.ArrayList<Job> res = new Gee.ArrayList<Job>();

            var ret = yield this.poll_active_merge_requests(project_id, default_soup_session, db_dir, default_date);

            res.add_all (ret ?? new Gee.ArrayList<Job>());

            ret = yield this.poll_stale_merge_requests(project_id, default_soup_session, db_dir, default_date);

            res.add_all (ret ?? new Gee.ArrayList<Job>());

            ret = yield this.poll_failed_merge_requests(project_id, default_soup_session, db_dir);

            res.add_all (ret ?? new Gee.ArrayList<Job>());

            return res;
        }

        protected async Gee.ArrayList<Job>? poll_stale_merge_requests (uint project_id, Soup.Session? default_soup_session = null, string db_dir = Config.SHARED_STATE_DIR, GLib.DateTime? default_date = null) throws DatabaseError {
            string json_reply;
            var db = new SqliteDatabase ();
            var parser = new Json.Parser ();
            var query_url = "%s/api/v4/projects/%u/merge_requests?state=opened&updated_before=%s".printf (this.gitlab_instance_url, project_id, default_date != null ? default_date.to_string () : new GLib.DateTime.now ().add_days (-28).to_string ());
            var request_sender = new RequestSender (query_url, "GET", null, null, default_soup_session);

            db.open ("%s/poller.db".printf (db_dir));

            yield request_sender.send(out json_reply);

            if (json_reply == null) {
                warning ("Didn't get reply from Gitlab for polling...");
                return null;
            }

            try {
                parser.load_from_data (json_reply);
            } catch (GLib.Error e) {
                warning ("Failed to parse response containing all open MRs due to error %s", e.message);
                return null;
            }

            Gee.ArrayList<Job> res = new Gee.ArrayList<Job>();
            var now_time = new GLib.DateTime.now ();
            try {
                foreach (var merge_request in parser.get_root ().get_array ().get_elements ()) {
                    var id = merge_request.get_object ().get_int_member ("id");
                    db.save_stale_mark_time (id, now_time);
                    res.add ((Job) new StaleMergeRequestJob.from_json (Json.to_string (merge_request, false), gitlab_instance_url, api_auth_token));
                }
            } catch (GLib.Error e) {
                warning ("Failed to iterate over stale MRs due to error %s", e.message);
            }

            return res;
        }

        protected async Gee.ArrayList<Job>? poll_active_merge_requests (uint project_id, Soup.Session? default_soup_session = null, string db_dir = Config.SHARED_STATE_DIR, GLib.DateTime? default_date = null) throws DatabaseError {
            string json_reply;
            var db = new SqliteDatabase ();
            var parser = new Json.Parser ();
            var query_url = "%s/api/v4/projects/%u/merge_requests?state=opened&labels=status:mr-stale&updated_after=%s".printf (this.gitlab_instance_url, project_id, default_date != null ? default_date.to_string () : new GLib.DateTime.now ().add_days (-28).add_seconds (60).to_string ());
            var request_sender = new RequestSender (query_url, "GET", null, null, default_soup_session);

            db.open ("%s/poller.db".printf (db_dir));

            yield request_sender.send(out json_reply);

            if (json_reply == null) {
                warning ("Didn't get reply from Gitlab for polling...");
                return null;
            }

            try {
                parser.load_from_data (json_reply);
            } catch (GLib.Error e) {
                warning ("Failed to parse response containing all open MRs due to error %s", e.message);
                return null;
            }

            Gee.ArrayList<Job> res = new Gee.ArrayList<Job>();
            var merge_requests = parser.get_root ().get_array ().get_elements ();
            try {
                foreach (var merge_request in merge_requests) {
                    var id = merge_request.get_object ().get_int_member ("id");
                    var stale_mark_time = db.get_stale_mark_time (id);
                    if (stale_mark_time != null) {
                        var last_update = new GLib.DateTime.from_iso8601 (merge_request.get_object ().get_string_member ("updated_at"), null);
                        if (stale_mark_time.difference (last_update) >= GLib.TimeSpan.MINUTE) {
                            res.add ((Job) new ActiveMergeRequestJob.from_json (Json.to_string (merge_request, false), gitlab_instance_url, api_auth_token));
                        }
                    }
                }
            } catch (GLib.Error e) {
                warning ("Failed to iterate over active MRs due to error %s", e.message);
            }

            return res;
        }

        protected async Gee.ArrayList<Job>? poll_failed_merge_requests (uint project_id, Soup.Session? default_soup_session = null, string db_dir = Config.SHARED_STATE_DIR) throws DatabaseError {
            GLib.List<weak Json.Node? > merge_requests;
            string json_reply;
            var database = new SqliteDatabase ();
            var parser = new Json.Parser ();
            var query_url = "%s/api/v4/projects/%u/merge_requests?state=opened&view=simple".printf (this.gitlab_instance_url, project_id);
            var request_sender = new RequestSender (query_url, "GET", null, null, default_soup_session);

            yield request_sender.send(out json_reply);

            if (json_reply == null) {
                warning ("Didn't get reply from Gitlab for polling...");
                return null;
            }

            try {
                parser.load_from_data (json_reply);
            } catch (GLib.Error e) {
                warning ("Failed to parse response containing all open MRs due to error %s", e.message);
                return null;
            }

            merge_requests = parser.get_root ().get_array ().get_elements ();
            database.open ("%s/poller.db".printf (db_dir));
            Gee.ArrayList<Job> res = new Gee.ArrayList<Job>();
            try {
                foreach (var merge_request in merge_requests) {
                    var merge_request_id = merge_request.get_object ().get_int_member ("id");
                    var merge_request_iid = merge_request.get_object ().get_int_member ("iid");
                    var merge_request_query_url = "%s/api/v4/projects/%u/merge_requests/%lld".printf (this.gitlab_instance_url, project_id, merge_request_iid);
                    var merge_request_sender = new RequestSender (merge_request_query_url, "GET", null, null, default_soup_session);
                    string merge_request_json_reply;
                    PipelineJob pipeline_job;
                    PipelineStatus? pipeline_status;

                    yield merge_request_sender.send(out merge_request_json_reply);

                    pipeline_job = new PipelineJob.from_json (merge_request_json_reply, this.gitlab_instance_url, this.api_auth_token);
                    pipeline_status = database.get_pipeline_status (merge_request_id);
                    if (pipeline_status == null || pipeline_status != pipeline_job.status) {
                        res.add ((Job) pipeline_job);
                        pipeline_status = pipeline_job.status;
                    }
                    database.save_pipeline_status (merge_request_id, pipeline_status);
                }
            } catch (GLib.Error e) {
                warning ("Failed to iterate over merge requests due to error %s", e.message);
                return null;
            }

            return res;
        }

        public string gitlab_instance_url { get; private set; }
        private string api_auth_token { private get; private set; }
    }
}
