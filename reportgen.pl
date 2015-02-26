#! /usr/bin/perl
#----------------------------------------------------------------------
# Description: REPORTGEN main file
# Author:  Tiknonenko Iliya (iliya.t@mail.ru)
# Created at: Sun Feb 22 18:41:03 MSK 2015
# Computer: tis 
# System: Linux 3.18.4-1-ARCH on i686
#
#----------------------------------------------------------------------

use strict;
use warnings;

#should rewrite using modules
#require "rr.pl";

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

#a kind of parser

my %docdata;
my $state = 'wait_begin';
foreach (<$cmdfile>){
#specifying begin and end of block
    if(/^\S.*/){
        if ($state eq 'wait_begin'){
            chomp($_);
            $docdata{machine} = $_;
            $state = 'wait_end';
        }
        else {
            chomp($_);
            $docdata{human} = $_;
            last;#equivalent to 'break'
        }
    }
#parsing commands/keywords
    else {
        if (/\b(report|article|book)\b.*\bnamed\b\s"(.*)"/) {
            $docdata{type} = $1;
            $reportfilename = $2;
        }
        elsif (/\bwith\b\s(\d*)?pt\sfont/){
            $docdata{font} = $1;
        }
        elsif (/\bmath\b/) { $docdata{math} = 1; }
        elsif (/I\swant:/){
# in my point of view  
# i will use 'I want'
# for some special case
# that need some LaTeX knowledge
            if (/want:.*\bbabel\b/){
                my $i;
                if (my @captured = /(?::|,)\s+(?:(\w+)\sbabel)+/g){
                    foreach $i (@captured){
                        if ($i ne $captured[$#captured]){
                            $docdata{babel}.= "".$i.",";
                        }
                        else{
                            $docdata{babel}.= "".$i;
                        }
                    }
                }
            }
#elsif...
        }
        elsif (/\b(?:is|are|am)\b/){
            if (/\b(?:is|are|am)\b(?:\s+\w+)*\s+\bin\b/){
#capturing 'param is in taram'
                if(/(\w+)\s+(?:is|are|am).*\bin\b\s+(\S+)/){
                    $docdata{$1}=$2;
                }
            }
            elsif(/(\w+)\s+\b(?:is|are|am)\b\s+(".*")/){
#capturing 'param is "taram"'
                $docdata{$1}=$2;    
            }
        }
    }
}
#end of human's speech parser

open(my $report , '>', $reportfilename);

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
close $cmdfile, $report;
#just log
#my @keys = keys %docdata; 
#foreach (@keys){
#    print "".$_.":".$docdata{$_}."\n";
#}
print "
Hi, $docdata{human}!
I have done what you wanted.
You may find output in $reportfilename.
Good luck.
    $docdata{machine}\n ";
