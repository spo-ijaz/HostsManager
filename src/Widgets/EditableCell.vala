using Gtk;
using Gdk;

namespace HostsManager.Widgets {

	class EditableCell : Box {

		public enum FieldType {
			IP_ADDRESS,
			HOSTNAME
		}

		public MainWindow main_window { get; construct; }
		public EditableLabel editable_label { get; construct; }
		public Label label { get; construct; }
		public Models.HostRow host_row  { get; set; }
		public Services.HostsFile hosts_file_service  { get; set; }
		public FieldType field_type { get; set; }

		construct {

			this.editable_label = new EditableLabel ("");
			this.label = new Label ("");
			EventControllerKey event_controller_key = new EventControllerKey ();
			event_controller_key.key_released.connect (
			                                           (keyval, keycode, state) => {

				// Enter
				if (keycode != 36) {
					return;
				}

				string previous_hostname = this.host_row.hostname;
				try {

					Services.RegexHostRow regex = new Services.RegexHostRow (this.host_row.ip_address, this.host_row.hostname);

					if (this.field_type == FieldType.HOSTNAME) {

						this.hosts_file_service.set_hostname (regex, editable_label.text, this.host_row);
					} else {

						this.hosts_file_service.set_ip_address (regex, editable_label.text, this.host_row);
					}

					this.editable_label.remove_css_class ("wrong_input");
				} catch (InvalidArgument invalid_argument) {

					debug ("InvalidArgument: %s", invalid_argument.message);
					this.host_row.hostname = previous_hostname;
					this.editable_label.add_css_class ("wrong_input");
				}

				return;
			});

			this.editable_label.add_controller (event_controller_key);
			this.append (editable_label);
		}

		public EditableCell (MainWindow main_window, Services.HostsFile hosts_file_service) {
			Object (
			        main_window: main_window,
			        hosts_file_service: hosts_file_service
			);
		}

		// public void initDragAndDrop () {

		////Drag & drop support
		// Widget column_view_cell = list_item.child.get_parent ();

		// DragSource hostname_drag_source = new DragSource ();

		// Value the_value = Value (Type.UINT);
		// the_value.set_uint (list_item.position);

		// ContentProvider content_provider = new ContentProvider.for_value (the_value);
		// hostname_drag_source.drag_begin.connect (() => {

		////For drag & drop support. Without that, DropTarget content can be garraychar, because label contains chars..
		////  this.set_can_target (false);
		// });
		// hostname_drag_source.set_content (content_provider);
		// column_view_cell.add_controller (hostname_drag_source);

		// DropTarget hostname_drop_target = new DropTarget (Type.UINT, DragAction.COPY);
		// hostname_drop_target.drop.connect ((value, x, y) => {

		// main_window.handle_drop (value.get_uint (), list_item.position);
		////  this.set_can_target (true);
		// return true;
		// });

		// column_view_cell.add_controller (hostname_drop_target);
		// }
	}
}