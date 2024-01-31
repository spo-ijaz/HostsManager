using GLib;

namespace HostsManager.Services {

	class RegexHostRow : Regex {

		public RegexHostRow (Value ipaddress_arg = "", Value hostname_arg = "") {

			string ipaddress = (string) ipaddress_arg != "" ? Regex.escape_string ((string) ipaddress_arg) : Config.ipaddress_regex_str ();
			string hostname = (string) hostname_arg != "" ? Regex.escape_string ((string) hostname_arg) : Config.hostname_regex_str ();

			try {

				string regexStr = """(?P<enabled>#?)\s?(?P<row>(?P<ipaddress>""" + ipaddress + """)(?P<divider>\s+)(?P<hostname>""" + hostname + "))";
				// debug (regexStr);
				base (regexStr);
			} catch (Error e) {

				error ("RegexHostRow failed: %s", e.message);
			}
		}
	}
}
