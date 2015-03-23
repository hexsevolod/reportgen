#!/usr/bin/perl
#--------------------------------------------
# Description: prepares links for images in Latex document
# Author: Iliya Tikhonenko <iliya.t@mail.ru>
# Created at: Mon Mar 23 22:47:31 MSK 2015
#--------------------------------------------
use strict;
use warnings;
my ($imgdir) = @ARGV;
chdir($imgdir);

sub wrap{
    my ($fname) = @_;
    $fname =~ s/\..*$//;
    my $wrap;
    $wrap .= '\begin{figure}[h]'."\n";
    $wrap .= '\center{';
    $wrap .= '\includegraphics[width = 1.0\linewidth]{'."$fname"."}";
    $wrap .= "}\n";
    $wrap .= "\\caption{}\n";
    $wrap .= "\\label{img:$fname}\n";
    $wrap .= '\end{figure}'."\n";
    return $wrap;
}
foreach my $file (<*>) {
    if ($file =~ m/.*\.(?:png|jpg|pdf)/){
        print &wrap($file), "\n";
    }
}
