#!/usr/bin/perl 

use strict;
use IO::Socket::INET;

my $host = 'cube.ac';
#my $host = 'localhost';
my $port = 12345;
my ($socket, @data);

$socket = new IO::Socket::INET (
PeerAddr   => '127.0.0.1:5000',
Proto        => 'udp'
) or die "ERROR in Socket Creation : $!\n”;

$data = “cube data here”;
$socket->send(@data);

