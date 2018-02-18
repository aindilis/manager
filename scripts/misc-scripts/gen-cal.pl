#!/usr/bin/perl -w

my @weekdaylist = qw ( Mon Tue Wed Thu Fri Sat Sun );

$date = $ARGV[0] || "";
#$date = "-d'now -1 month'";

my $weekday = `date "+%a" $date`;
chomp $weekday;
my $dayofmonth = `date "+%d" $date`;
chomp $dayofmonth;
$daymod = $dayofmonth % 7;
my $month = `date "+%b" $date`;
chomp $month;
foreach my $i (split /\n/,`seq -w 1 31`) {
  print $weekdaylist[($i + $daymod + 3) % 7] . " $month $i\n";
}
