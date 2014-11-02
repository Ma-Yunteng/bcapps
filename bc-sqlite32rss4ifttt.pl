#!/bin/perl

# does exactly what sqlite32rss.pl does, but formatted and improved
# for IFTTT which requires a specific feed format

# given the output of sqlite3 -line -batch, create an RSS feed
# --title: feed title
# --desc: channel description
# --noheader: suppress the header, useful for testing

require "/usr/local/lib/bclib.pl";

unless ($globopts{noheader}) {print "Content-type: text/xml\n\n";}

print << "MARK";
<?xml version="1.0" encoding="ISO-8859-1" ?><rss version="2.0">
<channel><title>$globopts{title}</title><description>$globopts{desc}</description>

MARK
;

# read in the entire STDIN
local($/) = 0777;
my($all) = <STDIN>;

# and split on double newline
for $item (split(/\n\n/, $all)) {
  # if there is a title field, use it
  if ($item=~s/title\s+\=\s+(.*?)$//) {$title=$1;} else {$title="Untitled";}

  # list of fields, separated by commas
  $item=~s/\n/, /g;
  $item=~s/\s+\=\s+/: /g;
  $item=~s/\s+/ /g;
  $guid = sha1_hex($item);
print << "MARK";
<item><title>$title</title><link>http://barrycarter.info</link>
<description>$item</description>
<guid>$guid</guid>
</item>
MARK
;
}

print << "MARK";
</channel></rss>
MARK
;