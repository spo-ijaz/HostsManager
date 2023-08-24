[GtkTemplate (ui = "/com/github/gyan000/hostsmanager/ui/MainWindow.ui")]
public class MainWindow : Gtk.Window {

	[GtkChild]
	public unowned Gtk.ToggleButton search_toggle_button;

	construct {
	}

	public MainWindow (HostsManager.App app) {
		Object (
			application: app
		);
	}


	[GtkCallback]
	private void on_search_toggle_button_toggled () {

		info("on_search_toggle_button_toggled");
	}
}
