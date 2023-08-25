namespace HostsManager {

	public class HostRowFilter : Gtk.Filter {

	}

	public  bool match (Object? item) {

		info ("HostRowFilter");
		return true;
	}
}
