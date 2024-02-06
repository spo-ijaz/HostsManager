namespace HostsManager.Models {

	class HostRow : Object {

		public enum RowType {
			COMMENT,
			EMPTY,
			HOST_GROUP,
			HOST
		}

		public enum IPVersion {
			IPV4,
			IPV6
		}

		public uint id { get; set; }
		public uint parent_id { get; set; }
		public RowType row_type { get; set; }
		public bool enabled { get; set; }
		public string hostname { get; set; }
		public string ip_address { get; set; }
		public IPVersion ip_version { get; set; }
		public string host_group_name { get; set; }
		public string comment { get; set; }
		public string row { get; set; }

		public HostRow (uint id, uint parent_id, RowType row_type, bool enabled, string ip_address, IPVersion ip_version, string hostname, string host_group_name, string comment, string row) {

			this.id = id;
			this.parent_id = parent_id;
			this.row_type = row_type;
			this.enabled = enabled;
			this.ip_address = ip_address;
			this.ip_version = ip_version;
			this.hostname = hostname;
			this.host_group_name = host_group_name;
			this.comment = comment;
			this.row = row;
		}
	}
}