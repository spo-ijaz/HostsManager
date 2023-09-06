using Adw;
using Gtk;
using Gdk;

namespace HostsManager.Widgets {

    class HostRow : ActionRow {

        public Models.HostRow host_row { get; construct; }

        private Box box;
        private EditableLabel ip_address_entry;
        private EditableLabel hostname_entry;
        private Switch enabled_switch;

        construct {

            this.box = new Box (Orientation.HORIZONTAL, 10);

            this.ip_address_entry = new EditableLabel (host_row.ip_address);
            this.hostname_entry = new EditableLabel (host_row.hostname);

            this.box.append (this.ip_address_entry);
            this.box.append (this.hostname_entry);

            this.enabled_switch = new Switch ();
            this.enabled_switch.set_active (host_row.enabled);

            this.add_prefix (this.box);
            this.add_suffix (this.enabled_switch);

            this.enabled_switch.get_parent ().set_valign (Align.CENTER);
        }

        public HostRow (Models.HostRow host_row) {
            Object (
                    host_row: host_row
            );
        }
    }
}