project('hr.from.josipantolis.souschef', 'vala', 'c')
gnome = import('gnome')
i18n = import('i18n')

# Translation module
add_global_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()),
    language:'c',
)

# List all dependencies
dependencies = [
    dependency('gtk4'),
    dependency('granite-7'),
    dependency('sqlite3'),
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
)

test('tests', test_executable)

