#!/usr/bin/perl -w

use strict;
use CubeClient;

my $host = 'localhost';
my $port = 12345;

my $index = 0;
my @data = (255, 0, 255, 0, 255, 0);  # Purple, Green

my $client = CubeClient->new($host, $port);
$client->set_data($index, \@data);
