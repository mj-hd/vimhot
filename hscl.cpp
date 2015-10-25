// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// hscl.cpp
//                                               Last Modified:2006/09/01-17:55.
//
// ���ꐫ�F���ɂ�����
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


#include <iostream.h>
#include <windows.h>
#include <sys/stat.h>


typedef BOOL (CALLBACK *HSPFUNC)( int, int, int, int );

HSPFUNC hsc_ini;
HSPFUNC hsc_objname;
HSPFUNC hsc_comp;
HSPFUNC hsc_getmes;
HSPFUNC hsc3_getruntime;
HSPFUNC hsc3_run;


// �}�C�N���\�t�g�d�l�̊֐��̃A�h���X�����߂ĕԂ�
static char *GetMSProcAddress( HINSTANCE hDll, char *_funcname ) {
    char funcname[128];
    char *entry;

    sprintf( funcname, "_%s@16", _funcname );
    entry = (char *)GetProcAddress( hDll, funcname );
    if( entry == NULL ) {
        throw "�֐��|�C���^���擾�ł��܂���ł����B\n";
    }

    return entry;

}

// �v���v���Z�b�T���ۂ����G���[�Ȃ畁�ʂ̃G���[���b�Z�[�W�d�l�ȃt�H�[�}�b�g�ɐ��`����
// ���������ۂ����炻�̂܂�ܖ߂�B
// ��������������̂Œ���
void toNormalErrorFormat( char _message[] ) {

    std::string message( _message );

    // - - - - �܂��͎�v�ȏ�񂪓������s���擾 - - - - //
    int headIndex = message.find( "#Error" );
    int footIndex = message.find( "#Fatal error reported." );

    // ��L�̌����őo��������Ȃ������炻��̓v���v���Z�b�T����݂łȂ��Ƃ݂Ȃ�
    if( (unsigned)footIndex == string::npos || (unsigned)headIndex == string::npos ) {
        return;
    }
    std::string targetLine = message.substr( headIndex, footIndex - headIndex );

    // - - - - �t�@�C�����擾 - - - - //

    int fileHeadIndex = targetLine.rfind( "[" );
    int fileFootIndex = targetLine.rfind( "]" );
    std::string fileName = targetLine.substr( fileHeadIndex + 1, fileFootIndex - fileHeadIndex - 1 );

    // - - - - �s���擾 - - - - //
    int lineHeadIndex = targetLine.find_first_of( "0123456789" );
    int lineFootIndex = targetLine.find_first_not_of( "0123456789", lineHeadIndex );
    std::string lineNumber = targetLine.substr( lineHeadIndex, lineFootIndex - lineHeadIndex );

    // - - - - ���K�̏璷�ȏ��͍���Ƃ� - - - - //
    targetLine = targetLine.substr( 0, targetLine.find( " in " ) );

    targetLine = targetLine.substr( targetLine.find( ":" ) + 1, string::npos );
    std::string hoge = fileName + "(" + lineNumber + ")" + " : error -1 : " + targetLine;

    wsprintf( _message, "%s", ( message.substr( 0, headIndex ) + hoge ).c_str() );

}


void printUsage(void) {
    cout << "# hscl\n";
    cout << "\n";
    cout << "[����]\n";
    cout << " hscl \"�Ώۃt�@�C����\"     ���ꂾ���ŃR���p�C��and���s���\�ł�\n";
    cout << "\n";
    cout << "[hscl.ini]\n";
    cout << " �\�[�X�R�[�h�Ɠ����f�B���N�g����hscl.ini�Ƃ����t�@�C����u�����Ƃł�����Ƃ����ݒ肪�o���܂��B\n";
    cout << "ini�t�@�C���̃Z�N�V������hscl�݂̂ɂȂ��Ă���A�ݒ�̓L�[�����Œ��ڎw�肷�邱�ƂɂȂ�܂��B\n";
    cout << "\n";
    cout << " rootfile=filename:        �R���p�C���Ώۂ������I�Ɍ��肷��\n";
    cout << " debuginfo=0~1:            �f�o�b�O����t�����邩�ǂ���\n";
    cout << " exmacro=0~1:              �g���}�N�����g�p���邩�ǂ���\n";
    cout << " debugmode=0~1:            �f�o�b�O���[�h���g�p���邩�ǂ���\n";
    cout << " shortprog=0~1:            �΃V���[�g����p�̃��b�Z�[�W��\��\n";
    cout << " debugwindow=0~1:          �f�o�b�O�E�B���h�E��\�����邩�ǂ���\n";
    cout << "\n";
    cout << "e.x)�R���p�C���Ώۂ�test.hsp�A�f�o�b�O�E�B���h�E���g�p�B\n";
    cout << " [hscl]\n";
    cout << " rootfile=test.hsp\n";
    cout << " debugwindow = 1\n";
    cout << "\n";
}


int compile( int debugInfo, int exMacro, int debugMode, int debugWindow ) {

    // �R���p�C�����s
    try {
        if( hsc_comp( debugInfo, ( exMacro == 0 ) | debugMode << 1, debugWindow, 0 ) ) {
            throw NULL;
        }
    }
    catch( void *e ) {
        char errorMessage[1024];
        hsc_getmes( (int)errorMessage, 0, 0, 0 );
        toNormalErrorFormat( errorMessage );
        cout << errorMessage;
        return 1;
    }

    return 0;
}


void shortInfo( char *hspobj ) {
    int lastsize = 0;
    FILE *fp;
    if( ( fp = fopen( "hscl.dat", "r" ) ) != NULL ) {
        fscanf( fp, "%d", &lastsize );
        fclose( fp );
    }

    struct stat fileInfo;
    if( stat( hspobj, &fileInfo ) == -1 ) {
        fprintf( stderr, "Error(%d) [stat]", errno );
    }
    int fileLimit = 4096;
    int dist = fileLimit - fileInfo.st_size;
    int difs = fileInfo.st_size - lastsize;
    printf( "compile: %d(%d %c %d)Bytes, %dBytes %s  ...%s", 
            fileInfo.st_size,
            fileLimit,
            dist >= 0 ? '-' : '+',
            dist >= 0 ? dist : -dist,
            difs,
            difs >= 0 ? "added" : "decreased",
            fileInfo.st_size <= fileLimit ? "OK!" : "TOO BIG!!" );

    if( ( fp = fopen( "hscl.dat", "w" ) ) != NULL ) {
        fprintf( fp, "%d", fileInfo.st_size );
        fclose( fp );
    } else {
        printf( "fail" );
    }
}


int main( int argc, char *argv[] ) {

    // ��������������
    if( argc == 1 ) {
        printUsage();
        return 0;
    }


    // �����̃f�B���N�g���p�X���擾
    std::string exeDirpath( argv[0] );
    exeDirpath = exeDirpath.substr( 0, exeDirpath.rfind( "\\" ) );

    // �J�����g�f�B���N�g�����擾
    char currentDirectory[_MAX_PATH];
    GetCurrentDirectory( _MAX_PATH, currentDirectory );

    // ini�̐ݒ��ǂݍ���
    char settingFile[_MAX_PATH];
    char hspobj[_MAX_PATH];

    wsprintf( settingFile, "%s\\%s", currentDirectory, "hscl.ini" );

    GetPrivateProfileString( "hscl", "rootfile", argv[1], argv[1], _MAX_PATH, settingFile );
    GetPrivateProfileString( "hscl", "objfile", "obj", hspobj, _MAX_PATH, settingFile );

    int debugInfo = GetPrivateProfileInt( "hscl", "debuginfo", 1, settingFile ) != 0;
    int exMacro = GetPrivateProfileInt( "hscl", "exmacro", 1, settingFile ) != 0;
    int debugMode = GetPrivateProfileInt( "hscl", "debugmode", 0, settingFile ) != 0;
    int debugWindow = GetPrivateProfileInt( "hscl", "debugwindow", 0, settingFile ) != 0;
    int shortProg = GetPrivateProfileInt( "hscl", "shortprog", 0, settingFile ) != 0;


    // dll�ǂݍ���
    HINSTANCE hDll;
    try {
        hDll = LoadLibrary( ( exeDirpath + "\\" + "hspcmp.dll" ).c_str() );
        if( hDll == NULL ) {
            throw "DLL�̓ǂݍ��݂Ɏ��s���܂����B\n���̃G���[�͎��s�t�@�C���Ɠ����ꏊ�� hspcmp.dll ��u���Β���܂��B\n�Ƃ������}�j���A���ǂ�ł���������B\n";
        }
    }
    catch( char *e ) {
        cout << e;
        return 0;
    }

    // �֐��ǂݍ���
    try {
        hsc_ini = (HSPFUNC)GetMSProcAddress( hDll, "hsc_ini" );
        hsc_objname = (HSPFUNC)GetMSProcAddress( hDll, "hsc_objname" );
        hsc_comp = (HSPFUNC)GetMSProcAddress( hDll, "hsc_comp" );
        hsc_getmes = (HSPFUNC)GetMSProcAddress( hDll, "hsc_getmes" );
        hsc3_getruntime = (HSPFUNC)GetMSProcAddress( hDll, "hsc3_getruntime" );
        hsc3_run = (HSPFUNC)GetMSProcAddress( hDll, "hsc3_run" );
    }
    catch( char *e ) {
        cout << e;
        return 0;
    }


    // �r�o����I�u�W�F�N�g�̐ݒ�
    hsc_ini( 0, (int)argv[1], 0, 0 );
    hsc_objname( 0, (int)hspobj, 0, 0 );


    if( shortProg ) {
        if( compile( 0, exMacro, debugMode, debugWindow ) ) return 1;
        shortInfo(hspobj);
        if( compile( 1, exMacro, debugMode, debugWindow  ) ) return 1;
    } else {
        if( compile( debugInfo, exMacro, debugMode, debugWindow  ) ) return 1;
    }


    // ���s���s
    char cfname[_MAX_PATH];
    *cfname = 0;
    hsc3_getruntime( (int)cfname, (int)hspobj, 0, 0 );

    char execmd[1024];
    wsprintf( execmd, "%s %s",
            ( *cfname == 0 ) ? "hsp3" : cfname, 
            hspobj );
    
    try {
        if( hsc3_run( (int)execmd, 0, 0, 0 ) != 0 ) {
            throw "�����^�C���t�@�C����������܂���\n���̃G���[�� hsp3.exe �����s�t�@�C���Ɠ����ꏊ�ɒu���Α�������܂��B\n�Ƃ������}�j���A���ǂ�ł���������\n";
        }
    }
    catch( char *e ) {
        cout << e;
        return 0;
    }

    return 0;

}
