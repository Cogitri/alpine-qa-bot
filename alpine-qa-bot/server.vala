/*
 * SPDX-FileCopyrightText: 2020 Rasmus Thomsen <oss@cogitri.dev>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
namespace AlpineQaBot {
    public class WebHookEventListenerServer : Soup.Server {
        public WebHookEventListenerServer (string gitlab_token) throws GLib.Error {
            Object (port: 8088);
            assert (this != null);

            this.gitlab_token = gitlab_token;
            this.job_queue = new AsyncQueue<AlpineQaBot.Job>();
            this.add_handler ("/triage/system-hooks", gitlab_post_handler);
            this.add_handler (null, default_handler);
            this.listen_all (8080, Soup.ServerListenOptions.IPV4_ONLY);

        }

        private static void gitlab_post_handler (Soup.Server server, Soup.Message msg, string path, GLib.HashTable ? query, Soup.ClientContext client) {
            var self = server as WebHookEventListenerServer;
            assert (self != null);

            if (msg.request_headers.get_one ("X-Gitlab-Token") != self.gitlab_token) {
                msg.set_status (Soup.Status.FORBIDDEN);
                msg.set_response ("application/json", Soup.MemoryUse.COPY, "{'message': 'FAIL'}".data);
                return;
            }

            switch (msg.request_headers.get_one ("X-Gitlab-Event")) {
            case "Pipeline Hook":
                try {
                    self.job_queue.push (new PipelineJob.from_json ((string) msg.request_body.data));
                } catch (Error e) {
                    warning ("Failed to add new job due to error %s", e.message);
                    msg.set_response ("application/json", Soup.MemoryUse.COPY, "{'message': 'FAIL'}".data);
                    msg.set_status (Soup.Status.INTERNAL_SERVER_ERROR);
                    return;
                }
                break;
            default:
                warning ("Received unknown event %s", msg.request_headers.get_one ("X-Gitlab-Event"));
                break;
            }

            msg.set_response ("application/json", Soup.MemoryUse.COPY, "{'message': 'OK'}".data);
            msg.set_status (Soup.Status.OK);
        }

        private static void default_handler (Soup.Server server, Soup.Message msg, string path, GLib.HashTable ? query, Soup.ClientContext client) {
            var self = server as WebHookEventListenerServer;
            assert (self != null);
            string html_head = "<head><title>Gitlab-Bot status page</title></head>";
            string html_body = "<body><h1>Status:</h1><p>Up and running!</p></body>";
            msg.set_response ("text/html", Soup.MemoryUse.COPY, "<html>%s%s</html>".printf (html_head, html_body).data);
            msg.set_status (Soup.Status.OK);
        }

        private string gitlab_token;
        public AsyncQueue<AlpineQaBot.Job> job_queue { get; private set; }
    }
}
