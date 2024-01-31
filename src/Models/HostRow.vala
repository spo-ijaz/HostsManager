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

		public RowType row_type { get; set; }
		public bool enabled { get; set; }
		public string hostname { get; set; }
		public string ip_address { get; set; }
		public IPVersion  ip_version { get; set; }
		public uint list_box_row_idx { get; set; }  // The index inside the Gtk.ListBox.
		public string host_group_name { get; set; }
		public string comment { get; set; }
		public string row { get; set; }
		public ListStore rows_list_store { get; set; }

		public HostRow (RowType row_type, bool enabled, string ip_address, IPVersion ip_version, string hostname, string host_group_name, string comment, uint list_box_row_idx, string row) {

			this.row_type = row_type;
			this.enabled = enabled;
			this.ip_address = ip_address;
			this.ip_version = ip_version;
			this.hostname = hostname;
			this.host_group_name = host_group_name;
			this.comment = comment;
			this.list_box_row_idx = list_box_row_idx;
			this.row = row;
		}
	}
}
