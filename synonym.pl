#!/usr/bin/perl
#------------------------------------------------------------
# Description: small module for finding synonyms in the dictionary
# Author: Iliya Tikhonenko <iliya.t@mail.ru>
# Created at: Thu Apr  2 22:49:52 MSK 2015
#------------------------------------------------------------
#use strict;
#use warnings;

use YAML::XS;
require 'dumper.pl';

#loading synonyms dictionary
sub get_dict {
    my $ref = load_data("dicts/syn.yml");
    return $ref;
}

sub find {
    my ($value) = @_;
    my @tags;
    my %dict = %{ get_dict() }; #dereferencing hash
    foreach my $key (keys %dict) {
        foreach (@{ $dict{$key} }) { #array from value
            if (m/$value/i) {
                push @tags, $key;
            }
        }
    }
    # checking if empty
    if (not defined $tags[0]) {
        push @tags, lc $value;
    }
    return @tags;
}

#serialisation using string
#for the case of collisions
print( join( "," , find(@ARGV) ) );
