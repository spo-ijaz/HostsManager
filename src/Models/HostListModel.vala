using GLib;

namespace HostsManager.Models {

	class HostListModel : GLib.ListModel, Object {

		private Array<Models.HostRow> rows;

		construct {
			this.rows = new Array<Models.HostRow> ();
		}

		public HostListModel () {
		}

		public void append(Models.HostRow host_row) {
			
			this.rows.append_val (host_row);
		}

		public GLib.Object? get_item (uint position) {
			
			return this.rows.index (position);
		}
		public GLib.Type get_item_type () {

			return typeof (Models.HostRow);
		}

		public uint get_n_items () {
			
			return this.rows.length;
		}

		public Object? get_object (uint position) {

			return this.rows.index (position);
		}

		public void insert_after_position(uint position, Models.HostRow host_row) {

			debug ("insert_after_position | position %u | %s - %s | %u", position, host_row.hostname, host_row.comment, host_row.id);


			this.rows.insert_val (position+1, host_row);
			this.rows.remove_index (host_row.id+1);

			//  this.rows.prepend_val (host_row);
			this.items_changed (position+1, 0, 1);
			this.items_changed (host_row.id+1, 1, 0);
		}

		public void remove_all () {

			this.rows.remove_range (0, rows.length);
		}
	}
}