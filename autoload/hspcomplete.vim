"
" hspcomplete.vim  ver 1.0.0
"
"
" 概要
"   HSPでomnicomplete
"
"
" 設定必要かも・・・
"   
"  \(HSPを普通の場所にインストールしてない|バージョンが違う)方は
"  どうぞ。
"   
      let s:hspath = '~/.wine/drive_c/hsp34/hsphelp'


" 無駄な改行コードを削除
func! s:chomp(raw)
  let idx = len( a:raw ) - 1
  while 1
    if a:raw[idx] != "\n"
      break
    endif
    let idx -= 1
  endwhile
  return strpart( a:raw, 0, idx + 1 )
endfunc


let s:lastftime = 0

" tagsから
func! s:TagInitialize()

  let tagfilename = "tags"

  let ftime = getftime( tagfilename )
  if ftime > s:lastftime || ftime == -1 " 更新
    let s:t_funclist = []
    let s:t_orderlist = []
    let s:t_macrolist = []
    let s:t_constlist = []
  else

    " 必要なし
    return
  endif
  let s:lastftime = ftime

  if ftime == -1
    return
  endif

  let lines = readfile( tagfilename )

  for line in lines
    " ヘッダはスキップ
    if strpart( line, 0, 2 ) == "!_"
      continue
    endif

    " ファイルで代用
    let dll = matchstr( line, '\t\S\{-}\t' )
    let dll = substitute( dll, '\t', '', 'g' )
    let dll = '[' . dll . ']'

    " 全てのタグファイルが / で検索されるという前提だから注意
    let prminfo = matchstr( line, '/\^.*' )
    let prminfo = strpart( prminfo, 2, len( prminfo ) - 2 )
    let prminfo = matchstr( prminfo, '[^/]*' )

    let name = substitute( prminfo, '\(#define\|#modfunc\|#modcfunc\|#const\|#deffunc\|#defcfunc\|#enum\|global\|ctype\|#cfunc\|#func\)', '', 'g' )
    let name = matchstr( name, '\<\S\{-}\>' )

    " 関数
    if (prminfo =~ '\<ctype\>' && prminfo =~ '^#define') || (prminfo =~ '^#\(defcfunc\|cfunc\)')
      call add( s:t_funclist, {'name': name . '(', 'prm': prminfo, 'summary': 'ユーザー定義関数（マクロ）', "dll": dll, "prminfo": '', "kind": "f"} )
    " マクロ
    elseif prminfo =~ '^#define'
      call add( s:t_macrolist, {'name': name, 'prm': prminfo, 'summary': 'ユーザー定義マクロ', "dll": dll, "prminfo": '', "kind": "m"} )
    " 命令
    elseif prminfo =~ '^#\(deffunc\|func\)'
      call add( s:t_orderlist, {'name': name, 'prm': prminfo, 'summary': 'ユーザー定義命令', "dll": dll, "prminfo": '', "kind": "o"} )
    " 定数
    elseif prminfo =~ '^#\(enum\|const\)'
      call add( s:t_constlist, {'name': name, 'prm': prminfo, 'summary': 'ユーザー定義定数', "dll": dll, "prminfo": '', "kind": "c"} )
    else
      " ラベル（HSPの仕様上、対応のしようが無い）
    endif

  endfor

endfunc



" 辞書構築
func! s:Initialize()

  let s:funclist = []
  let s:orderlist = []
  let s:svlist = []
  let s:prmtypelist = []
  let s:definemodifierlist = []
  let s:modifierlist = []
  let s:macrolist = []
  let s:swmacrolist = []

  echo "Constructing DataBases"

  " まずは.hsファイルを探索

  for file in split( glob(s:hspath . "\\" . "*.hs"), "\n" )

    let lines = readfile( file )

    " dll取得
    let index = 0
    let dll = ""
    while lines[index] != "%index"
      if lines[index] == "%dll"
        let dll = "@" . lines[index+1]
      endif
      let index = index + 1
    endwhile

    " type取得
    let index = 0
    let type = ""
    while lines[index] != "%index"
      if lines[index] == "%type"
        let type = lines[index+1]
      endif
      let index = index + 1
    endwhile


    " システム変数っぽい？
    let is_sv = ( type =~ "システム変数" )

    " hs から

    while index < len( lines )

      " %indexまで行をすすめる
      while index < len( lines )
        if lines[index] == "%index"
          break
        endif
        let index = index + 1
      endwhile
      if index >= len( lines )
        break
      endif

      " 関数名を取得
      let index = index + 1
      let name = lines[index]

      " サマリー取得
      let index = index + 1
      let summary = lines[index]

      " パラメータリスト取得
      let _index = index
      let prm = ""
      let haveprm = 0
      while _index < len( lines )
        if lines[_index] == "%index"
          let _index -= 1
          break
        endif
        if lines[_index] == "%prm"
          let prm = lines[_index+1]
          let haveprm = 1
          break
        endif
        let _index = _index + 1
      endwhile

      " パラメータのサマリー取得
      let prminfo = ""
      if haveprm
        let _index += 2
        while _index < len( lines ) 
          if strpart( lines[_index], 0, 1 ) == "%"
            break
          endif
          let prminfo .= lines[_index] . "\n"
          let _index = _index + 1
        endwhile
      endif


      " 追加
      if is_sv
        call add( s:svlist, {'name': name, 'prm': prm, 'summary': summary, "dll": dll, "prminfo": s:chomp(prminfo), "kind": "v"} )
      elseif prm =~ "^(" && prm =~ ")$"
        call add( s:funclist, {'name': name . '(', 'prm': prm, 'summary': summary, "dll": dll, "prminfo": s:chomp(prminfo), "kind": "f"} )
      else
        call add( s:orderlist, {'name': name, 'prm': prm, 'summary': summary, "dll": dll, "prminfo": s:chomp(prminfo), "kind": "o"} )
      endif

      let index = _index + 1

    endwhile


  endfor


  " .hsに記載されてないやつ

  " プリプロセッサ
  call add( s:swmacrolist, {'name': '_debug', 'prm': '', 'summary': 'デバッグモード時（マクロ）', 'dll': '', 'prminfo': '', "kind": "d"} )
  call add( s:swmacrolist, {'name': '__hsp30__', 'prm': '', 'summary': 'ver3.0使用時（マクロ）', 'dll': '', 'prminfo': '', "kind": "d"} )
  call add( s:macrolist, {'name': '__file__', 'prm': '', 'summary': '現時点で解析されているファイル名（マクロ）', 'dll': '', 'prminfo': '', "kind": "d"} )
  call add( s:macrolist, {'name': '__line__', 'prm': '', 'summary': '現時点で解析されている行番号（マクロ）', 'dll': '', 'prminfo': '', "kind": "d"} )
  call add( s:macrolist, {'name': '__date__', 'prm': '', 'summary': '使用時点の日付（マクロ）', 'dll': '', 'prminfo': '', "kind": "d"} )
  call add( s:macrolist, {'name': '__time__', 'prm': '', 'summary': '使用時点の時刻（マクロ）', 'dll': '', 'prminfo': '', "kind": "d"} )
  call add( s:macrolist, {'name': '__hspver__', 'prm': '', 'summary': 'HSPバージョン番号（マクロ）', 'dll': '', 'prminfo': '', "kind": "d"} )


  " パラメータタイプ
  call add( s:prmtypelist, {'name': 'int', 'prm': '', 'summary': '整数値(32bit)', 'dll': '', 'prminfo': '', "kind": "p"} )
  call add( s:prmtypelist, {'name': 'var', 'prm': '', 'summary': '変数のデータポインタ(32bit)', 'dll': '', 'prminfo': '', "kind": "p"} )
  call add( s:prmtypelist, {'name': 'str', 'prm': '', 'summary': '文字列ポインタ(32bit)', 'dll': '', 'prminfo': '', "kind": "p"} )
  call add( s:prmtypelist, {'name': 'wstr', 'prm': '', 'summary': 'unicode文字列ポインタ(32bit)', 'dll': '', 'prminfo': '', "kind": "p"} )
  call add( s:prmtypelist, {'name': 'sptr', 'prm': '', 'summary': 'ポインタ整数値または文字列のポインタ(32bit)', 'dll': '', 'prminfo': '', "kind": "p"} )
  call add( s:prmtypelist, {'name': 'wptr', 'prm': '', 'summary': 'ポインタ整数値またはunicode文字列のポインタ(32bit)', 'dll': '', 'prminfo': '', "kind": "p"} )
  call add( s:prmtypelist, {'name': 'double', 'prm': '', 'summary': '実数値(64bit)', 'dll': '', 'prminfo': '', "kind": "p"} )
  call add( s:prmtypelist, {'name': 'label', 'prm': '', 'summary': 'ラベルポインタ(32bit)', 'dll': '', 'prminfo': '', "kind": "p"} )
  call add( s:prmtypelist, {'name': 'float', 'prm': '', 'summary': '実数値(32bit)', 'dll': '', 'prminfo': '', "kind": "p"} )
  call add( s:prmtypelist, {'name': 'pval', 'prm': '', 'summary': 'PVal構造体のポインタ(32bit)', 'dll': '', 'prminfo': '', "kind": "p"} )
  call add( s:prmtypelist, {'name': 'bmscr', 'prm': '', 'summary': 'BMSCR構造体のポインタ(32bit)', 'dll': '', 'prminfo': '', "kind": "p"} )
  call add( s:prmtypelist, {'name': 'comobj', 'prm': '', 'summary': 'COMOBJ型変数のデータポインタ(32bit)', 'dll': '', 'prminfo': '', "kind": "p"} )
  call add( s:prmtypelist, {'name': 'prefstr', 'prm': '', 'summary': 'システム変数refstrのポインタ(32bit)', 'dll': '', 'prminfo': '', "kind": "p"} )
  call add( s:prmtypelist, {'name': 'pexinfo', 'prm': '', 'summary': 'EXINFO構造体のポインタ(32bit)', 'dll': '', 'prminfo': '', "kind": "p"} )
  call add( s:prmtypelist, {'name': 'nullptr', 'prm': '', 'summary': 'ヌルポインタ(32bit)', 'dll': '', 'prminfo': '', "kind": "p"} )

  " プリプロセッサの修飾子
  call add( s:modifierlist, {'name': 'global', 'prm': '', 'summary': 'グローバル修飾子', 'dll': '', 'prminfo': '', "kind": ""} )

  " #defineの修飾子
  call add( s:definemodifierlist, {'name': 'ctype', 'prm': '', 'summary': 'C言語風表記', 'dll': '', 'prminfo': '', "kind": ""} )

endfunction



function! hspcomplete#Complete(findstart, base)

  if !exists( "s:funclist" )
    call s:Initialize()
  endif

  call s:TagInitialize()

  if a:findstart
    let index = getline('.')
    let start = col('.') - 1
    while start > 0 && index[start - 1] =~ "[0-9A-Za-z_#]"
      let start -= 1
    endwhile
    return start
  else

    let res = []

    let complist = []

    " カーソルより前のを取得
    let huge = strpart( getline('.'), 0, col('.') )

    " 命令
    if huge !~ "[^ 	]"
      call extend( complist, s:t_orderlist )
      call extend( complist, s:t_macrolist )
      call extend( complist, s:orderlist )

    " 関数定義
    elseif huge =~ '^\s*#\(cfunc\|func\|deffunc\|defcfunc\|compfunc\|modfunc\|modinit\)'
      call extend( complist, s:modifierlist )
      call extend( complist, s:prmtypelist )

    " スタティックな条件分岐
    elseif huge =~ '^\s*#\(if\|ifdef\|ifndef\)'
      call extend( complist, s:t_macrolist )
      call extend( complist, s:swmacrolist )
      call extend( complist, s:t_constlist )

    " #define
    elseif huge =~ '^\s*#\(define\)'
      " global, ctype
      call extend( complist, s:modifierlist )
      call extend( complist, s:definemodifierlist )

      " こんなにいらん？
      call extend( complist, s:t_orderlist )
      call extend( complist, s:t_funclist )
      call extend( complist, s:t_constlist )
      call extend( complist, s:t_macrolist )

      call extend( complist, s:orderlist )
      call extend( complist, s:funclist )
      call extend( complist, s:svlist )
      call extend( complist, s:prmtypelist )
      call extend( complist, s:definemodifierlist )
      call extend( complist, s:modifierlist )
      call extend( complist, s:macrolist )
      call extend( complist, s:swmacrolist )

    " #undef
    elseif huge =~ '^\s*#\(undef\)'

      " とりあえず、けすかも知れない
      call extend( complist, s:t_funclist )
      call extend( complist, s:t_constlist )
      call extend( complist, s:t_orderlist )
      call extend( complist, s:t_macrolist )

      call extend( complist, s:funclist )
      call extend( complist, s:orderlist )
      call extend( complist, s:svlist )
      call extend( complist, s:prmtypelist )
      call extend( complist, s:definemodifierlist )
      call extend( complist, s:modifierlist )
      call extend( complist, s:macrolist )
      call extend( complist, s:swmacrolist )

    " 定数
    elseif huge =~ '^\s*#\(const\|enum\)'

      " global
      call extend( complist, s:modifierlist )

      call extend( complist, s:t_constlist )
      call extend( complist, s:t_macrolist )

    " 関数、命令、マクロ
    else
      call extend( complist, s:t_funclist )
      call extend( complist, s:t_constlist )
      call extend( complist, s:t_macrolist )

      call extend( complist, s:funclist )
      call extend( complist, s:svlist )
      call extend( complist, s:macrolist )
    endif

    for comp in complist
      if comp.name =~ "^".a:base
        call add( res, {'word': comp.name, "menu": comp.summary, "info": comp.name .  comp.dll . "  " . comp.prm . "\n" . comp.prminfo} )
      endif
    endfor

    return res

  endif
endfunc

" vim: sw=2
