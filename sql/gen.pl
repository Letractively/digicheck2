#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use DBD::Pg qw(:pg_types);
use Digest::MD5 'md5_hex';




my $dsn = "DBI:Pg:dbname=digick";

my $buf;
my $data1;
my $data2;
my $data3;

open FH, '<', '1.jpg';
binmode FH;
while (read(FH, $buf, 16384)) {$data1 .= $buf};
close FH;

print "data1 is " . length($data1) . "\n";

$buf = '';

open FH, '<', '2.jpg';
binmode FH;
while (read(FH, $buf, 16384)) {$data2 .= $buf};
close FH;

$buf = '';

open FH, '<', '3.jpg';
binmode FH;
while (read(FH, $buf, 16384)) {$data3 .= $buf};
close FH;

my $dbh = DBI->connect($dsn, 'digick');

my $q1 = $dbh->prepare("INSERT INTO cam1(img,csum) VALUES(?,?)");

my $q2 = $dbh->prepare("INSERT INTO cam2(img,csum) VALUES(?,?)");

my $q3 = $dbh->prepare("INSERT INTO cam3(img,csum) VALUES(?,?)");

my $q4 = $dbh->prepare("INSERT INTO record(img1,img2,img3,caja) VALUES(?,?,?,?)");

$q1->bind_param(1, undef, {pg_type => PG_BYTEA});

$q2->bind_param(1, undef, {pg_type => PG_BYTEA});

$q3->bind_param(1, undef, {pg_type => PG_BYTEA});

foreach (1) {
    $q1->execute($data1, md5_hex($data1));
    my $ref1 = $dbh->last_insert_id(undef, undef, 'cam1', undef);
    $q2->execute($data2, md5_hex($data2));
    my $ref2 = $dbh->last_insert_id(undef, undef, 'cam2', undef);
    $q3->execute($data3, md5_hex($data3));
    my $ref3 = $dbh->last_insert_id(undef, undef, 'cam3', undef);
    
    $q4->execute($ref1, $ref2, $ref3, 1);

}

$q1->finish;
$q2->finish;
$q3->finish;
$q4->finish;

$dbh->disconnect;
