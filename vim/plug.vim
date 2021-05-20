" Git support
Plug 'tpope/vim-fugitive'
" Surround
Plug 'tpope/vim-surround'
" Dark theme
Plug 'rafi/awesome-vim-colorschemes'
"Better C++ highlighting
Plug 'bfrg/vim-cpp-modern'
" YouCompleteMe
Plug 'ycm-core/YouCompleteMe'
" AutoClose parens/braces/etc.
Plug 'Townk/vim-autoclose'
" ClangFormat
Plug 'Chiel92/vim-autoformat'
" File tree
Plug 'preservim/nerdtree'
" Commenting
Plug 'preservim/nerdcommenter'
" Nice tmux + vim integration
Plug 'preservim/vimux'
" Delete buffers without screwing up the layout (optional dependency of vim-symlink)
Plug 'moll/vim-bbye'
" Symlinks
Plug 'aymericbeaumet/vim-symlink'
" Airline
Plug 'vim-airline/vim-airline'
" Fuzzy file finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Bazel support
Plug 'google/vim-maktaba'
Plug 'bazelbuild/vim-bazel'
Plug 'grailbio/bazel-compilation-database'
" Python syntax highlighting
Plug 'vim-python/python-syntax'
