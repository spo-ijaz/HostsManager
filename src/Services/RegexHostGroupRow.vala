using GLib;

namespace HostsManager.Services {

	class RegexHostGroupRow : Regex {

		public RegexHostGroupRow (Value host_group_name_arg = "") {

			string host_group_name = (string) host_group_name_arg != "" ? Regex.escape_string ((string) host_group_name_arg) : Config.host_group_name_regex_str ();

			try {

				string regexStr = """##\s(?P<row>(?P<host_group_name>""" + host_group_name + """))""";
				// debug (regexStr);
				base (regexStr);
			} catch (Error e) {

				error ("RegexHostGroupRow failed: %s", e.message);
			}
		}
	}
}
