namespace HostsManager.Models {

	class HostRow : Object {

		public bool complete { get; set; }
		public bool enabled { get; set; }
		public string hostname { get; set; }
		public string ip_address { get; set; }

		public HostRow (bool complete, bool enabled, string ip_address, string hostname) {

			this.complete = complete;
			this.enabled = enabled;
			this.ip_address = ip_address;
			this.hostname = hostname;
		}
	}
}
