using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

	class BaseActionRow : Adw.ActionRow  {

		public MainWindow main_window { get; construct; }
		public Models.HostRow host_row { get; construct; }

		public signal void trash_button_clicked ();

		protected Button edit_button;
		protected Button trash_button;

		construct {

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

		public BaseActionRow (MainWindow main_window, Models.HostRow host_row) {
			Object (
			        main_window: main_window,
			        host_row: host_row
			);
		}
	}
}