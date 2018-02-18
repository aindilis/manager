#!/usr/local/bin/perl -w

$TEMP = 0;
open(TEMP,"< temp");
while (<TEMP>) {
	s/\s*\n$//;
	tr/ /+/;
	system "netscape -remote 'openURL(http://www.google.com/search?q=$_)'";
	<STDIN>;
}
