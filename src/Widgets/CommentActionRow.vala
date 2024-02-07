using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

    class CommentActionRow : ActionRow  {

        public MainWindow main_window { get; construct; }
        public Models.HostRow host_row { get; construct; }

        private Button edit_button;
        private Button trash_button;

        construct {

            this.title = host_row.comment;
            this.margin_start = this.host_row.parent_id > 0 ? 30 : 0;


            this.edit_button = new Button.from_icon_name ("document-edit-symbolic");
            this.edit_button.set_has_frame (false);
            this.edit_button.clicked.connect ((edit_button) => {

                Widgets.CommentEditMessageDialog comment_edit_message_dialog = new Widgets.CommentEditMessageDialog (this.main_window, this.host_row);
                comment_edit_message_dialog.present ();
                comment_edit_message_dialog.response.connect ((response) => {
                    if (response == "replace") {

                        this.title = this.host_row.comment;
                    }
                });
            });
            this.add_prefix (edit_button);

            this.trash_button = new Button.from_icon_name ("user-trash-symbolic");
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