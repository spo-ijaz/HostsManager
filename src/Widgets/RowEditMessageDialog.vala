using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

	class RowEditMessageDialog : Adw.MessageDialog  {

		public MainWindow main_window { get; construct; }
		public Models.HostRowModel host_row { get; construct; }

		private Box box;
		private Entry entry_text;
		private Entry entry_ip;

		construct {

			this.set_modal (true);
			this.set_size_request (this.main_window.get_width () - 50, -1);

			this.set_transient_for (this.main_window);

			this.entry_text = new Entry ();
			this.set_halign (Align.FILL);
			this.entry_text.set_hexpand (true);

			switch (this.host_row.row_type) {

			case Models.HostRowModel.RowType.COMMENT:
				this.heading = _("Update a comment row");
				this.entry_text.set_text (this.host_row.comment);
				break;

			case Models.HostRowModel.RowType.HOST:
				this.heading = _("Update a host row");
				this.entry_text.set_text (this.host_row.hostname);
				break;

			case Models.HostRowModel.RowType.HOST_GROUP:
				this.heading = _("Update a group name");
				this.entry_text.set_text (this.host_row.host_group_name);
				break;
			}

			this.entry_text.changed.connect ((editable) => {

				switch (this.host_row.row_type) {

					case Models.HostRowModel.RowType.COMMENT:
						this.host_row.comment = editable.get_text ();
						break;

					case Models.HostRowModel.RowType.HOST:
						this.host_row.hostname = editable.get_text ();
						break;

					case Models.HostRowModel.RowType.HOST_GROUP:
						this.host_row.host_group_name = editable.get_text ();
						break;
				}
			});


			this.box = new Box (Orientation.VERTICAL, 2);
			this.box.append (this.entry_text);

			if (this.host_row.row_type == Models.HostRowModel.RowType.HOST) {

				this.entry_ip = new Entry ();
				this.entry_ip.set_halign (Align.FILL);
				this.entry_ip.set_hexpand (true);
				this.entry_ip.set_text (this.host_row.ip_address);
				this.entry_ip.changed.connect ((editable) => {

					this.host_row.ip_address = editable.get_text ();
				});

				this.box.append (this.entry_ip);
			}

			this.set_extra_child (this.box);

			this.add_responses (
			                    "cancel",
			                    _("cancel"),
			                    "replace",
			                    _("replace")
			);

			this.set_response_appearance ("replace", Adw.ResponseAppearance.DESTRUCTIVE);
		}

		public RowEditMessageDialog (MainWindow main_window, Models.HostRowModel host_row) {
			Object (
			        main_window: main_window,
			        host_row: host_row
			);
		}
	}
}