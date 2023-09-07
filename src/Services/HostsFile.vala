using Adw;
using GLib;

public errordomain InvalidArgument {
	IPADDRESS,
	HOSTNAME,
}

namespace HostsManager.Services {

	class HostsFile : Object {

		public MainWindow main_window { get; construct; }
		public ListStore hosts_list_store { get; construct; }

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

		public HostsFile (HostsManager.MainWindow main_window, ListStore hosts_list_store) {

			Object (
			        main_window: main_window,
			        hosts_list_store: hosts_list_store
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

				debug ("Restauring backup of \"%s\" -> \"%s\" ", host_file_bkp.get_path (), host_file.get_path ());
				this.hosts_list_store.remove_all ();
				host_file_bkp.copy (host_file, FileCopyFlags.OVERWRITE);
				this.read_file ();

				this.main_window.toast.set_title (_("Host file restored."));
				this.main_window.toast_overlay.add_toast (this.main_window.toast);
			} catch (Error e) {

				this.main_window.toast.set_title (_("Unable to restore from backup file: ") + host_file_bkp.get_path ());
				this.main_window.toast_overlay.add_toast (this.main_window.toast);
				error ("Error: %s", e.message);
			}
		}

		public void read_file () {

			try {

				this.hosts_list_store.remove_all ();
				var data_input_stream = new DataInputStream (this.host_file.read ());

				MatchInfo match_info;
				Services.HostsRegex regex = new Services.HostsRegex ();
				string row;

				while ((row = data_input_stream.read_line (null)) != null) {

					//  debug ("row: %s", row);
					Models.HostRow host_row = new Models.HostRow (Models.HostRow.RowType.EMPTY,
					                                              false,
					                                              "",
					                                              "",
					                                              "",
					                                              row);

					if (regex.match (row, 0, out match_info)) {

						host_row.row_type = Models.HostRow.RowType.HOST;
						host_row.enabled = match_info.fetch_named ("enabled") != "#";
						host_row.ip_address = match_info.fetch_named ("ipaddress");
						host_row.hostname = match_info.fetch_named ("hostname");
					} else {

						host_row.row_type = row.length > 0 ? Models.HostRow.RowType.COMMENT : Models.HostRow.RowType.EMPTY;
						host_row.comment = row;
					}

					debug ("Append row : %s - %s | %s | ( %s )", 
					host_row.ip_address,
					host_row.hostname,
					host_row.row,
					host_row.row_type.to_string());

					this.hosts_list_store.append (host_row);
				}
			} catch (Error e) {

				error ("Error to read file: %s", e.message);
			}
		}

		public void save_file () {

			try {

				// TODO: There's probably a better way to do that.
				Models.HostRow host_row = new Models.HostRow (Models.HostRow.RowType.EMPTY,
				                                              false,
				                                              "",
				                                              "",
				                                              "",
				                                              "");

				string all_rows = "";
				for (uint idx = 0; idx < this.hosts_list_store.n_items; idx++) {

					host_row = this.hosts_list_store.get_item (idx) as Models.HostRow;

					if (host_row != null) {

						all_rows += host_row.row + "\n";
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

		public void set_enabled (HostsRegex modRegex, bool active, Models.HostRow host_row) {

			try {

				host_row.row = modRegex.replace (host_row.row, -1, 0, active ? """#\g<row>""" : """\g<row>""");
				host_row.enabled = active;
				this.save_file ();
			} catch (RegexError regex_error) {

				error ("Regex failed: %s", regex_error.message);
			}
		}

		public void set_ip_address (HostsRegex modRegex, string ip_address, Models.HostRow host_row) throws InvalidArgument {

			this.valide_ip_address (ip_address);

			try {

				host_row.row = modRegex.replace (host_row.row, -1, 0, """\g<enabled>""" + ip_address + """\g<divider>\g<hostname>""");
				host_row.ip_address = ip_address;
				this.save_file ();
			} catch (RegexError regex_error) {

				GLib.error ("Regex failed: %s", regex_error.message);
			}
		}

		public void set_hostname (HostsRegex modRegex, string hostname, Models.HostRow host_row) throws InvalidArgument {

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