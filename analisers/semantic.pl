#!/usr/bin/perl
#------------------------------------------------------------
# Description: semantic analiser
# much more clever then syntax analiser
# Author: Iliya Tikhonenko <iliya.t@mail.ru>
# Created at: Sat Apr  4 23:57:08 MSK 2015
#------------------------------------------------------------
require "../dumper.pl";


sub fill {
#    print shift;
    my (%hash) = @_;
    my %mandatories = (
            type => 'article',
            reportfilename => 'report.txt',
            pattern => 'patterns/default',
            );
    my %additions = (
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

    foreach (keys %mandatories){
        if (not exists $mandatories{$_}) {
            warn "$_ not set"; 
            $hash{$_} = $mandatories{$_};
        }
    }
    
    foreach (keys %additions) {
        ;
    }
    return \%hash;
}

sub populate {
    my ($data) = @_;
    my %normalised;
    my $tag;
    chdir "../";
    foreach (keys %$data) {
        $tag = `./synonym.pl $_`;
        $normalised{$tag} = $data->{$_};
    }
    return %normalised;
}

my $data_ref = load_data();
print dump_data( fill( populate($data_ref) ) );

