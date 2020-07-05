/*
 * SPDX-FileCopyrightText: 2020 Rasmus Thomsen <oss@cogitri.dev>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
namespace AlpineQaBot {
    public class Worker {
        public Worker (AsyncQueue<AlpineQaBot.Job> job_queue, MainLoop loop, Soup.Session? soup_session = null) {
            this.job_queue = job_queue;
            this.soup_session = soup_session;
            this.loop = loop;

            this.worker_thread = new Thread<void>("worker-thread", thread_func);
        }

        private void thread_func () {
            while (true) {
                var job = this.job_queue.pop ();
                if (job is JobShutdown) {
                    this.loop.quit ();
                }
                job.process (this.soup_session);
            }
        }

        private MainLoop loop;
        private Soup.Session? soup_session;
        private AsyncQueue<Job> job_queue;
        private Thread<void> worker_thread;
    }
}
