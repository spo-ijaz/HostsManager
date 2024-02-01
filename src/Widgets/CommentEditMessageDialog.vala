using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

	class CommentEditMessageDialog : Adw.MessageDialog  {

		public MainWindow main_window { get; construct; }
		public Models.HostRow host_row { get; construct; }

		private Box box;
		private Entry entry;

		construct {

			this.set_modal (true);
			this.set_size_request (
			                       this.main_window.get_width () - 50,
			                       -1
			);

			this.set_transient_for (this.main_window);
			this.heading = "Update a comment row";

			this.entry = new Entry ();
			this.set_halign (Align.FILL);
			this.entry.set_hexpand (true);
			this.entry.set_text (this.host_row.comment);
			this.entry.changed.connect ((editable) => {

				this.host_row.comment = editable.get_text ();
			});


			this.box = new Box (Orientation.HORIZONTAL, 2);
			this.box.append (this.entry);

			this.set_extra_child (this.box);

			this.add_responses (
			                    "cancel",
			                    "_cancel",
			                    "replace",
			                    "_replace"
			);

			this.set_response_appearance ("replace", Adw.ResponseAppearance.DESTRUCTIVE);
		}

		public CommentEditMessageDialog (MainWindow main_window, Models.HostRow host_row) {
			Object (
			        main_window: main_window,
			        host_row: host_row
			);
		}
	}
}