set nocompatible      " be improved, required
filetype off          " required

set  rtp+=~/.vim/bundle/Vundle.vim

" Plguins
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'preservim/nerdtree'
Plugin 'flazz/vim-colorschemes'

call vundle#end()
filetype plugin indent on

" テーマを molokai にする
colorscheme molokai 
" シンタックスハイライトを有効にする
syntax enable
" tmux-yunk 用
set clipboard=unnamedplus
" メッセージ欄を2行に
set cmdheight=2
" 行末のスペースを可視化
set listchars=tab:^\ ,trail:~   
set title
set number
