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
		public Models.HostRow host_row  { get; set;}
		public Services.HostsFile hosts_file_service  { get; set; }
		public ListItem list_item  { get; set; }

		public FieldType field_type { get; set; }

		construct {

			this.editable_label = new EditableLabel ("");
			EventControllerKey event_controller_key = new EventControllerKey ();
			event_controller_key.key_released.connect (
				(keyval, keycode, state) => {

					// Enter
					if (keycode != 36) {
						return;
					}

					string previous_hostname = host_row.hostname;
					try {

						Services.HostsRegex regex = new Services.HostsRegex (host_row.ip_address, host_row.hostname);

						if (this.field_type == FieldType.HOSTNAME) {

							this.hosts_file_service.set_hostname (regex, editable_label.text, list_item.position);
							host_row.hostname = editable_label.text;
						} else {

							this.hosts_file_service.set_ip_address (regex, editable_label.text, list_item.position);
							host_row.ip_address = editable_label.text;
						}

						editable_label.remove_css_class ("wrong_input");
					} catch (InvalidArgument invalid_argument) {

						debug ("InvalidArgument: %s", invalid_argument.message);
						host_row.hostname = previous_hostname;
						editable_label.add_css_class ("wrong_input");
					}

					return ;
			});

			editable_label.add_controller (event_controller_key);
			this.append (editable_label);
		}

		public EditableCell (MainWindow main_window, Services.HostsFile hosts_file_service, ListItem list_item) {
			Object (
				main_window: main_window,
				hosts_file_service: hosts_file_service,
				list_item: list_item
			);
		}

		public void initDragAndDrop () {

			//Drag & drop support
			Widget column_view_cell = list_item.child.get_parent ();

			DragSource hostname_drag_source = new DragSource ();

			Value the_value = Value (Type.UINT);
			the_value.set_uint (list_item.position);

			ContentProvider content_provider = new ContentProvider.for_value (the_value);
			hostname_drag_source.drag_begin.connect (() => {

				//For drag & drop support. Without that, DropTarget content can be garraychar, because label contains chars..
				//  this.set_can_target (false);
			});
			hostname_drag_source.set_content (content_provider);
			column_view_cell.add_controller (hostname_drag_source);

			DropTarget hostname_drop_target = new DropTarget (Type.UINT, DragAction.COPY);
			hostname_drop_target.drop.connect ((value, x, y) => {

				main_window.handle_drop (value.get_uint (), list_item.position);
				//  this.set_can_target (true);
				return true;
			});

			column_view_cell.add_controller (hostname_drop_target);
		}
		
	}
}
