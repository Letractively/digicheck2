# Mijares Consultoría y Sistemas SL
# Copyright 2013 - All Rights Reserved
# Released under Apache License 2.0
#
#


package Digiserial;

use Mouse;
use Device::SerialPort;
use IO::Socket::UNIX;

sub write_config_file {

    my $self = shift;
    my $dev = shift;
    my $serial = new Device::SerialPort($dev);
    $serial->baudrate(115200);
    $serial->parity('none');
    $serial->databits(8);
    $serial->stopbits(0);
    $serial->write_settings;
    $serial->save('/tmp/serialport.conf');
    $serial->close;
    warn "Created configuration for SerialPort $dev\n";

}

sub start {
    
    my $self = shift;
    my $dev = shift;
    $self->write_config_file($dev) unless -e '/tmp/serialport.conf';
    my $serial = new Device::SerialPort('/tmp/serialport.conf') or die
	"Can't open SerialPort $!\n";
    $serial->read_char_time(0);
    $serial->read_const_time(100);
    
    my $buffer = '';
    
    my $TIMES = 6000;
    my $timeout = $TIMES;
    
    while ($timeout > 0) {
	
	my ($count, $saw) = $serial->read(255);
	
	chomp $saw;
	
	if ($count > 0) {
	    $buffer .= $saw;
	}
	
	if ($buffer) {
	    
	    if ($self->valid($buffer)) {
		print 'dice: ', $buffer, "\n";
		print 'ord: ', ord $buffer, "\n";
		$self->send($self->transform($buffer));
		last;
	    }
	    else {
		print "caracter no valido\n";
		last;
	    }
	}
	
	
	else {
	    $timeout--;
	}
	
	if ($timeout == 0) {
	    warn "Nothing in 10 minutes\n";
	}
	
    }
}

sub valid {

    my $self = shift;
    my $val = shift;
    my @chars = (97, 98 ,99, 100, 101, 102, 103, 104);
    return 1 if (ord($val) ~~ @chars);
    return 0;
}
	    


sub transform {

    my $self = shift;
    my $char = shift;

    my %tabla = (
        97 => '1',
	98 => '2',
	99 => '3',
	100 => '4',
	101 => '5',
	102 => '6',
	103 => '7',
	104 => '8'
	);
    
    return $tabla{ord($char)};
	
}



sub send {

    my $self = shift;
    my $control = shift;

    my $socket = IO::Socket::UNIX->new(
	Type => SOCK_STREAM,
	Peer => '/tmp/digicheck2.socket')
	or die "Can't connect to server: $!\n";

    print $socket $control;

}


1;
