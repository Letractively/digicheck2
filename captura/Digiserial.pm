# Mijares Consultoría y Sistemas SL
# Released under Apache License 2.0
#
#


package Digiserial;

use Mouse;
use Device::SerialPort;
use IO::Socket::UNIX qw(SOCKET_STREAM);

sub write_config_file {

    my $self = shift;
    my $serial = new Device::SerialPort('/dev/ttyS0');
    $serial->baudrate(9600);
    $serial->parity('none');
    $serial->databits(8);
    $serial->stopbits(1);
    $serial->write_settings;
    $serial->save('/tmp/ttyS0.conf');
    $serial->close;
    warn "Created configuration for SerialPort\n";

}

sub start {
    
    my $self = shift;
    $self->write_config_file unless -f '/tmp/ttyS0.conf';
    my $serial = new Device::SerialPort('/tmp/ttyS0.conf') or die
	"Can't open SerialPort $!\n";
    $serial->write('0x4C0x610x6D0x610x6E0x6E0x610x0A0x0D');
    $serial->read_char_time(0);
    $serial->read_const_time(100);

    my $TIMES = 6000;
    my $timeout = $TIMES;

    while ($timeout > 0) {

	my ($count, $saw) = $serial->read(255);
	
	if ($count > 0) {
	    
	    $self->send($self->transform($saw));
	    $serial->write('0x400x400x40'); ## See if separated with spaces
	    last;

	} else {

	    $timeout--;

	}

	if ($timeout == 0) {
	    warn "Nothing in 10 minutes\n";
	}

    }

}
	    
sub transform {

    my $self = shift;
    my $char = shift;

    my %tabla = (
	0xC0 => '1',
	0xC1 => '2',
	0xC2 => '3',
	0xC3 => '4',
	0xC4 => '5',
	0xC5 => '6',
	0xC6 => '7',
	0xC7 => '8'
	);
    
    return $tabla{$char};
	
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
