using GLib;

namespace HostsManager.Services {

	class RegexHostRowIpv6 : Regex {

		public RegexHostRowIpv6 (Value ipaddress_arg = "", Value hostname_arg = "") {

			string ip_v6_address = (string) ipaddress_arg != "" ? Regex.escape_string ((string) ipaddress_arg) : Config.ipv6_address_regex_str ();
			string hostname = (string) hostname_arg != "" ? Regex.escape_string ((string) hostname_arg) : Config.hostname_regex_str ();

			try {

				string regex_str_ipv6 = """(?P<enabled>#?)\s?(?P<row>(?P<ipaddress>""" + ip_v6_address + """)(?P<divider>\s+)(?P<hostname>.*""" + hostname + "))";

				base (regex_str_ipv6);
			} catch (Error e) {

				error ("RegexHostRow failed: %s", e.message);
			}
		}
	}
}