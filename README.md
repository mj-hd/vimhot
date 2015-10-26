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

noremap <F5> :make<CR>
```

また，別途OpenBrowserを導入し，`.vimrc`に以下のような設定をすることで，ヘルプを一発で開くことができるようになります．  
```
NeoBundle 'open-browser.vim'

~~~中略~~~

noremap <F1> :execute "OpenBrowser http://ohdl.hsproom.me/?q=" . expand( "<cword>" )<CR>
```

# テスト環境
Mac OS X El Capitan, Vim 7.4, HSP 3.4

# 既知の問題
* HDLが内部エラーで起動しない
