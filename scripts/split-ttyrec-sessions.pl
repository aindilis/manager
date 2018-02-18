#!/usr/bin/perl -w

use Term::TtyRec;
use FileHandle;

use Time::HiRes qw(usleep);

# this is a way to split sessions into more easily manageable portions
# for viewing, etc.

my $file = shift;

if (0) {
  $file =~ /([0-9]+)\.ttyrec.gz$/;
  my $dir = $1;
  my $c = `zcat "$file"`;

  # unzip the file

  my $separator = '';

  system "mkdir /tmp/$dir";
  my $i = 0;
  my $OUT;
  foreach my $segment (split /$separator/, $c) {
    print length($segment)."\n";
    # save the segments in a temp file
    open(OUT,">/tmp/$dir/$i") or die "ouch!\n";
    print OUT $separator.$segment.$separator;
    close(OUT);
    ++$i;
  }
}

# $handle is any IO::* object
my $handle = FileHandle->new($file);
my $ttyrec = Term::TtyRec->new($handle);

# iterates through datafile
my $lsec;
while (my($sec, $text) = $ttyrec->read_next) {
  print $text;
  if ($lsec) {
    my $dur = 1000000.0*($sec - $lsec);
    # print "$dur\n";
    usleep(int($dur));
  }
  $lsec = $sec;
}
