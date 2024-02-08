%global gtk4_version 4.12

Name:     hosts-manager
Version:  4.2.0
Release:  %autorelease
Summary:  Manage your `/etc/hosts` file
License:  GPL-3.0-or-later
URL:      https://gitlab.gnome.org/spo-ijaz/HostsManager
Source0:  https://gitlab.gnome.org/spo-ijaz/HostsManager/-/archive/%{version}/HostsManager-%{version}.tar.gz

BuildRequires:  libappstream-glib
BuildRequires:  desktop-file-utils
BuildRequires:  gcc
BuildRequires:  gettext
BuildRequires:  meson
BuildRequires:  vala
BuildRequires:  pkgconfig(gtk4) >= %{gtk4_version}
BuildRequires:  pkgconfig(libadwaita-1)

Requires:       gtk4%{?_isa} >= %{gtk4_version}
Requires:       hicolor-icon-theme

%description
Easily add, remove, update entries in your /etc/hosts files.

%prep
%autosetup -n HostsManager-%{version}

%build
export VALAFLAGS="-g"
%meson
%meson_build

%install
%meson_install

%check

appstream-util validate-relax --nonet %{buildroot}/%{_datadir}/metainfo/org.gnome.gitlab.spo-ijaz.hostsmanager.appdata.xml.appdata.xml
desktop-file-validate %{buildroot}/%{_datadir}/applications/org.gnome.gitlab.spo-ijaz.hostsmanager.appdata.xml.desktop

%files
%doc AUTHORS README.md
%license COPYING
%{_bindir}/org.gnome.gitlab.spo-ijaz.hostsmanager.appdata.xml
%{_bindir}/org.gnome.gitlab.spo-ijaz.hostsmanager.appdata.xml.app
%{_datadir}/applications/org.gnome.gitlab.spo-ijaz.hostsmanager.appdata.xml.desktop
%{_datadir}/metainfo/org.gnome.gitlab.spo-ijaz.hostsmanager.appdata.xml.appdata.xml
%{_datadir}/polkit-1/actions/org.gnome.gitlab.spo-ijaz.hostsmanager.appdata.xml.pkexec.policy
%{_datadir}/locale/*/LC_MESSAGES/org.gnome.gitlab.spo-ijaz.hostsmanager.appdata.xml.mo
%{_datadir}/icons/hicolor/*/apps/org.gnome.gitlab.spo-ijaz.hostsmanager.appdata.xml*.png
%{_datadir}/icons/hicolor/*/apps/org.gnome.gitlab.spo-ijaz.hostsmanager.appdata.xml*.svg

%changelog
%autochangelog
