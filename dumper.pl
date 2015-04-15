#!/usr/bin/perl
#------------------------------------------------------------
# Description: general dumping and loading functions
# This file was made to locate all crutches and bicycles here
# for unifing 
# Please, not cry
#
# there were some troubles with Yaml.pm package
# it is deprecated now 
#
# Author: Iliya Tikhonenko <iliya.t@mail.ru>
# Created at: Wed Mar 25 21:40:29 MSK 2015
#------------------------------------------------------------

use strict;
use warnings;
use YAML::XS;

sub dump_data {
    my ($ref) = @_;
    return Dump($ref);
}

# a kind of magic
# local used instead of my for special vars ($_, $", etc)
# If the $/ variable is undefined, 
# the <...> operator will read the entire file all at once:
# =====
# \   /
#  \_/
#  | |
#  | |
#   |
sub load_data {
    my $infile;
    if (defined($_[0])){
        my ($infilename) = @_;
        open $infile ,'<', $infilename or die $!;
    }
    else { $infile = \*STDIN; }
    my $dump = do { local $/ = undef; <$infile> };
    my $docdata_ref = Load($dump);
    return ($docdata_ref);
}

1;