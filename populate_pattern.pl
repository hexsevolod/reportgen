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
            print $1, "\n";
        }
        else {
            if (not m/^%/) {
                print $report $_;
            }
        }
    }
}


sub print_tag {
    my $tag = shift;
    chdir "handlers/";
    my %contents = %{ $docdata{contents} };
    my %prembl = %{ $docdata{preamble} };
    
    switch ($tag) {
        case 'table'  { report `./csv2latex.pl $contents{table}`    }
        case 'img'    { report `./img2latex.pl -d $contents{img}` }
        case 'scheme' { report `./img2latex.pl -f $contents{scheme}` }
        case 'author' { report "\\author\{$prembl{author}\}\n"}
        case 'babel'  { report '\usepackage['.$prembl{babel}.']'.'{babel}'."\n"}
        case 'class'  {
            if (defined $prembl{font}) {
                report '\documentclass'."\[$prembl{font}pt, a4paper\]{".$prembl{type}."}\n";
            }
            else {
                report '\documentclass'."\[a4paper\]{".$prembl{type}."}\n";
            }
        }
        case 'math'   {
            if ($prembl{math} == 1) {
                report '\usepackage{amsmath}'."\n".'\usepackage{amsfonts}'."\n".'\usepackage{amssymb}'."\n";
            }
        }
        case 'imgdir' { report '\graphicspath{{'.$prembl{img}."/}}\n" }
        case 'title'  { report '\title{'.$prembl{title}."}\n" }
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
        print "hello!\n";
        print $report '\graphicspath{'.$prembl{img}."/}\n";
    }
    elsif (m/title/) {
        print $report '\title{'.$prembl{title}."}\n";
    }
    
}

sub parsepat {
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
            while (<$pattern> and not m/>[^<|>]*$/) {
                $string .= $_;
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
parsepat();
print "
Hi, $docdata{controls}{human}!
I have done what you wanted.
You may find output in $docdata{controls}{reportfilename}.
Good luck.
    $docdata{controls}{machine}\n ";
