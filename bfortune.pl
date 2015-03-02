#!/opt/local/bin/perl

use strict;

# Get script directory
$0 =~ /^(.+[\\\/])[^\\\/]+[\\\/]*$/;

my $PROGDIR = $1 || './';
my $GETSCRIPT = 'get_bforts.pl';
my $FORTUNEFILE = 'fortunes_b';
my $DELIMITER = "\0";
my $ANSICOLORS = @ARGV ? $ARGV[0] : 1;

my @fortune_list;

sub get_fortune_list {
    local $/ = undef;
    open my $fort_fh, '<', "$PROGDIR$FORTUNEFILE"
        or die "Error: could not open fortune file for reading\n";
    @fortune_list = split "$DELIMITER", <$fort_fh>;
    close $fort_fh;
}

sub put_fortune_list {
    open my $fort_fh, '>', "$PROGDIR$FORTUNEFILE"
        or die "Error: could not open fortune file for writing\n";
    print $fort_fh join "$DELIMITER", @fortune_list;
    close $fort_fh;
}

sub retrieve_new_fortunes {
    my ($bg) = @_; # If bg, run in background
    if ($bg) {
        if ($^O eq 'MSWin32') {
            system("start /B perl \"$PROGDIR$GETSCRIPT\" 2>NUL");
        } else {
            system("perl \"$PROGDIR$GETSCRIPT\" & 2>/dev/null");
        }
    } else {
        if (system("perl \"$PROGDIR$GETSCRIPT\"")) {
            die "Error: retrieval script failed. " .
                "Check Internet connection?\n";
        }
    }
}

if (!(-e "$PROGDIR$FORTUNEFILE")) {
    retrieve_new_fortunes();
}

get_fortune_list();

if (!@fortune_list) {
    retrieve_new_fortunes();
    get_fortune_list();
}

my $fortune = shift @fortune_list;

# replace non-breaking spaces with standard spaces; helps with |more
$fortune =~ s/\xA0/ /g;

if (!$ANSICOLORS) {
    $fortune =~ s/\033\[.*?m//g
}

print $fortune;

if (@fortune_list < 2) {
    retrieve_new_fortunes('bg');
} else {
    put_fortune_list();
}

