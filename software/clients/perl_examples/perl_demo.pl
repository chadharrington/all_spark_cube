#!/usr/bin/perl -w

use strict;
use AllSparkCubeClient;

my $host = 'localhost';
my $port = 12345;

my @data = (255, 0, 255, 0, 255, 0);  # Purple, Green

my $client = AllSparkCubeClient->new($host, $port);
$client->set_colors(\@data);

print "Success\n"
