_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
_/                                                                            _/
_/  VimDeHotSoup                                                              _/
_/                                                                            _/
_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/



�T�v�F

  �ȉ��̋@�\��񋟂��܂��B
  �uVIM���ĉ��v�l�ɂ͕K�v�Ȃ��Ǝv���܂��B

- �V���^�b�N�X�n�C���C�g
- make ��������ƕύX
- �������G���[�W�����v���\
- �^�O�t�@�C���̐���
- TagExplorer�Ƃ̘A�g
- hs ����̃V���^�b�N�X�̐錾�\���̐���
- �R�}���h���C���R���p�C��
- omnicomplete

  �Ȃ�HSP3.1�ȊO�ł̓���͕ۏႵ�܂���





�J���i���e�X�g�j���F
- OS                : WindowsXP SP2
- Perl Version      : ActivePerl v5.8.8
- HSP Version       : 3.1
- C Compiler        : BCC5.5
- Vim               : v7.0�i���艮�Łj





�t�@�C���T�v�F

- .\compiler\hsp.vim
  VIM�ł�make��ʂ���hscl.exe���g�p�ł���悤�ɂ���

- .\ftplugin\hsp.vim
  HSP�p�t�@�C���^�C�v�v���O�C��

- .\syntax\hsp.vim
  HSP�p�V���^�b�N�X�t�@�C��

- .\example
  ������Ƃ����T���v��

- .\hscl.exe
  HSP�̃R�}���h���C���R���p�C���B
  �G���[���v���v���Z�b�T����݂̂��̂Ȃ琮�`���Ă���G���[���o�́B
  ���܂蕡�G�Ȃ��Ƃ͂ł��܂���B

- .\hscl.cpp
  ���̃\�[�X�R�[�h

- .\hs2syn.pl
  hs�t�@�C������V���^�b�N�X�̐錾�\���𐶐�����t�@�C��
  Perl�������ł�������K�v�ł�

- .\htags.pl
  hsp�t�@�C������^�O�t�@�C���𐶐�����t�@�C��
  ������Perl�������ł�������K�v�ł�

- .\autoload\hspcomplete.vim
  hsp��omnicomplete���s���܂�



�����F

1.hscl.exe��hsp.exe�Ɠ����t�H���_�ɒu�� 

  ���̂Ƃ��ɒu���ꂽ�t�H���_�� "C:\Program Files\hsp30" �ł͂Ȃ��Ƃ� 
  .\compiler\hsp.vim �� CompilerSet makeprg = ... �Ƃ����������ȉ��̂悤�ɏ���������K�v������܂�
  CompilerSet makeprg = [hscl.exe�̒u���ꂽ�p�X] %
  ���̂Ƃ������������ӓ_������܂��B
  - �p�X�̗��[���u\"�v�ň͂�
  - ���p�X�y�[�X���u\�v�ŃG�X�P�[�v����
  - ��؂蕶���ł��� \ �� \\ �ɂ��Ȃ���΂Ȃ�Ȃ�

  �Ⴆ�� hscl.exe �� "D:\My Tools\Hsp\" �̂悤�ȃt�H���_�ɒu���Ƃ���
  CompilerSet makeprg = \"D:\\My\ Tools\\Hsp\\hscl\" %
  �ɂȂ�܂��B


2."compiler, ftplugin, syntax, autoload" �t�H���_�̒��g��
  "VIM\runtime" �̑Ή�����ꏊ�Ɉڂ�
  �i���ӁF�����܂Œ��g���ړ����邾���ł��B�t�H���_���ƈڂ��Ȃ��悤�Ɂj


3._vimrc�ӂ�Ɉȉ��̏������������ށB

- - - - - - - - - - �������� - - - - - - - - - 
autocmd BufRead *.hsp call FileTypeHsp()
function FileTypeHsp()
  compiler hsp
  set filetype=hsp
  se omnifunc=hspcomplete#Complete
endfunction
- - - - - - - - - - �����܂� - - - - - - - - - 


4.���ɂ���� FileTypeHsp() �̒��Ɏ��̂悤�Ȃ��Ƃ������ƍK���ɂȂ�邩������܂���B
�@�i���ɉ����ĕύX���Ă��������j

- - - - - - - - - - �������� - - - - - - - - - 
  noremap <F1> :execute "!\"c:\\Program Files\\hsp30\\hsphelp\\helpman.exe\"" . " " . expand( "<cword>" )<CR>
  noremap <F5> :make
- - - - - - - - - - �����܂� - - - - - - - - - 

5.TagExplorer���g�p����Ƃ��͈ȉ���ǉ����Ă��������B

- - - - - - - - - - �������� - - - - - - - - - 
  let g:TE_Ctags_Path="htags"
- - - - - - - - - - �����܂� - - - - - - - - - 


6.matchit.vim �𓱓����Ă݂�ƕ֗������ł��B�������@�� google �ɕ����Ă��������B


- 7 �� 8 �̓^�O�t�@�C���̐������������l��A�V���^�b�N�X��ǉ��������l����

7.htags.pl, hs2syn.pl���p�X���ʂ����ꏊ�ɒu��

8.�K����Perl�������ł�����𐮂���i�����ȗ��j





�g�����F

- �������������Ă���΁A�K����HSP�̃t�@�C�����J�����Ƃ��Ƀn�C���C�g������Ă���
  ���A:make �ɂ��R���p�C�����ł���͂��ł��B�ł��Ȃ��Ƃ����l�̓G���[���b�Z�[�W��
  �ɂ�߂������Ă���΂��Ă��������B

- htags.pl, hs2syn.pl �̐����́A����������n�����Ƀt�@�C�������s����Ό����̂�
  ����������܂��傤�B�������悤�ł��� Perl �������ł�������K�v�ł��B

- ���ǎg�����Ȃ�đS���������Ȃ�������A�A







compiler, ftplugin, syntax �̐ݒ�F

���O�Ɉȉ��̕ϐ����`���Ƃ����Ƃł�����Ƃ����ݒ肪�ł��܂�

- g:HspUseBoolean
  Boolean�l�ł��� true, false ���n�C���C�g�����B���łȂ̂� null ���n�C���C�g

- g:HspUseAtModule
  variable@module �Ȃ񂩂� @module���n�C���C�g�����B

- g:HspUseDoubleSlashIndent
  �f�t�H���g�ł̓R�����g�� "//" ���g�p������Ԃŉ��s���Ă��A
  ���s�Ŏ����I�ɃR�����g���p�����Ȃ��悤�ɂȂ��Ă��邯�ǁA�p���ł���悤�ɂ���B

  �Ⴆ��Boolean�l���g������������ _vimrc�ӂ��
    g:HspUseBoolean = 1
  �Ə������݂܂��B����͑O�q�� "compiler hsp" �����O�ɖ�����΂Ȃ�܂���B







�d�l�F
- �}�N���𕡐��s�Œ�`����Ƃ��� \ ���g�����ǂ��̏����͂��������B
  ���Ƀ}�N������Ȃ��Ă��s���ł���΃n�C���C�g�����

- HSP�Ɠ��̋L�@�i $, % �̓�� �j��������Ƃ��������Bfoobar$20, $07.22�Ƃ�
  % �̕��̓}�N����p�ɂȂ��Ă��ē�i�\�L�łȂ��Ă��n�C���C�g���ꂿ�Ⴄ
  ( iskeyword ������Ε��C�H�j

- �G���[�̕\���͖ʓ|�������������ĂȂ�

- ���x���錾�Ŏg�� '*' �������ꂽ�玩���I�ɃC���f���g�����悤�Ǝv��������
  C++ �� Java �ӂ�ő��p���� /* ~ */ �ȃC���f���g���g���l�ԂɂƂ��Ă͎ז��ȊO��
  ���҂ł��Ȃ��̂� cindent �ōς܂��Ă�B�i�Ή����ĂȂ��j

- make �����Ƃ��ɁA�G���[�������}�N���ɂ����̂��ƃ}�N���錾�ɔ��ł��܂�
  �������� <C-o> ���ʓ|

- htags �̓R�����g�̒��̊֐��錾������Ȃ�����o���B
  ���ƃg���b�L�[�ȃR�����g�̂���������Ƃ����ƍ��Ȃ��B





���쌠�F
  �ʔ������ĕςȋL�@�𑽗p���ď������_���\�[�X�R�[�h�Ȃ̂ŕςȕ������炯��������
  ���܂����A���̃t�@�C���B�̒��쌠�͓��Ɏ咣���܂���̂ŉ����A�Ĕz�z�Ȃǎ��R��
  �ǂ����B
