namespace HostsManager {

	public class App : Gtk.Application
	{
		private unowned MainWindow main_window;

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

			var main_window = new MainWindow (this);
			main_window.close_request.connect_after ((main_window) => {
				activate_action ("quit", null);
				return false;
			});

			this.main_window = main_window;
			main_window.present ();
		}
	}
}

