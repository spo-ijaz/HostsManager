using Adw;
using GLib;

namespace HostsManager.Services {

	class HostsFileService : Object {

		public MainWindow main_window { get; construct; }
		public Models.HostRowListModel host_row_list_model { get; construct; }

		private File host_file;
		private File host_file_bkp;
		private FileMonitor host_file_monitor;

		private const int HOST_GROUP_ROW_END_LINES = 3;

		construct {

			string host_file_path = ConfigService.hostfile_path ();
			this.host_file = File.new_for_path (host_file_path);
			this.host_file_bkp = File.new_for_path (host_file_path + ".bkp");

			try {

				this.host_file_monitor = this.host_file.monitor (FileMonitorFlags.NONE, null);
				this.host_file_monitor.changed.connect ((src, dest, event) => {

					if (event == FileMonitorEvent.CHANGED || event == FileMonitorEvent.CHANGES_DONE_HINT) {

						this.hot_reload ();
						this.main_window.hide_buttons ();
					}
				});


				debug ("Backup of \"%s\" -> \"%s\" ", this.host_file.get_path (), this.host_file_bkp.get_path ());
				host_file.copy (this.host_file_bkp, FileCopyFlags.OVERWRITE);

				this.main_window.toast.set_title (_("Host file backup here: ") + this.host_file_bkp.get_path ());
				this.main_window.toast_overlay.add_toast (this.main_window.toast);
			} catch (Error e) {

				error ("Error: %s", e.message);
			}
		}

		public HostsFileService (HostsManager.MainWindow main_window, Models.HostRowListModel host_row_list_model) {

			Object (
			        main_window: main_window,
			        host_row_list_model: host_row_list_model
			);
		}

		public void hot_reload () {

			debug ("Hot reloading of \"%s\" ", this.host_file.get_path ());
			this.host_row_list_model.remove_all ();
			this.read_file ();

			this.main_window.toast.set_title (_("Host file has changed. Reloaded."));
			this.main_window.toast_overlay.add_toast (this.main_window.toast);
		}

		public void read_file () {

			try {

				this.host_row_list_model.remove_all ();
				var data_input_stream = new DataInputStream (this.host_file.read ());

				MatchInfo match_info;
				Services.RegexHostRowIpv4 regex_host_row_ipv4 = new Services.RegexHostRowIpv4 ();
				Services.RegexHostRowIpv6 regex_host_row_ipv6 = new Services.RegexHostRowIpv6 ();
				Services.RegexHostGroupRow regex_host_group_row = new Services.RegexHostGroupRow ();
				Services.RegexCommentRow regex_comment_row = new Services.RegexCommentRow ();

				bool in_group = false;
				uint current_parent_id = 0;

				string current_row;
				uint current_id = 0;

				// If >= self.HOST_GROUP_ROW_END_LINES - it's the end of a hosts group.
				int num_empty_rows_in_raw = 0;

				while ((current_row = data_input_stream.read_line (null)) != null) {

					// debug ("| row #%u :  %s", current_id, current_row);
					Models.HostRowModel host_row = new Models.HostRowModel (current_id,
					                                                        0,
					                                                        Models.HostRowModel.RowType.EMPTY,
					                                                        false,
					                                                        "",
					                                                        Models.HostRowModel.IPVersion.IPV4,
					                                                        "",
					                                                        "",
					                                                        "",
					                                                        current_row);

					if (regex_host_row_ipv4.match (host_row.row, 0, out match_info)) {

						num_empty_rows_in_raw = 0;
						host_row.row_type = Models.HostRowModel.RowType.HOST;
						host_row.enabled = match_info.fetch_named ("enabled") != "#";
						host_row.ip_address = match_info.fetch_named ("ipaddress");
						host_row.hostname = match_info.fetch_named ("hostname");
					} else if (regex_host_row_ipv6.match (host_row.row, 0, out match_info)) {

						num_empty_rows_in_raw = 0;
						host_row.row_type = Models.HostRowModel.RowType.HOST;
						host_row.enabled = match_info.fetch_named ("enabled") != "#";
						host_row.ip_address = match_info.fetch_named ("ipaddress");
						host_row.hostname = match_info.fetch_named ("hostname");
					} else if (regex_host_group_row.match (current_row, 0, out match_info)) {

						num_empty_rows_in_raw = 0;
						host_row.row_type = Models.HostRowModel.RowType.HOST_GROUP;
						host_row.host_group_name = match_info.fetch_named ("host_group_name");
					} else if (regex_comment_row.match (current_row, 0, out match_info)) {

						num_empty_rows_in_raw = 0;
						host_row.row_type = Models.HostRowModel.RowType.COMMENT;
						host_row.comment = match_info.fetch_named ("comment");
					} else {

						host_row.row_type = Models.HostRowModel.RowType.EMPTY;
						num_empty_rows_in_raw++;

						if (num_empty_rows_in_raw >= HOST_GROUP_ROW_END_LINES) {

							in_group = false;
						}
					}

					// debug ("|-> row type        : %s", host_row.row_type.to_string ());
					// debug ("|-> ip              : %s", host_row.ip_address);
					// debug ("|-> hostname        : %s", host_row.hostname);
					// debug ("|-> host_group_name : %s", host_row.host_group_name);
					// debug ("|-> comment         : %s", host_row.comment);

					if (host_row.row_type == Models.HostRowModel.RowType.HOST_GROUP) {

						in_group = true;
						current_parent_id = current_id;
						this.host_row_list_model.append (host_row);

						// debug ("                    | %s group detected ( #%u )", host_row.row, current_in_group_num_row);
					} else {

						if (in_group) {

							host_row.parent_id = current_parent_id;
						} else {

							in_group = false;
							current_parent_id = 0;
						}

						this.host_row_list_model.append (host_row);
					}

					current_id++;
					// debug ("------------");
				}
			} catch (Error e) {

				error ("Error to read file: %s", e.message);
			}
		}

		public void restore_from_backup () {

			try {

				debug ("Restauring backup of \"%s\" -> \"%s\" ", this.host_file_bkp.get_path (), this.host_file.get_path ());
				this.host_file_bkp.copy (host_file, FileCopyFlags.OVERWRITE);

				this.main_window.toast.set_title (_("Host file restored."));
				this.main_window.toast_overlay.add_toast (this.main_window.toast);
			} catch (Error e) {

				this.main_window.toast.set_title (_("Unable to restore from backup file: ") + this.host_file_bkp.get_path ());
				this.main_window.toast_overlay.add_toast (this.main_window.toast);
				error ("Error: %s", e.message);
			}
		}

		public void save_file () {

			try {

				string all_rows = "";
				bool in_group = false;
				int num_empty_rows_in_raw = 0;

				for (uint current_row = 0; current_row < this.host_row_list_model.get_n_items (); current_row++) {

					Models.HostRowModel host_row = this.host_row_list_model.get_item (current_row) as Models.HostRowModel;

					switch (host_row.row_type) {

					case Models.HostRowModel.RowType.EMPTY:

						num_empty_rows_in_raw++;
						all_rows += "\n";
						break;

					case Models.HostRowModel.RowType.COMMENT:

						if (in_group && host_row.parent_id == 0) {
							all_rows += this.get_end_host_group_lines (num_empty_rows_in_raw);
							in_group = false;
						}

						all_rows += "# " + host_row.comment + "\n";
						num_empty_rows_in_raw = 0;
						break;

					case Models.HostRowModel.RowType.HOST:

						if (in_group && host_row.parent_id == 0) {
							all_rows += this.get_end_host_group_lines (num_empty_rows_in_raw);
							in_group = false;
						}

						all_rows += (host_row.enabled ? "" : "# ") + host_row.ip_address + " " + host_row.hostname + "\n";
						num_empty_rows_in_raw = 0;
						break;

					case Models.HostRowModel.RowType.HOST_GROUP:

						in_group = true;
						all_rows += "## " + host_row.host_group_name + "\n";
						num_empty_rows_in_raw = 0;
						break;
					}
				}

				StringBuilder rows_string_builder = new StringBuilder (all_rows);

				this.host_file.replace_contents (rows_string_builder.data, null, false, FileCreateFlags.NONE, null);

				this.main_window.toast.set_title (_("Host file updated."));
				this.main_window.toast_overlay.add_toast (this.main_window.toast);
			} catch (Error e) {

				error ("Unable to save file: %s", e.message);
			}
		}

		private string get_end_host_group_lines (uint num_empty_rows_in_raw) {

			string return_lines = "";
			for (var current_num_empty_row = num_empty_rows_in_raw; current_num_empty_row < HostsFileService.HOST_GROUP_ROW_END_LINES; current_num_empty_row++) {

				return_lines += "\n";
			}

			return return_lines;
		}
	}
}