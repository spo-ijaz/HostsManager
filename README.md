# HostsManager App


Managing your `/etc/hosts` file.

<p align="center">
  <img alt="Screenshot" src="./data/screenshots/main.png">
</p>


# Compilation & installation

```sh
meson build --prefix=/usr
cd build
ninja
sudo ninja install
```

# Development 

Done with [Builder](https://wiki.gnome.org/Apps/Builder), so you can compile and start the application directly with the development profile.
