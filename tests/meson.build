jobs_test_exe = executable(
    'jobs_test',
    files('jobs_test.vala'),
    dependencies: [static_lib_dep, test_deps]
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
