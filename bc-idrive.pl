#!/bin/perl

# Given a file with a list of idrive accounts and passwords, use
# idevsutil to dump filelists from each account (trivial wrapper
# around idevsutil), including username and password (dumping password
# is baddish, but since I'm using this for backup, it's more important
# to know the pw than to hide it)

require "/usr/local/lib/bclib.pl";

debug(%globopts);

my(@accts) = split(/\n/, read_file("$homedir/idrive-accounts.txt"));

for $i (@accts) {

  if ($i=~/^\s*$/ || $i=~/^\#/) {next;}

  my($u,$p) = split(/:/, $i);

  # must write pw to consistent temp file for caching
  my($pwfile) = "/var/tmp/".sha1_hex($i);
  write_file($p, $pwfile);

  # find IP address of server
  my($out, $err,$res) = cache_command2("/root/build/idevsutil_linux/idevsutil --password-file=$pwfile --getServerAddress $u", "age=86400");

  unless ($out=~/webApiServerIP=\"(.*?)\"/) {
    warn "NO IP ADDRESS FOR: $u";
    next;
  }

  my($ip) = $1;

  # TODO: have no idea why above doesn't work, but this is the IP that
  # does work at least for me
  $ip = "207.189.119.146";

  # TODO: standardize where I keep idevsutil
  my($cmd) = "/root/build/idevsutil_linux/idevsutil --password-file=$pwfile --search $u\@$ip\:\:home/", "age=3600";

  debug("CMD: $cmd");

  ($out, $err, $res) = cache_command2($cmd, "age=3600");

  print "User: $u\nPass: $p\n$out\n";
}

