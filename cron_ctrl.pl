#!/usr/bin/perl

use Getopt::Long;

sub start {
    my $cmd = "@ARGV[0]";
    my @cron_out = `crontab -l`;
    my @result;

    while (@cron_out) {
        my $line = shift @cron_out;
        # all command will not followed by any parameters
        if ($line =~ /$cmd/ && $line =~ /#./) {
            $line =~ s/^#+//;
        }
        @result = (@result, $line);
    }

    open(OUTFILE, ">/tmp/cron_ctrl_temp_file");
    print OUTFILE @result;

    `crontab /tmp/cron_ctrl_temp_file`;
}

sub stop {
    my $cmd = "@ARGV[0]";
    my @cron_out = `crontab -l`;
    my @result;

    while (@cron_out) {
        my $line = shift @cron_out;
        # all command will not followed by any parameters
        if ($line =~ /$cmd/) {
            $line = "#$line";
        }
        @result = (@result, $line);
    }

    open(OUTFILE, ">/tmp/cron_ctrl_temp_file");
    print OUTFILE @result;

    `crontab /tmp/cron_ctrl_temp_file`;
}

sub list {
    my @cron_out = `crontab -l`;
    my @result;

    while (@cron_out) {
        my $line = shift @cron_out;
        if ($line !~ /#./) {
            @result = (@result, $line);
        }
    }

    print @result;
}

sub run {
    Getopt::Long::GetOptions('start'=>\$start, 'stop'=>\$stop, 'list'=>\$list);

    if (defined($start)) {
        start(@ARGV);
        return;
    }

    if (defined($stop)) {
        stop(@ARGV);
        return;
    }

    if (defined($list)) {
        list(@ARGV);
        return;
    }
}

run();
