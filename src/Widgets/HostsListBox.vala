using Gtk;
using Gdk;

namespace HostsManager.Widgets {

	class HostsListBox : Widget {

		public MainWindow main_window { get; construct; }
		public Services.HostsFile hosts_file_service  { get; construct; }
		public ListBox list_box { get; construct; }

		private string search_entry_text = "";
		private uint expanded_host_row_id = 0;

		construct {

			this.list_box = new ListBox ();
			this.list_box.bind_model (this.hosts_file_service.rows_list_store, create_widget_func);

			this.list_box.set_filter_func (this.filter_list_box);


			DropTarget hostname_drop_target = new DropTarget (Type.OBJECT, DragAction.MOVE);
			hostname_drop_target.drop.connect ((value, x, y) => {

				this.handle_drop (value.get_object (), x, y);
				// this.set_can_target (true);
				return true;
			});

			this.list_box.add_controller (hostname_drop_target);
		}

		public HostsListBox (MainWindow main_window, Services.HostsFile hosts_file_service) {
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

			Models.HostRow host_row = item as Models.HostRow;

			DragSource hostname_drag_source = new DragSource ();

			Value the_value = Value (Type.OBJECT);
			the_value.set_object (host_row);

			ContentProvider content_provider = new ContentProvider.for_value (the_value);
			hostname_drag_source.drag_begin.connect (() => {

				// For drag & drop support. Without that, DropTarget content can be garraychar, because label contains chars..
				// this.set_can_target (false);
			});
			hostname_drag_source.set_actions (DragAction.MOVE);
			hostname_drag_source.set_content (content_provider);

			if (host_row.row_type == Models.HostRow.RowType.HOST_GROUP) {

				// Erreur de segmentation (core dumped) - if not set here
				this.search_entry_text = "";

				Widgets.HostGroupExpanderRow host_group_expander_row = new Widgets.HostGroupExpanderRow (this.main_window, host_row);
				host_group_expander_row.add_controller (hostname_drag_source);
				host_group_expander_row.expand_button.clicked.connect (() => this.handle_expand_button_clicked (host_group_expander_row));

				return host_group_expander_row;
			} else if (host_row.row_type == Models.HostRow.RowType.HOST) {

				Widgets.HostActionRow host_action_row = new Widgets.HostActionRow (this.main_window, host_row);
				host_action_row.add_controller (hostname_drag_source);

				return host_action_row;
			} else if (host_row.row_type == Models.HostRow.RowType.COMMENT) {


				Widgets.CommentActionRow comment_action_row = new Widgets.CommentActionRow (this.main_window, host_row);
				comment_action_row.add_controller (hostname_drag_source);

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
					}

					return true;
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

		private void handle_drop (Object drag_item, double x, double y) {

			debug ("%s", drag_item.get_class ().get_name ());
			debug ("drop_item_position: %f, %f", x, y);

			ListBoxRow list_box_row = this.list_box.get_row_at_y ((int) y);

			Models.HostRow dragged_host_row = drag_item as Models.HostRow;
			uint dropped_position = 0;

			if (list_box_row.name == "HostsManagerWidgetsHostActionRow") {

				Widgets.HostActionRow host_action_row = list_box_row as Widgets.HostActionRow;
				dropped_position = host_action_row.host_row.id;
			} else if (list_box_row.name == "HostsManagerWidgetsCommentActionRow") {

				Widgets.CommentActionRow comment_action_row = list_box_row as Widgets.CommentActionRow;
				dropped_position = comment_action_row.host_row.id;
			} else if (list_box_row.name == "HostsManagerWidgetsHostGroupExpanderRow") {

				Widgets.HostGroupExpanderRow host_group_expander_row = list_box_row as Widgets.HostGroupExpanderRow;
				dropped_position = host_group_expander_row.host_row.id;
			}

			this.hosts_file_service.rows_list_store.insert_after_position (dropped_position, dragged_host_row);
		}

		private void handle_expand_button_clicked (Widgets.HostGroupExpanderRow host_group_expander_row) {

			expanded_host_row_id = host_group_expander_row.expanded ? 0 : host_group_expander_row.host_row.id;
			host_group_expander_row.expanded = !host_group_expander_row.expanded;
			this.list_box.invalidate_filter ();
		}
	}
}