using GLib;

namespace HostsManager.Models {

	class HostListModel : GLib.ListModel, Object {

		private SList<Models.HostRow> rows;

		construct {
			this.rows = new SList<Models.HostRow> ();
		}

		public HostListModel () {
		}

		public void append (Models.HostRow host_row) {

			this.rows.append (host_row);
		}

		public GLib.Object? get_item (uint position) {

			return this.rows.nth_data (position);
		}
		public GLib.Type get_item_type () {

			return typeof (Models.HostRow);
		}

		public uint get_n_items () {

			return this.rows.length ();
		}

		public Object ? get_object (uint position) {

			return this.rows.nth_data (position);
		}

		public void insert_after_position (Models.HostRow dragged_host_row, Models.HostRow drop_target_host_row) {

			debug ("dragged_host_row: %s %s %s", dragged_host_row.hostname, dragged_host_row.host_group_name, dragged_host_row.comment);
			debug ("drop_target_host_row: %s %s %s", drop_target_host_row.hostname, drop_target_host_row.host_group_name, drop_target_host_row.comment);

			int drop_target_host_index = this.rows.index (drop_target_host_row);
			int dragged_host_row_index = this.rows.index (dragged_host_row);

			if (dragged_host_row_index > drop_target_host_index) {
				drop_target_host_index++;
			}

			debug ("drop_target_host_index: %u", drop_target_host_index);
			debug ("dragged_host_row_index: %u", dragged_host_row_index);


			this.debug_list ();

			//  unowned SList<Models.HostRow> entry4 = this.rows.find_custom (dragged_host_row, strcmp);
			//  this.rows.remove_link (entry4);
			this.rows.remove (dragged_host_row);
			this.items_changed (dragged_host_row_index, 1, 0);


			this.rows.insert (dragged_host_row, drop_target_host_index);
			this.items_changed (drop_target_host_index, 0, 1);


			int dragged_host_row_index_2 = this.rows.index (dragged_host_row);
			debug ("dragged_host_row_index_2: %u", dragged_host_row_index_2);

			this.debug_list ();
		}

		public void remove_all () {

			this.rows.foreach ((host_row) => {
				this.rows.remove (host_row);
			});
		}

		private void debug_list () {

			debug ("======================================================================================");

			this.rows.foreach ((host_row) => {

				int index = this.rows.index (host_row);

				debug ("#%i (%u) %s %s %s", index, host_row.id, host_row.hostname, host_row.host_group_name, host_row.comment);
			});
			debug ("======================================================================================");
		}
	}
}