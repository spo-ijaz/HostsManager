# The resources (NOTE: needed by e.g. src/)
resources = gnome.compile_resources(
	meson.project_name(),
	meson.project_name() + '.gresource.xml',
	c_name: 'resources',
)

#Install icons
icon_sizes = ['16', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i, meson.project_name() + '.svg'),
        join_paths('icons', i, meson.project_name() + '.png'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
endforeach

# Translate and install our .desktop file
i18n.merge_file(
    input: meson.project_name() + '.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.project_source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

# Translate and install our .appdata file
i18n.merge_file(
    input: meson.project_name() + '.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.project_source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

# Translate and install polkit action file
i18n.merge_file(
    input: meson.project_name() + '.pkexec.policy.in',
    output: meson.project_name() + '.pkexec.policy',
    po_dir: join_paths(meson.project_source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'polkit-1/actions'),
    data_dirs: join_paths(meson.project_source_root(), 'gettext')
)
