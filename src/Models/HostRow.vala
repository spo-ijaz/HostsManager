namespace HostsManager {

	class HostRow : Object {

		public bool enabled { get; set; }
		public string host { get; set; }
		public string ip_address { get; set; }

		public HostRow(bool enabled, string host, string ip_address) {

			this.enabled = enabled;
			this.host = host;
			this.ip_address = ip_address;
		}
	}
}
