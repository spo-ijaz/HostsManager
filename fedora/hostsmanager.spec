%global gtk4_version 4.10


Name:     hosts-manager
Version:  3.0.4
Release:  %autorelease
Summary:  Manage your `/etc/hosts` file
License:  GPL-3.0-or-later
URL:      https://github.com/spo-ijaz/HostsManager
Source:   https://github.com/spo-ijaz/HostsManager.git
TYPE:     SCM
#Source:   hosts-manager-3.0.4.tar.gz

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
%autosetup -c

%build
export VALAFLAGS="-g"
%meson
%meson_build

%install
# %find_lang %{name}
%meson_install

%check
	
appstream-util validate-relax --nonet %{buildroot}/%{_datadir}/metainfo/com.github.spo-ijaz.hostsmanager.appdata.xml
desktop-file-validate %{buildroot}/%{_datadir}/applications/com.github.spo-ijaz.hostsmanager.desktop

%files
# %files -f %{name}.lang
%doc AUTHORS README.md
%license COPYING
%{_bindir}/com.github.spo-ijaz.hostsmanager
%{_bindir}/com.github.spo-ijaz.hostsmanager.app
%{_datadir}/applications/com.github.spo-ijaz.hostsmanager.desktop
%{_datadir}/metainfo/com.github.spo-ijaz.hostsmanager.appdata.xml
%{_datadir}/polkit-1/actions/com.github.spo-ijaz.hostsmanager.pkexec.policy
# %{_datadir}/locale/*/LC_MESSAGES/com.github.spo-ijaz.hostsmanager.mo
%{_datadir}/icons/hicolor/*/apps/com.github.spo-ijaz.hostsmanager*.png
%{_datadir}/icons/hicolor/*/apps/com.github.spo-ijaz.hostsmanager*.svg

%changelog
%autochangelog