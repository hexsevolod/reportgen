#! /usr/bin/perl
#----------------------------------------------------------------------
# Description: REPORTGEN main file
# Author:  Tiknonenko Iliya (iliya.t@mail.ru)
# Created at: Sun Feb 22 18:41:03 MSK 2015
# Computer: tis 
#----------------------------------------------------------------------
use strict;
use warnings;

#TODO rewrite using modules 
#and Getopt::Std instead of hard handling
#we are not cyclists
require "dumper.pl";

my $cmdfilename;
my $reportfilename;
sub prompt{
    print "".$_[0]."\n";
    my $inp = <>;
    chomp($inp);
    return $inp;
}

if (!defined($ARGV[0])){
    print "
    This is   
    < R E P O R T G E N >
        LaTex reports generator
        \n";
    $cmdfilename = prompt("Input name of file with directives for REPORTGEN: ");

}
elsif ($ARGV[0] eq '-h'){
    print "
    This is   
    <  R E P O R T G E N  >
        LaTex reports generator
        \n";
}
else {
    $cmdfilename = $ARGV[0];
}

#parsing&applying
chdir "analisers/";
my $model = `./syntax.pl -i $cmdfilename | ./semantic.pl | ./structure.pl`;
print $model;
chdir "../";
`echo "$model" | ./populate_pattern.pl`;
