using GLib;

namespace HostsManager.Services {

	class RegexHostRowIpv4 : Regex {

		public RegexHostRowIpv4 (Value ipaddress_arg = "", Value hostname_arg = "") {

			string ip_v4_address = (string) ipaddress_arg != "" ? Regex.escape_string ((string) ipaddress_arg) : Config.ipv4_address_regex_str ();
			string hostname = (string) hostname_arg != "" ? Regex.escape_string ((string) hostname_arg) : Config.hostname_regex_str ();

			try {

				string regex_str_ipv4 = """(?P<enabled>#?)\s?(?P<row>(?P<ipaddress>""" + ip_v4_address + """)(?P<divider>\s+)(?P<hostname>.*""" + hostname + "))";

				base (regex_str_ipv4);
			} catch (Error e) {

				error ("RegexHostRow failed: %s", e.message);
			}
		}
	}
}