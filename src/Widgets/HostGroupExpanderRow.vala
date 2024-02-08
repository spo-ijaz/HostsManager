using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

    class HostGroupExpanderRow : Widgets.BaseActionRow  {

        public Gtk.Button expand_button  { get; construct; }
        public bool expanded;

        construct {

            this.title = host_row.host_group_name;
            this.add_css_class ("title-3");
            this.expanded = false;

            this.edit_button.clicked.connect ((edit_button) => {

                Widgets.RowEditMessageDialog comment_edit_message_dialog = new Widgets.RowEditMessageDialog (this.main_window, this.host_row_dialog);
                comment_edit_message_dialog.present ();
                comment_edit_message_dialog.response.connect ((response) => {
                    if (response == "replace" && this.host_row.host_group_name != this.host_row_dialog.host_group_name) {

                        this.title = this.host_row_dialog.host_group_name;
                        this.host_row.host_group_name = this.host_row_dialog.host_group_name;
                        // We don't care about giving the right arguments here, it's just to inform the main windows there is an update.
                        this.host_row_list_model.items_changed (0, 0, 0);
                    } else {

                        this.host_row_dialog.host_group_name = this.host_row.host_group_name;
                    }
                });
            });

            this.expand_button = new Gtk.Button.from_icon_name ("pan-end-symbolic");
            this.expand_button.set_has_frame (false);
            this.expand_button.clicked.connect (() => {
                this.expand_button.set_icon_name (expanded ? "pan-end-symbolic" : "pan-down-symbolic");
            });

            this.add_suffix (this.expand_button);
        }

        public HostGroupExpanderRow (MainWindow main_window, Models.HostRowModel host_row, Models.HostRowListModel host_row_list_model) {
            Object (
                    main_window: main_window,
                    host_row: host_row,
                    host_row_list_model: host_row_list_model
            );
        }
    }
}