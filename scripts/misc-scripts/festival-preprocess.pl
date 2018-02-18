#!/usr/bin/perl -w

my $contents = "";

sub GetContents {
  while ($input = <STDIN>) {
    $contents .= $input;
  }
  return $contents;
}

sub FestivalPreprocess {
  my $contents = GetContents;

  # split into sentences
  my $OUT;
  open (OUT,">/tmp/preprocess");
  print OUT $contents;
  close (OUT);
  system "/home/ajd/bin/sentence-boundary.pl -d /home/ajd/bin/HONORIFICS -i /tmp/preprocess -o /tmp/postprocess";
  $contents = `cat /tmp/postprocess`;

  # now strip the sentences of extra junk
  $contents =~ s/[^a-zA-Z]{3,}/ /g;
  $contents =~ s/ [^a-zA-Z] / /g;
  return $contents;
}

print FestivalPreprocess;
