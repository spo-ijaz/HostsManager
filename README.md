# HostsManager


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



# Compilation & installation

```sh
meson build --prefix=/usr
cd build
ninja
sudo ninja install
```

# Development 

Done with [Builder](https://wiki.gnome.org/Apps/Builder), so you can compile and start the application directly with the development profile.


```sh
meson build --prefix=/testbuild -Dprofile=development
cd build
ninja
sudo ninja install
```

## Todo
- [x] Put back translations.
- [ ] Be able to undo a delete (using toastoverlay )
- [ ] Handle IPv6 ?


## Update translation

```bash
meson build --prefix=/build -Dprofile=development
cd build
meson compile com.github.spo-ijaz.hostsmanager-pot
meson compile com.github.spo-ijaz.hostsmanager-update-po
```
