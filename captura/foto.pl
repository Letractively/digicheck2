#!/usr/bin/env perl

use warnings;
use strict;
use Video::Capture::V4l;
use Imager;

my $frame;

my $grab = new Video::Capture::V4l
    or die "Unable to open Videodevice: $!";

# my $grab1 = new Video::Capture::V4l("/dev/video1")
#     or die "No pude abrir dispositivo $!";

# my $grab2 = new Video::Capture::V4l("/dev/video2")
#     or die "No pude abrir dispositivo $!";

# the following initializes the camera for NTSC 
my $channel = $grab->channel(3); #1 is composite 0 is for tuner 
$channel->norm(1);
$channel->set;

# my $channel1 = $grab1->channel(1); #1 is composite 0 is for tuner 
# $channel->norm(1);
# $channel->set;

# my $channel2 = $grab2->channel(2); #1 is composite 0 is for tuner 
# $channel->norm(1);
# $channel->set;

sleep 1;

for my $f (0, 1) {
    $frame = $grab->capture(1 - $f, 640, 480);
    $grab->sync($f) or die "unable to sync";
}
	
&guarda('0');

# for my $f (0, 1) {
#     $frame = $grab1->capture(1 - $f, 640, 480);
#     $grab1->sync($f) or die "unable to sync";
# }

# &guarda('1');

# for my $f (0, 1) {
#     $frame = $grab2->capture(1 - $f, 640, 480);
#     $grab2->sync($f) or die "unable to sync";
# }

# &guarda('2');



sub guarda {
    my $num = shift;
    my $temp;
# save $fr now, as it contains the raw BGR data 
    open (JP, '>', \$temp) or die $!;
    print JP "P6\n640 480\n255\n";    #header 
    $frame = reverse $frame;
    print JP $frame;
    close JP;
    
    my $img = Imager->new();
    $img->read( data => $temp, type => 'pnm' )
	or warn $img->errstr();
    $img->flip( dir => "hv" );
    my $img2 = $img->rotate(right=>90);
    $img2->write( data => \$temp, type => 'jpeg' )
	or warn $img->errstr;   
    open JP, '>', "file$num.jpg" or die $!;
    print JP $temp;
    close JP;
}
