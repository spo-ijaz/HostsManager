using GLib;
using Gtk;

namespace HostsManager {

	[GtkTemplate (ui = "/com/github/spo-ijaz/hostsmanager/ui/main-window.ui")]
	public class MainWindow : ApplicationWindow {

		private const ActionEntry[] ACTION_ENTRIES = {
			{ "focus-search-bar", focus_search_bar },
			{ "host-row-add", host_row_add },
			{ "host-row-delete", host_row_delete },
			{ "restore-fron-backup", restore_from_backup },
			{ "app-quit", app_quit },
		};

		[GtkChild]
		public unowned ShortcutController shortcut_controller;
		[GtkChild]
		public unowned HeaderBar header_bar;
		[GtkChild]
		public unowned PopoverMenu popover_menu;
		[GtkChild]
		public unowned ToggleButton search_toggle_button;
		[GtkChild]
		public unowned SearchBar search_bar;
		[GtkChild]
		public unowned SearchEntry search_entry;
		[GtkChild]
		public unowned ScrolledWindow hosts_scrolled_window;
		[GtkChild]
		public unowned ColumnView hosts_column_view;
		[GtkChild]
		public unowned SingleSelection hosts_single_selection;
		[GtkChild]
		public unowned FilterListModel hosts_filter_list_model;
		[GtkChild]
		public unowned GLib.ListStore hosts_list_store;
		[GtkChild]
		public unowned StringFilter hosts_string_filter;

		private Services.HostsFile hosts_file_service;

		construct {

			this.set_title (Services.Config.hostfile_path ());

			// Action, menu, shortcuts...
			this.add_action_entries (ACTION_ENTRIES, this);

			Menu menu = new Menu ();
			menu.append ("search by hostname", "win.focus-search-bar");
			menu.append ("restore from backup file", "win.restore-fron-backup");
			menu.append ("help", "win.show-help-overlay");
			menu.append ("about", null);
			menu.append ("quit", "win.app-quit");

			this.popover_menu.set_menu_model (menu);
			this.popover_menu.activate ();

			this.add_controller (shortcut_controller);

			// Help overlay
			Builder help_builder = new Builder.from_resource ("/com/github/spo-ijaz/hostsmanager/ui/app-shortcuts-window.ui");
			this.set_help_overlay (help_builder.get_object ("app-shortcuts-window") as ShortcutsWindow);

			// Filter for LibStore.
			PropertyExpression property_expression = new PropertyExpression (typeof (Models.HostRow), null, "hostname");
			this.hosts_string_filter.set_expression (property_expression);

			// Intiailize the list store
			this.hosts_file_service = new Services.HostsFile ();
			this.append_hots_rows_to_list_store ();
		}

		public MainWindow (App app) {
			Object (
			        application: app
			);
		}

		private void app_quit () {

			this.application.quit ();
		}

		//
		// Store
		//
		public void append_hots_rows_to_list_store () {

			try {
				for (MatchInfo match_info = this.hosts_file_service.get_entries (); match_info.matches (); match_info.next ()) {

					this.hosts_list_store.append (new Models.HostRow (
					                                                  true,
					                                                  match_info.fetch_named ("enabled") != "#",
					                                                  match_info.fetch_named ("ipaddress"),
					                                                  match_info.fetch_named ("hostname")));
				}
			} catch (Error e) {

				error ("Regex failed: %s", e.message);
			}
		}

		//
		// Search bar
		//
		[GtkCallback]
		private void on_search_toggle_button_toggled () {

			this.search_bar.visible = !this.search_bar.visible;
			this.search_entry.grab_focus ();
		}

		private void focus_search_bar (SimpleAction action, GLib.Variant? parameter) {

			this.on_search_toggle_button_toggled ();
		}

		[GtkCallback]
		private void signal_search_entry_search_changed_handler () {

			this.hosts_string_filter.set_search (search_entry.text);
		}

		//
		// Host row creation / deletion / restoration
		//
		private void host_row_add () {

			this.hosts_list_store.append (new Models.HostRow (
			                                                  true,
			                                                  true,
			                                                  "127.0.0.1",
			                                                  "new.localhost"));

			try {

				this.hosts_file_service.add ("127.0.0.1", "new.localhost");
			} catch (InvalidArgument err) {

				debug ("InvalidArgument: %s", err.message);
			}

			// We wait a little the time for the new row widgets to be displayed and
			// so hosts_scrolled_window.kvadjustment is updated accordingly.
			Timeout.add (50, () => {

				Adjustment adjustment = this.hosts_scrolled_window.vadjustment;
				adjustment.set_value (adjustment.get_upper ());
				return true;
			});
		}

		private void host_row_delete () {

			Models.HostRow host_row = hosts_single_selection.selected_item as Models.HostRow;
			if (host_row == null) {
				return;
			}

			debug ("Deleting %s - %s", host_row.ip_address, host_row.hostname);
			Services.HostsRegex modRegex = new Services.HostsRegex (host_row.ip_address, host_row.hostname);
			this.hosts_file_service.remove (modRegex);

			this.hosts_list_store.remove (hosts_single_selection.get_selected ());
		}

		private void restore_from_backup () {

			hosts_list_store.remove_all ();
			this.hosts_file_service.restore_from_backup ();
			this.append_hots_rows_to_list_store ();
		}

		//
		// Columns's widgets initial render
		//
		[GtkCallback]
		private void signal_enabled_setup_handler (SignalListItemFactory factory, ListItem list_item) {

			CheckButton check_button = new CheckButton ();
			check_button.active = false;
			check_button.set_halign (Align.CENTER);

			list_item.set_child (check_button);
		}

		[GtkCallback]
		private void signal_enabled_bind_handler (SignalListItemFactory factory, ListItem list_item) {

			if (list_item.child == null) {

				this.signal_enabled_setup_handler (factory, list_item);
			}

			CheckButton? check_button = list_item.get_child () as CheckButton;
			Models.HostRow? host_row = list_item.item as Models.HostRow;


			if (check_button != null && host_row != null) {

				check_button.active = host_row.enabled;
				check_button.toggled.connect (() => {

					Services.HostsRegex regex = new Services.HostsRegex (host_row.ip_address, host_row.hostname);
					this.hosts_file_service.set_enabled (regex, !check_button.active);
					host_row.enabled = check_button.active;
				});
			}
		}

		[GtkCallback]
		private void signal_enabled_unbind_handler (SignalListItemFactory factory, ListItem list_item) {

			if (list_item.child != null) {

				list_item.child = null;
			}
		}

		[GtkCallback]
		private void signal_ip_address_setup_handler (SignalListItemFactory factory, ListItem list_item) {

			list_item.set_child (new EditableLabel (""));
		}

		[GtkCallback]
		private void signal_ip_address_bind_handler (SignalListItemFactory factory, ListItem list_item) {

			if (list_item.child == null) {

				this.signal_ip_address_setup_handler (factory, list_item);
			}

			EditableLabel? editable_label = list_item.child as EditableLabel;
			Models.HostRow? host_row = list_item.item as Models.HostRow;

			if (editable_label != null && host_row != null) {

				editable_label.set_text (host_row.ip_address);
				editable_label.changed.connect (() => {

					string previous_ip_address = host_row.ip_address;
					try {

						Services.HostsRegex regex = new Services.HostsRegex (host_row.ip_address, host_row.hostname);
						this.hosts_file_service.set_ip_address (regex, editable_label.text);
						host_row.ip_address = editable_label.text;
					} catch (InvalidArgument err) {

						debug ("InvalidArgument: %s", err.message);
						host_row.ip_address = previous_ip_address;
					}
				});
			}
		}

		[GtkCallback]
		private void signal_ip_address_unbind_handler (SignalListItemFactory factory, ListItem list_item) {

			if (list_item.item != null) {

				list_item.set_child (null);
			}
		}

		[GtkCallback]
		private void signal_host_setup_handler (SignalListItemFactory factory, ListItem list_item) {

			list_item.set_child (new EditableLabel (""));
		}

		[GtkCallback]
		private void signal_host_bind_handler (SignalListItemFactory factory, ListItem list_item) {

			if (list_item.child == null) {

				this.signal_host_setup_handler (factory, list_item);
			}

			EditableLabel? editable_label = list_item.child as EditableLabel;
			Models.HostRow? host_row = list_item.item as Models.HostRow;

			if (editable_label != null && host_row != null) {

				editable_label.set_text (host_row.hostname);
				editable_label.changed.connect (() => {

					string previous_hostname = host_row.hostname;
					try {

						Services.HostsRegex regex = new Services.HostsRegex (host_row.ip_address, host_row.hostname);
						this.hosts_file_service.set_hostname (regex, editable_label.text);
						host_row.hostname = editable_label.text;
					} catch (InvalidArgument err) {

						debug ("InvalidArgument: %s", err.message);
						host_row.hostname = previous_hostname;
					}
				});
			}
		}

		[GtkCallback]
		private void signal_host_unbind_handler (SignalListItemFactory factory, ListItem list_item) {

			if (list_item.item != null) {

				list_item.set_child (null);
			}
		}
	}
}