using Adw;
using GLib;

public errordomain InvalidArgument {
	IPADDRESS,
	HOSTNAME,
}

namespace HostsManager.Services {

	class HostsFile : Object {

		public MainWindow main_window { get; construct; }
		public Array<string> content { get; construct; }
		private File host_file;
		private File host_file_bkp;
		private FileMonitor host_file_monitor;

		construct {

			this.content = new Array<string> ();

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

			this.read_file ();
		}

		public HostsFile (HostsManager.MainWindow main_window) {

			Object (
			        main_window: main_window
			);
		}

		// public MatchInfo get_entries () {

		// MatchInfo entries;
		// HostsRegex regex = new HostsRegex ();
		////  regex.match (this.hosts_file_content, 0, out entries);

		// return entries;
		// }

		// public uint8[] get_rows () {

		// return this.hosts_file_content;
		// }

		public void set_enabled (HostsRegex modRegex, bool active) {

			// try {

			// this.hosts_file_content = modRegex.replace (this.hosts_file_content, -1, 0, active ? """\n#\g<row>""" : """\g<row>""");
			// this.save_file ();
			// } catch (RegexError regex_error) {

			// error ("Regex failed: %s", regex_error.message);
			// }
		}

		public void set_ip_address (HostsRegex modRegex, string ipaddress) throws InvalidArgument {

			// this.valide_ip_address (ipaddress);

			// try {

			// this.hosts_file_content = modRegex.replace (this.hosts_file_content, -1, 0, """\n\g<enabled>""" + ipaddress + """\g<divider>\g<hostname>""");
			// this.save_file ();
			// } catch (RegexError regex_error) {

			// GLib.error ("Regex failed: %s", regex_error.message);
			// }
		}

		public void set_hostname (HostsRegex modRegex, string hostname, uint index) throws InvalidArgument {

			this.validate_host_name (hostname);

			try {

				this.content.insert_val (index, modRegex.replace (this.content.index (index), -1, 0, """\n\g<enabled>\g<ipaddress>\g<divider>""" + hostname));
				this.save_file ();
			} catch (RegexError regex_error) {

				GLib.error ("Regex failed: %s", regex_error.message);
			}
		}

		public void add (string ipaddress, string hostname, bool save = true) throws InvalidArgument {

			// this.valide_ip_address (ipaddress);
			// this.validate_host_name (hostname);

			// this.hosts_file_content = this.hosts_file_content + "\n" + ipaddress + " " + hostname;

			// if (save == true) {

			// this.save_file ();
			// }
		}

		public void remove (HostsRegex modRegex, bool save) {

			try {

				// this.hosts_file_content = modRegex.replace (this.hosts_file_content, -1, 0, "");
				// if (save == true) {

				// this.save_file ();
				// }
			} catch (RegexError regex_error) {

				error ("Regex failed: %s", regex_error.message);
			}
		}

		public void restore_from_backup () {

			// try {

			// debug ("Restauring backup of \"%s\" -> \"%s\" ", host_file_bkp.get_path (), host_file.get_path ());
			// host_file_bkp.copy (host_file, FileCopyFlags.OVERWRITE);
			// this.read_file ();

			// this.main_window.toast.set_title (_("Host file restored."));
			// this.main_window.toast_overlay.add_toast (this.main_window.toast);
			// } catch (Error e) {

			// this.main_window.toast.set_title (_("Unable to restore from backup file: ") + host_file_bkp.get_path ());
			// this.main_window.toast_overlay.add_toast (this.main_window.toast);
			// error ("Error: %s", e.message);
			// }
		}

		public void read_file () {

			try {

				var dis = new DataInputStream (this.host_file.read ());

				string row;
				while ((row = dis.read_line (null)) != null) {

					this.content.append_val (row);
				}
			} catch (Error e) {

				error ("Error to read file: %s", e.message);
			}
		}

		public void save_file () {

			try {

				// TODO: There's probably a better way to do that.
				string all_rows = "";
				foreach (string row in this.content) {
					all_rows += row+"\n";
				}

				StringBuilder rows_string_builder = new StringBuilder (all_rows);

				this.host_file.replace_contents (rows_string_builder.data, null, false, FileCreateFlags.NONE, null);

				this.main_window.toast.set_title (_("Host file updated."));
				this.main_window.toast_overlay.add_toast (this.main_window.toast);
			} catch (Error e) {

				error ("Unable to save file: %s", e.message);
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