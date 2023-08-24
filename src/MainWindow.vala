namespace HostsManager {

	[GtkTemplate (ui = "/com/github/gyan000/hostsmanager/ui/main-window.ui")]
	public class MainWindow : Gtk.Window {

		[GtkChild]
		public unowned Gtk.ToggleButton search_toggle_button;

		construct {
		}

		public MainWindow (App app) {
			Object (
				application: app
			);
		}


		[GtkCallback]
		private void on_search_toggle_button_toggled () {

			info("on_search_toggle_button_toggled");
		}
	}
}
