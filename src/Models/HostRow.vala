namespace HostsManager.Models {

	class HostRow : Object {

		public enum RowType {
			EMPTY,
			COMMENT,
			HOST
		}

		public uint line_number { get; set; }
		public RowType row_type { get; set; }
		public bool enabled { get; set; }
		public string hostname { get; set; }
		public string ip_address { get; set; }
		public string comment { get; set; }
		public uint previous_position { get; set; } // Used when we want to
		public string previous_full_row { get; set; } // undo a delete host

		public HostRow (uint line_number, RowType row_type, bool enabled, string ip_address, string hostname, string comment, string previous_full_row) {

			this.line_number = line_number;
			this.row_type = row_type;
			this.enabled = enabled;
			this.ip_address = ip_address;
			this.hostname = hostname;
			this.comment = comment;
			this.previous_full_row = previous_full_row;
		}
	}
}
