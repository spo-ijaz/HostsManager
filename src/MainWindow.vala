using Adw;
using Gdk;
using GLib;
using Gtk;

namespace HostsManager {

	[GtkTemplate (ui = "/com/github/spo-ijaz/hostsmanager/ui/main-window.ui")]
	public class MainWindow : Adw.ApplicationWindow {

		private const ActionEntry[] ACTION_ENTRIES = {
			{ "focus-search-bar", focus_search_bar },
			{ "host-row-add", host_row_add },
			{ "host-row-delete", host_row_delete },
			{ "host-row-undo", signal_shortcut_undo_triggered },
			{ "restore-fron-backup", restore_from_backup },
			{ "show-about", show_about },
			{ "app-quit", app_quit },
		};

		[GtkChild]
		public unowned CssProvider css_provider;
		[GtkChild]
		public unowned ToastOverlay toast_overlay;
		[GtkChild]
		public unowned Toast toast;
		[GtkChild]
		public unowned Toast toast_undo;
		[GtkChild]
		public unowned ShortcutController shortcut_controller;
		[GtkChild]
		public unowned Adw.HeaderBar header_bar;
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
		public unowned MultiSelection hosts_multi_selection;
		[GtkChild]
		public unowned FilterListModel hosts_filter_list_model;
		[GtkChild]
		public unowned GLib.ListStore hosts_list_store;
		[GtkChild]
		public unowned StringFilter hosts_string_filter;


		private Services.HostsFile hosts_file_service;
		private GLib.ListStore hosts_list_undo_store;

		construct {

			Adw.WindowTitle window_title = this.header_bar.title_widget as Adw.WindowTitle;
			if (window_title != null) {

				window_title.subtitle = Services.Config.hostfile_path ();
			}

			// Custom CSS
			this.css_provider.load_from_resource ("/com/github/spo-ijaz/hostsmanager/ui/hosts-manager.css");
			StyleContext.add_provider_for_display (
			                                       this.get_display (),
			                                       this.css_provider,
			                                       STYLE_PROVIDER_PRIORITY_USER);

			// Action, menu, shortcuts...
			this.add_action_entries (ACTION_ENTRIES, this);

			Menu menu = new Menu ();
			menu.append (_("Restore from backup file"), "win.restore-fron-backup");
			menu.append (_("Shortcuts"), "win.show-help-overlay");
			menu.append (_("About"), "win.show-about");
			menu.append (_("Quit"), "win.app-quit");

			this.popover_menu.set_menu_model (menu);
			this.popover_menu.activate ();

			this.add_controller (shortcut_controller);


			// Help overlay
			Builder help_builder = new Builder.from_resource ("/com/github/spo-ijaz/hostsmanager/ui/app-shortcuts-window.ui");
			this.set_help_overlay (help_builder.get_object ("app-shortcuts-window") as ShortcutsWindow);

			// Filter for LibStore.
			PropertyExpression property_expression = new PropertyExpression (typeof (Models.HostRow), null, "hostname");
			this.hosts_string_filter.set_expression (property_expression);

			// Initiailize the list store
			this.hosts_list_undo_store = new GLib.ListStore (typeof (Models.HostRow));
			this.hosts_file_service = new Services.HostsFile (this);
			this.append_hots_rows_to_list_store ();

			//  for (uint idx; idx < this.hosts_list_store.n_items; idx++) {

			//  	Models.HostRow host_row = this.hosts_list_store.get_item (idx) as Models.HostRow;
			//  	debug("%s %s %s", host_row.row_type.to_string(), host_row.ip_address, host_row.hostname);
			//  }

			// To automatically select the current row
			// Works but give this error : Gtk-CRITICAL ** gtk_widget_compute_point: assertion 'GTK_IS_WIDGET (widget)' failed
			// this.hosts_column_view.set_single_click_activate (true);
		}

		public MainWindow (App app) {
			Object (
			        application: app
			);
		}

		public void hot_reload () {

			this.hosts_list_undo_store.remove_all ();
			this.hosts_list_store.remove_all ();
			this.hosts_file_service.read_file ();
			this.append_hots_rows_to_list_store ();
			this.toast.title = _("Host file has changed. Reloaded.");
			this.toast_overlay.add_toast (this.toast);
		}

		private void app_quit () {

			this.application.quit ();
		}

		private void show_about () {

			string[] developers = {
				"Sébastien PORQUET <sebastien.porquet@ijaz.fr>",
				"Benjamin BUHLER <elementary.hostsmanager@freiken-douhl.de>",
			};

			var about = new Adw.AboutWindow () {
				transient_for = this,
				application_name = "HostsManager",
				application_icon = AppConfig.APP_ID,
				developer_name = _("Sébastien PORQUET"),
				version = AppConfig.PACKAGE_VERSION,
				website = "https://github.com/spo-ijaz/HostsManager",
				issue_url = "https://github.com/spo-ijaz/HostsManager/issues",
				developers = developers,
				copyright = _("© 2018 Benjamin BUHLER"),
				license_type = Gtk.License.GPL_3_0
			};

			about.present ();
		}

		//
		// Store
		//
		private void append_hots_rows_to_list_store () {

			MatchInfo match_info;
			Services.HostsRegex regex = new Services.HostsRegex ();

			uint line_number = 0;
			foreach (string row in this.hosts_file_service.get_rows ()) {

				debug ("row: %s", row);
				Models.HostRow host_row = new Models.HostRow (
					line_number,
					Models.HostRow.RowType.EMPTY,
					false,
					"",
					"",
					"",
					row
				);

				if (regex.match (row, 0, out match_info)) {
					debug ("`->added as host line");
					host_row.row_type = Models.HostRow.RowType.HOST;
					host_row.enabled = match_info.fetch_named ("enabled") != "#";
					host_row.ip_address = match_info.fetch_named ("ipaddress");
					host_row.hostname = match_info.fetch_named ("hostname");

				} else {
					debug ("`-> added as comment");
					host_row.row_type = row.length > 0 ? Models.HostRow.RowType.COMMENT : Models.HostRow.RowType.EMPTY;
					host_row.comment = row;
				}

				this.hosts_list_store.append (host_row);
				//  this.hosts_list_store.splice (line_number, 0, {host_row});
				line_number++;
			}
		}

		//
		// Search bar
		//
		[GtkCallback]
		private void on_search_toggle_button_toggled () {

			this.search_bar.set_visible (this.search_toggle_button.get_active ());
			this.search_entry.grab_focus ();
		}

		private void focus_search_bar (SimpleAction action, GLib.Variant? parameter) {

			this.search_toggle_button.set_active (!this.search_toggle_button.get_active ());
			this.on_search_toggle_button_toggled ();
		}

		[GtkCallback]
		private void signal_search_entry_search_changed_handler () {

			this.hosts_string_filter.set_search (search_entry.text);
		}

		//
		// Host row creation / deletion / restoration
		//
		private void host_row_add_into_file (Models.HostRow host_row, bool save = true) {

			try {

				this.hosts_file_service.add (host_row.ip_address, host_row.hostname, save);
			} catch (InvalidArgument invalid_argument) {

				debug ("InvalidArgument: %s", invalid_argument.message);
			}
		}

		private void host_row_add () {

			Models.HostRow host_row = new Models.HostRow (
			                                              this.hosts_list_store.n_items,
			                                              Models.HostRow.RowType.HOST,
			                                              true,
			                                              "127.0.0.1",
			                                              "new.localhost",
			                                              "",
			                                              "127.0.0.1 new.localhost");
			this.hosts_list_store.append (host_row);
			this.host_row_add_into_file (host_row);

			// We wait a little the time for the new row widgets to be displayed and
			// so hosts_scrolled_window.kvadjustment is updated accordingly.
			Timeout.add_once (50, () => {

				Adjustment adjustment = this.hosts_scrolled_window.vadjustment;
				adjustment.set_value (adjustment.get_upper ());
			});
		}

		private void host_row_delete () {

			var iter = Gtk.BitsetIter ();
			uint position;
			GLib.ListStore host_rows_to_delete = new GLib.ListStore (typeof (Models.HostRow));

			if (!iter.init_first (this.hosts_multi_selection.get_selection (), out position)) {
				return;
			}

			do {
				Models.HostRow host_row = this.hosts_list_store.get_item (position) as Models.HostRow;
				if (host_row != null && host_row.row_type == Models.HostRow.RowType.HOST) {

					debug ("Deleting %s - %s", host_row.ip_address, host_row.hostname);

					host_rows_to_delete.append (host_row);

					host_row.previous_position = position;
					this.hosts_list_undo_store.append (host_row);
					this.hosts_file_service.remove (host_row.line_number, false);
				}
			} while (iter.next (out position));

			// Can't use GLib.ListStore.splice () because the model contains hosts file comments (or empty lines)
			// So it's slow as hell.
			uint position_to_delete;
			for (int idx = 0; idx < host_rows_to_delete.n_items; idx++ ) {

				if (this.hosts_list_store.find (host_rows_to_delete.get_item (idx), out position_to_delete)) {

					this.hosts_list_store.remove (position_to_delete);
				}
			}

			this.hosts_file_service.save_file ();
			this.toast_overlay.add_toast (this.toast_undo);
		}

		private void host_row_delete_undo (bool from_shortcut = false) {

			if (this.hosts_list_undo_store.get_n_items () > 0) {

				int position;
				for (position = 0; position <= this.hosts_list_undo_store.n_items; position++) {

					Models.HostRow host_row = this.hosts_list_undo_store.get_item (position) as Models.HostRow;
					if (host_row != null) {

						debug ("Restoring host \"%s\", IP address \"%s\", previous position: %u", host_row.hostname, host_row.ip_address, host_row.previous_position);
						this.hosts_list_store.insert (host_row.previous_position, host_row);
						this.hosts_file_service.restore (host_row, false);

						if (from_shortcut == true) {

							break;
						}
					}
				}

				if (from_shortcut == false) {

					this.hosts_list_undo_store.remove_all ();
				} else {

					this.hosts_list_undo_store.remove (position);
				}

				this.hosts_file_service.save_file ();
			} else {

				this.toast.title = _("No deleted entries to restore.");
				this.toast_overlay.add_toast (this.toast);
			}
		}

		private void signal_shortcut_undo_triggered () {

			// will undo only one row at once.
			this.host_row_delete_undo (true);
		}

		[GtkCallback]
		private void signal_toast_undo_button_clicked_handler () {

			// will undo all deleted rows.
			this.host_row_delete_undo (false);
		}

		private void restore_from_backup () {

			this.hosts_list_undo_store.remove_all ();
			this.hosts_list_store.remove_all ();
			this.hosts_file_service.restore_from_backup ();
			this.append_hots_rows_to_list_store ();
		}

		//
		// ColumnsViewColumn's widgets signals handler
		//
		[GtkCallback]
		private void signal_enabled_setup_handler (SignalListItemFactory factory, Object object) {

			CheckButton check_button = new CheckButton ();
			check_button.active = false;
			check_button.set_halign (Align.CENTER);

			ListItem list_item = object as ListItem;
			list_item.set_child (check_button);
		}

		[GtkCallback]
		private void signal_enabled_bind_handler (SignalListItemFactory factory, Object object) {

			ListItem list_item = object as ListItem;
			if (list_item.child == null) {

				this.signal_enabled_setup_handler (factory, list_item);
			}

			CheckButton? check_button = list_item.get_child () as CheckButton;
			Models.HostRow? host_row = list_item.item as Models.HostRow;

			if (check_button != null && host_row != null) {

				if (host_row.row_type != Models.HostRow.RowType.HOST) {

					debug("signal_enabled_bind_handler - %u %s %s %s ", host_row.line_number, host_row.row_type.to_string(), host_row.ip_address, host_row.hostname);
					check_button.get_parent ().set_visible (false);
					return;
				}

				check_button.active = host_row.enabled;
				check_button.toggled.connect (() => {

					Services.HostsRegex regex = new Services.HostsRegex (host_row.ip_address, host_row.hostname);
					this.hosts_file_service.set_enabled (regex, !check_button.active, host_row.line_number);
					host_row.enabled = check_button.active;
				});
			}
		}

		[GtkCallback]
		private void signal_host_ip_address_setup_handler (SignalListItemFactory factory, Object object) {

			ListItem list_item = object as ListItem;
			list_item.set_child (new Widgets.EditableCell (this, this.hosts_file_service, list_item));
		}

		[GtkCallback]
		private void signal_ip_address_bind_handler (SignalListItemFactory factory, Object object) {

			ListItem list_item = object as ListItem;
			if (list_item.child == null) {

				this.signal_host_ip_address_setup_handler (factory, list_item);
			}

			Widgets.EditableCell? editable_cell = list_item.child as Widgets.EditableCell;
			Models.HostRow? host_row = list_item.item as Models.HostRow;

			if (editable_cell != null && host_row != null) {

				if (host_row.row_type != Models.HostRow.RowType.HOST) {
					debug("signal_ip_address_bind_handler - %u %s %s %s ", host_row.line_number, host_row.row_type.to_string(), host_row.ip_address, host_row.hostname);
					editable_cell.get_parent ().set_visible (false);
					return;
				}

				editable_cell.field_type = Widgets.EditableCell.FieldType.IP_ADDRESS;
				editable_cell.editable_label.set_text (host_row.ip_address);
				editable_cell.host_row = host_row;
			}
		}

		[GtkCallback]
		private void signal_host_bind_handler (SignalListItemFactory factory, Object object) {

			ListItem list_item = object as ListItem;
			if (list_item.child == null) {

				this.signal_host_ip_address_setup_handler (factory, list_item);
			}

			Widgets.EditableCell? editable_cell = list_item.child as Widgets.EditableCell;
			Models.HostRow? host_row = list_item.item as Models.HostRow;

			if (editable_cell != null && host_row != null) {

				if (host_row.row_type != Models.HostRow.RowType.HOST) {

					debug("signal_host_bind_handler - %u %s %s %s ", host_row.line_number, host_row.row_type.to_string(), host_row.ip_address, host_row.hostname);
					editable_cell.get_parent ().set_visible (false);
					return;
				}

				editable_cell.field_type = Widgets.EditableCell.FieldType.HOSTNAME;
				editable_cell.editable_label.set_text (host_row.hostname);
				editable_cell.host_row = host_row;
			}
		}

		[GtkCallback]
		private void signal_column_view_unbind_handler (SignalListItemFactory factory, Object object) {

			ListItem list_item = object as ListItem;
			if (list_item.item != null) {

				list_item.set_child (null);
			}
		}

		// Drag & Drop
		// public void handle_drop (uint drag_item_position, uint drop_item_position) {


		// var iter = Gtk.BitsetIter ();
		// uint position;
		// uint initial_position = 0;
		// bool initial_position_init = false;
		// Object[] host_rows_to_move = {};

		// debug ("drag_item_position: %u | drop_item_position: %u", drag_item_position, drop_item_position);
		//// if (!iter.init_first (this.hosts_multi_selection.get_selection (), out position)) {
		//// debug ("par la");
		//// return;
		//// }

		// iter.init_first (this.hosts_multi_selection.get_selection (), out position);
		// do {

		// debug ("M - par la");
		// Models.HostRow host_row = this.hosts_list_store.get_item (position) as Models.HostRow;
		// if (host_row != null && host_row.row_type == Models.HostRow.RowType.HOST) {

		// if (initial_position_init == false) {

		// initial_position_init = true;
		// initial_position = position;
		// }

		// host_rows_to_move += host_row;
		// }
		// } while (iter.next (out position));

		// this.host_row_delete (true);
		// debug ("drop_item_position: %u | num host_rows_to_move:  %u", drop_item_position, host_rows_to_move.length);
		// this.hosts_list_store.splice (drop_item_position, 0, host_rows_to_move);
		// }
	}
}