#!/usr/bin/env perl

use Digiserial;

my $obj = Digiserial->new;

while (1) {

$obj->start('/dev/ttyS0');

}
