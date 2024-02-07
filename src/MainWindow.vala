using Adw;
using Gdk;
using GLib;
using Gtk;

//  todo: fix when adding a host group inside empty host group row (there's a margin)
//  todo: fix when add a comment/action row inside empty host group row
namespace HostsManager {

	[GtkTemplate (ui = "/com/github/spo-ijaz/hostsmanager/ui/main-window.ui")]
	public class MainWindow : Adw.ApplicationWindow {

		private const ActionEntry[] ACTION_ENTRIES = {
			{ "focus-search-bar", focus_search_bar },
			{ "host-row-add", add_host_row },
			{ "add-host-group-row", add_hosts_group_row },
			{ "add-comment-row", add_comment_row },
			{ "host-row-delete", delete_row },
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
		public unowned ShortcutController shortcut_controller;
		[GtkChild]
		public unowned Adw.HeaderBar header_bar;
		[GtkChild]
		public unowned PopoverMenu popover_menu;
		[GtkChild]
		public unowned PopoverMenu popover_add_row_menu;
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

			Menu main_menu = new Menu ();
			main_menu.append (_("Restore from backup file"), "win.restore-fron-backup");
			main_menu.append (_("Shortcuts"), "win.show-help-overlay");
			main_menu.append (_("About"), "win.show-about");
			main_menu.append (_("Quit"), "win.app-quit");

			this.popover_menu.set_menu_model (main_menu);
			this.popover_menu.activate ();

			// Menu to add different type of row...
			Menu add_row_menu = new Menu ();
			add_row_menu.append (_("Add a host group row"), "win.add-host-group-row");
			add_row_menu.append (_("Add a comment row"), "win.add-comment-row");

			this.popover_add_row_menu.set_menu_model (add_row_menu);
			this.popover_add_row_menu.activate ();

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
		private void add_host_row () {

			Models.HostRow new_host_row = new Models.HostRow (
			                                                  this.hosts_file_service.rows_list_store.get_n_items (),
			                                                  0,
			                                                  Models.HostRow.RowType.HOST,
			                                                  true,
			                                                  "127.0.0.1",
			                                                  Models.HostRow.IPVersion.IPV4,
			                                                  "hostname.domaine",
			                                                  "",
			                                                  "", "127.0.0.1 hostname.domaine");
			this.add_new_host_row (new_host_row);
		}

		private void add_comment_row () {

			Models.HostRow new_host_row = new Models.HostRow (
			                                                  this.hosts_file_service.rows_list_store.get_n_items (),
			                                                  0,
			                                                  Models.HostRow.RowType.COMMENT,
			                                                  true,
			                                                  "",
			                                                  Models.HostRow.IPVersion.IPV4,
			                                                  "",
			                                                  "",
			                                                  "a comment", "# a comment");
			this.add_new_host_row (new_host_row);
		}

		private void add_hosts_group_row () {

			Models.HostRow new_host_row = new Models.HostRow (
			                                                  this.hosts_file_service.rows_list_store.get_n_items (),
			                                                  0,
			                                                  Models.HostRow.RowType.HOST_GROUP,
			                                                  true,
			                                                  "",
			                                                  Models.HostRow.IPVersion.IPV4,
			                                                  "",
			                                                  "Group name",
			                                                  "", "## Group name");
			this.add_new_host_row (new_host_row);
		}

		private void delete_row () {

			Models.HostRow selected_host_row = this.get_selected_host_row ();
			if (selected_host_row == null) {
				return;
			}

			this.hosts_file_service.rows_list_store.remove (selected_host_row);
		}

		[GtkCallback]
		private void signal_on_search_toggle_button_toggled () {
		}

		private void restore_from_backup () {

			// this.hosts_list_undo_store.remove_all ();
			this.hosts_file_service.restore_from_backup ();
		}

		private Models.HostRow? get_selected_host_row () {

			Widgets.BaseActionRow action_row = this.hosts_list_box.list_box.get_selected_row () as Widgets.BaseActionRow;
			if (action_row == null) {
				return null;
			}

			Models.HostRow host_row = action_row.host_row;
			if (host_row == null) {
				return null;
			}

			return host_row;
		}

		private void add_new_host_row (Models.HostRow new_host_row) {

			Models.HostRow selected_host_row = this.get_selected_host_row ();

			if (selected_host_row == null) {

				this.hosts_file_service.rows_list_store.append (new_host_row);
			} else {

				this.hosts_file_service.rows_list_store.insert_after_position (new_host_row, selected_host_row);
			}
		}
	}
}