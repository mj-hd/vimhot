#!/usr/bin/perl

use strict;
use open IN  => ":encoding(cp932)";

my $numArg = @ARGV;
if( $numArg <= 1 ) {        # no argument
    &printUsage();
    exit;
}

my $synname = shift;

foreach ( @ARGV ) {
    print "\" $_";
    &printSyntax( $_, $synname );
    print "\n";
}

exit;

sub printSyntax {

    open IN, shift;
    my $synname = shift;

    my $preLine = "";
    my $interval = 10;
    my $nprinted = 0;

    while( <IN> ) {
        s/[\r\n]+\z//;
        if( $preLine =~ /%index/ ) {
            if( $nprinted % $interval == 0 ) {
                print "\n";
                print "syn keyword $synname ";
            }
            print "$_ ";
            $nprinted++;
        }
        $preLine = $_ if $_ !~ /^$/;
    }
    print "\n";

    close IN;



}

sub printUsage {
    print <<HERE;
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
- - hs2syn.pl
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

hs2syn.pl syntax-name file-name ...

syntax-name:

    使用するシンタックスのグループ名を指定する

file-name:

    対象のhsファイルを指定する

HERE
}
