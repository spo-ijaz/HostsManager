using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

	class BaseActionRow : Adw.ActionRow  {

		public MainWindow main_window { get; construct; }
		public Models.HostRowModel host_row { get; construct; }
		public Models.HostRowListModel host_row_list_model { get; construct; }

		public signal void trash_button_clicked ();

		protected Button edit_button;
		protected Button trash_button;
		protected Models.HostRowModel host_row_dialog;

		construct {


			this.host_row_dialog = new Models.HostRowModel (
				this.host_row.id,
				this.host_row.parent_id,
				this.host_row.row_type,
				this.host_row.enabled,
				this.host_row.ip_address,
				this.host_row.ip_version,
				this.host_row.hostname,
				this.host_row.host_group_name,
				this.host_row.comment,
				this.host_row.row
			);

			this.margin_start = this.host_row.parent_id > 0 ? 30 : 0;

			this.edit_button = new Button.from_icon_name ("document-edit-symbolic");
			this.edit_button.set_has_frame (false);
			this.add_prefix (edit_button);

			this.trash_button = new Button.from_icon_name ("user-trash-symbolic");
			this.trash_button.set_has_frame (false);
			this.trash_button.clicked.connect (() => {

				this.trash_button_clicked ();
			});

			this.add_suffix (this.trash_button);
		}

		public BaseActionRow (MainWindow main_window, Models.HostRowModel host_row_model, Models.HostRowListModel host_row_list_model) {
			Object (
			        main_window: main_window,
			        host_row: host_row_model,
			        host_row_list_model: host_row_list_model
			);
		}
	}
}