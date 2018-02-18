#!/usr/bin/perl -w

use Manager::Records::Context::TaskManager;

my $tm = Manager::Records::Context::TaskManager->new();
$tm->QueryUserAboutMappings;

