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

		public void insert_after_position (Models.HostRow dragged_host_row, Models.HostRow drop_target_host_row, bool ignore_parent_id = false) {

			debug ("----");
			debug ("dragged_host_row: %s %s %s", dragged_host_row.hostname, dragged_host_row.host_group_name, dragged_host_row.comment);
			debug ("drop_target_host_row: %s %s %s", drop_target_host_row.hostname, drop_target_host_row.host_group_name, drop_target_host_row.comment);


			// If we drop on a hosts group, append to after this group.
			if (drop_target_host_row.row_type == Models.HostRow.RowType.HOST_GROUP) {

				debug ("> drop_target_host_row.row_type == Models.HostRow.RowType.HOST_GROUP");
				Models.HostRow append_after_this_host_row = new Models.HostRow (0, 0, Models.HostRow.RowType.EMPTY, true, "", Models.HostRow.IPVersion.IPV4, "", "", "", "");
				this.rows.foreach ((host_row) => {

					if (host_row.parent_id == drop_target_host_row.id) {

						debug ("looping %s %s %s", host_row.hostname, host_row.host_group_name, host_row.comment);
						append_after_this_host_row = host_row;
					}
				});

				this.insert_after_position (dragged_host_row, append_after_this_host_row, true);

				this.debug_list ();
			} else {


				debug ("> drop_target_host_row.row_type == Models.HostRow.RowType.HOST_GROUP");

				int drop_target_host_index = this.rows.index (drop_target_host_row);
				int dragged_host_row_index = this.rows.index (dragged_host_row);

				if (dragged_host_row_index > drop_target_host_index) {
					drop_target_host_index++;
				}

				debug ("drop_target_host_index: %u", drop_target_host_index);
				debug ("dragged_host_row_index: %u", dragged_host_row_index);

				this.rows.remove (dragged_host_row);
				this.items_changed (dragged_host_row_index, 1, 0);

				this.rows.insert (dragged_host_row, drop_target_host_index);
				this.items_changed (drop_target_host_index, 0, 1);

				// If we drop on a hosts group child row, update the model.
				if (!ignore_parent_id && drop_target_host_row.parent_id > 0) {
					debug ("> drop_target_host_row.parent_id > 0 -> %u | %s %s %s", drop_target_host_row.parent_id, drop_target_host_row.hostname, drop_target_host_row.host_group_name, drop_target_host_row.comment);
					dragged_host_row.parent_id = drop_target_host_row.id;
				} else {
					dragged_host_row.parent_id = 0;
				}

				// If we drag a hosts group, move all childs.
				if (dragged_host_row.row_type == Models.HostRow.RowType.HOST_GROUP) {
					debug ("> dragged_host_row.row_type == Models.HostRow.RowType.HOST_GROUP");

					this.rows.foreach ((host_row) => {

						if (host_row.parent_id == dragged_host_row.id) {
							debug ("moving %s %s %s", host_row.hostname, host_row.host_group_name, host_row.comment);
							this.insert_after_position (host_row, drop_target_host_row);
						}
					});
				}
			}
		}

		public void remove_all () {

			this.rows.foreach ((host_row) => {
				this.rows.remove (host_row);
			});
		}

		private void debug_list () {

			debug ("======================================================================================");

			this.rows.foreach ((host_row) => {

				debug ("#%i (%u) %s %s %s", (int) this.rows.index (host_row), host_row.id, host_row.hostname, host_row.host_group_name, host_row.comment);
			});
			debug ("======================================================================================");
		}
	}
}