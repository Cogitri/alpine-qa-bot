/*
 * SPDX-FileCopyrightText: 2020 Rasmus Thomsen <oss@cogitri.dev>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
namespace AlpineQaBot {
    public class Worker {
        public Worker (AsyncQueue<AlpineQaBot.Job> job_queue) {
            this.job_queue = job_queue;

            this.worker_thread = new Thread<void>("worker-thread", thread_func);
        }

        private void thread_func () {
            while (true) {
                var job = this.job_queue.pop ();
                job.process ();
            }
        }

        private AsyncQueue<Job> job_queue;
        private Thread<void> worker_thread;
    }
}
