#!/usr/bin/perl

# records the percent of time for user & system & idle every second,
# and only keep recent 7 days, one day one file, means that 
# the last 8th day's date file will be removed.

use strict;

my @last_us;
my @last_sy;
my @last_id;
my @last_total;

sub clear_file {
    my $mon = shift @_;
    my $day = shift @_;
    my $filename = "$mon-$day.log";
    if (-e $filename) {
        unlink($filename);
    }
}

sub extr_items {
    my $info = `cat /proc/stat`;
    my @lines = split("\n", $info);

    my @out;
    my $count = 0;

    while (@lines) {
        my $line = shift @lines;

        if ($line =~ /cpu /) {
            my ($name, $user, $nice, $sys, $idle, $iowait, $irq, $softirq, $steal, $guest) = split(" ", $line);
            my $total = $user + $nice + $sys + $idle + $iowait + $irq + $softirq + $steal + $guest;
            my $us = sprintf("%.2f", ($user - @last_us[0]) / ($total - @last_total[0]) * 100);
            my $sy = sprintf("%.2f", ($sys - @last_sy[0]) / ($total - @last_total[0]) * 100);
            my $id = sprintf("%.2f", ($idle - @last_id[0]) / ($total - @last_total[0]) * 100);
            @last_us[0] = $user;
            @last_sy[0] = $sys;
            @last_id[0] = $idle;
            @last_total[0] = $total;
            my @item = ("us:$us", "sy:$sy", "id:$id");
            @out = (@out, "@item");
        }

        if ($line =~ /cpu[\d]/) {
            $count++;
            my ($name, $user, $nice, $sys, $idle, $iowait, $irq, $softirq, $steal, $guest) = split(" ", $line);
            my $total = $user + $nice + $sys + $idle + $iowait + $irq + $softirq + $steal + $guest;
            my $us = sprintf("%.2f", ($user - @last_us[$count]) / ($total - @last_total[$count]) * 100);
            my $sy = sprintf("%.2f", ($sys - @last_sy[$count]) / ($total - @last_total[$count]) * 100);
            my $id = sprintf("%.2f", ($idle - @last_id[$count]) / ($total - @last_total[$count]) * 100);
            @last_us[$count] = $user;
            @last_sy[$count] = $sys;
            @last_id[$count] = $idle;
            @last_total[$count] = $total;
            my @item = ("us:$us", "sy:$sy", "id:$id");
            @out = (@out, "| $name @item");
        }
    }

    return "@out";
}

sub recording {
    my $mon = sprintf("%.2d", shift @_);
    my $day = sprintf("%.2d", shift @_);
    my $hour = sprintf("%.2d", shift @_);
    my $min = sprintf("%.2d", shift @_);
    my $sec = sprintf("%.2d", shift @_);
    my $record = extr_items();

    open(OUTFILE, ">>$mon-$day.log");
    print OUTFILE ("[$hour:$min:$sec] $record\n");
    close(OUTFILE);
}

sub run {
    while (1) {
        my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime(time() - 86400 * 7);
        clear_file(++$mon, $day);
        ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime();
        recording(++$mon, $day, $hour, $min, $sec);
        sleep(1);
    }
}

run();
