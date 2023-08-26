using Gtk;

namespace HostsManager.Filters {

	public class HostRowFilter :  Filter {

		public HostRowFilter() {
      }

		public override bool match (Object? object) {

			Models.HostRow? host_row = object as Models.HostRow;
			if (host_row != null) {

				info ("test : %s", host_row.hostname );
			}

			return true;
		}
	}
}
