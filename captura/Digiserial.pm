# Mijares Consultoría y Sistemas SL
# Released under Apache License 2.0
#
#


package Digiserial;

use Mouse;
use Device::SerialPort;
use IO::Socket::UNIX;

sub write_config_file {

    my $self = shift;
    my $serial = new Device::SerialPort('/dev/ttyS0');
    $serial->baudrate(44100);
    $serial->parity('none');
    $serial->databits(8);
    $serial->stopbits(0);
    $serial->write_settings;
    $serial->save('/tmp/ttyS0.conf');
    $serial->close;
    warn "Created configuration for SerialPort ttyS0\n";

}

sub start {
    
    my $self = shift;
    $self->write_config_file unless -f '/tmp/ttyS0.conf';
    my $serial = new Device::SerialPort('/tmp/ttyS0.conf') or die
	"Can't open SerialPort $!\n";
    $serial->read_char_time(0);
    $serial->read_const_time(100);

    $serial->write('Lamanna' . chr(0xa) . chr(0xd));

    my $buffer = '';

    my $TIMES = 6000;
    my $timeout = $TIMES;

    while ($timeout > 0) {
	
	my ($count, $saw) = $serial->read(255);
	
	chomp $saw;
	
	if ($count > 0) {
	    $buffer .= $saw;
	}
	
	if ($self->verified($buffer)) {
	    
	    print 'dice: ', $buffer, "\n";
	    print 'hex: ', hex $buffer, "\n";
	    print 'ord: ', ord $buffer, "\n";
	    print 'chr: ', chr $buffer, "\n";
	    last;
	    	    
	} else {
	    $timeout--;
	}
	
	if ($timeout == 0) {
	    warn "Nothing in 10 minutes\n";
	}
	
    }
    
}



sub verified {

    my $self = shift;
    my $val = shift;
    my @chars = (192, 193 ,194, 195, 196, 197, 198, 199);
    return (ord($val) ~~ @chars ? 1 : 0);
}
	    


sub transform {

    my $self = shift;
    my $char = shift;

    my %tabla = (
        192 => '1',
	193 => '2',
	194 => '3',
	195 => '4',
	196 => '5',
	197 => '6',
	198 => '7',
	199 => '8'
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