#!/usr/bin/perl
#--------------------------------------------
# Description: prepares links for images in Latex document
# Author: Iliya Tikhonenko <iliya.t@mail.ru>
# Created at: Mon Mar 23 22:47:31 MSK 2015
#--------------------------------------------
use strict;
use warnings;
use Getopt::Std;

my %opts;
getopts('f:d:',\%opts);
chdir ("../");
sub wrap{
    my ($fname) = @_;
    $fname =~ s/\..*$//;
    $fname =~ m/\/*(\w+)$/;
    my $label = $1;
    my $wrap;
    $wrap .= '\begin{figure}[h]'."\n";
    $wrap .= '\center{';
    $wrap .= '\includegraphics[width = 1.0\linewidth]{'."$fname"."}";
    $wrap .= "}\n";
    $wrap .= "\\caption{}\n";
    $wrap .= "\\label{img:".$label."}\n";
    $wrap .= '\end{figure}'."\n";
    return $wrap;
}
if (defined $opts{d}) {
    chdir($opts{d});
    foreach my $file (<*>) {
        if ($file =~ m/.*\.(?:png|jpg|pdf)$/){
            print &wrap($file), "\n";
        }
    }
}

elsif (defined $opts{f}) {
    my $file = $opts{f};
    if (not -e $file) { die "$file not exists"; }
    if ($file =~ m/.*\.(?:png|jpg|pdf)/) {
            print &wrap($file), "\n";
    }
}
