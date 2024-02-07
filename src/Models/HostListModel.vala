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

		public void insert_after_position (Models.HostRow dragged_source_host_row, Models.HostRow drop_target_host_row, bool ignore_parent_id = false) {

			debug ("----");
			debug ("| dragged_host_row    : %u (%u) | %s %s %s", dragged_source_host_row.id, dragged_source_host_row.parent_id, dragged_source_host_row.hostname, dragged_source_host_row.host_group_name, dragged_source_host_row.comment);
			debug ("| drop_target_host_row: %u (%u) | %s %s %s", drop_target_host_row.id, drop_target_host_row.parent_id, drop_target_host_row.hostname, drop_target_host_row.host_group_name, drop_target_host_row.comment);

			// If we drop on a hosts group, append the dragged row after this group.
			if (drop_target_host_row.row_type == Models.HostRow.RowType.HOST_GROUP) {

				debug ("[ drop_target_host_row.row_type == Models.HostRow.RowType.HOST_GROUP ]");
				Models.HostRow append_after_this_host_row = new Models.HostRow (0, 0, Models.HostRow.RowType.EMPTY, true, "", Models.HostRow.IPVersion.IPV4, "", "", "", "");
				this.rows.foreach ((host_row) => {

					if (host_row.parent_id == drop_target_host_row.id) {

						debug ("looping %s %s %s", host_row.hostname, host_row.host_group_name, host_row.comment);
						append_after_this_host_row = host_row;
					}
				});

				this.insert_after_position (dragged_source_host_row, append_after_this_host_row, true);
			}
			// Handle a comment / action row  drop, or move the main host group row.
			else if (dragged_source_host_row.row_type != Models.HostRow.RowType.HOST_GROUP) {

				debug ("[ move_host_group || drop_target_host_row.row_type != Models.HostRow.RowType.HOST_GROUP ]");

				this.insert_dragged_source_after_drop_target (dragged_source_host_row, drop_target_host_row);

				// If we drop on a hosts group child row, update the model.
				if (!ignore_parent_id && drop_target_host_row.parent_id > 0) {

					debug ("[ drop_target_host_row.parent_id > 0 ] drop %u vs drag %u | %s %s %s", drop_target_host_row.parent_id, dragged_source_host_row.parent_id, drop_target_host_row.hostname, drop_target_host_row.host_group_name, drop_target_host_row.comment);
					dragged_source_host_row.parent_id = drop_target_host_row.id;
				}
			}
			// If we drag a hosts group, move all childs.
			else if (dragged_source_host_row.row_type == Models.HostRow.RowType.HOST_GROUP) {

				debug ("[ dragged_host_row.row_type == Models.HostRow.RowType.HOST_GROUP ]");

				List<Models.HostRow> host_groups_rows = new List<Models.HostRow> ();
				this.rows.foreach ((host_row) => {

					if (host_row.parent_id == dragged_source_host_row.id) {

						host_groups_rows.append (host_row);
					}
				});

				int drop_target_host_row_index = this.rows.index (drop_target_host_row);
				int dragged_source_host_row_index = this.rows.index (dragged_source_host_row);


				// Dragging bottom -> top
				if (drop_target_host_row_index < dragged_source_host_row_index) {

					drop_target_host_row = this.rows.nth_data (drop_target_host_row_index + 1);
				}

				debug ("%u %s", drop_target_host_row_index, drop_target_host_row.comment);

				if (drop_target_host_row_index > dragged_source_host_row_index) {

					host_groups_rows.reverse ();
				}

				host_groups_rows.foreach ((host_row) => {

					debug ("> moving %s %s %s", host_row.hostname, host_row.host_group_name, host_row.comment);
					this.insert_dragged_source_after_drop_target (host_row, drop_target_host_row);
				});


				// Dragging bottom -> top
				if (drop_target_host_row_index < dragged_source_host_row_index) {

					drop_target_host_row = this.rows.find (host_groups_rows.first ().data).data as Models.HostRow;
				}

				this.insert_dragged_source_after_drop_target (dragged_source_host_row, drop_target_host_row);

				host_groups_rows = null;
			}
		}

		public void remove_all () {

			this.rows.foreach ((host_row) => {
				this.rows.remove (host_row);
			});
		}

		private void insert_dragged_source_after_drop_target (Models.HostRow dragged_source_host_row, Models.HostRow drop_target_host_row) {

			int drop_target_host_row_index = this.rows.index (drop_target_host_row);
			int dragged_source_host_row_index = this.rows.index (dragged_source_host_row);

			// if (moving_host_row_from_group) {
			// drop_target_host_row_index += 1;
			// }

			this.rows.remove (dragged_source_host_row);
			this.items_changed (dragged_source_host_row_index, 1, 0);

			if (this.rows.nth_data (drop_target_host_row_index) != null) {

				debug ("> insert at %u", drop_target_host_row_index);
				this.rows.insert (dragged_source_host_row, drop_target_host_row_index);
				this.items_changed (drop_target_host_row_index, 0, 1);
			} else {

				debug ("> append to the end");
				this.rows.append (dragged_source_host_row);
				this.items_changed (this.rows.index (dragged_source_host_row), 0, 1);
			}
		}
	}
}