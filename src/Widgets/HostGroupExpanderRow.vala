using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

    class HostGroupExpanderRow : Adw.ActionRow  {

        public MainWindow main_window { get; construct; }
        public Models.HostRow host_row { get; construct; }
        public Gtk.Button expand_button  { get; construct; }
        public bool expanded;


        private Gtk.Button edit_button;
        private Gtk.Button trash_button;

        construct {

            this.title = host_row.host_group_name;
            this.expanded = false;

            this.edit_button = new Gtk.Button.from_icon_name ("document-edit-symbolic");
            this.edit_button.set_has_frame (false);
            this.add_prefix (this.edit_button);

            this.trash_button = new Gtk.Button.from_icon_name ("user-trash-symbolic");
            this.trash_button.set_has_frame (false);
            this.add_suffix (this.trash_button);

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