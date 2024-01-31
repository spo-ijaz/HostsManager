using Adw;
using GLib;

public errordomain InvalidArgument {
	IPADDRESS,
	HOSTNAME,
}

namespace HostsManager.Services {

	class HostsFile : Object {

		public MainWindow main_window { get; construct; }
		public ListStore rows_list_store { get; construct; }

		private File host_file;
		private File host_file_bkp;
		private FileMonitor host_file_monitor;

		construct {

			string host_file_path = Config.hostfile_path ();
			this.host_file = File.new_for_path (host_file_path);
			this.host_file_bkp = File.new_for_path (host_file_path + ".bkp");

			try {

				this.host_file_monitor = host_file.monitor (FileMonitorFlags.NONE, null);
				this.host_file_monitor.changed.connect ((src, dest, event) => {

					if (event == FileMonitorEvent.CHANGED) {

						this.main_window.hot_reload ();
					}
				});


				debug ("Backup of \"%s\" -> \"%s\" ", host_file.get_path (), host_file_bkp.get_path ());
				host_file.copy (host_file_bkp, FileCopyFlags.OVERWRITE);

				this.main_window.toast.set_title (_("Host file backup here: ") + host_file_bkp.get_path ());
				this.main_window.toast_overlay.add_toast (this.main_window.toast);
			} catch (Error e) {

				error ("Error: %s", e.message);
			}

			// this.read_file ();
		}

		public HostsFile (HostsManager.MainWindow main_window, ListStore rows_list_store) {

			Object (
			        main_window: main_window,
			        rows_list_store: rows_list_store
			);
		}

		// public void remove (uint index, bool save) {

		//// this.content[index] = null;
		//// if (save == true) {

		//// this.save_file ();
		//// }
		// }

		public void restore (Models.HostRow host_row, bool save = true) {

			// this.content[host_row.previous_position] = host_row.previous_full_row;

			// if (save == true) {

			// this.save_file ();
			// }
		}

		public void restore_from_backup () {

			try {

				// debug ("Restauring backup of \"%s\" -> \"%s\" ", host_file_bkp.get_path (), host_file.get_path ());
				// this.hosts_list_store_ipv6.remove_all ();
				// host_file_bkp.copy (host_file, FileCopyFlags.OVERWRITE);
				// this.read_file ();

				// this.main_window.toast.set_title (_("Host file restored."));
				// this.main_window.toast_overlay.add_toast (this.main_window.toast);
			} catch (Error e) {

				this.main_window.toast.set_title (_("Unable to restore from backup file: ") + host_file_bkp.get_path ());
				this.main_window.toast_overlay.add_toast (this.main_window.toast);
				error ("Error: %s", e.message);
			}
		}

		public void read_file () {

			try {

				this.rows_list_store.remove_all ();
				var data_input_stream = new DataInputStream (this.host_file.read ());

				MatchInfo match_info;
				Services.RegexHostRow regex_host_row = new Services.RegexHostRow ();
				Services.RegexHostGroupRow regex_host_group_row = new Services.RegexHostGroupRow ();
				Services.RegexCommentRow regex_comment_row = new Services.RegexCommentRow ();
				string row;

				// We store row by row, nothing more.
				// It's the HostsListBox widget which is responsible for grouping the host rows.
				uint num_row = 0;
				while ((row = data_input_stream.read_line (null)) != null) {

					debug ("| row #%u :  %s", num_row, row);
					Models.HostRow row_model = new Models.HostRow (Models.HostRow.RowType.EMPTY,
					                                               false,
					                                               "",
					                                               Models.HostRow.IPVersion.IPV4,
					                                               "",
					                                               "",
					                                               "",
					                                               num_row++,
					                                               row);

					if (regex_host_row.match (row, 0, out match_info)) {

						row_model.row_type = Models.HostRow.RowType.HOST;
						row_model.enabled = match_info.fetch_named ("enabled") != "#";
						row_model.ip_address = match_info.fetch_named ("ipaddress");
						row_model.hostname = match_info.fetch_named ("hostname");
					} else if (regex_host_group_row.match (row, 0, out match_info)) {

						row_model.row_type = Models.HostRow.RowType.HOST_GROUP;
						row_model.host_group_name = match_info.fetch_named ("host_group_name");
					} else if (regex_comment_row.match (row, 0, out match_info)) {

						row_model.row_type = Models.HostRow.RowType.COMMENT;
						row_model.comment = match_info.fetch_named ("comment");
					} else {

						row_model.row_type = Models.HostRow.RowType.EMPTY;
					}

					debug ("|-> row type        : %s", row_model.row_type.to_string ());
					debug ("|-> ip              : %s", row_model.ip_address);
					debug ("|-> hostname        : %s", row_model.hostname);
					debug ("|-> host_group_name : %s", row_model.host_group_name);
					debug ("|-> comment         : %s", row_model.comment);
					debug ("------------");

					this.rows_list_store.append (row_model);
				}
			} catch (Error e) {

				error ("Error to read file: %s", e.message);
			}
		}

		public void save_file () {

			try {

				//// TODO: There's probably a better way to do that.
				// Models.HostRow host_row = new Models.HostRow (Models.HostRow.RowType.EMPTY,
				// false,
				// "",
				// "",
				// "");

				// string all_rows = "";
				// for (uint idx = 0; idx < this.hosts_list_store_ipv6.n_items; idx++) {

				// host_row = this.hosts_list_store_ipv6.get_item (idx) as Models.HostRow;

				// if (host_row != null) {

				// all_rows += host_row.row + "\n";
				// }
				// }

				// StringBuilder rows_string_builder = new StringBuilder (all_rows);

				// this.host_file.replace_contents (rows_string_builder.data, null, false, FileCreateFlags.NONE, null);

				// this.main_window.toast.set_title (_("Host file updated."));
				// this.main_window.toast_overlay.add_toast (this.main_window.toast);
			} catch (Error e) {

				error ("Unable to save file: %s", e.message);
			}
		}

		public void set_enabled (RegexHostRow modRegex, bool active, Models.HostRow host_row) {

			try {

				host_row.row = modRegex.replace (host_row.row, -1, 0, active ? """#\g<row>""" : """\g<row>""");
				host_row.enabled = active;
				this.save_file ();
			} catch (RegexError regex_error) {

				error ("Regex failed: %s", regex_error.message);
			}
		}

		public void set_ip_address (RegexHostRow modRegex, string ip_address, Models.HostRow host_row) throws InvalidArgument {

			this.valide_ip_address (ip_address);

			try {

				host_row.row = modRegex.replace (host_row.row, -1, 0, """\g<enabled>""" + ip_address + """\g<divider>\g<hostname>""");
				host_row.ip_address = ip_address;
				this.save_file ();
			} catch (RegexError regex_error) {

				GLib.error ("Regex failed: %s", regex_error.message);
			}
		}

		public void set_hostname (RegexHostRow modRegex, string hostname, Models.HostRow host_row) throws InvalidArgument {

			this.validate_host_name (hostname);

			try {

				host_row.row = modRegex.replace (host_row.row, -1, 0, """\g<enabled>\g<ipaddress>\g<divider>""" + hostname);
				host_row.hostname = hostname;
				this.save_file ();
			} catch (RegexError regex_error) {

				GLib.error ("Regex failed: %s", regex_error.message);
			}
		}

		private void validate_host_name (string hostname) throws InvalidArgument {

			if (!Regex.match_simple ("^" + Config.hostname_regex_str () + "$", hostname)) {

				throw new InvalidArgument.HOSTNAME ("Invalid hostname format");
			}
		}

		private void valide_ip_address (string ipaddress) throws InvalidArgument {

			if (!Regex.match_simple ("^" + Config.ipaddress_regex_str () + "$", ipaddress)) {

				throw new InvalidArgument.IPADDRESS ("Invalid ip address format");
			}
		}
	}
}