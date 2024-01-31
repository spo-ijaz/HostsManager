using Gtk;
using Gdk;

namespace HostsManager.Widgets {

	class HostsListBox : Gtk.Widget {

		public MainWindow main_window { get; construct; }
		public Services.HostsFile hosts_file_service  { get; construct; }
		public Gtk.ListBox list_box { get; construct; }

		construct {

			this.list_box = new Gtk.ListBox();
			// this.append(this.list_box);
		}

		public HostsListBox(MainWindow main_window, Services.HostsFile hosts_file_service) {
			Object(
			       main_window: main_window,
			       hosts_file_service: hosts_file_service
			);
		}

		/*

		        1. populate (0, this.list_box, false);


		        func populate(uint idx, Widget containerWidget, bool inGroup) {

		                for (; idx < list_store.n_items; idx++) {

		                        HostRow row = list_store.get_item(idx)

		                        if row_type = group

		                                if inGroup {
		                                        this.list_box.append(containerWidget)
		                                }

		                                populate(idx++, new ExpanderRow, true)

		                        else
		                                addListBoxRow(row, containerWidget)
		                                populate(idx++, containerWidget, inGroup);

		                }


		        }


		        func addListBoxRow(HostRow row, Widget containerWidget) {

		                Widget list_box_row;

		                if row_type = host {

		                        list_box_row = new HostRow (row)
		                } else if row_type = comment {

		                        list_box_row = new CommentRow (row)
		                }

		                if widget type of Adw.expanderRow
		                        (containerWidget as ExpanderRow).add_row(list_box_row)
		                else
		                        (containerWidget as ListBox).append(list_box_row)
		        }

		 */


		public void populate(uint idx, Gtk.Widget container_widget, bool in_group) {

			debug("| idx: %u", idx);

			if (this.hosts_file_service.rows_list_store.n_items == idx) {

				this.list_box.append(container_widget);
				return;
			}

			Models.HostRow host_row = this.hosts_file_service.rows_list_store.get_item(idx) as Models.HostRow;
			if (host_row.row_type == Models.HostRow.RowType.HOST_GROUP) {

				if (in_group) {

					this.list_box.append(container_widget);
				}

				populate(++idx, new Widgets.HostGroupExpanderRow(this.main_window, host_row), true);
			} else {

				_addListBoxRow(host_row, container_widget);
				populate(++idx, container_widget, in_group);
			}
		}

		private void _addListBoxRow(Models.HostRow host_row, Gtk.Widget container_widget) {

			Gtk.Widget list_box_row;

			if (host_row.row_type == Models.HostRow.RowType.HOST) {

				this._addToContainerWidget(new Widgets.HostActionRow(this.main_window, host_row), container_widget);
			} else if (host_row.row_type == Models.HostRow.RowType.COMMENT) {

				this._addToContainerWidget(new Widgets.CommentActionRow(this.main_window, host_row), container_widget);
			}
		}

		private void _addToContainerWidget(Gtk.Widget list_box_row, Gtk.Widget container_widget) {

			if (container_widget.name == "HostsManagerWidgetsHostGroupExpanderRow") {

				(container_widget as Adw.ExpanderRow).add_row(list_box_row);
			} else {

				(container_widget as Gtk.ListBox).append(list_box_row);
			}
		}
	}
}