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
            this.enabled_swtich.state_set.connect ((state_set) => {

                this.host_row.enabled = state_set;
                // We don't care about giving the right arguments here, it's just to inform the main windows there is an update.
                this.host_row_list_model.items_changed (0, 0, 0);
            });

            this.add_prefix (this.enabled_swtich);

            this.edit_button.clicked.connect ((edit_button) => {

                Widgets.RowEditMessageDialog comment_edit_message_dialog = new Widgets.RowEditMessageDialog (this.main_window, this.host_row_dialog);
                comment_edit_message_dialog.present ();
                comment_edit_message_dialog.response.connect ((response) => {
                    if (response == "replace") {

                        if (this.host_row.hostname != this.host_row_dialog.hostname) {

                            this.title = this.host_row_dialog.hostname;
                            this.host_row.hostname = this.host_row_dialog.hostname;
                            // We don't care about giving the right arguments here, it's just to inform the main windows there is an update.
                            this.host_row_list_model.items_changed (0, 0, 0);
                        }

                        if (this.host_row.ip_address != this.host_row_dialog.ip_address) {


                            bool ipdaddress_valid = true;
                            Models.HostRowModel.IPVersion ip_version = Models.HostRowModel.IPVersion.IPV4;
                            if (!Regex.match_simple ("^" + Services.ConfigService.ipv4_address_regex_str () + "$", this.host_row_dialog.ip_address)) {

                                ipdaddress_valid = false;

                                if (Regex.match_simple ("^" + Services.ConfigService.ipv6_address_regex_str () + "$", this.host_row_dialog.ip_address)) {

                                    ipdaddress_valid = true;
                                    ip_version = Models.HostRowModel.IPVersion.IPV6;
                                }
                            }

                            if (ipdaddress_valid) {

                                this.subtitle = this.host_row_dialog.ip_address;
                                this.host_row.ip_address = this.host_row_dialog.ip_address;
                                this.host_row.ip_version = ip_version;
                                // We don't care about giving the right arguments here, it's just to inform the main windows there is an update.
                                this.host_row_list_model.items_changed (0, 0, 0);
                            } else {

                                this.main_window.toast.set_title (_("Invalid IP address format."));
				                this.main_window.toast_overlay.add_toast (this.main_window.toast);
                                this.reset_host_row_dialog_fields ();
                            }
                        }
                    } else {

                        this.reset_host_row_dialog_fields ();
                    }
                });
            });
        }

        public HostActionRow (MainWindow main_window, Models.HostRowModel host_row, Models.HostRowListModel host_row_list_model) {
            Object (
                    main_window: main_window,
                    host_row: host_row,
                    host_row_list_model: host_row_list_model
            );
        }

        private void reset_host_row_dialog_fields () {

            this.host_row_dialog.ip_address = this.host_row.ip_address;
            this.host_row_dialog.hostname = this.host_row.hostname;
        }
    }
}