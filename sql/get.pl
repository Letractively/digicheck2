#!/usr/bin/perl

use strict;
use warnings;
use DBI;

my $dsn = "DBI:Pg:dbname=digick";

my $dbh = DBI->connect($dsn, 'digick');

my $q1 = $dbh->prepare("SELECT img FROM cam2 WHERE id = ?");

$q1->execute(203);

my @pics = $q1->fetchrow_array;

$q1->finish;

$dbh->disconnect;

my $memfile;
open FH, '>', '/tmp/img.jpg';
binmode FH;
print FH $pics[0];
close FH;
