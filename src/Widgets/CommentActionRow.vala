using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

    class CommentActionRow : Adw.ActionRow  {

        public MainWindow main_window { get; construct; }
        public Models.HostRow host_row { get; construct; }

        private Gtk.Button edit_button;
        private Gtk.Button trash_button;

        construct {

            this.title = host_row.comment;

            this.edit_button = new Gtk.Button.from_icon_name ("document-edit-symbolic");
            this.edit_button.set_has_frame (false);
            this.add_prefix (edit_button);

            this.trash_button = new Gtk.Button.from_icon_name ("user-trash-symbolic");
            this.trash_button.set_has_frame (false);
            this.add_suffix (this.trash_button);
        }

        public CommentActionRow (MainWindow main_window, Models.HostRow host_row) {
            Object (
                    main_window: main_window,
                    host_row: host_row
            );
        }
    }
}