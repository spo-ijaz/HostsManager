using GLib;

public errordomain InvalidArgument {
  IPADDRESS,
  HOSTNAME,
}

namespace HostsManager.Services {

	class HostsFile
	{
	  private string hostsFileContent;

	  public HostsFile() {

		 readFile();
	  }

	  public MatchInfo getEntries () {

		 MatchInfo entries;
		 HostsRegex regex = new HostsRegex();
		 regex.match(this.hostsFileContent, 0, out entries);

		 return entries;
	  }

	  public void setEnabled (HostsRegex modRegex, bool active) {

		 try {

		   this.hostsFileContent = modRegex.replace (this.hostsFileContent, -1, 0, active ? """\n#\g<row>""" : """\g<row>""");
		   saveFile();
		 }
		 catch (RegexError e) {

		   error("Regex failed: %s", e.message);
		 }
	  }

	  public void setIpAddress (HostsRegex modRegex, string ipaddress) throws InvalidArgument {

		 validateIpAddress (ipaddress);

		 try {

		   this.hostsFileContent = modRegex.replace (this.hostsFileContent, -1, 0, """\g<enabled>""" + ipaddress + """\g<divider>\g<hostname>""");
		   saveFile();
		 }
		 catch (RegexError e) {

		   GLib.error ("Regex failed: %s", e.message);
		 }
	  }

	  public void setHostname (HostsRegex modRegex, string hostname) throws InvalidArgument {

		 validateHostname(hostname);

		 try {

		   this.hostsFileContent = modRegex.replace (this.hostsFileContent, -1, 0, """\g<enabled>\g<ipaddress>\g<divider>""" + hostname);
		   saveFile();
		 }
		 catch (RegexError e) {

		   GLib.error ("Regex failed: %s", e.message);
		 }
	  }

	  public void add (string ipaddress, string hostname) throws InvalidArgument {

		 validateIpAddress (ipaddress);
		 validateHostname (hostname);

		 this.hostsFileContent = this.hostsFileContent + "\n" + ipaddress + " " + hostname;
		 saveFile();
	  }

	  public void remove (HostsRegex modRegex) {

		 try {

		   this.hostsFileContent = modRegex.replace(this.hostsFileContent, -1, 0, "");
		   saveFile();
		 }
		 catch (RegexError e) {

		   error("Regex failed: %s", e.message);
		 }
	  }

	  private void readFile () {

		 try {

		   FileUtils.get_contents (Config.hostfile_path (), out this.hostsFileContent, null);
		 }
		 catch (Error e) {

		   error ("Unable to read file: %s", e.message);
		 }
	  }

	  private void saveFile () {

		 try {

		   FileUtils.set_contents(Config.hostfile_path (), this.hostsFileContent, this.hostsFileContent.length);
		 }
		 catch (Error e) {

		   error ("Unable to save file: %s", e.message);
		 }
	  }

	  private void validateHostname (string hostname) throws InvalidArgument {

		 if (!Regex.match_simple("^" + Config.hostname_regex_str() + "$", hostname)) {

		   throw new InvalidArgument.HOSTNAME ("Invalid hostname format");
		 }
	  }

	  private void validateIpAddress (string ipaddress) throws InvalidArgument {

		 if (!Regex.match_simple("^" + Config.ipaddress_regex_str() + "$", ipaddress)) {

		   throw new InvalidArgument.IPADDRESS ("Invalid ip address format");
		 }
	  }
	}
}
