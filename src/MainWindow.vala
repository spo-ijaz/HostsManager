[GtkTemplate (ui = "/com/github/gyan000/hostsmanager/ui/main-window.ui")]
public class MainWindow : Gtk.ApplicationWindow {

	[GtkChild]
	public unowned Gtk.ToggleButton search_toggle_button;

  construct {

  }

  public MainWindow (HostsManager.App app) {
    Object (
      application: app
    );
  }
}
