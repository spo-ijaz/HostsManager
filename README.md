# HostsManager

![Contributors](https://img.shields.io/github/contributors/spo-ijaz/HostsManager)
![Stars](https://img.shields.io/github/stars/spo-ijaz/HostsManager)
![License](https://img.shields.io/github/license/spo-ijaz/HostsManager)
![Issues](https://img.shields.io/github/issues/spo-ijaz/HostsManager)
[![HostsManager](https://img.shields.io/badge/copr-HostsManager-51A2DA?label=COPR&logo=fedora&logoColor=white)](https://copr.fedorainfracloud.org/coprs/spo-ijaz/HostsManager/)


<br/>
<p align="center">Manage your `/etc/hosts` file.</p>

<p align="center">
  <img width="500" alt="Screenshot" src="./data/screenshots/main.png">
</p>

# Features

* Adding / Deleting a row.
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

- [x] Put back translations.
- [ ] Be able to undo a delete (using toastoverlay )
- [ ] Add in systray.
- [ ] Handle IPv6 ?

## Update translations

```bash
meson build --prefix=/build -Dprofile=development
cd build
meson compile com.github.spo-ijaz.hostsmanager-pot
meson compile com.github.spo-ijaz.hostsmanager-update-po
```
