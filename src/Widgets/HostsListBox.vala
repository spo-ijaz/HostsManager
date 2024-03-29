using Gtk;
using Gdk;

namespace HostsManager.Widgets {

	class HostsListBox : Widget {

		public MainWindow main_window { get; construct; }
		public Services.HostsFileService hosts_file_service { get; construct; }
		public Models.HostRowListModel host_row_list_model { get; construct; }
		public ListBox list_box { get; construct; }

		private string search_entry_text = "";
		private uint expanded_host_row_id = 0;

		construct {

			this.list_box = new ListBox ();
			this.list_box.set_selection_mode (SelectionMode.SINGLE);
			this.list_box.bind_model (this.hosts_file_service.host_row_list_model, create_widget_func);
			this.list_box.set_filter_func (this.filter_list_box);

			DropTarget hostname_drop_target = new DropTarget (Type.OBJECT, DragAction.MOVE);
			hostname_drop_target.drop.connect ((value, x, y) => this.handle_drop (value, x, y));

			this.list_box.add_controller (hostname_drop_target);
		}

		public HostsListBox (MainWindow main_window, Services.HostsFileService hosts_file_service) {
			Object (
			        main_window: main_window,
			        hosts_file_service: hosts_file_service
			);
		}

		public void set_search_entry_text (string search_entry_text) {

			this.search_entry_text = search_entry_text;
			this.list_box.invalidate_filter ();
		}

		public Widget create_widget_func (Object item) {

			Models.HostRowModel host_row = item as Models.HostRowModel;

			DragSource hostname_drag_source = new DragSource ();

			Value the_value = Value (Type.OBJECT);
			the_value.set_object (host_row);

			ContentProvider content_provider = new ContentProvider.for_value (the_value);
			hostname_drag_source.set_actions (DragAction.MOVE);
			hostname_drag_source.set_content (content_provider);

			if (host_row.row_type == Models.HostRowModel.RowType.HOST_GROUP) {

				Widgets.HostGroupExpanderRow host_group_expander_row = new Widgets.HostGroupExpanderRow (this.main_window, host_row, this.hosts_file_service.host_row_list_model);
				host_group_expander_row.add_controller (hostname_drag_source);
				host_group_expander_row.expand_button.clicked.connect (() => this.handle_expand_button_clicked (host_group_expander_row));
				host_group_expander_row.trash_button_clicked.connect (() => this.hosts_file_service.host_row_list_model.remove (host_row));

				return host_group_expander_row;
			} else if (host_row.row_type == Models.HostRowModel.RowType.HOST) {

				Widgets.HostActionRow host_action_row = new Widgets.HostActionRow (this.main_window, host_row, this.hosts_file_service.host_row_list_model);
				host_action_row.add_controller (hostname_drag_source);
				host_action_row.trash_button_clicked.connect (() => this.hosts_file_service.host_row_list_model.remove (host_row));

				return host_action_row;
			} else if (host_row.row_type == Models.HostRowModel.RowType.COMMENT) {

				Widgets.CommentActionRow comment_action_row = new Widgets.CommentActionRow (this.main_window, host_row, this.hosts_file_service.host_row_list_model);
				comment_action_row.add_controller (hostname_drag_source);
				comment_action_row.trash_button_clicked.connect (() => this.hosts_file_service.host_row_list_model.remove (host_row));

				return comment_action_row;
			} else {

				ListBoxRow list_box_row = new ListBoxRow ();
				list_box_row.add_controller (hostname_drag_source);

				return list_box_row;
			}
		}

		public bool filter_list_box (ListBoxRow list_box_row) {

			try {
				if (this.search_entry_text.length <= 1) {

					if (list_box_row.name == "HostsManagerWidgetsHostActionRow") {

						Widgets.HostActionRow host_action_row = list_box_row as Widgets.HostActionRow;
						return (expanded_host_row_id > 0 && host_action_row.host_row.parent_id > 0 && host_action_row.host_row.parent_id == expanded_host_row_id) || host_action_row.host_row.parent_id == 0;
					} else if (list_box_row.name == "HostsManagerWidgetsCommentActionRow") {

						Widgets.CommentActionRow comment_action_row = list_box_row as Widgets.CommentActionRow;
						return (expanded_host_row_id > 0 && comment_action_row.host_row.parent_id > 0 && comment_action_row.host_row.parent_id == expanded_host_row_id) || comment_action_row.host_row.parent_id == 0;
					} else if (list_box_row.name == "HostsManagerWidgetsHostGroupExpanderRow") {

						return true;
					}

					return false;
				}

				Regex search_regexp = new Regex (this.search_entry_text);

				if (list_box_row.name == "HostsManagerWidgetsHostActionRow") {

					Widgets.HostActionRow host_action_row = list_box_row as Widgets.HostActionRow;

					return search_regexp.match (host_action_row.title);;
				} else if (list_box_row.name == "HostsManagerWidgetsCommentActionRow") {

					Widgets.CommentActionRow comment_action_row = list_box_row as Widgets.CommentActionRow;

					return search_regexp.match (comment_action_row.title);
				} else if (list_box_row.name == "HostsManagerWidgetsHostGroupExpanderRow") {

					return true;
				}

				return false;
			} catch (RegexError regex_error) {

				error ("filter_list_box - regex failed: %s", regex_error.message);
			}
		}

		private bool handle_drop (Value dropped_item, double x, double y) {

			Models.HostRowModel dragged_host_row = dropped_item.get_object () as Models.HostRowModel;

			Widget drop_target_widget = this.list_box.get_row_at_y ((int) y);
			Models.HostRowModel drop_target_host_row = new Models.HostRowModel (0, 0, Models.HostRowModel.RowType.EMPTY, true, "", Models.HostRowModel.IPVersion.IPV4, "", "", "", "");

			if (drop_target_widget.name == "HostsManagerWidgetsHostActionRow") {

				Widgets.HostActionRow host_action_row = drop_target_widget as Widgets.HostActionRow;
				drop_target_host_row = host_action_row.host_row;
			} else if (drop_target_widget.name == "HostsManagerWidgetsCommentActionRow") {

				Widgets.CommentActionRow comment_action_row = drop_target_widget as Widgets.CommentActionRow;
				drop_target_host_row = comment_action_row.host_row;
			} else if (drop_target_widget.name == "HostsManagerWidgetsHostGroupExpanderRow") {

				Widgets.HostGroupExpanderRow host_group_expander_row = drop_target_widget as Widgets.HostGroupExpanderRow;
				drop_target_host_row = host_group_expander_row.host_row;
			}

			this.hosts_file_service.host_row_list_model.insert_after_host_row (dragged_host_row, drop_target_host_row);
			return true;
		}

		private void handle_expand_button_clicked (Widgets.HostGroupExpanderRow host_group_expander_row) {

			expanded_host_row_id = host_group_expander_row.expanded ? 0 : host_group_expander_row.host_row.id;
			host_group_expander_row.expanded = !host_group_expander_row.expanded;
			this.list_box.invalidate_filter ();
		}
	}
}