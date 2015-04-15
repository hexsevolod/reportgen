#!/usr/bin/perl
use strict;
use warnings;

my ($fname) = @ARGV;
open my $file, '>', $fname or die $!;

my $com; #look of comments
my $lang; #some default language constructions
if ($fname =~ m/(?:\.c|\.cpp|\.cxx|\.cc|\.h)/) {
    $com = '//';
    
}
elsif ($fname =~ m/\.sql/) {
    $com = '--';
}
elsif ($fname =~ m/\.pl/) {
    $com = '#';
    $lang = "use strict;\nusewarnings;\n"
}
else {
    $com = '#';
}
my $border = '-'x60;
my $name = `git config user.name`;chomp $name;
my $email = `git config user.email`;chomp $email;
my $date = `LANG=C date`;chomp $date;
print $file 
"$com$border\n",
"$com Description: \n",
"$com Author: $name <$email>\n",
"$com Created at: $date\n",
"$com$border\n",
"$lang";

