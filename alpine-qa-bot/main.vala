/*
 * SPDX-FileCopyrightText: 2020 Rasmus Thomsen <oss@cogitri.dev>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
public int main (string[] args) {
    assert (Thread.supported ());

    var loop = new MainLoop ();
    AlpineQaBot.WebHookEventListenerServer ev = null;
    try {
        ev = new AlpineQaBot.WebHookEventListenerServer ("test");
    } catch (Error e) {
        warning ("Failed to listen on port 8080 due to error %s", e.message);
    }
    new AlpineQaBot.Worker (ev.job_queue);
    loop.run ();
    return 0;
}
