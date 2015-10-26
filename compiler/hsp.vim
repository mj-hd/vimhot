" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
" Vim compiler file
" Compiler:         HSP ver 3.0
" Maintainer:       Gonbei
" Last Modified:    2006/03/11-00:30.
" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

if exists( "b:current_compiler" )
  finish
endif
let b:current_compiler = "hsp"

if exists( ":CompilerSet" ) != 2
  command -nargs=* CompilerSet setlocal <args>
endif


CompilerSet makeprg=wine\ ~/.wine/drive_c/hsp34/hscl.exe\ %\ 2>&1\ 1>output.err;nkf\ -w\ --overwrite\ output.err;tr\ -d\ \'\\r\'\ <output.err;rm\ output.err
CompilerSet errorformat=%f\(%l)%*[^0-9]%n\ :\ %m
