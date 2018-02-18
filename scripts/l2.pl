#!/usr/bin/perl -w

use HTTP::Request;

use WWW::Mechanize;
# use LWP::UserAgent

my $mech = WWW::Mechanize->new;

# $mech->authorization_basic($username, $password);
# MechGet("https://<REDACTED>/button-bar.cgi");
# MechGet("https://<REDACTED>/loghours.cgi");
# MechGet("http://<REDACTED>/log.html");
$mech->get("http://<REDACTED>/log.html");

my $form = {
          'billable' => 'no',
          'job_id' => 18084,
          'time_out' => '21:13:53',
          'date_entered' => '07/24/06',
          'hours_description' => 'Total Time: 4.967 hours
Total Effort: 744.316

manager         Time: 4.906 Effort: 727.919
home            Time: 0.061 Effort: 14.242
rwhois          Time: 0.000 Effort: 2.155
',
          'total_hours' => '4.967',
          'time_in' => '14:36:34'
        };

print $mech->content();
$mech->submit_form
  (
   form_name => 'loghours',
   fields => $form,
  );

print $mech->content();
