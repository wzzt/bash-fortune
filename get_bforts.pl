#!/opt/local/bin/perl

use strict;
use HTML::Entities;
use LWP::UserAgent;

# Get script directory
$0 =~ /^(.+[\\\/])[^\\\/]+[\\\/]*$/;

my $PROGDIR = $1 || './';
my $URL;
   $URL = 'http://bash.org/?random1';
#  $URL = 'http://bash.org/?random'; #Uncomment for negatively scored quotes
my $FORTUNEFILE = 'fortunes_b';
my $DELIMITER = "\0";
my $WW_WIDTH = 70; # Word wrap width

# ANSI Escape quotes (for quote #, pos./neg./neut. scores, quote body, end)
# Default: Bold yellow, green, red, grey, grey
my $CL_NUM = "\033[01;33m";
my $CL_POS = "\033[00;32m";
my $CL_NEG = "\033[00;31m";
my $CL_NEU = "\033[00;37m";
my $CL_BDY = "\033[00;37m";
my $CL_END = "\033[00m";

my $page;

eval{ $page = LWP::UserAgent->new->get("$URL")->content };

if ($@) {
    print STDERR "Error: could not retrieve bash page\n";
    exit 2;
}

# Get metadata, quote pairs
my @fortunes = $page =~
    /<p class="quote">([\s\S]+?)<\/p>[\s\S]*?<p class="qt">([\s\S]+?)<\/p>/gim;

my @fortlist;

while (@fortunes) {
    my $metadata = shift(@fortunes);
    my $fortune = shift(@fortunes);
    my ($fnum, $score) = $metadata =~ /(#\d+)[\s\S]*?<font color="\w+">(-?\d+)/;
    $fortune =~ s/<\s*br\s*\/\s*>//g;
    $fortune =~ s/\r//g;
    $fortune = decode_entities($fortune);
    $fortune =~ s/(.{$WW_WIDTH}[^\s]*)\s+/$1\n/gm;
    # Hacky,but there are bugged empty quotes
    # that break the script otherwise
    next if $fnum eq undef or $fortune eq undef
        or $fortune =~ /Flag quote for review/;
    if ($score > 0) {
        push @fortlist, "$CL_NUM$fnum$CL_END ($CL_POS$score$CL_END):\n"
            . "$CL_BDY$fortune$CL_END\n";
    } elsif ($score < 0) {
        push @fortlist, "$CL_NUM$fnum$CL_END ($CL_NEG$score$CL_END):\n"
            . "$CL_BDY$fortune$CL_END\n";
    } else {
        push @fortlist, "$CL_NUM$fnum$CL_END ($CL_NEU$score$CL_END):\n"
            . "$CL_BDY$fortune$CL_END\n";
    }
}

open my $fort_fh, '>', "$PROGDIR$FORTUNEFILE"
    or print STDERR "Error: could not open fortune file for writing\n",
    exit 1;

print $fort_fh join $DELIMITER, @fortlist;

close $fort_fh;

exit 0;

