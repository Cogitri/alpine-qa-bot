/*
 * SPDX-FileCopyrightText: 2020 Rasmus Thomsen <oss@cogitri.dev>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
public int main (string[] args) {
    assert (GLib.Thread.supported ());

    var key_file = new GLib.KeyFile ();
    var key_file_path = "%s/alpine-qa-bot/alpine-qa-bot.config".printf (Config.SYSCONFIG_DIR);
    try {
        key_file.load_from_file (key_file_path, GLib.KeyFileFlags.NONE);
    } catch (GLib.FileError e) {
        error ("Failed to read key file %s due to error '%s'", key_file_path, e.message);
    } catch (GLib.KeyFileError e) {
        error ("Failed to parse key file %s due to error '%s'", key_file_path, e.message);
    }

    string gitlab_instance_url = null;
    string gitlab_token = null;
    uint server_port = 0;
    try {
        gitlab_instance_url = key_file.get_string ("Server", "GitlabUrl");
        gitlab_token = key_file.get_string ("Server", "GitlabToken");
        server_port = key_file.get_integer ("Server", "Port");
    } catch (GLib.KeyFileError e) {
        error ("Failed to find required keys in config files due to error '%s'", e.message);
    }

    var loop = new MainLoop ();
    AlpineQaBot.WebHookEventListenerServer ev = null;
    try {
        ev = new AlpineQaBot.WebHookEventListenerServer (gitlab_instance_url, gitlab_token, server_port);
    } catch (Error e) {
        warning ("Failed to listen on port 8080 due to error %s", e.message);
    }
    new AlpineQaBot.Worker (ev.job_queue);
    loop.run ();
    return 0;
}