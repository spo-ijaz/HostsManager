using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

    class HostActionRow : Widgets.BaseActionRow  {

        private Gtk.Switch enabled_swtich;

        construct {

            this.title = host_row.hostname;
            this.subtitle = host_row.ip_address;
            this.margin_start = this.host_row.parent_id > 0 ? 30 : 0;

            this.enabled_swtich = new Gtk.Switch ();
            this.enabled_swtich.set_valign (Gtk.Align.BASELINE_CENTER);
            this.enabled_swtich.set_active (this.host_row.enabled);
            this.add_prefix (this.enabled_swtich);

            this.edit_button.clicked.connect ((edit_button) => {

                Widgets.RowEditMessageDialog comment_edit_message_dialog = new Widgets.RowEditMessageDialog (this.main_window, this.host_row);
                comment_edit_message_dialog.present ();
                comment_edit_message_dialog.response.connect ((response) => {
                    if (response == "replace") {

                        this.title = this.host_row.hostname;
                        this.subtitle = this.host_row.ip_address;
                    }
                });
            });
        }

        public HostActionRow (MainWindow main_window, Models.HostRow host_row) {
            Object (
                    main_window: main_window,
                    host_row: host_row
            );
        }
    }
}