#!/usr/bin/env perl

use strict;
use warnings;
use IO::Socket::UNIX qw( SOCK_STREAM SOMAXCONN );

#my $socket_path = '/tmp/wibble';
my $socket_path = '/tmp/digicheck2.socket';
unlink($socket_path);

my $listner = IO::Socket::UNIX->new(
   Type   => SOCK_STREAM,
   Local  => $socket_path,
   Listen => SOMAXCONN,
)
   or die("Can't create server socket: $!\n");

for(;;) {
my $socket = $listner->accept()
   or die("Can't accept connection: $!\n");


chomp( my $line = <$socket> );
print qq{Client Sez "$line"\n};
print $socket "Same to ya, fella\n";
}
