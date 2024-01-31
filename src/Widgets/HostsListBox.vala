using Gtk;
using Gdk;

namespace HostsManager.Widgets {

	class HostsListBox : Widget {

		public MainWindow main_window { get; construct; }
		public Services.HostsFile hosts_file_service  { get; construct; }
		public ListBox list_box { get; construct; }

		private GLib.List<ListBox> group_list_box;

		private string search_entry_text;

		construct {

			this.group_list_box = new GLib.List<ListBox>();

			this.list_box = new ListBox();
			this.list_box.bind_model(this.hosts_file_service.rows_list_store, create_widget_func);

			this.search_entry_text = "";
			this.list_box.set_filter_func(this.filter_list_box);
		}

		public HostsListBox(MainWindow main_window, Services.HostsFile hosts_file_service) {
			Object(
			       main_window: main_window,
			       hosts_file_service: hosts_file_service
			);
		}

		public void set_search_entry_text(string search_entry_text) {

			this.search_entry_text = search_entry_text;
			this.list_box.invalidate_filter();
			this.group_list_box.foreach ((list_box) => {
				list_box.invalidate_filter();
			});

		}

		private Gtk.Widget create_widget_func(Object item) {
			
			Models.HostRow host_row = item as Models.HostRow;

			if (host_row.row_type == Models.HostRow.RowType.HOST_GROUP) {

				// Erreur de segmentation (core dumped) - if not set here
				this.search_entry_text = "";

				Widgets.HostGroupExpanderRow expander_row = new Widgets.HostGroupExpanderRow(this.main_window, host_row);
				
				ListBox group_hosts_list_box = new ListBox();
				group_hosts_list_box.bind_model(host_row.rows_list_store, this.create_widget_func);
				group_hosts_list_box.set_filter_func(this.filter_list_box);
				this.group_list_box.append(group_hosts_list_box);
				
				expander_row.add_row(group_hosts_list_box);

				return expander_row;

				//  return  new Widgets.HostGroupExpanderRow(this.main_window, host_row);
			} 
			else if (host_row.row_type == Models.HostRow.RowType.HOST) {

				return new Widgets.HostActionRow(this.main_window, host_row);
			} else  if (host_row.row_type == Models.HostRow.RowType.COMMENT) {

				return new Widgets.CommentActionRow(this.main_window, host_row);
			} else {

				return new Gtk.ListBoxRow();
			}
		}

		private bool filter_list_box(ListBoxRow list_box_row) {

			if (this.search_entry_text.length <= 2) {

				return true;
			}

			Regex search_regexp = new Regex(this.search_entry_text);

			if (list_box_row.name == "HostsManagerWidgetsHostActionRow") {

				Widgets.HostActionRow host_action_row = list_box_row as Widgets.HostActionRow;
				return search_regexp.match(host_action_row.title);
			} else if (list_box_row.name == "HostsManagerWidgetsCommentActionRow") {

				Widgets.CommentActionRow comment_action_row = list_box_row as Widgets.CommentActionRow;
				return search_regexp.match(comment_action_row.title);
			}
			
			return true;
		}
	}
}