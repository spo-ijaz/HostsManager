# Project name and programming language
project(
	'com.github.spo-ijaz.hostsmanager',
	['vala', 'c'],
	version: '3.0.4',
	license: 'MIT License',
	meson_version: '>= 1.0.0',
)

gnome = import('gnome')
i18n = import('i18n')

# Add our custom VAPI dir
add_project_arguments(
  ['--vapidir', meson.project_source_root() / 'vapi'],
  language: 'vala'
)

# Application ID
if get_option('profile') == 'development'
	hostsmanager_app_id = 'com.github.spo-ijaz.hostsmanager.Devel'
else
	hostsmanager_app_id = 'com.github.spo-ijaz.hostsmanager'
endif

# Common variables
valac = meson.get_compiler('vala')
app_config_h_dir = include_directories('.')

# Dependencies
adw_dep = dependency('libadwaita-1', version: '>= 1.3')
gtk4_dep = dependency('gtk4', version: '>= 4.10')

# Configuration
app_conf = configuration_data()
app_conf.set_quoted('APP_ID', hostsmanager_app_id)
app_conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
app_conf.set_quoted('G_LOG_DOMAIN', meson.project_name())
app_conf.set_quoted('PACKAGE_NAME', meson.project_name())
app_conf.set_quoted('PACKAGE_STRING', meson.project_name())
app_conf.set_quoted('PACKAGE_VERSION', meson.project_version())
app_conf.set_quoted('VERSION', meson.project_version())
app_conf.set_quoted('PROFILE', get_option('profile'))
configure_file(output: 'app-config.h', configuration: app_conf)

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')


subdir('data')
subdir('po')
subdir('src')

gnome.post_install(
  gtk_update_icon_cache: true,
  # glib_compile_schemas: true,
  update_desktop_database: true,
)
