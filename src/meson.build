hostsmanager_sources = [
	'HostsManager.vala',
	'MainWindow.vala',
	'Models/HostListModel.vala',
	'Models/HostRow.vala',
	'Services/Config.vala',
	'Services/HostsFile.vala',
	'Services/RegexHostRow.vala',
	'Services/RegexHostGroupRow.vala',
	'Services/RegexCommentRow.vala',
	'Widgets/CommentActionRow.vala',
	'Widgets/CommentEditMessageDialog.vala',
	'Widgets/HostActionRow.vala',
	'Widgets/EditableCell.vala',
	'Widgets/HostGroupExpanderRow.vala',
	'Widgets/HostsListBox.vala',
	resources
]

hostsmanager_vala_args = [
  '--pkg', 'app-config',
]

executable(
	 meson.project_name(),
	 'HostsManager-pkexec.vala',
	 dependencies: [adw_dep, gtk4_dep],
	 install: true
)

executable(
	meson.project_name()+ '.app',
	hostsmanager_sources,
	include_directories: app_config_h_dir,
	vala_args: hostsmanager_vala_args,
	dependencies: [adw_dep, gtk4_dep],
	install: true,
)
