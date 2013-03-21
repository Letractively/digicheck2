#!/usr/bin/env perl

use strict;
use warnings;
use Video::Capture::V4l;
use IO::Socket::UNIX qw( SOCK_STREAM SOMAXCONN );
use Imager;
use DigiDB;

my $frame0;
my $frame1;
my $frame2;

my $grab0 = new Video::Capture::V4l('/dev/video0')
    or die "Unable to open Videodevice: $!";

my $grab1 = new Video::Capture::V4l('/dev/video1')
    or die "No pude abrir dispositivo $!";

my $grab2 = new Video::Capture::V4l('/dev/video2')
    or die "No pude abrir dispositivo $!";

my $obj = DigiDB->new;

my $channel0 = $grab0->channel(0); #1 is composite 0 is for tuner 
$channel0->norm(1);
$channel0->set;

my $channel1 = $grab1->channel(0); #1 is composite 0 is for tuner 
$channel1->norm(1);
$channel1->set;

my $channel2 = $grab2->channel(0); #1 is composite 0 is for tuner 
$channel2->norm(1);
$channel2->set;


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

my $caja = $line;

if ($line) {
    
    print "Client Sez: $line\n";
    
    for my $f (0, 1) {
	my $frame0 = $grab0->capture(1 - $f, 640, 480);
	$grab0->sync($f) or die "unable to sync";
    }
#    &guarda('0-' . $line);

    my $pic0 = &jpeg_roted($frame0);

    for my $f (0, 1) {
	my $frame1 = $grab1->capture(1 - $f, 640, 480);
	$grab1->sync($f) or die "unable to sync";
    }
#    &guarda('1-' . $line);

    my $pic1 = &jpeg($frame1);

    for my $f (0, 1) {
	my $frame2 = $grab2->capture(1 - $f, 640, 480);
	$grab2->sync($f) or die "unable to sync";
    }
#    &guarda('2-' . $line);

    my $pic2 = &jpeg($frame2);

    $obj->save2pg($pic0, $pic1, $pic2, $caja);

    
}

}


# sub guarda {
#     my $num = shift;
#     my $temp;
# # save $fr now, as it contains the raw BGR data 
#     open (JP, '>', \$temp) or die $!;
#     print JP "P6\n640 480\n255\n";    #header 
#     $frame = reverse $frame;
#     print JP $frame;
#     close JP;
    
#     my $img = Imager->new();
#     $img->read( data => $temp, type => 'pnm' )
# 	or warn $img->errstr();
#     $img->flip( dir => "hv" );
#     my $img2 = $img->rotate(right=>90);
#     $img2->write( data => \$temp, type => 'jpeg' )
# 	or warn $img->errstr;   
#     open JP, '>', "~/file$num.jpg" or die $!;
#     print JP $temp;
#     close JP;
# }

sub jpeg {

    my $raw = shift;
    my $temp;
# save $fr now, as it contains the raw BGR data 
    open (JP, '>', \$temp) or die $!;
    print JP "P6\n640 480\n255\n";    #header 
    $raw = reverse $raw;
    print JP $raw;
    close JP;
    
    my $img = Imager->new();
    $img->read( data => $temp, type => 'pnm' )
	or warn $img->errstr();
    $img->flip( dir => "hv" );
    $img->write( data => \$temp, type => 'jpeg' )
	or warn $img->errstr;
    return \$temp;
}

sub jpeg_roted {

    my $raw = shift;
    my $temp;
# save $fr now, as it contains the raw BGR data 
    open (JP, '>', \$temp) or die $!;
    print JP "P6\n640 480\n255\n";    #header 
    $raw = reverse $raw;
    print JP $raw;
    close JP;
    
    my $img = Imager->new();
    $img->read( data => $temp, type => 'pnm' )
	or warn $img->errstr();
    $img->flip( dir => "hv" );
    my $img2 = $img->rotate(right=>90);
    $img2->write( data => \$temp, type => 'jpeg' )
	or warn $img->errstr;   
    return \$temp;
}
