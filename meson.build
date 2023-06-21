project('hr.from.josipantolis.souschef', 'vala', 'c')
gnome = import('gnome')
i18n = import('i18n')

# Translation module
add_global_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()),
    language:'c',
)

# Add 3rd party vapi bindings
add_project_arguments([
    '--vapidir',
    join_paths(meson.current_source_dir(), 'vapi', 'libcmark-vapi')],
    language: 'vala'
)

# List all dependencies
dependencies = [
    dependency('gtk4'),
    dependency('granite-7'),
    dependency('sqlite3'),
    dependency('libcmark'),
]

subdir('data')
subdir('po')
subdir('src')
subdir('test')

# Defining executable
executable(
    meson.project_name(),
    sources, # from src/meson.build
    gresources, # from data/meson.build
    dependencies: dependencies,
    install: true,
    link_args : '-lm',
)

gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true,
)

# Defning tests executable
test_executable = executable(
    meson.project_name () + '-tests',
    common_sources + test_sources,
    dependencies: dependencies,
    link_args : '-lm',
)

test('tests', test_executable)

