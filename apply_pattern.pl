#!/usr/bin/perl
#----------------------------------------------------------------------
# Description: REPORTGEN apply_pattern function
# Author:  Tiknonenko Iliya (iliya.t@mail.ru)
# Created at: Sun Mar 5 18:33:56 MSK 2015
# ----------------------------------------------------------------------
use strict;
use warnings;
use Switch;
use YAML;

# a kind of magic
# local used instead of my for special vars ($_, $", etc)
# If the $/ variable is undefined, 
# the <...> operator will read the entire file all at once:
#======
#\   /
# | |
# | |
#  |
my $yml = do { local $/ = undef; <STDIN> };
my $docdata_ref = Load($yml);
$/="param";
#end of `crutched` code
 
print Dump($docdata_ref);
my %docdata = %$docdata_ref;


# add pairs key:'value' to the tag handler
sub report {
    foreach (@_) {
        if (m/<\[(w+)\][^>]*>/) {    
            print_tag($1);
        }

        else {
            print;
        }
    }
}

sub print_tag {
    my $tag = shift;
    if (not exists $docdata{$tag}) {
        die "Unknown tag!" 
    }
    else {
        switch ($tag) {
            case 'table' {`csv2latex $docdata{$tag}`; }
            case 'img' {` $docdata{$tag}`; }
            case 'table' {`csv2latex $docdata{table}`; }
            case 'table' {`csv2latex $docdata{table}`; }
            case 'table' {`csv2latex $docdata{table}`; }
            
        }
    }
    
}
sub apply {
    open (my $pattern, '<', $docdata{pattern}) or die "Pattern not specified";
    open (my $report, '>' , $docdata{reportfilename});
    my $string;
    my @captured;
    foreach (<$pattern>)
    {
# strings are concatenated
# until there is no uclosed tags
# everything is captured
# tag values are in angular brackets
        if (m/[^<|>]*<\[\w+\][^>]*/)
        {
            foreach (<$pattern>) {
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
            report ($_);
        }
    }
}
