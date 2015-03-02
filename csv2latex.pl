#!/usr/bin/perl
#----------------------------------------------------------------------
# Description: csv to latex parsable code translator
# Author: Iliya Tikhonenko (iliya.t@mail.ru)
# Created at: Mon Mar 2 20:46:24 MSK 2015
# Computer: tis 
#----------------------------------------------------------------------

use strict;
use warnings;

my $fname = $ARGV[0]; 
open (my $csvfile, "<", $fname) or die "file $fname not exists: $!\n";
my @line = split(/,/, <$csvfile>);
my $quant = $#line;
print '\begin{tabular}{|';
for (my $i = 0; $i < $quant+1; $i++){
    print 'c|';
}
print '}'."\n";
seek $csvfile , 0, 0;
print '\hline'."\n";
foreach (<$csvfile>){
    chomp;
    s/,/&/g;
    print $_.'\\\\'."\n", '\hline'."\n"; 
}
print '\end{tabular}'."\n";
close $csvfile;
