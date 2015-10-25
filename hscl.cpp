// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// hscl.cpp
//                                               Last Modified:2006/09/01-17:55.
//
// 統一性皆無につき注意
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


// マイクロソフト仕様の関数のアドレスを求めて返す
static char *GetMSProcAddress( HINSTANCE hDll, char *_funcname ) {
    char funcname[128];
    char *entry;

    sprintf( funcname, "_%s@16", _funcname );
    entry = (char *)GetProcAddress( hDll, funcname );
    if( entry == NULL ) {
        throw "関数ポインタを取得できませんでした。\n";
    }

    return entry;

}

// プリプロセッサっぽかいエラーなら普通のエラーメッセージ仕様なフォーマットに整形する
// ちがうっぽかたらそのまんま戻る。
// 第一引数をいじるので注意
void toNormalErrorFormat( char _message[] ) {

    std::string message( _message );

    // - - - - まずは主要な情報が入った行を取得 - - - - //
    int headIndex = message.find( "#Error" );
    int footIndex = message.find( "#Fatal error reported." );

    // 上記の検索で双方見つからなかったらそれはプリプロセッサがらみでないとみなす
    if( (unsigned)footIndex == string::npos || (unsigned)headIndex == string::npos ) {
        return;
    }
    std::string targetLine = message.substr( headIndex, footIndex - headIndex );

    // - - - - ファイル名取得 - - - - //

    int fileHeadIndex = targetLine.rfind( "[" );
    int fileFootIndex = targetLine.rfind( "]" );
    std::string fileName = targetLine.substr( fileHeadIndex + 1, fileFootIndex - fileHeadIndex - 1 );

    // - - - - 行数取得 - - - - //
    int lineHeadIndex = targetLine.find_first_of( "0123456789" );
    int lineFootIndex = targetLine.find_first_not_of( "0123456789", lineHeadIndex );
    std::string lineNumber = targetLine.substr( lineHeadIndex, lineFootIndex - lineHeadIndex );

    // - - - - お尻の冗長な情報は削っとく - - - - //
    targetLine = targetLine.substr( 0, targetLine.find( " in " ) );

    targetLine = targetLine.substr( targetLine.find( ":" ) + 1, string::npos );
    std::string hoge = fileName + "(" + lineNumber + ")" + " : error -1 : " + targetLine;

    wsprintf( _message, "%s", ( message.substr( 0, headIndex ) + hoge ).c_str() );

}


void printUsage(void) {
    cout << "# hscl\n";
    cout << "\n";
    cout << "[書式]\n";
    cout << " hscl \"対象ファイル名\"     これだけでコンパイルand実行が可能です\n";
    cout << "\n";
    cout << "[hscl.ini]\n";
    cout << " ソースコードと同じディレクトリにhscl.iniというファイルを置くことでちょっとした設定が出来ます。\n";
    cout << "iniファイルのセクションはhsclのみになっており、設定はキーだけで直接指定することになります。\n";
    cout << "\n";
    cout << " rootfile=filename:        コンパイル対象を強制的に決定する\n";
    cout << " debuginfo=0~1:            デバッグ情報を付加するかどうか\n";
    cout << " exmacro=0~1:              拡張マクロを使用するかどうか\n";
    cout << " debugmode=0~1:            デバッグモードを使用するかどうか\n";
    cout << " shortprog=0~1:            対ショート部門用のメッセージを表示\n";
    cout << " debugwindow=0~1:          デバッグウィンドウを表示するかどうか\n";
    cout << "\n";
    cout << "e.x)コンパイル対象をtest.hsp、デバッグウィンドウを使用。\n";
    cout << " [hscl]\n";
    cout << " rootfile=test.hsp\n";
    cout << " debugwindow = 1\n";
    cout << "\n";
}


int compile( int debugInfo, int exMacro, int debugMode, int debugWindow ) {

    // コンパイル試行
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

    // 引数が無かった
    if( argc == 1 ) {
        printUsage();
        return 0;
    }


    // 自分のディレクトリパスを取得
    std::string exeDirpath( argv[0] );
    exeDirpath = exeDirpath.substr( 0, exeDirpath.rfind( "\\" ) );

    // カレントディレクトリを取得
    char currentDirectory[_MAX_PATH];
    GetCurrentDirectory( _MAX_PATH, currentDirectory );

    // iniの設定を読み込む
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


    // dll読み込み
    HINSTANCE hDll;
    try {
        hDll = LoadLibrary( ( exeDirpath + "\\" + "hspcmp.dll" ).c_str() );
        if( hDll == NULL ) {
            throw "DLLの読み込みに失敗しました。\nこのエラーは実行ファイルと同じ場所に hspcmp.dll を置けば直ります。\nというかマニュアル読んでくださいよ。\n";
        }
    }
    catch( char *e ) {
        cout << e;
        return 0;
    }

    // 関数読み込み
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


    // 排出するオブジェクトの設定
    hsc_ini( 0, (int)argv[1], 0, 0 );
    hsc_objname( 0, (int)hspobj, 0, 0 );


    if( shortProg ) {
        if( compile( 0, exMacro, debugMode, debugWindow ) ) return 1;
        shortInfo(hspobj);
        if( compile( 1, exMacro, debugMode, debugWindow  ) ) return 1;
    } else {
        if( compile( debugInfo, exMacro, debugMode, debugWindow  ) ) return 1;
    }


    // 実行試行
    char cfname[_MAX_PATH];
    *cfname = 0;
    hsc3_getruntime( (int)cfname, (int)hspobj, 0, 0 );

    char execmd[1024];
    wsprintf( execmd, "%s %s",
            ( *cfname == 0 ) ? "hsp3" : cfname, 
            hspobj );
    
    try {
        if( hsc3_run( (int)execmd, 0, 0, 0 ) != 0 ) {
            throw "ランタイムファイルが見つかりません\nこのエラーは hsp3.exe を実行ファイルと同じ場所に置けば多分直ります。\nというかマニュアル読んでくださいよ\n";
        }
    }
    catch( char *e ) {
        cout << e;
        return 0;
    }

    return 0;

}
