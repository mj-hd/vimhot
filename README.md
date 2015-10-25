# vimhot
HSP用のvimプラグイン  
[vimhot](http://hp.vector.co.jp/authors/VA038334/archive/)のMac, Linux用改造版です．  
Windows環境の人は，公式版を使ってください  

# 変更点
* 主にwineを使用するように  
* modcfuncなどがハイライトされるように  

# 依存
* nkf
* wine

# インストール
## NeoBundle
```
NeoBundle 'mjhd-devlion/vimhot'
```

`hscl.exe`ファイルをHSPのインストールディレクトリに配置してください．  

## 手動
`autoload`, `compiler`, `ftplugin`, `syntax`を`~/.vim`以下にコピーしてください．  

# 設定
`compiler/hsp.vim`を編集し，`hscl.exe`ファイルのパスを修正してください．  
以下のような設定を`.vimrc`に追加すると，幸せになれるそうです．  
```
autocmd BufRead *.hsp call FileTypeHsp()
function FileTypeHsp()
  compiler hsp
  set filetype=hsp
  se omnifunc=hspcomplete#Complete
endfunction

noremap <F1> :execute "!wine ~/.wine/drive_c/hsp34/hsphelp/helpman.exe" . " " . expand( "<cword>" )<CR>
noremap <F5> :make<CR>
```

# テスト環境
Mac OS X El Capitan, Vim 7.4, HSP 3.4

# 既知の問題
* HDLが内部エラーで起動しない
