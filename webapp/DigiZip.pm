package DigiZip;

use Mouse;
use Archive::Zip;

sub compress {
    my $self = shift;
    my $img1 = shift;
    my $img2 = shift;
    my $img3 = shift;
    my $csum1 = shift;
    my $csum2 = shift;
    my $csum3 = shift;
    my $ts = shift;
    my $caja = shift;
    
    my $file;

    my $zip = Archive::Zip->new;

    $zip->addString($img1, 'camara1.jpg')->desiredCompressionMethod('COMPRESSION_STORED');
    $zip->addString($img2, 'camara2.jpg')->desiredCompressionMethod('COMPRESSION_STORED');
    $zip->addString($img3, 'camara3.jpg')->desiredCompressionMethod('COMPRESSION_STORED');
    $zip->addString($csum1, 'camara1-md5.txt');
    $zip->addString($csum2, 'camara2-md5.txt');
    $zip->addString($csum3, 'camara3-md5.txt');
    $zip->addString("Pago realizado en la caja $caja", 'ubicacion.txt');
    $zip->addString("Fecha exacta en formato YYYY-MM-DD HH:MM:SS.NNNNNN --> $ts", 'marca-tiempo.txt');


    open my $fh, '>', \$file;

    $zip->writeToFileHandle($fh);

    close $fh;

    return $file;
    
}
    
1;
