_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
_/                                                                            _/
_/  VimDeHotSoup                                                              _/
_/                                                                            _/
_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/



概要：

  以下の機能を提供します。
  「VIMって何」人には必要ないと思います。

- シンタックスハイライト
- make をちょっと変更
- もちろんエラージャンプも可能
- タグファイルの生成
- TagExplorerとの連携
- hs からのシンタックスの宣言構文の生成
- コマンドラインコンパイラ
- omnicomplete

  なおHSP3.1以外での動作は保障しません





開発（兼テスト）環境：
- OS                : WindowsXP SP2
- Perl Version      : ActivePerl v5.8.8
- HSP Version       : 3.1
- C Compiler        : BCC5.5
- Vim               : v7.0（香り屋版）





ファイル概要：

- .\compiler\hsp.vim
  VIMでのmakeを通してhscl.exeを使用できるようにする

- .\ftplugin\hsp.vim
  HSP用ファイルタイププラグイン

- .\syntax\hsp.vim
  HSP用シンタックスファイル

- .\example
  ちょっとしたサンプル

- .\hscl.exe
  HSPのコマンドラインコンパイラ。
  エラーがプリプロセッサがらみのものなら整形してからエラーを出力。
  あまり複雑なことはできません。

- .\hscl.cpp
  ↑のソースコード

- .\hs2syn.pl
  hsファイルからシンタックスの宣言構文を生成するファイル
  Perlを処理できる環境が必要です

- .\htags.pl
  hspファイルからタグファイルを生成するファイル
  同じくPerlを処理できる環境が必要です

- .\autoload\hspcomplete.vim
  hspでomnicompleteを行います



準備：

1.hscl.exeをhsp.exeと同じフォルダに置く 

  このときに置かれたフォルダが "C:\Program Files\hsp30" ではないとき 
  .\compiler\hsp.vim の CompilerSet makeprg = ... という部分を以下のように書き換える必要があります
  CompilerSet makeprg = [hscl.exeの置かれたパス] %
  このとき少しだけ注意点があります。
  - パスの両端を「\"」で囲む
  - 半角スペースを「\」でエスケープする
  - 区切り文字である \ は \\ にしなければならない

  例えば hscl.exe を "D:\My Tools\Hsp\" のようなフォルダに置くときは
  CompilerSet makeprg = \"D:\\My\ Tools\\Hsp\\hscl\" %
  になります。


2."compiler, ftplugin, syntax, autoload" フォルダの中身を
  "VIM\runtime" の対応する場所に移す
  （注意：あくまで中身を移動するだけです。フォルダごと移さないように）


3._vimrc辺りに以下の処理を書き込む。

- - - - - - - - - - ここから - - - - - - - - - 
autocmd BufRead *.hsp call FileTypeHsp()
function FileTypeHsp()
  compiler hsp
  set filetype=hsp
  se omnifunc=hspcomplete#Complete
endfunction
- - - - - - - - - - ここまで - - - - - - - - - 


4.他にも上の FileTypeHsp() の中に次のようなことを書くと幸せになれるかもしれません。
　（環境に応じて変更してください）

- - - - - - - - - - ここから - - - - - - - - - 
  noremap <F1> :execute "!\"c:\\Program Files\\hsp30\\hsphelp\\helpman.exe\"" . " " . expand( "<cword>" )<CR>
  noremap <F5> :make
- - - - - - - - - - ここまで - - - - - - - - - 

5.TagExplorerを使用するときは以下を追加してください。

- - - - - - - - - - ここから - - - - - - - - - 
  let g:TE_Ctags_Path="htags"
- - - - - - - - - - ここまで - - - - - - - - - 


6.matchit.vim を導入してみると便利かもです。導入方法は google に聞いてください。


- 7 と 8 はタグファイルの生成をしたい人や、シンタックスを追加したい人だけ

7.htags.pl, hs2syn.plをパスが通った場所に置く

8.適当にPerlを処理できる環境を整える（説明省略）





使い方：

- 準備が完了していれば、適当にHSPのファイルを開いたときにハイライトがされていて
  かつ、:make によるコンパイルもできるはずです。できないという人はエラーメッセージと
  にらめっこしてがんばってください。

- htags.pl, hs2syn.pl の説明は、何も引数を渡さずにファイルを実行すれば見れるので
  そちらを見ましょう。しつこいようですが Perl を処理できる環境が必要です。

- 結局使い方なんて全く説明しなかったり、、







compiler, ftplugin, syntax の設定：

事前に以下の変数を定義しとくことでちょっとした設定ができます

- g:HspUseBoolean
  Boolean値である true, false がハイライトされる。ついでなので null もハイライト

- g:HspUseAtModule
  variable@module なんかの @moduleがハイライトされる。

- g:HspUseDoubleSlashIndent
  デフォルトではコメントに "//" を使用した状態で改行しても、
  次行で自動的にコメントを継続しないようになっているけど、継続できるようにする。

  例えばBoolean値を使いたかったら _vimrc辺りに
    g:HspUseBoolean = 1
  と書き込みます。これは前述の "compiler hsp" よりも前に無ければなりません。







仕様：
- マクロを複数行で定義するときに \ を使うけどその処理はいい加減。
  特にマクロじゃなくても行末であればハイライトされる

- HSP独特の記法（ $, % の二つ ）がちょっとおかしい。foobar$20, $07.22とか
  % の方はマクロ専用になっていて二進表記でなくてもハイライトされちゃう
  ( iskeyword いじれば平気？）

- エラーの表示は面倒くさいからやってない

- ラベル宣言で使う '*' が押されたら自動的にインデントさせようと思ったけど
  C++ や Java 辺りで多用する /* ~ */ なインデントを使う人間にとっては邪魔以外の
  何者でもないので cindent で済ませてる。（対応してない）

- make したときに、エラー原因がマクロによるものだとマクロ宣言に飛んでしまう
  いちいち <C-o> が面倒

- htags はコメントの中の関数宣言ももれなくつくり出す。
  あとトリッキーなコメントのつけ方をするとちゃんと作れない。





著作権：
  面白がって変な記法を多用して書いたダメソースコードなので変な部分だらけだったり
  しますが、このファイル達の著作権は特に主張しませんので改造、再配布など自由に
  どうぞ。
