# Compile static resources
gresources = gnome.compile_resources(
    'gresource',
    'gresource.xml',
    source_dir: 'data',
)

# Translate and install .desktop file
i18n.merge_file(
    input: 'souschef.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.source_root() / 'po' / 'extra',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications',
)

# Install .service file
service_config = configuration_data()
service_config.set('EXEC_NAME', get_option('prefix') / get_option('bindir') / meson.project_name())

configure_file(
    input: 'souschef.service.in',
    output: meson.project_name() + '.service',
    configuration: service_config,
    install: true,
    install_dir: get_option('datadir') / 'dbus-1' / 'services',
)

# Translate and install appdata file
i18n.merge_file (
    input: 'souschef.metainfo.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: meson.source_root() / 'po' / 'extra',
    install: true,
    install_dir: get_option('datadir') / 'metainfo',
)

# Install GSchema
install_data(
    'gschema.xml',
    rename: meson.project_name() + '.gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas',
)

# Install icons
icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        'icons' / i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps',
        rename: meson.project_name() + '.svg',
    )
    install_data(
        'icons' / i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i + '@2' / 'apps',
        rename: meson.project_name() + '.svg',
    )
endforeach
