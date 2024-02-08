### 2024-02-08 - Release v4.2.1
* Fix invalid ui ressource location file.

### 2024-02-08 - Release v4.2.0
* Completely new user interface, using Gtk.Listbox, with less bugs.
* It's now possible to manage group of hosts.

### 2023-09-07 - Release v4.1.0
* New entries deletion handler fixed. (we can remove, undo one or more entries)
* Update / deleted issues when filter is activated are fixed.
* Change the way the "undo" functionality works. (check README.md)

### 2023-09-02 - Release v4.0.1
* Empty deleted hosts list when hosts file changed on the system, or when we reload from the backup file.

### 2023-09-02 - Release v4.0.0
* Better deletion handler: when entries are deleted, they come back to the same place where they were instead of being appended to the end of the file.
* Undo delete shortcut now undo only one entry at once...
* ... whereas "undo" button from the toast will restore all deleted entries at once.
* 
### 2023-09-01 - Release v3.0.10
* Hot reload: if the hosts file has changed, entries are reloaded.

### 2023-09-01 - Release v3.0.9
* Fix issue when newly added host was added on the same last line of the previously last host of the file
* Add another missing FR translation.

### 2023-09-01 - Release v3.0.8
* Restore missing FR translations.
* Code clean-up.

### 2023-08-31 - Release v3.0.7
* We can now selected multiple entries to delete.
* And <Ctrl>+z shortcuts will undo all the deleted entries at once.
* Re-use Gtk.Label for IP address & hostname edit, but validate, update file only when enter is pressed.
* Fix Gtk.SearchBar not correctly toggled, with shortcuts or button.

### 2023-08-30 - Release v3.0.6
* Move add entry button to the right.
* Undo deleted entries, with `<Ctrl> + Z` shortcut.

