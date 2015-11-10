#!/usr/bin/perl

use IO::Socket::INET;
use Getopt::Long;

$port = 8888;

sub run {
    GetOptions('host|h=s'=>\$host, 'cmd|c=s'=>\$cmd);

    if (!defined($host) || !defined($cmd)) {
        print STDOUT "Usage: ./control.pl --host|h ip --cmd|c \"command [args]\"\n";
        return;
    }

    $server = IO::Socket::INET->new(PeerAddr => "$host",
        PeerPort => $port,
        Proto    => "tcp",
        Type     => SOCK_STREAM)
        or die "Could not connect to $host:$port: $!\n";

    print $server "$cmd";
    shutdown($server, 1);

    while (<$server>) {
        print STDOUT $_;
    }

    close($server);
}

run();
