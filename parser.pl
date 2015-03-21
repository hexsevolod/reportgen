#!/usr/bin/perl
#----------------------------------------------------------------------
# Description: REPORTGEN parser
# Author:  Tiknonenko Iliya (iliya.t@mail.ru)
# Created at: Mon Mar 2 22 20:30:00 MSK 2015
# Computer: tis 
#----------------------------------------------------------------------
use strict;
use warnings;

sub check_docdata{
#    print shift;
    my (%hash) = @_;
    my %defaults = (
            type => 'article',
            reportfilename => 'report.txt',
            pattern => 'patterns/default',
            font => '12pt',
            babel => 'english'
            );

    if (not exists $hash{machine}) { 
        die "
            I'm too proud to be unnamed.
            Sinserly yours,
                     ".`uname -n`."\n";
    }
    elsif (not exists $hash{human}) {
        my $probable_human = `whoami`;
        chomp($probable_human);
        die "
            I am not allowded to talk to strangers.
            Maybe you are ".$probable_human." ? \n";
    }

    foreach (keys %defaults){
        if (not exists $defaults{$_}){
            $hash{$_} = $defaults{$_};
        }
    }
    return %hash;
}

sub parse {
    my ($cmdfile) = @_;
    my %docdata;
    my $state = 'wait_begin';
    foreach (<$cmdfile>){
        if(/^\S.*/){
#for comments
            if (/^#/){
                next;
            }
#specifying begin and end of block
            elsif ($state eq 'wait_begin'){
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
                    
                    if (/like\s+"(\S+)"/) {
                        $docdata{pattern}=$1;
                    }
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
#checking some valuable values
#or setting them)
    return check_docdata(%docdata);
}
1;
 
