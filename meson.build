# Project name and programming language
project(
	'com.github.spo-ijaz.hostsmanager',
	['vala', 'c'],
	version: '1.0.0',
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
config_h_dir = include_directories('.')

# Dependencies
gtk4_dep = dependency('gtk4', version: '>= 4.10')

# Configuration
conf = configuration_data()
conf.set_quoted('APP_ID', hostsmanager_app_id)
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('G_LOG_DOMAIN', meson.project_name())
conf.set_quoted('PACKAGE_NAME', meson.project_name())
conf.set_quoted('PACKAGE_STRING', meson.project_name())
conf.set_quoted('PACKAGE_VERSION', meson.project_version())
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('PROFILE', get_option('profile'))
configure_file(output: 'config.h', configuration: conf)

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
