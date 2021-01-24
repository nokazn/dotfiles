" -------------------- dein Scripts --------------------

if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('~/.vim/dein')
  call dein#begin('~/.vim/dein')
  " Required:
  call dein#add('~/.vim/dein/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here like this:
  call dein#add('preservim/nerdtree')
  call dein#add('itchyny/lightline.vim')
  call dein#add('joshdick/onedark.vim')
  call dein#add('airblade/vim-gitgutter')

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on

" シンタックスハイライトを有効にする
syntax enable

" install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

" -------------------- End dein Scripts -------------------------

" -------------------- NerdTree --------------------

" vim 起動時に NerdTree を起動
autocmd VimEnter * execute 'NERDTree'

let NERDTreeShowHidden=1

" Ctrl + e で NerdTree を toggle
map <silent><C-e> :NERDTreeFocus<CR>
" map <silent><C-e> :NERDTreeToggle<CR>
map <silent><C-f> :NERDTreeFind<CR>

" -------------------- vim-gitgutter --------------------

" .swp ファイルを作成するまでの時間 (ms)
set updatetime=500

" -------------------- config --------------------

" クリップボードと連携 (tmux-yunk 用)
set clipboard=unnamedplus

" テーマを onedark にする
colorscheme onedark

" 文字コード
set fileencodings=utf-8,cp932

" 行末のスペースを可視化
set list
set listchars=tab:^\ ,trail:~

" 行番号を表示
set number

" カーソルのある行をハイライト
set cursorline

" メッセージ欄を2行に
set cmdheight=2

" ステータスバー
set laststatus=2

" 補完の候補をステータスに表示
set wildmenu

" 新しい行で挿入モードに入ったときにインデントを予め挿入
set smartindent

" インクリメンタルサーチ
set incsearch

" 検索結果のハイライト
set hlsearch

" -------------------- key bindings --------------------

" ESC を押下した後に noh (nohlsearch)
nnoremap <esc> :noh<return><esc> 
nnoremap <esc>^[ <esc>^[

" gr で前のタブへ移動 (gt で次のタブへ移動)
nnoremap gr :tabprevious<return><esc>

"タブを左右に移動する
nnoremap <Tab>l :+tabmove<return><esc>
nnoremap <Tab>h :-tabmove<return><esc>

