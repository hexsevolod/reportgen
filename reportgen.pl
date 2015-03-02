#! /usr/bin/perl
#----------------------------------------------------------------------
# Description: REPORTGEN main file
# Author:  Tiknonenko Iliya (iliya.t@mail.ru)
# Created at: Sun Feb 22 18:41:03 MSK 2015
# Computer: tis 
#----------------------------------------------------------------------
use strict;
use warnings;

#should rewrite using modules
require "parser.pl";

my $inp;
my $cmdfilename;
my $reportfilename;
sub prompt{
    print "".$_[0]."\n";
    $inp = <>;
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

open(my $cmdfile, '<', $cmdfilename) or die "$cmdfilename not exist";
#parsing
my %docdata = parse($cmdfile);


open(my $report , '>', $docdata{reportfilename});

print $report '\documentclass'."\[$docdata{font}pt, a4paper\]{".$docdata{type}."}\n";
print $report '\usepackage[utf8]{inputenc}'."\n";
if ($docdata{math} == 1){
    print $report '\usepackage{amsmath}'."\n".
          '\usepackage{amsfonts}'."\n".'\usepackage{amssymb}'."\n";
}

if (defined($docdata{babel})){
    print $report '\usepackage['.$docdata{babel}.']'.'{babel}'."\n";
}
print $report '\author{'.$docdata{human}."}\n";

print $report "\\begin{document}\n";
if (defined($docdata{data}) or defined($docdata{data})){
    $docdata{table} = $docdata{data};
    print $report `./csv2latex.pl $docdata{table}`;
}
print $report "\\end{document}\n";

close $cmdfile;
close $report;
#just log
#my @keys = keys %docdata; 
#foreach (@keys){
#    print "".$_.":".$docdata{$_}."\n";
#}
print "
Hi, $docdata{human}!
I have done what you wanted.
You may find output in $docdata{reportfilename}.
Good luck.
    $docdata{machine}\n ";
