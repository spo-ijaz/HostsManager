using GLib;

namespace HostsManager.Models {

	class HostRowListModel : GLib.ListModel, Object {

		// public signal
		private SList<Models.HostRowModel> rows;

		construct {
			this.rows = new SList<Models.HostRowModel> ();
		}

		public HostRowListModel () {
		}

		public void append (Models.HostRowModel host_row) {

			this.rows.append (host_row);

			int host_row_index = this.rows.index (host_row);
			this.items_changed (host_row_index, 0, 1);
		}

		public GLib.Object? get_item (uint position) {

			return this.rows.nth_data (position);
		}
		public GLib.Type get_item_type () {

			return typeof (Models.HostRowModel);
		}

		public uint get_n_items () {

			return this.rows.length ();
		}

		public void insert_after_host_row (Models.HostRowModel source_host_row, Models.HostRowModel target_host_row, bool ignore_host_row_parent_id = false, bool from_drag_and_drop = true) {

			// debug ("----");
			// debug ("| dragged_host_row    : %u (%u) | %s %s %s", dragged_source_host_row.id, dragged_source_host_row.parent_id, dragged_source_host_row.hostname, dragged_source_host_row.host_group_name, dragged_source_host_row.comment);
			// debug ("| drop_target_host_row: %u (%u) | %s %s %s", drop_target_host_row.id, drop_target_host_row.parent_id, drop_target_host_row.hostname, drop_target_host_row.host_group_name, drop_target_host_row.comment);

			// If we drop on a hosts group, append the dragged row after this group if this group is not empty.
			if (target_host_row.row_type == Models.HostRowModel.RowType.HOST_GROUP) {

				// debug ("> Dropped on a host group row.");
				Models.HostRowModel append_after_this_host_row = new Models.HostRowModel (0, 0, Models.HostRowModel.RowType.EMPTY, true, "", Models.HostRowModel.IPVersion.IPV4, "", "", "", "");
				int num_hosts_group_childs = 0;
				this.rows.foreach ((host_row) => {

					if (host_row.parent_id == target_host_row.id) {

						// debug ("looping %s %s %s", host_row.hostname, host_row.host_group_name, host_row.comment);
						append_after_this_host_row = host_row;

						if (host_row.row_type != Models.HostRowModel.RowType.EMPTY) {

							num_hosts_group_childs++;
						}
					}
				});

				if (num_hosts_group_childs > 0) {

					this.insert_after_host_row (source_host_row, append_after_this_host_row, true, from_drag_and_drop);
				} else {

					// debug ("> inserting into empy hots group.");
					source_host_row.parent_id = target_host_row.id;
					this.insert_host_row (source_host_row, target_host_row, from_drag_and_drop);
				}
			}
			// Handle a comment / action row  drop, or move the main host group row.
			else if (source_host_row.row_type != Models.HostRowModel.RowType.HOST_GROUP) {

				// debug ("> Dropped on a comment or action row.");

				// If we drop on a hosts group child row, update the model.
				if (!ignore_host_row_parent_id && target_host_row.parent_id > 0) {

					// debug ("> It's a row from a hosts group | parent_id: %u", drop_target_host_row.parent_id);
					source_host_row.parent_id = target_host_row.parent_id;
				}
				// When a row is dragged-out of hosts group.
				else {

					source_host_row.parent_id = 0;
				}

				this.insert_host_row (source_host_row, target_host_row, from_drag_and_drop);
			}
			// If we drag a hosts group, move all childs.
			else if (source_host_row.row_type == Models.HostRowModel.RowType.HOST_GROUP) {

				// debug ("> Moving all rows from hosts group.");

				List<Models.HostRowModel> host_groups_rows = new List<Models.HostRowModel> ();
				this.rows.foreach ((host_row) => {

					if (host_row.parent_id == source_host_row.id) {

						host_groups_rows.append (host_row);
					}
				});

				int drop_target_host_row_index = this.rows.index (target_host_row);
				int dragged_source_host_row_index = this.rows.index (source_host_row);


				// Dragging bottom -> top
				if (drop_target_host_row_index < dragged_source_host_row_index) {

					target_host_row = this.rows.nth_data (drop_target_host_row_index + 1);
				}

				// debug ("%u %s", drop_target_host_row_index, drop_target_host_row.comment);

				if (drop_target_host_row_index > dragged_source_host_row_index) {

					host_groups_rows.reverse ();
				}

				host_groups_rows.foreach ((host_row) => {

					// debug ("> moving %s %s %s", host_row.hostname, host_row.host_group_name, host_row.comment);
					this.insert_host_row (host_row, target_host_row, from_drag_and_drop);
				});


				// Dragging bottom -> top
				if (drop_target_host_row_index < dragged_source_host_row_index) {

					target_host_row = this.rows.find (host_groups_rows.first ().data).data as Models.HostRowModel;
				}

				this.insert_host_row (source_host_row, target_host_row, from_drag_and_drop);

				host_groups_rows = null;
			}
		}

		public void remove (Models.HostRowModel host_row) {

			int host_row_index = this.rows.index (host_row);

			if (host_row != null) {

				this.rows.remove (host_row);
				this.items_changed (host_row_index, 1, 0);
			}

			if (host_row.row_type == Models.HostRowModel.RowType.HOST_GROUP) {

				this.rows.foreach ((child_host_row) => {

					if (child_host_row.parent_id == host_row.id) {

						int sub_host_row_index = this.rows.index (child_host_row);
						this.rows.remove (child_host_row);
						this.items_changed (sub_host_row_index, 1, 0);
					}
				});
			}
		}

		public void remove_all () {

			List<Models.HostRowModel> host_rows_to_remove = new List<Models.HostRowModel> ();
			this.rows.foreach ((host_row) => {
				host_rows_to_remove.append (host_row);
			});

			host_rows_to_remove.foreach ((host_row) => {

				int host_row_index = this.rows.index (host_row);
				this.rows.remove (host_row);
				this.items_changed (host_row_index, 1, 0);
			});

			host_rows_to_remove = null;
		}

		private void insert_host_row (Models.HostRowModel source_host_row, Models.HostRowModel target_host_row, bool from_drag_and_drop = true) {

			int target_host_row_index = this.rows.index (target_host_row);
			int source_host_row_index = this.rows.index (source_host_row);

			if (from_drag_and_drop) {

				this.rows.remove (source_host_row);
				this.items_changed (source_host_row_index, 1, 0);
			}

			if (this.rows.nth_data (target_host_row_index) != null) {

				// debug ("> insert at %u", drop_target_host_row_index);
				this.rows.insert (source_host_row, target_host_row_index);
				this.items_changed (target_host_row_index, 0, 1);
			} else {

				// debug ("> append to the end");
				this.rows.append (source_host_row);
				this.items_changed (this.rows.index (source_host_row), 0, 1);
			}
		}
	}
}