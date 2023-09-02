namespace HostsManager.Models {

	class HostRow : Object {

		public enum RowType {
			EMPTY,
			COMMENT,
			HOST
		}

		public RowType row_type { get; set; }
		public bool enabled { get; set; }
		public string hostname { get; set; }
		public string ip_address { get; set; }
		public string comment { get; set; }
		public uint previous_position { get; set; } // Used when we want to undo a delete host

		public HostRow (RowType row_type, bool enabled, string ip_address, string hostname, string comment) {

			this.row_type = row_type;
			this.enabled = enabled;
			this.ip_address = ip_address;
			this.hostname = hostname;
			this.comment = comment;
		}
	}
}