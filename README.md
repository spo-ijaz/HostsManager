# HostsManager App


Managing your `/etc/hosts` file.

<p align="center">
  <img alt="Screenshot" src="./data/screenshots/main.png">
</p>


# Features
* Adding / Deleting a row. (`Delete` key, to remove a row)
* Checks on IP address and hostname.
* Search through hostnames.
* Shorcuts.
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

## Todo
- [ ] Put back translations.
- [ ] Be able to undo a delete (using toastoverlay )
