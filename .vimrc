" Vundle.vim
set nocompatible      " be improved, required
filetype off          " required
set  rtp+=~/.vim/bundle/Vundle.vim

" Plguins
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'preservim/nerdtree'
Plugin 'itchyny/lightline.vim'
Plugin 'joshdick/onedark.vim'
call vundle#end()
filetype plugin indent on

" vim 起動時に NerdTree を起動
autocmd VimEnter * execute 'NERDTree'
" Ctrl + e で NerdTree を toggle
map <silent><C-e> :NERDTreeFocus<CR>
" map <silent><C-e> :NERDTreeToggle<CR>
map <silent><C-f> :NERDTreeFind<CR>
let NERDTreeShowHidden=1

" クリップボードと連携 (tmux-yunk 用)
set clipboard=unnamedplus

" シンタックスハイライトを有効にする
syntax enable
" テーマを molokai にする
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
" ESC を押下した後に noh (nohlsearch)
nnoremap <esc> :noh<return><esc> 
nnoremap <esc>^[ <esc>^[

" gr で前のタブへ移動 (gt で次のタブへ移動)
nnoremap gr :tabprevious<return><esc>
"タブを左右に移動する
nnoremap <Tab>l :+tabmove<return><esc>
nnoremap <Tab>h :-tabmove<return><esc>

