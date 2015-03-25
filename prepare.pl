#!/usr/bin/perl
use strict;
use warnings;

my ($fname) = @ARGV;
open my $file, '>', $fname or die $!;
my $border = '-'x60;
my $name = `git config user.name`;chomp $name;
my $email = `git config user.email`;chomp $email;
my $date = `LANG=C date`;chomp $date;
print $file 
"#$border\n",
"# Description: \n",
"# Author: $name <$email>\n",
"# Created at: $date\n",
"#$border\n";
