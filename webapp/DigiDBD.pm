package DigiDBD;

use Mouse;
use DBI;



sub get_by_date {
    
    my $self = shift;
    my $date = shift;
    my $caja = shift;
    
    my $dsn = "DBI:Pg:dbname=digick";
    
    my $dbh = DBI->connect($dsn, 'digick');

    my $query = "SELECT id, ts FROM record WHERE date_trunc('day', ts) = ?";

    $query .= "AND caja = ?" unless defined($caja);
    
    my $get_id = $dbh->prepare($query);

    defined($caja) ? $get_id->execute($date) : $get_id->execute($date,$caja);

    my (@ref, @ts);

    while (my ($x, $y) = $get_id->fetchrow_array) {
	push (@ref, $x);
	push (@ts, $y);
    }

    $get_id->finish;
    $dbh->disconnect;

    return undef unless (@ref > 0);

    return \@ref, \@ts;
}


sub get_thumb {
    my $self = shift;
    my $ref = shift;
    my $cam = shift;
    
    my $dsn = "DBI:Pg:dbname=digick";
    
    my $dbh = DBI->connect($dsn, 'digick');

    my $query = "SELECT img FROM ";
    $query .= $cam;
    $query .=  " WHERE id = ?";

    my $get_pic = $dbh->prepare($query);
    
    $get_pic->execute($ref);
    
    my $pic = $get_pic->fetchrow_arrayref;

    $get_pic->finish;

    $dbh->disconnect;

    return $pic->[0];
}    


sub get_more {
    my $self = shift;
    my $ref = shift;

    my $dsn = "DBI:Pg:dbname=digick";
    
    my $dbh = DBI->connect($dsn, 'digick');

    my $get_meta = $dbh->prepare("SELECT caja, ts FROM record WHERE id = ?");
    my $get_table1 = $dbh->prepare("SELECT csum FROM cam1 WHERE id = ?");
    my $get_table2 = $dbh->prepare("SELECT csum FROM cam2 WHERE id = ?");
    my $get_table3 = $dbh->prepare("SELECT csum FROM cam3 WHERE id = ?");

    $get_meta->execute($ref);
    $get_table1->execute($ref);
    $get_table2->execute($ref);
    $get_table3->execute($ref);

    my ($caja, $ts) = $get_meta->fetchrow_array;
    my $csum1 = $get_table1->fetchrow_arrayref;
    my $csum2 = $get_table2->fetchrow_arrayref;
    my $csum3= $get_table3->fetchrow_arrayref;

    $get_meta->finish;
    $get_table1->finish;
    $get_table2->finish;
    $get_table3->finish;

    $dbh->disconnect;

    return $csum1->[0], $csum2->[0], $csum3->[0], $caja, $ts;
}


sub get_all {
    my $self = shift;
    my $ref = shift;

    my $dsn = "DBI:Pg:dbname=digick";
    
    my $dbh = DBI->connect($dsn, 'digick');

    my $get_meta = $dbh->prepare("SELECT caja, ts FROM record WHERE id = ?");
    my $get_table1 = $dbh->prepare("SELECT img, csum FROM cam1 WHERE id = ?");
    my $get_table2 = $dbh->prepare("SELECT img, csum FROM cam2 WHERE id = ?");
    my $get_table3 = $dbh->prepare("SELECT img, csum FROM cam3 WHERE id = ?");

    $get_meta->execute($ref);
    $get_table1->execute($ref);
    $get_table2->execute($ref);
    $get_table3->execute($ref);

    my ($caja, $ts) = $get_meta->fetchrow_array;
    my ($img1, $csum1) = $get_table1->fetchrow_array;
    my ($img2, $csum2) = $get_table2->fetchrow_array;
    my ($img3, $csum3) = $get_table3->fetchrow_array;

    $get_meta->finish;
    $get_table1->finish;
    $get_table2->finish;
    $get_table3->finish;

    $dbh->disconnect;

    return $img1, $csum1, $img2, $csum2, $img3, $csum3, $caja, $ts;
}



1;
