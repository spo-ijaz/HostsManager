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

		private Services.HostsFile hosts_file_service;
		private Models.HostListModel rows_list_store;
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
			this.rows_list_store = new Models.HostListModel ();
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

			this.hosts_list_box.set_search_entry_text (this.search_entry.text);
		}

		//
		// Host row creation / deletion / restoration
		//
		private void host_row_add () {
		}

		private void host_row_delete () {
		}

		private void host_row_delete_undo (bool from_shortcut = false) {
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
	}
}