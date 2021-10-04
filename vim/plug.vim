" Git support
Plug 'tpope/vim-fugitive'
" Surround
Plug 'tpope/vim-surround'
" Dark theme
Plug 'joshdick/onedark.vim'
" AutoClose parens/braces/etc.
Plug 'Townk/vim-autoclose'
" ClangFormat
Plug 'Chiel92/vim-autoformat'
" File tree
Plug 'preservim/nerdtree'
" Commenting
Plug 'preservim/nerdcommenter'
" Delete buffers without screwing up the layout (optional dependency of vim-symlink)
Plug 'moll/vim-bbye'
" Symlinks
Plug 'aymericbeaumet/vim-symlink'
" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Fuzzy file finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

""""" Syntax Highlighting
" Python syntax highlighting
Plug 'vim-python/python-syntax'
"Better C++ highlighting
Plug 'bfrg/vim-cpp-modern'
