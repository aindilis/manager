#!/usr/bin/perl -w

my $file = shift;
print "Now reading file <$file>\n";

# convert file to text
my $result = `file $file`;
if ($result =~ /PDF document/) {
  system "pdftotext \"$file\" /tmp/output";
} else {
  system "cp \"$file\" /tmp/output";
}

# filter and read
system "cat /tmp/output | /home/ajd/bin/festival-preprocess.pl > /tmp/output2";

if ($result =~ /PDF document/) {
  system "festival --tts /tmp/output2 & killall xpdf";
  system "xpdf \"$file\"";
  system "killall -9 festival audsp";
} else {
  system "festival --tts /tmp/output2";
}
