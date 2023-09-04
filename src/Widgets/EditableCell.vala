using Gtk;


namespace HostsManager.Widgets {

	class EditableCell : Box {

		public enum FieldType {
			 IP_ADDRESS,
			 HOSTNAME
		}

		public EditableLabel editable_label { get; construct; }
		public Models.HostRow host_row  { get; set;}
		public Services.HostsFile hosts_file_service  { get; set; }

		public FieldType field_type { get; set; }

		construct {

			this.editable_label = new EditableLabel ("");
			//Drag & drop support
			// Widget column_view_cell = list_item.child.get_parent ();

			// DragSource hostname_drag_source = new DragSource ();

			// Value the_value = Value (Type.UINT);
			// the_value.set_uint (list_item.position);

			// ContentProvider content_provider = new ContentProvider.for_value (the_value);
			// hostname_drag_source.drag_begin.connect (() => {

				//For drag & drop support. Without that, DropTarget content can be garraychar, because label contains chars..
			// 	editable_label.set_can_target (false);
			// });
			// hostname_drag_source.set_content (content_provider);
			// column_view_cell.add_controller (hostname_drag_source);

			// DropTarget hostname_drop_target = new DropTarget (Type.UINT, DragAction.COPY);
			// hostname_drop_target.drop.connect ((value, x, y) => {

			// 	this.handle_drop (value.get_uint (), list_item.position);
			// 	return true;
			// });

			// column_view_cell.add_controller (hostname_drop_target);

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

							this.hosts_file_service.set_hostname (regex, editable_label.text);
							host_row.hostname = editable_label.text;
						} else {

							this.hosts_file_service.set_ip_address (regex, editable_label.text);
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

		public EditableCell (Services.HostsFile hosts_file_service) {
			Object (
				hosts_file_service: hosts_file_service
			);
		}

		// private void handle_drop (uint drag_item_position, uint drop_item_position) {

		// 	var iter = Gtk.BitsetIter ();
		// 	uint position;
		// 	uint initial_position = 0;
		// 	uint num_items_to_delete = 0;

		// 	debug ("drag_item_position: %u | drop_item_position: %u", drag_item_position, drop_item_position);
		// 	if (!iter.init_first (this.hosts_multi_selection.get_selection (), out position)) {
		// 		return;
		// 	}

		// 	do {

		// 		Models.HostRow host_row = this.hosts_list_store.get_item (position) as Models.HostRow;

		// 		if (host_row != null) {

		// 			if(initial_position == 0) {

		// 				initial_position = position;
		// 			}

		// 			debug ("Deleting %s - %s", host_row.ip_address, host_row.hostname);
		// 			num_items_to_delete++;
		// 		}
		// 	} while (iter.next (out position));

		// 	this.hosts_list_store.splice (initial_position, num_items_to_delete, {});
		// 	this.hosts_file_service.save_file ();
		// }
	}
}
