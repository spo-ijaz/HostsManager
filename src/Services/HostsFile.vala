using GLib;

public errordomain InvalidArgument {
	IPADDRESS,
	HOSTNAME,
}

namespace HostsManager.Services {

	class HostsFile {

		private string hostsFileContent;
		private File host_file;
		private File host_file_bkp;

		public HostsFile () {

			string host_file_path = Config.hostfile_path ();
			this.host_file = File.new_for_path (host_file_path);
			this.host_file_bkp = File.new_for_path (host_file_path + ".bkp");

			try {

				debug ("Backup of \"%s\" -> \"%s\" ", host_file.get_path (), host_file_bkp.get_parse_name ());
				host_file.copy (host_file_bkp, FileCopyFlags.OVERWRITE);
			} catch (Error e) {

				error ("Error: %s", e.message);
			}

			this.read_file ();
		}

		public MatchInfo get_entries () {

			MatchInfo entries;
			HostsRegex regex = new HostsRegex ();
			regex.match (this.hostsFileContent, 0, out entries);

			return entries;
		}

		public void set_enabled (HostsRegex modRegex, bool active) {

			try {

				this.hostsFileContent = modRegex.replace (this.hostsFileContent, -1, 0, active ? """\n#\g<row>""" : """\g<row>""");
				this.save_file ();
			} catch (RegexError e) {

				error ("Regex failed: %s", e.message);
			}
		}

		public void set_ip_address (HostsRegex modRegex, string ipaddress) throws InvalidArgument {

			this.valide_ip_address (ipaddress);

			try {

				this.hostsFileContent = modRegex.replace (this.hostsFileContent, -1, 0, """\g<enabled>""" + ipaddress + """\g<divider>\g<hostname>""");
				this.save_file ();
			} catch (RegexError e) {

				GLib.error ("Regex failed: %s", e.message);
			}
		}

		public void set_hostname (HostsRegex modRegex, string hostname) throws InvalidArgument {

			this; validate_host_name (hostname);

			try {

				this.hostsFileContent = modRegex.replace (this.hostsFileContent, -1, 0, """\g<enabled>\g<ipaddress>\g<divider>""" + hostname);
				this.save_file ();
			} catch (RegexError e) {

				GLib.error ("Regex failed: %s", e.message);
			}
		}

		public void add (string ipaddress, string hostname) throws InvalidArgument {

			this.valide_ip_address (ipaddress);
			this.validate_host_name (hostname);

			this.hostsFileContent = this.hostsFileContent + "\n" + ipaddress + " " + hostname;
			this.save_file ();
		}

		public void remove (HostsRegex modRegex) {

			try {

				this.hostsFileContent = modRegex.replace (this.hostsFileContent, -1, 0, "");
				this.save_file ();
			} catch (RegexError e) {

				error ("Regex failed: %s", e.message);
			}
		}

		public void restore_from_backup () {

			try {

				debug ("Restauring backup of \"%s\" -> \"%s\" ", host_file_bkp.get_path (), host_file.get_parse_name ());
				host_file_bkp.copy (host_file, FileCopyFlags.OVERWRITE);
				this.read_file ();
			} catch (Error e) {

				error ("Error: %s", e.message);
			}
		}

		private void read_file () {

			try {

				FileUtils.get_contents (Config.hostfile_path (), out this.hostsFileContent, null);
			} catch (Error e) {

				error ("Error: %s", e.message);
			}
		}

		private void save_file () {

			try {

				FileUtils.set_contents (Config.hostfile_path (), this.hostsFileContent, this.hostsFileContent.length);
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