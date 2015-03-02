#!/usr/bin/perl
#----------------------------------------------------------------------
# Description: REPORTGEN parser
# Author:  Tiknonenko Iliya (iliya.t@mail.ru)
# Created at: Mon Mar 2 22 20:30:00 MSK 2015
# Computer: tis 
#----------------------------------------------------------------------
use strict;
use warnings;

my $defaultreportname='report.tex';
sub parse {
    my ($cmdfile) = @_;
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
            if (/make\b/i){
                if (/\b(report|article|book)\b/) {
                    $docdata{type} = $1;
                    if (/named\s+"(\S+)"/){
                        $docdata{reportfilename} = $1;
                    }
                    else {
                        $docdata{reportfilename} = $defaultreportname;
                    }
                    if (/like\s+"(\S+)"/) {
                        $docdata{pattern}=$1;
                    }
                }
                else {
                    die "unknown doctype\n";
                }
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
                elsif(/(\w+)\s+\b(?:is|are|am)\b\s+("\S")/){
#capturing 'param is "taram"'
                    $docdata{$1}=$2;    
                }
            }
        }
    }
#end of human's speech parser
    return %docdata;
}

 
