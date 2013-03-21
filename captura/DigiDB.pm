package DigiDB;

use Mouse;
use DBI;
use DBD::Pg qw/:pg_types/;
use Digest::MD5;

sub save2pg {
    
    my $self = shift;
    my $data0 = shift;
    my $data1 = shift;
    my $data2 = shift;
    my $caja = shift;

    my $dsn = "DBI:Pg::dbname=digick";

    my $dbh = DBI->connect($dsn, 'digick');

    my $q1 = $dbh->prepare("INSERT INTO cam1(img,csum) VALUES(?,?)");

    my $q2 = $dbh->prepare("INSERT INTO cam2(img,csum) VALUES(?,?)");
    
    my $q3 = $dbh->prepare("INSERT INTO cam3(img,csum) VALUES(?,?)");
    
    my $q4 = $dbh->prepare("INSERT INTO record(img1,img2,img3,caja) VALUES(?,?,?,?)");
    
    $q1->bind_param(1, undef, {pg_type => PG_BYTEA});
    
    $q2->bind_param(1, undef, {pg_type => PG_BYTEA});
    
    $q3->bind_param(1, undef, {pg_type => PG_BYTEA});

    $q1->execute($data0, md5_hex($data0));
    my $ref0 = $dbh->last_insert_id(undef, undef, 'cam1', undef);
    $q2->execute($data1, md5_hex($data1));
    my $ref1 = $dbh->last_insert_id(undef, undef, 'cam2', undef);
    $q3->execute($data2, md5_hex($data2));
    my $ref2 = $dbh->last_insert_id(undef, undef, 'cam3', undef);
    
    $q4->execute($ref0, $ref1, $ref2, $caja);
    
    $q1->finish;
    $q2->finish;
    $q3->finish;
    $q4->finish;
    
    $dbh->disconnect;
    
}
