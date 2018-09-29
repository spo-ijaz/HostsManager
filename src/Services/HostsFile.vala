public errordomain InvalidArgument
{
  HOSTNAME,
  IPADDRESS,
}

class HostsManager.Services.HostsFile
{
  private string hostsFileContent;

  public HostsFile()
  {
    readFile();
  }

  public MatchInfo getEntries()
  {
    MatchInfo entries;
    HostsRegex regex = new HostsRegex();
    regex.match(hostsFileContent, 0, out entries);
    return entries;
  }

  public void setEnabled(HostsRegex modRegex, bool active)
  {
    try
    {
      hostsFileContent = modRegex.replace(hostsFileContent, -1, 0, active ? """\n#\g<row>""" : """\g<row>""");
      saveFile();
    }
    catch (RegexError e)
    {
      GLib.error("Regex failed: %s", e.message);
    }
  }

  public void setIpAddress(HostsRegex modRegex, string ipaddress) throws InvalidArgument
  {
    if (!Regex.match_simple("^" + Config.ipaddress_regex_str + "$", ipaddress))
    {
      throw new InvalidArgument.IPADDRESS("Invalid ip address format");
    }

    try
    {
      hostsFileContent = modRegex.replace(hostsFileContent, -1, 0, """\g<enabled>""" + ipaddress + """\g<divider>\g<hostname>""");
      saveFile();
    }
    catch (RegexError e)
    {
      GLib.error("Regex failed: %s", e.message);
    }
  }

  public void setHostname(HostsRegex modRegex, string hostname) throws InvalidArgument
  {
    if (!Regex.match_simple("^" + Config.hostname_regex_str + "$", hostname))
    {
      throw new InvalidArgument.HOSTNAME("Invalid hostname format");
    }

    try
    {
      hostsFileContent = modRegex.replace(hostsFileContent, -1, 0, """\g<enabled>\g<ipaddress>\g<divider>""" + hostname);
      saveFile();
    }
    catch (RegexError e)
    {
      GLib.error("Regex failed: %s", e.message);
    }
  }

  private void readFile()
  {
    try
    {
      FileUtils.get_contents(Config.hostfile_name, out hostsFileContent, null);
    }
    catch (Error e)
    {
      GLib.error("Unable to read file: %s", e.message);
    }
  }

  private void saveFile()
  {
    try
    {
      FileUtils.set_contents(Config.hostfile_name, hostsFileContent, hostsFileContent.length);
    }
    catch (Error e)
    {
      GLib.error("Unable to save file: %s", e.message);
    }
  }
}