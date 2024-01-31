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
		// [GtkChild]
		// public unowned FilterListModel hosts_filter_list_model;
		// [GtkChild]
		// public unowned GLib.ListStore hosts_list_store;
		// [GtkChild]
		// public unowned StringFilter hosts_string_filter;
		// [GtkChild]
		// public unowned Gtk.ListBox host_groups_list_box;
		// [GtkChild]
		// public unowned Gtk.Popover popover_section_edit;

		private Services.HostsFile hosts_file_service;
		// private GLib.ListStore hosts_list_undo_store;
		private GLib.ListStore rows_list_store;
		private Widgets.HostsListBox hosts_list_box;

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

			// Search bar entry
			this.search_toggle_button.bind_property ("active", this.search_bar, "visible");
			this.search_toggle_button.toggled.connect ((toogle_button) => {

				if (toogle_button.active) {

					this.search_entry.grab_focus ();
				}
			});
			this.search_entry.search_changed.connect (signal_search_changed_stop_search_handler);

			// Help overlay
			Builder help_builder = new Builder.from_resource ("/com/github/spo-ijaz/hostsmanager/ui/app-shortcuts-window.ui");
			this.set_help_overlay (help_builder.get_object ("app-shortcuts-window") as ShortcutsWindow);

			// Filter for LibStore.
			// PropertyExpression property_expression = new PropertyExpression (typeof (Models.HostRow), null, "hostname");
			// this.hosts_string_filter.set_expression (property_expression);

			// Initiailize the list store
			// this.hosts_list_undo_store = new GLib.ListStore (typeof (Models.HostRow));
			this.rows_list_store = new GLib.ListStore (typeof (Models.HostRow));
			this.hosts_file_service = new Services.HostsFile (this, this.rows_list_store);
			this.hosts_file_service.read_file ();


			this.hosts_list_box = new Widgets.HostsListBox (this, this.hosts_file_service);
			this.hosts_scrolled_window.set_child (this.hosts_list_box.list_box);
		}

		public MainWindow (App app) {
			Object (
			        application: app
			);
		}

		public void hot_reload () {

			// this.hosts_list_undo_store.remove_all ();
			// this.hosts_file_service.read_file ();
			// this.toast.title = _("Host file has changed. Reloaded.");
			// this.toast_overlay.add_toast (this.toast);
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
		// Search bar
		//
		private void focus_search_bar (SimpleAction action, GLib.Variant? parameter) {

			if (this.search_toggle_button.active) {

				this.search_toggle_button.set_active (false);
			} else {

				this.search_toggle_button.set_active (true);
				this.search_entry.grab_focus ();
			}
		}

		private void signal_search_changed_stop_search_handler () {

			this.hosts_list_box.set_search_entry_text(this.search_entry.text);
		}

		//
		// Host row creation / deletion / restoration
		//
		private void host_row_add () {

			// Models.HostRow host_row = new Models.HostRow (Models.HostRow.RowType.HOST,
			// true,
			// "127.0.0.1",
			// "domain.localhost.com",
			// "127.0.0.1 domain.localhost.com");
			// this.hosts_list_store.append (host_row);
			// this.hosts_file_service.save_file ();

			//// We wait a little the time for the new row widgets to be displayed and
			//// so hosts_scrolled_window.kvadjustment is updated accordingly.
			// Timeout.add_once (50, () => {

			// Adjustment adjustment = this.hosts_scrolled_window.vadjustment;
			// adjustment.set_value (adjustment.get_upper ());
			// });
		}

		private void host_row_delete () {

			// var iter = Gtk.BitsetIter ();
			// uint item_position_in_selection;
			// uint item_position_to_remove;
			// GLib.ListStore host_rows_to_delete = new GLib.ListStore (typeof (Models.HostRow));

			// If we delete lot's of entry, we remove previous undo deleted entries
			// because if we undo, we want only what we just mass deleted and not _all_ deleted entries since
			// the app was started
			// if (this.hosts_multi_selection.n_items > 1) {

			// this.hosts_list_undo_store.remove_all ();
			// }

			// if (!iter.init_first (this.hosts_multi_selection.get_selection (), out item_position_in_selection)) {
			// return;
			// }

			// do {
			//// 1. Get item from selection.
			// Models.HostRow host_row_to_remove_from_selection = hosts_multi_selection.get_item (item_position_in_selection) as Models.HostRow;
			// if (host_row_to_remove_from_selection == null) {

			// continue;
			// }

			// if (host_row_to_remove_from_selection.row_type != Models.HostRow.RowType.HOST) {


			// continue;
			// }

			//// 2. Get corresponding item from our main GLib.ListStore.
			// if (this.hosts_list_store.find (host_row_to_remove_from_selection, out item_position_to_remove)) {

			// debug ("Adding this item to removal list: %u | %s - %s", item_position_to_remove, host_row_to_remove_from_selection.ip_address, host_row_to_remove_from_selection.hostname);
			// host_row_to_remove_from_selection.previous_item_position = item_position_to_remove;
			// this.hosts_list_undo_store.append (host_row_to_remove_from_selection);
			// host_rows_to_delete.append (host_row_to_remove_from_selection);
			// }
			// } while (iter.next (out item_position_in_selection));

			//// Can't use GLib.ListStore.splice () because the model contains hosts file comments (or empty lines)
			//// So it's slow as hell.
			// for (int idx = 0; idx < host_rows_to_delete.n_items; idx++ ) {

			// Models.HostRow host_row_to_delete = host_rows_to_delete.get_item (idx) as Models.HostRow;
			// if (host_row_to_delete == null) {

			// continue;
			// }


			// if (this.hosts_list_store.find (host_row_to_delete, out item_position_to_remove)) {

			// Models.HostRow host_row_to_remove = this.hosts_list_store.get_item (item_position_to_remove) as Models.HostRow;
			// if (host_row_to_remove == null) {

			// continue;
			// }

			// debug ("Removing item %u | %s - %s", item_position_to_remove, host_row_to_remove.ip_address, host_row_to_remove.hostname);
			// this.hosts_list_store.remove (item_position_to_remove);
			// }
			// }

			this.hosts_file_service.save_file ();
			this.toast_overlay.add_toast (this.toast_undo);
		}

		private void host_row_delete_undo (bool from_shortcut = false) {

			// if (this.hosts_list_undo_store.get_n_items () > 0) {

			// int position;
			// for (position = 0; position <= this.hosts_list_undo_store.n_items; position++) {

			// Models.HostRow host_row = this.hosts_list_undo_store.get_item (position) as Models.HostRow;
			// if (host_row != null) {

			// debug ("Restoring host \"%s\", IP address \"%s\", previous position: %u", host_row.hostname, host_row.ip_address, host_row.previous_item_position);
			// this.hosts_list_store.insert (host_row.previous_item_position, host_row);
			// this.hosts_file_service.restore (host_row, false);

			// if (from_shortcut == true) {

			// break;
			// }
			// }
			// }

			// if (from_shortcut == false) {

			// this.hosts_list_undo_store.remove_all ();
			// } else {

			// this.hosts_list_undo_store.remove (position);
			// }

			// this.hosts_file_service.save_file ();
			// } else {

			// this.toast.title = _("No deleted entries to restore.");
			// this.toast_overlay.add_toast (this.toast);
			// }
		}

		[GtkCallback]
		private void signal_on_search_toggle_button_toggled () {
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

			// this.hosts_list_undo_store.remove_all ();
			this.hosts_file_service.restore_from_backup ();
		}

		//
		// ColumnsViewColumn's widgets signals handler
		//
		// [GtkCallback]
		// private void signal_enabled_setup_handler (SignalListItemFactory factory, Object object) {

		// CheckButton check_button = new CheckButton ();
		// check_button.active = false;
		// check_button.set_halign (Align.CENTER);

		// ListItem list_item = object as ListItem;
		// list_item.set_child (check_button);
		// }

		// [GtkCallback]
		// private void signal_enabled_bind_handler (SignalListItemFactory factory, Object object) {

		// ListItem list_item = object as ListItem;
		// if (list_item.child == null) {

		// this.signal_enabled_setup_handler (factory, list_item);
		// }

		// CheckButton? check_button = list_item.get_child () as CheckButton;
		// Models.HostRow? host_row = list_item.item as Models.HostRow;

		// if (check_button != null && host_row != null) {

		// bool visible = true;
		// if (host_row.row_type != Models.HostRow.RowType.HOST) {

		// visible = false;
		// }

		// check_button.get_parent ().set_visible (visible);

		// Services.HostsRegex regex = new Services.HostsRegex (host_row.ip_address, host_row.hostname);

		// check_button.active = host_row.enabled;
		// check_button.toggled.connect (() => {

		// this.hosts_file_service.set_enabled (regex, !check_button.active, host_row);
		// });
		// }
		// }

		// [GtkCallback]
		// private void signal_host_ip_address_setup_handler (SignalListItemFactory factory, Object object) {

		// ListItem list_item = object as ListItem;
		// list_item.set_child (new Widgets.EditableCell (this, this.hosts_file_service));
		// }

		// [GtkCallback]
		// private void signal_ip_address_bind_handler (SignalListItemFactory factory, Object object) {

		// ListItem list_item = object as ListItem;
		// if (list_item.child == null) {

		// this.signal_host_ip_address_setup_handler (factory, list_item);
		// }

		// Widgets.EditableCell? editable_cell = list_item.child as Widgets.EditableCell;
		// Models.HostRow? host_row = list_item.item as Models.HostRow;

		// if (editable_cell != null && host_row != null) {

		// bool visible = true;
		// if (host_row.row_type != Models.HostRow.RowType.HOST) {

		// visible = false;
		// }

		// editable_cell.get_parent ().set_visible (visible);

		// editable_cell.field_type = Widgets.EditableCell.FieldType.IP_ADDRESS;
		// editable_cell.editable_label.set_text (host_row.ip_address);
		// editable_cell.host_row = host_row;
		// }
		// }

		// [GtkCallback]
		// private void signal_host_bind_handler (SignalListItemFactory factory, Object object) {

		// ListItem list_item = object as ListItem;
		// if (list_item.child == null) {

		// this.signal_host_ip_address_setup_handler (factory, list_item);
		// }

		// Widgets.EditableCell? editable_cell = list_item.child as Widgets.EditableCell;
		// Models.HostRow? host_row = list_item.item as Models.HostRow;

		// if (editable_cell != null && host_row != null) {

		// bool visible = true;
		// if (host_row.row_type != Models.HostRow.RowType.HOST) {

		// visible = false;
		// }

		// editable_cell.get_parent ().set_visible (visible);

		// editable_cell.field_type = Widgets.EditableCell.FieldType.HOSTNAME;
		// editable_cell.editable_label.set_text (host_row.hostname);
		// editable_cell.host_row = host_row;
		// }
		// }

		// [GtkCallback]
		// private void signal_column_view_unbind_handler (SignalListItemFactory factory, Object object) {

		// ListItem list_item = object as ListItem;
		// if (list_item.item != null) {

		// list_item.set_child (null);
		// }
		// }
	}
}