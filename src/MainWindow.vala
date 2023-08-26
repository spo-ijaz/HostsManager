using GLib;
using Gtk;

namespace HostsManager {

	[GtkTemplate (ui = "/com/github/spo-ijaz/hostsmanager/ui/main-window.ui")]
	public class MainWindow : ApplicationWindow {

		private const ActionEntry[] ACTION_ENTRIES = {
			{ "focus-search-bar", focus_search_bar }
		};

		[GtkChild]
		public unowned HeaderBar header_bar;
		[GtkChild]
		public unowned ToggleButton search_toggle_button;
		[GtkChild]
		public unowned SearchBar search_bar;
		[GtkChild]
		public unowned SearchEntry search_entry;
		[GtkChild]
		public unowned ColumnView hosts_column_view;
		[GtkChild]
		public unowned GLib.ListStore hosts_list_store;

		private Services.HostsFile hosts_file;
		private GLib.ListStore hosts_list_store_ref;

		construct {

			this.set_title (Services.Config.hostfile_path ());

			// Actions
    		this.add_action_entries (ACTION_ENTRIES, this);

			// Gtk 4.12 only :/ 
			//hosts_column_view.set_row_factory ();

			// Populate column view
			this.hosts_list_store_ref = new GLib.ListStore (typeof(Models.HostRow));
			this.hosts_file = new Services.HostsFile ();

			try {
				for (MatchInfo match_info = this.hosts_file.getEntries(); match_info.matches(); match_info.next()) {
					
					Models.HostRow host_row = new Models.HostRow (
						true,
						match_info.fetch_named("enabled") != "#",
						match_info.fetch_named("ipaddress"),
						match_info.fetch_named("hostname"));

					this.hosts_list_store.append (host_row);
					this.hosts_list_store_ref.append (host_row);
			 	}
			 }
			 catch (Error e)  {

				error("Regex failed: %s", e.message);
			 }
		}

		public MainWindow (App app) {
			Object (
				application: app
			);
		}

		//
		// Search bar
		//
		[GtkCallback]
		private void on_search_toggle_button_toggled () {

			this.search_bar.visible = true;
			this.search_entry.grab_focus ();
		}

		private void focus_search_bar (SimpleAction action, GLib.Variant? parameter) {

			this.on_search_toggle_button_toggled ();
		}

		[GtkCallback]
		private void signal_search_entry_search_changed_handler ( ) {

			if(search_entry.text.length == 0) {
					
				hosts_list_store.remove_all ();
				for (uint item_pos = 0; item_pos < hosts_list_store_ref.get_n_items (); item_pos++) {

					Models.HostRow host_row = hosts_list_store_ref.get_item (item_pos) as Models.HostRow;
					hosts_list_store.append (host_row);
				}
				
				return;
			}

			try {

				//  Array<uint> items_pos_to_remove = new Array<uint> ();

				Regex hosts_filter_regex = new Regex (search_entry.text);
				hosts_list_store.remove_all ();


				for (uint item_pos = 0; item_pos < hosts_list_store_ref.get_n_items (); item_pos++) { 

					Models.HostRow host_row = hosts_list_store_ref.get_item (item_pos) as Models.HostRow;
					if(hosts_filter_regex.match (host_row.hostname) ) {

						hosts_list_store.append (host_row);
					}
				}
			}
			catch (Error e) {

				error("Regex failed: %s", e.message);
			}
		}

		//
		// Columns's widgets initial render
		//
		[GtkCallback]
		private void signal_enabled_setup_handler (SignalListItemFactory factory, ListItem list_item) {

			CheckButton check_button = new CheckButton();
			check_button.active = false;
			check_button.set_halign (Align.CENTER);

			list_item.child = check_button;
		}

		[GtkCallback]
		private void signal_enabled_bind_handler (SignalListItemFactory factory, ListItem list_item) {

			CheckButton check_button = list_item.child as CheckButton;
			Models.HostRow? host_row = list_item.item as Models.HostRow;

			if (host_row != null) {

            	check_button.active = host_row.enabled;
 				check_button.toggled.connect (() => {

					Services.HostsRegex regex = new Services.HostsRegex(host_row.ip_address, host_row.hostname);
      			this.hosts_file.setEnabled(regex, !check_button.active);
      			host_row.enabled = check_button.active;
				});
        }
		}

		[GtkCallback]
		private void signal_enabled_teardown_handler (SignalListItemFactory factory, ListItem list_item) {
			
			//  info ("signal_enabled_teardown_handler");
		}

		[GtkCallback]
		private void signal_enabled_unbind_handler (SignalListItemFactory factory, ListItem list_item) {
			
			list_item.child.destroy ();
		}


		[GtkCallback]
		private void signal_ip_address_setup_handler (SignalListItemFactory factory, ListItem list_item) {

			list_item.child = new EditableLabel ("");
		}

		[GtkCallback]
		private void signal_ip_address_bind_handler (SignalListItemFactory factory, ListItem list_item) {

			EditableLabel editable_label = list_item.child as EditableLabel;
			Models.HostRow? host_row = list_item.item as Models.HostRow;

			if (host_row != null) {
            editable_label.set_text (host_row.ip_address);
 				editable_label.changed.connect (() => {

					try {

						Services.HostsRegex regex = new Services.HostsRegex(host_row.ip_address, host_row.hostname);
						this.hosts_file.setIpAddress(regex, editable_label.text);
						host_row.ip_address = editable_label.text;
					}
					catch (InvalidArgument err) {

						debug("InvalidArgument: %s", err.message);
					}

				});
        }
		}

		[GtkCallback]
		private void signal_ip_address_teardown_handler (SignalListItemFactory factory, ListItem list_item) {
			
			//  info ("signal_enabled_teardown_handler");
		}

		[GtkCallback]
		private void signal_ip_address_unbind_handler (SignalListItemFactory factory, ListItem list_item) {
			
			list_item.child.destroy ();
		}




		[GtkCallback]
		private void signal_host_setup_handler (SignalListItemFactory factory, ListItem list_item) {

			list_item.child = new EditableLabel ("");
		}

		[GtkCallback]
		private void signal_host_bind_handler (SignalListItemFactory factory, ListItem list_item) {

			EditableLabel editable_label = list_item.child as EditableLabel;
			Models.HostRow? host_row = list_item.item as Models.HostRow;

			if (host_row != null) {
            editable_label.set_text (host_row.hostname);
 				editable_label.changed.connect (() => {

					try {

						Services.HostsRegex regex = new Services.HostsRegex(host_row.ip_address, host_row.hostname);
						this.hosts_file.setHostname (regex, editable_label.text);
						host_row.hostname = editable_label.text;
					}
					catch (InvalidArgument err) {

						debug("InvalidArgument: %s", err.message);
					}
				});
        }
		}

		[GtkCallback]
		private void signal_host_teardown_handler (SignalListItemFactory factory, ListItem list_item) {
			
			//  info ("signal_enabled_teardown_handler");
		}

		[GtkCallback]
		private void signal_host_unbind_handler (SignalListItemFactory factory, ListItem list_item) {

			list_item.child.destroy ();
		}
	}
}




