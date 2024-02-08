using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

    class CommentActionRow : Widgets.BaseActionRow  {

        construct {

            this.title = host_row.comment;
            this.add_css_class ("flat");

            this.edit_button.clicked.connect ((edit_button) => {

                Widgets.RowEditMessageDialog comment_edit_message_dialog = new Widgets.RowEditMessageDialog (this.main_window, host_row_dialog);
                comment_edit_message_dialog.present ();
                comment_edit_message_dialog.response.connect ((response) => {
                    if (response == "replace" && this.host_row.comment != this.host_row_dialog.comment) {
                        
                        this.title = this.host_row_dialog.comment;
                        this.host_row.comment = this.host_row_dialog.comment;
                        // We don't care about giving the right arguments here, it's just to inform the main windows there is an update.
                        this.host_row_list_model.items_changed (0, 0, 0);
                    } else {

                        this.host_row_dialog.comment = this.host_row.comment;
                    }
                });
            });
        }

        public CommentActionRow (MainWindow main_window, Models.HostRowModel host_row, Models.HostRowListModel host_row_list_model) {
            Object (
                    main_window: main_window,
                    host_row: host_row,
                    host_row_list_model: host_row_list_model
            );
        }
    }
}