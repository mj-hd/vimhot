# htags.pl
# HSP����^�O�𒊏o���邾��

use strict;
use warnings;

my $version = "0.0.2";
my $tagfile = "tags";


my $ARGC = @ARGV;
$ARGC == 0 and &printUsage and exit;        # no argument
my $option = $ARGV[0];


# remove tag file
$option ne "-a" and unlink( $tagfile );

# use standard output?
my $useStdOut = $option eq "-f";

# get Dir List
opendir( DIR, "./" );
my @dirlist = readdir( DIR );
closedir( DIR );

# print tag file information
open( OUT, ">> $tagfile" );
print OUT <<HERE;
!_TAG_FILE_FORMAT	2
!_TAG_FILE_SORTED	1
!_TAG_PROGRAM_AUTHOR	Gonbei	/gonbei0671\@hotmail.com/
!_TAG_PROGRAM_NAME	htags	/Tag generator for HSP language. The free compiler and so on are available on this page > [http://www.onionsoft.net/hsp/] /
!_TAG_PROGRAM_URL	http://hp.vector.co.jp/authors/VA038334/	//
!_TAG_PROGRAM_VERSION	$version	//
HERE
close( OUT );

my @files = $option eq "-R" ? @dirlist : @ARGV;
foreach my $filename ( @files ) {
    $filename =~ /\.hsp$/ or next;
    &writetags( $filename, $tagfile, $useStdOut );
}


open( IN, "< tags" );
my @file = <IN>;
@file = sort @file;
close( IN );

open( OUT, "> tags" );
print OUT @file;
close( OUT );





# �g�p���@��\�����ĂP��Ԃ�
sub printUsage {
    print <<HERE;
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
- htags version $version
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

htags [option] filename

option:

    -R
        �J�����g�f�B���N�g������HSP�t�@�C����S�Ē��ׂ�
        �T�u�f�B���N�g���͖���

    -a
        �^�O���X�V�ł͂Ȃ��h�ǉ��h����

    -f
        �W���o�͂�TagExplorer�����̏���f��
        TagExplorer��p

    �ȗ�
        �^�O���X�V

filename:
    
    HSP�̃t�@�C�����w�肷��
    �g���q��.hsp�Ŗ�����ΑS�Ė�������
    �����w�����

HERE
    return 1;
}


# �^�O�������o��
sub writetags {
    my $infile = shift;
    my $tagfile = shift;
    my $useStdOut = shift;
    open( IN, "<$infile" ) or print "�t�@�C����������܂���: $infile\n" and return 0;


    open( OUT, ">> $tagfile" );

    my $lineNumber = 0;

    foreach my $line ( <IN> ) {
        $lineNumber++;

        if( $line =~ /^\s*#(defcfunc|deffunc|cfunc|func|const|define|enum)[\t| ]*(.*)/ ) {

            my $tagtype = $1;
            my $tagname = $2;

            #get tag name
            $tagname =~ s/\s*(global|ctype)\s//g;
            $tagname =~ /^[a-zA-Z_][a-zA-Z0-9_]*/;
            $tagname = $&;

            $line =~ /^.*?$tagname.*/;

            my $exp = $&;
            $exp =~ s/(\/\/|;).*//g;
            $exp =~ s/(\/|\\)/\\$1/g;

            my( $field, $f ) = $tagtype =~ /(defcfunc|deffunc)/ ? ( "function", "f" ) :
                        $tagtype =~ /(define)/ ? ( "macro", "m" ) :
                        $tagtype =~ /(const)/ ? ( "constant", "m" ) :
                        $tagtype =~ /(enum)/ ? ( "enum", "e" ) :
                        $tagtype =~ /(cfunc|func)/ ? ( "function(DLL)", "p" ) : die "Not matched >> $tagtype";

            if( $useStdOut ) {
                print "$tagname\t$infile\t/^$exp\/;\"\t$field\tline:$lineNumber\n"
            } else {
                print OUT "$tagname\t\.\\$infile\t/^$exp\/\"\t$f\n";
            }

        }
        if( $line =~ /^\*(\S*)/ ) {

            my $tagname = $1;
            $tagname =~ /^[a-zA-Z_]/ or next;
            
            my( $field, $f ) = ( "label", "m" );

            if( $useStdOut ) {
                print "$tagname\t$infile\t/^\*$tagname\/;\"\t$field\tline:$lineNumber\n" if $useStdOut;
            } else {
                print OUT "$tagname\t\.\\$infile\t/^\*$tagname\/;\"\t$f\n";
            }
        }
    }

    close( IN );
    close( OUT );

    return 1;
}
