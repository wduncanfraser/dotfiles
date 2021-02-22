set number       " show line numbers
set showmatch    " show matching brackets
set ignorecase   " case insensitive matching 
set hlsearch     " highlight search results

" Default tab settings
set tabstop=2
set softtabstop=2
set expandtab
set shiftwidth=2
set autoindent
filetype plugin indent on

syntax on

call plug#begin()
Plug 'morhetz/gruvbox'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

" Colorscheme options.
set bg=dark
let g:gruvbox_contrast_dark='hard'
colorscheme gruvbox

