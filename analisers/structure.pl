#! /usr/bin/perl
#------------------------------------------------------------
# Description: generates structured data for latex preamble from 
# single hash
#
# Author: Iliya Tikhonenko <iliya.t@mail.ru>
# Created at: Fri Apr 10 13:45:23 MSK 2015
#------------------------------------------------------------
use strict;
use warnings;

require "../dumper.pl";

my $docdata = load_data();

sub specialise {
    my %document;
    foreach (keys %$docdata) {
        #individually handling 'img' and 'human'
        if (/human/) {
            #need for simple UI
            $document{preamble}{author} = $docdata->{$_};
            $document{controls}{$_} = $docdata->{$_};
        }
        
        elsif (/img/) {
            $document{preamble}{$_} = $docdata->{$_};
            $document{contents}{$_} = $docdata->{$_};
        }

        elsif (/(?:math|font|type|babel|title)/) {
            $document{preamble}{$_} = $docdata->{$_};
        }

        elsif (/(?:machine|pattern|reportfilename)/) {
            $document{controls}{$_} = $docdata->{$_};
        }

        else {
            $document{contents}{$_} = $docdata->{$_};
        }
    }
    return \%document;
}

print dump_data(specialise());
