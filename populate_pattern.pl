#!/usr/bin/perl
#----------------------------------------------------------------------
# Description: REPORTGEN apply_pattern function
# Author:  Tiknonenko Iliya (iliya.t@mail.ru)
# Created at: Sun Mar 5 18:33:56 MSK 2015
# ----------------------------------------------------------------------
use strict;
use warnings;
use Switch;
require "dumper.pl";

my $docdata_ref = load_data();
my %docdata = %$docdata_ref;

open (my $pattern, '<', "patterns/".$docdata{controls}{pattern}) or die "Pattern not specified: $!";
open (my $report, '>' , $docdata{controls}{reportfilename});
 

# add pairs key:'value' to the tag handler
sub report {
    foreach (@_) {
        if (m/<\[(\w+)\][^>]*>/) {
            print_tag($1);
        }
        else {
            print $report $_;
        }
    }
}


sub print_tag {
    my $tag = shift;
    chdir "handlers/";
    my %contents = %{ $docdata{contents} };
    my %prembl = %{ $docdata{preamble} };
    
    switch ($tag) {
        case m/table/  { print $report `./csv2latex.pl $contents{$tag}`    }
        case m/img/    { print $report `./img2latex.pl -d $contents{$tag}` }
        case m/scheme/ { print $report `./img2latex.pl -f $contents{$tag}` }
        case m/author/ { print $report "\\author\{$prembl{author}\}\n"}
        case m/babel/  { print $report '\usepackage['.$prembl{babel}.']'.'{babel}'."\n"}
        case m/class/   {
            if (defined $prembl{font}) {
                print $report '\documentclass'."\[$prembl{font}pt, a4paper\]{".$prembl{type}."}\n";
            }
            else {
                print $report '\documentclass'."\[a4paper\]{".$prembl{type}."}\n";
            }
        }
        case m/math/   {
            if ($prembl{math} == 1) {
                print $report '\usepackage{amsmath}'."\n".'\usepackage{amsfonts}'."\n".'\usepackage{amssymb}'."\n";
            }
        }
        case m/imgdir/ { print $report '\graphicspath{'.$prembl{img}."/}\n" }
        case m/title/  { print $report '\title{'.$prembl{title}."}\n" }
        else { warn "unsupported tag"}
    }
}

sub insert_preamble {
    my ($tag) = @_;
    my %prembl = %{ $docdata{preamble} };
    if ($tag =~ m/author/) {
        print $report "\\author\{$prembl{$_}\}\n";
    }
    
    elsif (m/babel/) {
        print $report '\usepackage['.$prembl{babel}.']'.'{babel}'."\n";
    }
    
    elsif (m/type/) {
        if (defined $prembl{font}) {
            print $report '\documentclass'."\[$prembl{font}pt, a4paper\]{".$prembl{type}."}\n";
        }
        else {
            print $report '\documentclass'."\[a4paper\]{".$prembl{type}."}\n";
        }
    }
    
    elsif (m/math/) {
        if ($prembl{math} == 1) {
            print $report '\usepackage{amsmath}'."\n".'\usepackage{amsfonts}'."\n".'\usepackage{amssymb}'."\n";
        }
    }
    elsif (m/imgdir/) {
        print $report '\graphicspath{'.$prembl{img}."/}\n";
    }
    elsif (m/title/) {
        print $report '\title{'.$prembl{title}."}\n";
    }
    
}

sub parse {
    my $string;
    my @captured;
    while (<$pattern>)
    {
# strings are concatenated
# until there is no unclosed tags
# everything is captured
# tag values are in angular brackets
        if (m/^\%.*$/) {
            next;
        }
        elsif (m/[^<|>]*<\[\w+\][^>]*/)
        {
            $string = $_; 
            while (<$pattern>) {
                $string .= $_;
                if (m/>[<|>]*$/) {
                    last;
                }
            }

            if (@captured = 
                    ($string =~ /([^<|>]*)(<\[\w+\][^>]*>)([^<|>]*)/g) ) {
                report(@captured);
            }

        }
        else {
            report($_);
        }
    }
}
parse();
print "
Hi, $docdata{controls}{human}!
I have done what you wanted.
You may find output in $docdata{controls}{reportfilename}.
Good luck.
    $docdata{controls}{machine}\n ";
