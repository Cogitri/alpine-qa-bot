lib_src = files(
    'jobs.vala',
    'server.vala',
    'worker.vala',
)

static_lib = shared_library(
    'alpine-qa-bot-static-lib',
    lib_src,
    dependencies: deps,
    vala_header: 'alpine-qa-bot.h',
    vala_vapi: 'alpine-qa-bot-0.0.vapi',
    vala_gir: 'Alpine-Qa-Bot-0.0.gir',
)

static_lib_dep = declare_dependency(
    link_with: static_lib,
    dependencies: deps,
    include_directories: include_directories('.'),
)

executable(
    'alpine-qa-bot-server',
    files('main.vala'),
    dependencies: static_lib_dep,
)
