#! /usr/bin/perl

#------------------------------------------------------------
# Description: syntax analiser(parser) 
# creates 'raw' hash 
# Author: Iliya Tikhonenko <iliya.t@mail.ru>
# Created at: Sat Apr 4 23:56:58 MSK 2015
#------------------------------------------------------------
use strict;
use warnings;

require "../dumper.pl";

my $cmdfile;

sub eval_opt {
    my ($i, $action, $error) = @_;
    if (exists $ARGV[$i+1] and $ARGV[$i+1] =~ m/^[^-].*/) {
        $action->();
    }
    else {
        die $error;
    } 

}
sub extract {
    my $i = 0; 
    while (exists $ARGV[$i]){
        if ($ARGV[$i] eq '-h'){
            print "
This is R E P O R T G E N parser \n
Usage: parser -i <file with instructions>
              ";
            $i++;
        }
        elsif ($ARGV[$i] eq '-i' or $ARGV[$i] eq '--input') {
            eval_opt($i, 
                    sub { 
                    open $cmdfile, '<:encoding(UTF-8)', $ARGV[$i+1] 
                    or die "file not exists\n";
                    },
                    "file with directives not specified\n");
            $i+=2;
        }
        else {
            die "unknown command-line argument\n";
        }
    }
}

sub parse {
    chdir ("../");
    extract();
    if (not defined($cmdfile)) {die "I don't know what to do\n"};
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
                elsif(/(\w+)\s+\b(?:is|are|am)\b\s+"(\S+)"/){
#capturing 'param is "taram"'
                    $docdata{$1}=$2;    
                }
            }
        }
    }
#end of human's speech parser
#checking some valuable values
#or setting them)
    return %docdata;
    close $cmdfile;
}

my %data = parse();

#print %data;
print dump_data(\%data);

