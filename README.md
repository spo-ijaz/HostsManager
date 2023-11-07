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
* Restore deleted entries if you made mistake :
  * If entries are removed one by one, shortcut `<Ctrl>+z` (or `undo` button) will undo the deletions until there are no more entries to restore.
  * If more than one entries are removed at once, shortcut `<Ctrl>+z` (or `undo` button), will restore all deleted entries at once. ( and deleted history is emptied when multiple entries are deleted at once.)
* Checks on IP address and hostname.
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

## Todo

- [ ] ~~Ask root password only when changes are made on the file.~~
	- Not possible easily, or we should spawn a `pkexec` process each time we want to modify the file, and use shell commands instead of Glib ones.
 	- Or maybe there's another mechanism...
- [x] Be able to re-order on the fly the rows. (Done on branch 4.1.1)
- [ ] Handle IPv6 ?

## Update translations

```bash
meson build --prefix=/build -Dprofile=development
cd build
meson compile com.github.spo-ijaz.hostsmanager-pot
meson compile com.github.spo-ijaz.hostsmanager-update-po
```

