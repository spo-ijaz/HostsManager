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
		public unowned NoSelection hosts_no_selection;
		[GtkChild]
		public unowned FilterListModel hosts_filter_list_model;
		[GtkChild]
		public unowned GLib.ListStore hosts_list_store;
		[GtkChild]
		public unowned StringFilter hosts_string_filter;

		private Services.HostsFile hosts_file;

		construct {

			this.set_title (Services.Config.hostfile_path ());

			// Actions
    		this.add_action_entries (ACTION_ENTRIES, this);

			PropertyExpression property_expression = new PropertyExpression (typeof(Models.HostRow), null, "hostname");
			hosts_string_filter.set_expression (property_expression);

			// Populate column view
			this.hosts_file = new Services.HostsFile ();

			try {
				for (MatchInfo match_info = this.hosts_file.getEntries(); match_info.matches(); match_info.next()) {
					
					Models.HostRow host_row = new Models.HostRow (
						true,
						match_info.fetch_named("enabled") != "#",
						match_info.fetch_named("ipaddress"),
						match_info.fetch_named("hostname"));

					this.hosts_list_store.append (host_row);
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

			hosts_string_filter.set_search (search_entry.text);
		}

		//
		// Columns's widgets initial render
		//
		
	}
}




