using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

    class HostGroupExpanderRow : Adw.ExpanderRow  {

        public MainWindow main_window { get; construct; }
        public Models.HostRow host_row { get; construct; }

        private Gtk.Button edit_button;

        construct {

            this.title = host_row.host_group_name;

            this.edit_button = new Gtk.Button.from_icon_name ("document-edit-symbolic");
            this.edit_button.set_has_frame (false);

            // this.add_suffix (this.edit_button);
            this.add_prefix (this.edit_button);
        }

        public HostGroupExpanderRow (MainWindow main_window, Models.HostRow host_row) {
            Object (
                    main_window: main_window,
                    host_row: host_row
            );
        }
    }
}