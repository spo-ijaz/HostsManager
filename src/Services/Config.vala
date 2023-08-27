namespace HostsManager.Services {

	class Config {

		public static string hostfile_path() {

			if (AppConfig.PROFILE == "development") {

				return Environment.get_home_dir() + "/hosts";
			}

			return "/etc/hosts";
		}

		public static string ipaddress_regex_str() {

			return """[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}""";
		}

		public static string hostname_regex_str() {

			return "[a-zA-Z0-9.-]+";
		}
	}
}