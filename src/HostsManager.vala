namespace HostsManager {

	public class App : Gtk.Application
	{
		private unowned MainWindow window;

		public App()
		{
			Object
			(
				application_id: AppConfig.APP_ID,
				resource_base_path: "/com/github/spo-ijaz/hostsmanager",
				flags: ApplicationFlags.FLAGS_NONE
			);
		}

		public static int main(string[] args)
		{
			var app = new App();
			return app.run(args);
		}

		protected override void activate()
		{
			var active_window = get_active_window();
			if (active_window != null) {
				active_window.present ();
				return;
			}

			create_window ();
		}

		private void create_window () {

			var win = new MainWindow (this);
			win.close_request.connect_after ((win) => {
				activate_action ("quit", null);
				return false;
			});

			this.window = win;
			win.present ();
		}
	}
}
