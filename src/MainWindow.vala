using GLib;
using Gtk;

namespace HostsManager {

	[GtkTemplate (ui = "/com/github/spo-ijaz/hostsmanager/ui/main-window.ui")]
	public class MainWindow : Window {

		[GtkChild]
		public unowned HeaderBar header_bar;
		[GtkChild]
		public unowned ToggleButton search_toggle_button;
		[GtkChild]
		public unowned Box box;
		[GtkChild]
		public unowned SearchBar search_bar;
		[GtkChild]
		public unowned SearchEntry search_entry;
		[GtkChild]
		public unowned ScrolledWindow hosts_scrolled_window;
		[GtkChild]
		public unowned ColumnView hosts_column_view;
		[GtkChild]
		public unowned ColumnViewColumn enabled_column_view_column;
		[GtkChild]
		public unowned ColumnViewColumn host_column_view_column;
		[GtkChild]
		public unowned ColumnViewColumn ipadress_column_view_column;
		[GtkChild]
		public unowned NoSelection hosts_no_selection;
		[GtkChild]
		public unowned FilterListModel hosts_filter_list_model;
		[GtkChild]
		public unowned GLib.ListStore host_list_store;

		private Services.HostsFile hosts_file;

		construct {

			hosts_file = new Services.HostsFile ();

			try {
				for (MatchInfo match_info = hosts_file.getEntries(); match_info.matches(); match_info.next()) {

					host_list_store.append (
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
		// Header bar
		//
		[GtkCallback]
		private void on_search_toggle_button_toggled () {

			info("on_search_toggle_button_toggled");
		}


		//
		// Columns's widgets initial render
		//
		[GtkCallback]
		private void signal_enabled_setup_handler (SignalListItemFactory factory, ListItem list_item)
		{
			CheckButton check_button = new CheckButton();
			check_button.active = false;

			list_item.child = check_button;
		}

		[GtkCallback]
		private void signal_enabled_bind_handler (SignalListItemFactory factory, ListItem list_item)
		{
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
		private void signal_ip_address_setup_handler (SignalListItemFactory factory, ListItem list_item)
		{
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
		private void signal_host_setup_handler (SignalListItemFactory factory, ListItem list_item)
		{
			list_item.child = new EditableLabel ("");
		}

		[GtkCallback]
		private void signal_host_bind_handler (SignalListItemFactory factory, ListItem list_item)
		{
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
