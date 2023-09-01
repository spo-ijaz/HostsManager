# HostsManager

![Contributors](https://img.shields.io/github/contributors/spo-ijaz/HostsManager)
![Stars](https://img.shields.io/github/stars/spo-ijaz/HostsManager)
![License](https://img.shields.io/github/license/spo-ijaz/HostsManager)
![Issues](https://img.shields.io/github/issues/spo-ijaz/HostsManager)
[![HostsManager](https://img.shields.io/badge/copr-HostsManager-51A2DA?label=COPR&logo=fedora&logoColor=white)](https://copr.fedorainfracloud.org/coprs/spo-ijaz/HostsManager/)


<br/>
<p align="center">Manage your `/etc/hosts` file with this simple GTK application for GNU/Linux.</p>

<p align="center">
  <img width="500" alt="Screenshot" src="./data/screenshots/main.png">
</p>

# Features

* Adding entry.
* Delete multiple entries at once.
* Restore deleted entries if you made mistake.
* Checks on IP address and hostname.
* Search through hostnames.
* Shortcuts.
* Restore from an automatic backup of your `/etc/hosts` file, made each time the application is started.

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

## Todo

- [ ] ~~Ask root password only when changes are made on the file.~~
	- Not possible easily, or we should spawn a `pkexec` process each time we want to modify the file, and use shell commands instead of Glib ones.
 	- Or maybe there's another mechanism...
- [ ] Be able to re-order on the fly the rows.
- [ ] Handle IPv6 ?
- [ ] Hot reload, when file saved locally.

## Update translations

```bash
meson build --prefix=/build -Dprofile=development
cd build
meson compile com.github.spo-ijaz.hostsmanager-pot
meson compile com.github.spo-ijaz.hostsmanager-update-po
```

