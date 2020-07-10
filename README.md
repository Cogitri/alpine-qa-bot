# alpine-qa-bot
[![Gitlab CI status](https://gitlab.alpinelinux.org/Cogitri/alpine-qa-bot/badges/master/pipeline.svg)](https://gitlab.alpineliux.org/Cogitri/alpine-qa-bot/commits/master)

alpine-qa-bot is a gitlab bot, written in Vala. It receives events via Gitlab's webhooks and reacts to them, e.g. by allowing maintainers to push to making newly created merge requests. It also periodically polls Gitlab for certain actions which aren't exposed via Gitlab's webhooks.

## Setting Up
First, you have to build&install alpine-qa-bot:

```sh
sudo apk add pc:glib-2.0 pc:gobject-2.0 pc:libsoup-2.4 pc:json-glib-1.0 pc:gee-0.8 pc:libuhttpmock-0.0 openssl vala meson
meson build && meson compile -C build && meson test -v -C build && meson install -C build
```

This will install alpine-qa-bot into /usr/local/bin/alpine-qa-bot-server.
Now you have to edit alpine-qa-bot's config to your liking. You have to set at least `GitlabToken` and `AuthenticationToken`. The former is the token you set as secret in your webhook settings, the latter is the API token of the bot account, which is used for making comments etc.

## Contributing

You can install and test alpine-qa-bot as described in `Setting Up`.

### Code formatting

alpine-qa-bot Vala code is formatted via uncrustify. Please install uncrustify and run it via `uncrustify -c uncrustify.cfg -l VALA src/*` from the top of the repo to make sure your code is formatted correctly.

### Adding commit suggestions

You can add additional commit suggestions to `data/suggestions.json` by adding new objects to the `"commit"` array. You can put strings containing PCRE regex into the `offenders` array of strings. If one of the offenders is matched against the commit message, the `sugggestion` will be posted on the MR, like this:

```
Beep Boop, I'm a Bot.

It seems one of your commit's message doesn't follow the Alpine Linux guidelines for commit messages. Please follow the format `$SUGGESTION`.
If you believe this was a mistake, please feel free to open an issue at https://gitlab.alpinelinux.org/Cogitri/alpine-qa-bot or ping @Cogitri.

Thanks!
```

Keep in mind that the suggestion objects are matched in order. If multiple `offender`s match a commit message the first one (as in the one that's closest to the top of the `suggestions.json` file will win and the `suggestion` it's attached to will be posted.

Please add a unittest for newly added `offenders`. Do do that, edit `tests/jobs_test.vala` and add your new `suggestion`/`offender` to the test list like so under `// Add new suggestions here`:

```
value_map.set("COMMIT_MESSAGE_THAT_TRIGGERS_SUGGESTION", "EXPECTED_SUGGESTION");
```
