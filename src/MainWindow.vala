using Adw;
using Gdk;
using GLib;
using Gtk;

// todo: fix when adding a host group inside empty host group row (there's a margin)
// todo: fix when add a comment/action row inside empty host group row
namespace HostsManager {

	[GtkTemplate (ui = "/org/gnome/gitlab/spo-ijaz/hostsmanager/ui/main-window.ui")]
	public class MainWindow : Adw.ApplicationWindow {

		private const ActionEntry[] ACTION_ENTRIES = {
			{ "add-comment-row", add_comment_row },
			{ "add-host-group-row", add_hosts_group_row },
			{ "focus-search-bar", focus_search_bar },
			{ "host-row-add", add_host_row },
			{ "host-row-delete", delete_row },
			{ "restore-from-backup", restore_from_backup },
			{ "save-changes", save_changes },
			{ "show-about", show_about },
			{ "app-quit", app_quit },
		};

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
		public unowned SplitButton add_row_split_button;
		[GtkChild]
		public unowned SearchBar search_bar;
		[GtkChild]
		public unowned SearchEntry search_entry;
		[GtkChild]
		public unowned Button save_button;
		[GtkChild]
		public unowned Button cancel_button;
		[GtkChild]
		public unowned ScrolledWindow hosts_scrolled_window;

		private Services.HostsFileService hosts_file_service;
		private Models.HostRowListModel host_row_list_model;
		private Widgets.HostsListBox hosts_list_box;

		construct {

			Adw.WindowTitle window_title = this.header_bar.title_widget as Adw.WindowTitle;
			if (window_title != null) {

				window_title.subtitle = Services.ConfigService.hostfile_path ();
			}

			// Action, menu, shortcuts...
			this.add_action_entries (ACTION_ENTRIES, this);

			Menu main_menu = new Menu ();
			main_menu.append (_("Restore from backup file"), "win.restore-from-backup");
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
			Builder help_builder = new Builder.from_resource ("/org/gnome/gitlab/spo-ijaz/hostsmanager/ui/app-shortcuts-window.ui");
			this.set_help_overlay (help_builder.get_object ("app-shortcuts-window") as ShortcutsWindow);

			// Add,  Save & cancel buttons
			this.add_row_split_button.add_css_class ("suggested-action");
			this.save_button.add_css_class ("destructive-action");

			// Initialize model & listbox.
			this.host_row_list_model = new Models.HostRowListModel ();
			this.hosts_file_service = new Services.HostsFileService (this, this.host_row_list_model);
			this.hosts_file_service.read_file ();


			this.hosts_list_box = new Widgets.HostsListBox (this, this.hosts_file_service);
			this.hosts_scrolled_window.set_child (this.hosts_list_box.list_box);

			this.hosts_file_service.host_row_list_model.items_changed.connect (() => {

				this.save_button.set_visible (true);
				this.cancel_button.set_visible (true);
			});
		}

		public MainWindow (App app) {
			Object (
			        application: app
			);
		}

		public void hide_buttons () {

			this.cancel_button.set_visible (false);
			this.save_button.set_visible (false);
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
				website = "https://gitlab.gnome.org/spo-ijaz/HostsManager",
				issue_url = "https://gitlab.gnome.org/spo-ijaz/HostsManager/-/issues",
				developers = developers,
				copyright = _("© 2024 Sébastien PORQUET"),
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

			Models.HostRowModel new_host_row = new Models.HostRowModel (
			                                                            this.hosts_file_service.host_row_list_model.get_n_items (),
			                                                            0,
			                                                            Models.HostRowModel.RowType.HOST,
			                                                            true,
			                                                            "127.0.0.1",
			                                                            Models.HostRowModel.IPVersion.IPV4,
			                                                            "hostname.domain",
			                                                            "",
			                                                            "", "127.0.0.1 hostname.domain");
			this.add_new_host_row (new_host_row);
		}

		private void add_comment_row () {

			Models.HostRowModel new_host_row = new Models.HostRowModel (
			                                                            this.hosts_file_service.host_row_list_model.get_n_items (),
			                                                            0,
			                                                            Models.HostRowModel.RowType.COMMENT,
			                                                            true,
			                                                            "",
			                                                            Models.HostRowModel.IPVersion.IPV4,
			                                                            "",
			                                                            "",
			                                                            "a comment", "# a comment");
			this.add_new_host_row (new_host_row);
		}

		private void add_hosts_group_row () {

			Models.HostRowModel new_host_row = new Models.HostRowModel (
			                                                            this.host_row_list_model.get_n_items (),
			                                                            0,
			                                                            Models.HostRowModel.RowType.HOST_GROUP,
			                                                            true,
			                                                            "",
			                                                            Models.HostRowModel.IPVersion.IPV4,
			                                                            "",
			                                                            "Group name",
			                                                            "", "## Group name");
			this.add_new_host_row (new_host_row);
		}

		private void delete_row () {

			Models.HostRowModel selected_host_row = this.get_selected_host_row ();
			if (selected_host_row == null) {
				return;
			}

			this.host_row_list_model.remove (selected_host_row);
		}

		[GtkCallback]
		private void signal_on_search_toggle_button_toggled () {
		}

		private void restore_from_backup () {

			this.hosts_file_service.host_row_list_model.remove_all ();
			this.hosts_file_service.restore_from_backup ();
			this.hide_buttons ();
		}

		private void save_changes () {

			this.hosts_file_service.save_file ();
		}

		private Models.HostRowModel? get_selected_host_row () {

			Widgets.BaseActionRow action_row = this.hosts_list_box.list_box.get_selected_row () as Widgets.BaseActionRow;
			if (action_row == null) {
				return null;
			}

			Models.HostRowModel host_row = action_row.host_row;
			if (host_row == null) {
				return null;
			}

			return host_row;
		}

		private void add_new_host_row (Models.HostRowModel new_host_row) {

			Models.HostRowModel selected_host_row = this.get_selected_host_row ();

			if (selected_host_row == null) {

				this.host_row_list_model.append (new_host_row);
			} else {

				this.host_row_list_model.insert_after_host_row (new_host_row, selected_host_row, false, false);
			}
		}
	}
}