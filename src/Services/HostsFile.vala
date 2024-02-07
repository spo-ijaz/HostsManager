using Adw;
using GLib;

public errordomain InvalidArgument {
	IPADDRESS,
	HOSTNAME,
}

namespace HostsManager.Services {

	class HostsFile : Object {

		public MainWindow main_window { get; construct; }
		// public ListStore rows_list_store { get; construct; }
		public Models.HostListModel rows_list_store { get; construct; }

		private File host_file;
		private File host_file_bkp;
		private FileMonitor host_file_monitor;

		private const int HOST_GROUP_ROW_END_LINES = 3;

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

		public HostsFile (HostsManager.MainWindow main_window, Models.HostListModel rows_list_store) {

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

					debug ("| row #%u :  %s", current_id, current_row);
					Models.HostRow host_row = new Models.HostRow (current_id,
					                                              0,
					                                              Models.HostRow.RowType.EMPTY,
					                                              false,
					                                              "",
					                                              Models.HostRow.IPVersion.IPV4,
					                                              "",
					                                              "",
					                                              "",
					                                              current_row);

					if (regex_host_row_ipv4.match (host_row.row, 0, out match_info)) {

						num_empty_rows_in_raw = 0;
						host_row.row_type = Models.HostRow.RowType.HOST;
						host_row.enabled = match_info.fetch_named ("enabled") != "#";
						host_row.ip_address = match_info.fetch_named ("ipaddress");
						host_row.hostname = match_info.fetch_named ("hostname");
					} else if (regex_host_row_ipv6.match (host_row.row, 0, out match_info)) {

						num_empty_rows_in_raw = 0;
						host_row.row_type = Models.HostRow.RowType.HOST;
						host_row.enabled = match_info.fetch_named ("enabled") != "#";
						host_row.ip_address = match_info.fetch_named ("ipaddress");
						host_row.hostname = match_info.fetch_named ("hostname");
					} else if (regex_host_group_row.match (current_row, 0, out match_info)) {

						num_empty_rows_in_raw = 0;
						host_row.row_type = Models.HostRow.RowType.HOST_GROUP;
						host_row.host_group_name = match_info.fetch_named ("host_group_name");
					} else if (regex_comment_row.match (current_row, 0, out match_info)) {

						num_empty_rows_in_raw = 0;
						host_row.row_type = Models.HostRow.RowType.COMMENT;
						host_row.comment = match_info.fetch_named ("comment");
					} else {

						host_row.row_type = Models.HostRow.RowType.EMPTY;
						num_empty_rows_in_raw++;

						if (num_empty_rows_in_raw >= HOST_GROUP_ROW_END_LINES) {

							in_group = false;
						}
					}

					debug ("|-> row type        : %s", host_row.row_type.to_string ());
					debug ("|-> ip              : %s", host_row.ip_address);
					debug ("|-> hostname        : %s", host_row.hostname);
					debug ("|-> host_group_name : %s", host_row.host_group_name);
					debug ("|-> comment         : %s", host_row.comment);

					if (host_row.row_type == Models.HostRow.RowType.HOST_GROUP) {

						in_group = true;
						current_parent_id = current_id;
						this.rows_list_store.append (host_row);

						// debug ("                    | %s group detected ( #%u )", host_row.row, current_in_group_num_row);
					} else {

						if (in_group) {

							host_row.parent_id = current_parent_id;
						} else {

							in_group = false;
							current_parent_id = 0;
						}

						this.rows_list_store.append (host_row);
					}

					current_id++;
					// debug ("------------");
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

		public void set_enabled (RegexHostRowIpv4 modRegex, bool active, Models.HostRow host_row) {

			try {

				host_row.row = modRegex.replace (host_row.row, -1, 0, active ? """#\g<row>""" : """\g<row>""");
				host_row.enabled = active;
				this.save_file ();
			} catch (RegexError regex_error) {

				error ("Regex failed: %s", regex_error.message);
			}
		}

		public void set_ip_address (RegexHostRowIpv4 modRegex, string ip_address, Models.HostRow host_row) throws InvalidArgument {

			this.valide_ipv4_address (ip_address);

			try {

				host_row.row = modRegex.replace (host_row.row, -1, 0, """\g<enabled>""" + ip_address + """\g<divider>\g<hostname>""");
				host_row.ip_address = ip_address;
				this.save_file ();
			} catch (RegexError regex_error) {

				GLib.error ("set_ip_address - regex failed: %s", regex_error.message);
			}
		}

		public void set_hostname (RegexHostRowIpv4 modRegex, string hostname, Models.HostRow host_row) throws InvalidArgument {

			this.validate_host_name (hostname);

			try {

				host_row.row = modRegex.replace (host_row.row, -1, 0, """\g<enabled>\g<ipaddress>\g<divider>""" + hostname);
				host_row.hostname = hostname;
				this.save_file ();
			} catch (RegexError regex_error) {

				GLib.error ("set_hostname - regex failed: %s", regex_error.message);
			}
		}

		private void validate_host_name (string hostname) throws InvalidArgument {

			if (!Regex.match_simple ("^" + Config.hostname_regex_str () + "$", hostname)) {

				throw new InvalidArgument.HOSTNAME ("Invalid hostname format");
			}
		}

		private void valide_ipv4_address (string ipaddress) throws InvalidArgument {

			if (!Regex.match_simple ("^" + Config.ipv4_address_regex_str () + "$", ipaddress)) {

				throw new InvalidArgument.IPADDRESS ("Invalid IPv4 address format.");
			}
		}

		private void valide_ipv6_address (string ipaddress) throws InvalidArgument {

			if (!Regex.match_simple ("^" + Config.ipv6_address_regex_str () + "$", ipaddress)) {

				throw new InvalidArgument.IPADDRESS ("Invalid IPv6 address format.");
			}
		}
	}
}