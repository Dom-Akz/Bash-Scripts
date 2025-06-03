" === General Settings ===
set number              " Show absolute line numbers
set relativenumber    " Uncomment for relative numbers

syntax on               " Enable syntax highlighting
set termguicolors       " Enable true color support (needed for modern color schemes)

set background=dark     " Use dark background for better theme contrast
colorscheme desert      " Built-in color scheme; change to 'elflord', 'evening', etc.

" === UI Enhancements ===
set cursorline          " Highlight current line
set showcmd             " Show command in bottom bar
set showmode            " Show current mode (e.g., -- INSERT --)
set wildmenu            " Enhanced command-line completion
set lazyredraw          " Faster scrolling

" === Indentation and Tabs ===
set tabstop=4           " Number of spaces a tab counts for
set shiftwidth=4        " Size of auto-indent
set expandtab           " Use spaces instead of tabs
set autoindent          " Auto-indent new lines

" === Searching ===
set hlsearch            " Highlight matches
set incsearch           " Incremental search
set ignorecase          " Ignore case when searching
set smartcase           " Override ignorecase if search has uppercase

" === File Management ===
set hidden              " Allow buffer switching without saving
set nobackup            " Don't keep backup files
set nowritebackup       " Don't create backup before overwriting
set noswapfile          " Disable swap files

" === Performance ===
set updatetime=300      " Faster completion
set timeoutlen=500      " Shorter wait for mapped sequences

