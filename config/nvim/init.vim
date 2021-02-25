call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mg979/vim-visual-multi'
Plug 'vim-airline/vim-airline'
Plug 'ntpeters/vim-better-whitespace'

" Git
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'airblade/vim-gitgutter'

" Nerdtree
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Languages
Plug 'leafgarland/typescript-vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'cespare/vim-toml'
Plug 'dag/vim-fish'

" Theme
Plug 'morhetz/gruvbox'

" COC
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

" COC extensions
let g:coc_global_extensions = [
      \ 'coc-eslint',
      \ 'coc-go',
      \ 'coc-json',
      \ 'coc-react-refactor',
      \ 'coc-tsserver',
      \ 'coc-rls',
      \ ]

" General
set number       " show line numbers
set showmatch    " show matching brackets
set ignorecase   " case insensitive matching
set hlsearch     " highlight search results

" Default tab settings
set tabstop=2
set softtabstop=2
set expandtab
set shiftwidth=2

" Airline
let g:airline_powerline_fonts=1

" Nerdtree
"let g:NERDTreeGitStatusUseNerdFonts=1
let g:NERDTreeGitStatusIndicatorMapCustom = {
      \ 'Modified'  :'✹',
      \ 'Staged'    :'✚',
      \ 'Untracked' :'✭',
      \ 'Renamed'   :'➜',
      \ 'Unmerged'  :'═',
      \ 'Deleted'   :'✖',
      \ 'Dirty'     :'✗',
      \ 'Ignored'   :'☒',
      \ 'Clean'     :'✔︎',
      \ 'Unknown'   :'?',
      \ }

" Colorscheme options.
set bg=dark
let g:gruvbox_contrast_dark='hard'
colorscheme gruvbox
