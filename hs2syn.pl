use strict;

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
    my $interval = 5;
    my $nprinted = 0;

    while( <IN> ) {
        s/\n//;
        if( $preLine =~ /%index/ ) {
            if( $nprinted % $interval == 0 ) {
                print "\n";
                print "syn keyword $synname ";
            }
            print $_;
            print " ";
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

    �g�p����V���^�b�N�X�̃O���[�v�����w�肷��

file-name:

    �Ώۂ�hs�t�@�C�����w�肷��

HERE
}
