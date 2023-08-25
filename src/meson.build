hostsmanager_sources = [
	'Filters/HostRowFilter.vala',
	'HostsManager.vala',
	'MainWindow.vala',
	'Models/HostRow.vala',
	resources
]

hostsmanager_vala_args = [
  '--pkg', 'config',
]

executable(
	 meson.project_name(),
	 'HostsManager-pkexec.vala',
	 dependencies: gtk4_dep,
	 install: true
)

executable(
	meson.project_name()+ '.app',
	hostsmanager_sources,
	include_directories: config_h_dir,
	vala_args: hostsmanager_vala_args,
	dependencies: gtk4_dep,
	install: true,
)
