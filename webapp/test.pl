#!/usr/bin/env perl

use Mojolicious::Lite;
use DateTime::Format::Pg;
use Imager;
use Digest::MD5 'md5_hex';
use DigiDBD;
use DigiZip;

get '/' => sub {
    my $self = shift;
    $self->render(template => 'search');
  };

post '/subset' => sub {
    my $self = shift;
    my $fecha = $self->param('fecha');
    my $caja = $self->param('caja');

    my $dater = DateTime::Format::Pg->new;
    my $obj = $dater->parse_datetime($fecha);
    my $date = $dater->format_timestamp($obj);

    my $pg = DigiDBD->new;
    my ($ref, $ts) = $pg->get_by_date($date, $caja);
    $self->render(text => 'No se encontraron coincidencias.') unless defined($ref);
    $self->stash(
    	ref => $ref,
	ts   => $ts,
	dater => $dater
	);
    
    $self->render(template => 'subset');
};


get '/thumbnail/:ref/(:cam).jpg' => sub {
    my $self = shift;
    my $ref = $self->param('ref');
    my $cam = $self->param('cam');
    my $jpg;

    my $obj = DigiDBD->new;
    my $pic = $obj->get_thumb($ref, $cam);

    my $imagen = Imager->new;
    $imagen->read(data => $pic, type => 'jpeg');

    my $thumb = $imagen->scale(xpixels => 100, qtype => 'preview');

    # $thumb->filter(type => 'autolevels');

    $thumb->write(data => \$jpg, type => 'jpeg');

    $self->render(data => $jpg, format => 'jpg');
    

};


get '/picture/:ref/(:cam).jpg' => sub {
    my $self = shift;
    my $ref = $self->param('ref');
    my $cam = $self->param('cam');

    my $obj = DigiDBD->new;
    my $pic = $obj->get_thumb($ref, $cam);

    $self->render(data => $pic, format => 'jpg');
    

};



get '/show/:id' => sub {
    my $self = shift;
    my $ref = $self->param('id');
    my $dater = DateTime::Format::Pg->new;

    my $pg = DigiDBD->new;

    my ($csum1, $csum2, $csum3, $caja, $ts) =
	$pg->get_more($ref);

    my $obj = $dater->parse_timestamp($ts);
    my $date = $dater->format_date($obj);
    my $time = $dater->format_time($obj);

    $self->stash(
	ref => $ref,
	csum1 => $csum1,
	csum2 => $csum2,
	csum3 => $csum3,
	caja => $caja,
	dia => $date,
	hora => $time
	);
    
    $self->render(template => 'show');
};


get '/zip/(:id).zip' => sub {
    my $self = shift;
    my $ref = $self->param('id');

    my $pg = DigiDBD->new;

    my ($img1, $csum1, $img2, $csum2, $img3, $csum3, $caja, $ts) =
	$pg->get_all($ref);

    my $file = DigiZip->new;

    my $zip = $file->compress($img1, $img2, $img3, $csum1, $csum2, $csum3, $ts, $caja);

    $self->render(data => $zip, type => 'zip');
};


post '/cheque' => sub {
    my $self = shift;
    my $num = $self->param('numero');

    $self->render(text => "Cheque numero $num solicitado, funcion no implementada");

};

app->start;
