#!/usr/bin/perl

sub run {
    $info = `ifconfig`;
    @cards = split("\n\n", $info);

    @out;

    $count = 0;
    while ($count < @cards) {
        @lines = split("\n", @cards[$count]);
        @fields = split(" ", @lines[0]);
        $name = @fields[0];

        @fields = split(" ", @lines[1]);
        @symb = split(":", @fields[1]);
        $ip = @symb[1];

        @out = (@out, "$name $ip");
        $count++;
    }

    $count = 0;
    while ($count < @out) {
        print "@out[$count]\n";
        $count++;
    }
}

run();
