project(
    'alpine-qa-bot',
    ['vala', 'c'],
    license: 'GPL-3.0-or-later',
    version: '0.0.1'
)

deps = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('libsoup-2.4', version: '>=2.46'),
    dependency('threads'),
    dependency('json-glib-1.0'),
    dependency('gee-0.8'),
    dependency('sqlite3'),
]

test_deps = [
    dependency('libuhttpmock-0.0')
]

# Add our config VAPI
add_project_arguments(
  [
    '--vapidir', join_paths(meson.source_root(), 'alpine-qa-bot'),
    '--pkg', 'config',
  ],
  language: 'vala'
)

# Configuration
conf = configuration_data()
conf.set_quoted('SYSCONFIG_DIR', get_option('prefix') / get_option('sysconfdir'))
conf.set_quoted('SHARED_STATE_DIR', get_option('prefix') / get_option('sharedstatedir') / 'alpine-qa-bot')

configure_file(output: 'config.h', configuration: conf)
# Include config.h
add_project_arguments(
  '-I@0@'.format(meson.current_build_dir()),
  language: 'c'
)

subdir('alpine-qa-bot')
subdir('data')
subdir('tests')
