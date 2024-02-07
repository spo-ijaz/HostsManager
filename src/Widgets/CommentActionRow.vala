using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

    class CommentActionRow : Widgets.BaseActionRow  {

        construct {

            this.title = host_row.comment;

            this.edit_button.clicked.connect ((edit_button) => {

                Widgets.RowEditMessageDialog comment_edit_message_dialog = new Widgets.RowEditMessageDialog (this.main_window, this.host_row);
                comment_edit_message_dialog.present ();
                comment_edit_message_dialog.response.connect ((response) => {
                    if (response == "replace") {

                        this.title = this.host_row.comment;
                    }
                });
            });
        }

        public CommentActionRow (MainWindow main_window, Models.HostRow host_row) {
            Object (
                    main_window: main_window,
                    host_row: host_row
            );
        }
    }
}