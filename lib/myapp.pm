package myapp;
use Dancer ':syntax';

our $VERSION = '0.1';
my $dir = "/root";
my @list;

sub get_data {
    my @out = `ls -l $dir`;
    shift @out;
    while (@out) {
        my $line = shift @out;
        my @tmp = split(" ", $line);
        my $time = "@tmp[5] @tmp[6] @tmp[7]";
        my $name = @tmp[8];
        @list = (@list, $name, $time);
    }
}

sub combin {
    my $html;
    $html = "<table border=\"1\">";

    while (@list) {
        my $item = shift @list;
        $html = "$html<tr>";
        $html = "$html<th>$item</th>";
        $item = shift @list;
        $html = "$html<th>$item</th>";
        $html = "$html</tr>";
    }

    $html = "$html</table>";
    return $html;
}

get '/' => sub {
    get_data();
    return combin();
};

true;
