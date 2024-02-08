hostsmanager_sources = [
	'HostsManager.vala',
	'MainWindow.vala',
	'Models/HostRowListModel.vala',
	'Models/HostRowModel.vala',
	'Services/ConfigService.vala',
	'Services/HostsFileService.vala',
	'Services/RegexHostRowIpv4.vala',
	'Services/RegexHostRowIpv6.vala',
	'Services/RegexHostGroupRow.vala',
	'Services/RegexCommentRow.vala',
	'Widgets/BaseActionRow.vala',
	'Widgets/CommentActionRow.vala',
	'Widgets/HostActionRow.vala',
	'Widgets/HostGroupExpanderRow.vala',
	'Widgets/HostsListBox.vala',
	'Widgets/RowEditMessageDialog.vala',
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
