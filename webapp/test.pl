#!/usr/bin/env perl

use Mojolicious::Lite;

get '/' => sub {
    my $self = shift;
    $self->render(text => 'Hello World!');
  };

post '/search' => sub {
    my $self = shift;
    $self->render(text => 'La busqueda');
};

get '/show/:id' => sub {
    my $self = shift;
    $self->render(text => 'Detalle');
};

app->start;
