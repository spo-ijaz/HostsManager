using GLib;

namespace HostsManager.Services {

	class RegexCommentRow : Regex {

		public RegexCommentRow (Value comment_arg = "") {

			string comment = (string) comment_arg != "" ? Regex.escape_string ((string) comment_arg) : ConfigService.comment_regex_str ();

			try {

				string regexStr = """#\s(?P<row>(?P<comment>""" + comment + """))""";
				// debug (regexStr);
				base (regexStr);
			} catch (Error e) {

				error ("RegexCommentRow failed: %s", e.message);
			}
		}
	}
}