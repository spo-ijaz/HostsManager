using GLib;
using Gtk;

namespace HostsManager {

	[GtkTemplate (ui = "/com/github/gyan000/hostsmanager/ui/main-window.ui")]
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

		construct {

			host_list_store.append (new HostRow(false, "test", "test"));
			host_list_store.append (new HostRow(true, "test2", "test2"));
			host_list_store.append (new HostRow(false, "test3", "test3"));

			this.debug ();
		}

		public MainWindow (App app) {
			Object (
				application: app
			);
		}

		private void debug () {

			info ("Enabled column title                : %s", this.enabled_column_view_column.get_title ());
			// info ("Enabled column UI resource file     : %s",(this.enabled_column_view_column.get_factory () as Gtk.BuilderListItemFactory).get_resource () );

			info ("hosts_no_selection.get_n_items      : %u", this.hosts_no_selection.get_n_items () );
			info ("host_list_store.n_items             : %u", this.host_list_store.n_items );
		}

		//
		// Header bar
		//
		[GtkCallback]
		private void on_search_toggle_button_toggled () {


			info("on_search_toggle_button_toggled");
		}


		//
		// Columns
		//
		[GtkCallback]
		private void signal_enabled_setup_handler(SignalListItemFactory factory, ListItem list_item)
		{
			CheckButton check_button = new CheckButton();
			check_button.active = false;

			list_item.child = check_button;
		}

		[GtkCallback]
		private void signal_enabled_bind_handler(SignalListItemFactory factory, ListItem list_item)
		{
			CheckButton check_button = list_item.child as CheckButton;
			HostRow? host_row = list_item.item as HostRow;

			if (null != host_row) {
            check_button.active = host_row.enabled;
        }
		}

		[GtkCallback]
		private void signal_host_setup_handler(SignalListItemFactory factory, ListItem list_item)
		{
			list_item.child = new Label ("");
		}

		[GtkCallback]
		private void signal_host_bind_handler(SignalListItemFactory factory, ListItem list_item)
		{
			Label label = list_item.child as Label;
			HostRow? host_row = list_item.item as HostRow;

			if (null != host_row) {
            label.set_label (host_row.host);
        }
		}

		[GtkCallback]
		private void signal_ip_address_setup_handler(SignalListItemFactory factory, ListItem list_item)
		{
			list_item.child = new Label ("");
		}

		[GtkCallback]
		private void signal_ip_address_bind_handler(SignalListItemFactory factory, ListItem list_item)
		{
			Label label = list_item.child as Label;
			HostRow? host_row = list_item.item as HostRow;

			if (null != host_row) {
            label.set_label (host_row.ip_address);
        }
		}
	}
}
