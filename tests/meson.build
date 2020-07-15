test_lib = static_library(
    'alpine-qa-bot-test-lib',
    files('test_lib.vala'),
    dependencies: test_deps,
)

test_lib_dep = declare_dependency(
    link_with: test_lib,
    dependencies: test_deps,
    include_directories: include_directories('.'),
)

jobs_test_exe = executable(
    'alpine-qa-bot-jobs-test',
    files('jobs_test.vala'),
    dependencies: [static_lib_dep, test_lib_dep]
)

custom_target(
    'openssl_cert',
    output: ['key.pem', 'cert.pem'],
    build_by_default: true,
    command: ['openssl', 'req', '-x509', '-newkey', 'rsa:2048', '-keyout', '@OUTPUT0@', '-out', '@OUTPUT1@', '-nodes', '-subj', '/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com'],
)

test(
    'Jobs Test',
    jobs_test_exe,
    env: ['G_TEST_SRCDIR=@0@'.format(meson.current_source_dir()), 'G_TEST_BUILDDIR=@0@'.format(meson.current_build_dir())],
)

server_test_exe = executable(
    'alpine-qa-bot-server-test',
    files('server_test.vala'),
    dependencies: [static_lib_dep, test_lib_dep],
)

test(
    'server-test',
    server_test_exe,
    env: ['G_TEST_SRCDIR=@0@'.format(meson.current_source_dir()), 'G_TEST_BUILDDIR=@0@'.format(meson.current_build_dir())],
)

database_test_exe = executable(
    'alpine-qa-bot-database-test',
    files('database_test.vala'),
    dependencies: [static_lib_dep, test_lib_dep],
)

test(
    'database-test',
    database_test_exe,
    env: ['G_TEST_SRCDIR=@0@'.format(meson.current_source_dir()), 'G_TEST_BUILDDIR=@0@'.format(meson.current_build_dir())],
)