using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

    class HostActionRow : Adw.ActionRow  {

        public MainWindow main_window { get; construct; }
        public Models.HostRow host_row { get; construct; }

        private Gtk.Button edit_button;
        private Gtk.Button trash_button;
        private Gtk.Switch enabled_swtich;

        construct {

            this.title = host_row.hostname;
            this.subtitle = host_row.ip_address;

            this.enabled_swtich = new Gtk.Switch ();
            this.enabled_swtich.set_valign (Gtk.Align.BASELINE_CENTER);
            this.enabled_swtich.set_active (this.host_row.enabled);
            this.add_prefix (this.enabled_swtich);

            this.edit_button = new Gtk.Button.from_icon_name ("document-edit-symbolic");
            this.edit_button.set_has_frame (false);
            this.add_prefix (this.edit_button);

            this.trash_button = new Gtk.Button.from_icon_name ("user-trash-symbolic");
            this.trash_button.set_has_frame (false);
            this.add_suffix (this.trash_button);
        }

        public HostActionRow (MainWindow main_window, Models.HostRow host_row) {
            Object (
                    main_window: main_window,
                    host_row: host_row
            );
        }
    }
}