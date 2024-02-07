using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

    class HostGroupExpanderRow : Widgets.BaseActionRow  {

        public Gtk.Button expand_button  { get; construct; }
        public bool expanded;

        construct {

            this.title = host_row.host_group_name;
            this.expanded = false;

            this.edit_button.clicked.connect ((edit_button) => {

                Widgets.RowEditMessageDialog comment_edit_message_dialog = new Widgets.RowEditMessageDialog (this.main_window, this.host_row);
                comment_edit_message_dialog.present ();
                comment_edit_message_dialog.response.connect ((response) => {
                    if (response == "replace") {

                        this.title = this.host_row.host_group_name;
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

        public HostGroupExpanderRow (MainWindow main_window, Models.HostRow host_row) {
            Object (
                    main_window: main_window,
                    host_row: host_row
            );
        }
    }
}