# HostsManager

<!-- ![Contributors](https://img.shields.io/gitlab/contributors/spo-ijaz/HostsManager) -->
<!-- ![Stars](https://img.shields.io/gitlab/stars/spo-ijaz/HostsManager) -->
<!-- ![License](https://img.shields.io/gitlab/license/spo-ijaz/HostsManager) -->
<!-- ![Issues](https://img.shields.io/gitlab/issues/spo-ijaz/HostsManager) -->
[![HostsManager](https://img.shields.io/badge/copr-HostsManager-51A2DA?label=COPR&logo=fedora&logoColor=white)](https://copr.fedorainfracloud.org/coprs/spo-ijaz/HostsManager/)


<br/>
<p align="center">Manage your `/etc/hosts` file with this simple GTK application for GNU/Linux.</p>

<p align="center">
  <img width="500" alt="Screenshot" src="./data/screenshots/main.png">
</p>

# Features

* Adding host row, comment row.
* Create group of hosts.
* Drag & drop.
* Checks on IP address (v4 or v6).
* Search through hostnames.
* Shortcuts.
* Restore from an automatic backup of your `/etc/hosts` file, made each time the application is started.
* Hot-reload of the entries if `/etc/hosts` file has changed.

# Package

| Distribution           | Status                                                                                                                                                                                                                        |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Fedora (38,39,rawhide) | [![Copr build status](https://copr.fedorainfracloud.org/coprs/spo-ijaz/HostsManager/package/hosts-manager/status_image/last_build.png)](https://copr.fedorainfracloud.org/coprs/spo-ijaz/HostsManager/package/hosts-manager/) 
|

# Compilation & installation

```sh
meson build --prefix=/usr
cd build
ninja
sudo ninja install
```

# Development

Done with [Builder](https://wiki.gnome.org/Apps/Builder), so you can compile and start the application directly with the development profile.

## Update translations

```bash
meson build --prefix=/build -Dprofile=development
cd build
meson compile org.gnome.gitlab.spo-ijaz.hostsmanager-pot
meson compile org.gnome.gitlab.spo-ijaz.hostsmanager-update-po
```

And use [poedit](https://poedit.net/) on `/po/xx.po` files to add translations.