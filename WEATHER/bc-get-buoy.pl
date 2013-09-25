#!/bin/perl

# does pretty much what recent_weather_buoy() does, but tries to
# comply to weather2.sql and do more error checking

# specifically, writes to STDOUT SQL commands to populate weather.db
# (does not actually run them)

require "/usr/local/lib/bclib.pl";

# fields in buoy that convert directly to fields in weather.db TODO:
# can buoy ids conflict with other IDSs (and is this a issue since we
# also record type?)

%convert = ("LAT" => "latitude", "LON" => "longitude", "STN" => "id", 
	    "WDIR" => "winddir");

# these fields must be converted from m/s to mph
%convertms = ("WSPD" => "windspeed", "GST" => "gust");

# these fields must be converted to Farenheit
%convertcf = ("ATMP" => "temperature", "DEWP" => "dewpoint");

# get data, split into lines
my($out,$err,$res) = cache_command2("curl http://www.ndbc.noaa.gov/data/latest_obs/latest_obs.txt", "age=150");

# TODO: error check here and stop if $out is too small, $err exists,
# $res is non-zero or something

# this file is important enough to keep around
write_file($out, "/var/tmp/noaa.buoy.txt");

# HACK: csv() does not handle ",," well
$out=~s/,,/, ,/isg;

my(@reports) = split(/\n/, $out);
# find first nonblank line
do {$headers = shift(@reports)} until $headers;
# header line (remove '#' at start of line)
$headers=~s/^\#//isg;
@headers = split(/\s+/, $headers);
# useless line (gives units of measurements)
shift(@reports);

# go through reports
for $i (@reports) {

  # the whole report
  my(%dbhash) = ();
  $dbhash{observation} = $i;

  # set hash directly from data
  my(%hash) = ();
  @fields = split(/\s+/, $i);


  # set hash from headers
  for $j (0..$#headers) {
    # remove the space I added above (sigh)
    $fields[$j]=~s/^\s*$//isg;
    $hash{$headers[$j]} = $fields[$j];
  }

  # all BUOY data here
  $dbhash{type} = "BUOY";

  # the date (uses up many fields)
  $dbhash{time} = "$hash{YYYY}-$hash{MM}-$hash{DD} $hash{hh}:$hash{mm}:00";

  # pressure
  $dbhash{pressure} = convert($hash{PRES},"hpa","in");

  # set dbhash values that convert over
  for $j (keys %convert) {$dbhash{$convert{$j}} = $hash{$j};}

  # similar, but convert m/s to mph
  for $j (keys %convertms) {
    $dbhash{$convertms{$j}} = convert($hash{$j},"mps","mph");
  }

  # similar, but convert C to F
  for $j (keys %convertcf) {
    $dbhash{$convertcf{$j}} = convert($hash{$j},"c","f");
  }

  # push this hash to results
  push(@res, {%dbhash});
}

@queries = hashlist2sqlite(\@res, "weather");

print "BEGIN;\n";
print join(";\n", @queries);
print ";\nCOMMIT;\n";

=item headers

The list of data that buoy report provides that we do NOT use (from
http://www.ndbc.noaa.gov/measdes.shtml)

WVHT - wave height
DPD - Dominant wave period
APD - Average wave period
MWD - The direction from which the [DPD] waves [...] are coming
PTDY - pressure tendency (may add this later)
WTMP - Sea surface temperature (maybe use this later?)
VIS - Station visibility
TIDE - tide

=cut
