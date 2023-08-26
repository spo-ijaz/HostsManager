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
		public unowned StringFilter hosts_string_filter;
		[GtkChild]
		public unowned GLib.ListStore hosts_list_store;

		private Services.HostsFile hosts_file;

		construct {

			this.set_title (Services.Config.hostfile_path ());

			//constant_expression.for_value ("hostname");
			//hosts_string_filter.set_expression (constant_expression);

			// Actions
    		this.add_action_entries (ACTION_ENTRIES, this);

			// Populate column view
			this.hosts_file = new Services.HostsFile ();

			try {
				for (MatchInfo match_info = this.hosts_file.getEntries(); match_info.matches(); match_info.next()) {

					this.hosts_list_store.append (
						new Models.HostRow (
							true,
							match_info.fetch_named("enabled") != "#",
							match_info.fetch_named("ipaddress"),
							match_info.fetch_named("hostname")
					));
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

			info (hosts_string_filter.get_expression ().get_value_type ().to_string ());


			//hosts_string_filter.set_expression (object_expression);
			hosts_string_filter.set_search (search_entry.text);
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

			if (null != host_row) {
            check_button.active = host_row.enabled;
 				check_button.toggled.connect (() => {

					Services.HostsRegex regex = new Services.HostsRegex(host_row.ip_address, host_row.hostname);
      			this.hosts_file.setEnabled(regex, !check_button.active);
      			host_row.enabled = check_button.active;
				});
        }
		}

		[GtkCallback]
		private void signal_ip_address_setup_handler (SignalListItemFactory factory, ListItem list_item) {

			list_item.child = new EditableLabel ("");
		}

		[GtkCallback]
		private void signal_ip_address_bind_handler (SignalListItemFactory factory, ListItem list_item) {

			EditableLabel editable_label = list_item.child as EditableLabel;
			Models.HostRow? host_row = list_item.item as Models.HostRow;

			if (null != host_row) {
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
		private void signal_host_setup_handler (SignalListItemFactory factory, ListItem list_item) {

			list_item.child = new EditableLabel ("");
		}

		[GtkCallback]
		private void signal_host_bind_handler (SignalListItemFactory factory, ListItem list_item) {

			EditableLabel editable_label = list_item.child as EditableLabel;
			Models.HostRow? host_row = list_item.item as Models.HostRow;

			if (null != host_row) {
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
	}
}




