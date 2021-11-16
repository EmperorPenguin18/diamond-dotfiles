"Basic stuff
set nocompatible
filetype plugin on
filetype indent on
syntax on
syntax enable

"General settings
set number
set relativenumber
let g:mapleader = ","
set hidden
set encoding=utf-8
set pumheight=10
set fileencoding=utf-8
set ruler
set cmdheight=2
set mouse=a
set splitbelow
set splitright
set t_Co=256
set conceallevel=0
set smarttab
set smartindent
set autoindent
set laststatus=0
set background=dark
set updatetime=300
set timeoutlen=500
set formatoptions-=cro
set clipboard=unnamedplus

"Fuzzy file finding
set path+=**
set wildmenu

"Tag jumping
command! MakeTags !ctags -R .

"File browser
let g:netrw_banner=0
let g:netrw_browser_split=4
let g:netrw_altv=1
let g:netrw_liststyle=3
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'

"Snippets
"nnoremap ,html :-1read $HOME/.config/nvim/skeleton.html3jwf>a

"Tabbing in visual mode
vmap  <Tab> >gv
vmap  <S-Tab> <gv

"Colorizer
let g:Hexokinase_highlighters = ['backgroundfull']
set termguicolors

"Better yank functionality
nmap Y y$
