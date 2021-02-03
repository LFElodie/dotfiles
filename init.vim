" nvim config

" Preinstall {{{

if empty(glob('~/.config/nvim/autoload/plug.vim'))
	silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    silent !sudo pip3 install flake8 autopep8
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
" }}}

" Global Virables {{{

let g:cache_root_path = $HOME . '/.cache/vim/'
let g:undo_dir = g:cache_root_path . 'undo'
let g:plugins_install_path = g:cache_root_path . 'plugins/'

" }}}

" Plugins {{{

call plug#begin(g:plugins_install_path)

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Appearance
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'gruvbox-community/gruvbox'

Plug 'jiangmiao/auto-pairs'
Plug 'kien/rainbow_parentheses.vim'
Plug 'tpope/vim-surround'
Plug 'Yggdroot/indentLine'
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'francoiscabrol/ranger.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'sillybun/vim-repl'

" Python
"Plug 'tell-k/vim-autopep8'
Plug 'nvie/vim-flake8'

" Markdown
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'


" Auto complete
Plug 'kiteco/vim-plugin'
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
Plug 'ncm2/ncm2-jedi'
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'

" Auto format
Plug 'Chiel92/vim-autoformat'

" C++
Plug 'ncm2/ncm2-pyclang'
Plug 'octol/vim-cpp-enhanced-highlight'

" Linter
Plug 'dense-analysis/ale'

call plug#end()

" }}}

" Plugins Settings {{{

" RainbowParentheses {{{
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

" }}}

" Auto complete  {{{

" kite
let g:kite_tab_complete=1
let g:kite_supported_languages = ['*']
set belloff+=ctrlg
set completeopt+=menuone   " show the popup menu even when there is only 1 match
set completeopt+=noinsert  " don't insert any text until user chooses a match
set completeopt-=longest   " don't insert the longest common text
set completeopt-=preview

" ncm2
autocmd BufEnter * call ncm2#enable_for_buffer()
let ncm2#complete_length = [[1, 1]]
inoremap <c-c> <ESC>
inoremap <expr> <CR> (pumvisible() ? "\<c-y>" : "\<CR>")
inoremap <expr> <Tab> pumvisible() ? "\<C-y>" : "\<Tab>"
let g:ncm2_pyclang#library_path = '/Library/Developer/CommandLineTools/usr/lib/libclang.dylib'

" }}}

" ALE {{{

let g:ale_linters = {
\   'c++': ['gcc', 'cppcheck'],
\   'c': ['gcc', 'cppcheck'],
\   'python': ['flake8', 'pylint'],
\   'csh': ['shell'],
\   'zsh': ['shell'],
\}

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\}

let g:ale_fix_on_save = 1
let g:ale_linters_explicit = 1
let g:ale_completion_delay = 500
let g:ale_echo_delay = 20
let g:ale_lint_delay = 500
let g:ale_echo_msg_format = '[%linter%] %code: %%s'
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:airline#extensions#ale#enabled = 1
let g:ale_cpp_cc_executable='gcc'

" }}}

" NERDTree {{{

let NERDTreeShowHidden=1

" }}}

" Airline {{{

let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'

" }}}

" auto format {{{

let g:autopep8_disable_show_diff=1
autocmd BufWritePost *.py call flake8#Flake8()
"autocmd FileType python noremap <buffer> <F8> :call Autopep8()<CR>
noremap <F8> :Autoformat<CR>

" }}}

" REPL for Python {{{

let g:repl_position = 3
nnoremap <leader>r :REPLToggle<Cr>
autocmd Filetype python nnoremap <F12> <Esc>:REPLDebugStopAtCurrentLine<Cr>
autocmd Filetype python nnoremap <F10> <Esc>:REPLPDBN<Cr>
autocmd Filetype python nnoremap <F11> <Esc>:REPLPDBS<Cr>

" }}}

" Markdown {{{

let g:vim_markdown_math = 1
let g:vim_markdown_folding_level = 6
let g:vim_markdown_conceal = 0

" }}}

" }}}

" Basic Settings {{{

" General Settings {{{

set autoread
set spelllang=en_us
set spell
let mapleader=","
set backspace=indent,eol,start
set number
set relativenumber
set showcmd
set cursorline
set showmatch
set matchtime=2
set laststatus=2
set updatetime=300
set scrolloff=7
set noshowmode
set signcolumn=yes
set colorcolumn=80
set nowrap
set mouse=n
set lazyredraw
set belloff=all
let g:auto_save = 1
let g:auto_save_events = ["InsertLeave", "TextChanged", "TextChangedI", "CursorHoldI", "CompleteDone"]

" }}}

" Colors {{{

syntax on
filetype plugin indent on

if (has("termguicolors"))
    set termguicolors
endif

colorscheme gruvbox
set background=dark

" }}}

" Tabs and Spaces {{{

set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent smartindent shiftround
set expandtab

" }}}

" File Find {{{

set wildmenu
set hidden

" }}}

" Searching {{{

set hlsearch                    " highlight searches "
set incsearch                   " do incremental searching, search as you type "
set ignorecase                  " ignore case when searching "
set smartcase                   " no ignorecase if Uppercase char present "

" }}}

" Section Folding {{{

set foldenable
set foldnestmax=2
set foldmethod=marker
autocmd FileType python set foldmethod=indent
autocmd FileType python set foldlevel=1

" }}}

" Encoding {{{

set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8

" }}}

" Undodir and Noswap {{{

if !isdirectory(g:undo_dir)
    call mkdir(g:undo_dir, "p", 0700)
endif

set undofile
exec 'set undodir=' .  g:undo_dir

set noswapfile

" }}}

" }}}

" Key binding and autocmd {{{

autocmd BufWritePost $MYVIMRC source $MYVIMRC

nnoremap <esc> :noh<return><esc>
nnoremap <esc>^[ <esc>^[

map <F5> :call CompileRunGcc()<CR>
func! CompileRunGcc()
        exec "w"
        if &filetype == 'c'
                exec "!g++ % -o %<"
                exec "!time ./%<"
        elseif &filetype == 'cpp'
                exec "!g++ % -o %<"
                exec "!time ./%<"
        elseif &filetype == 'java'
                exec "!javac %"
                exec "!time java %<"
        elseif &filetype == 'sh'
                :!time bash %
        elseif &filetype == 'python'
                "exec "!clear":
                exec "!time python3 %"
        elseif &filetype == 'html'
                exec "!firefox % &"
        elseif &filetype == 'go'
                " exec "!go build %<"
                exec "!time go run %"
        elseif &filetype == 'mkd'
                exec "!~/.vim/markdown.pl % > %.html &"
                exec "!firefox %.html &"
        endif
endfunc

autocmd BufWritePre * :call TrimWhitespace()
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun


map <leader>sa ggVG"
map <C-a> <Home>
map <C-e> <End>
map Y y$
nnoremap U <C-r>
cmap w!! w !sudo tee >/dev/null %
nnoremap Q :q<cr>
nnoremap <space> za

noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <leader>0 :tablast<cr>

noremap <C-h> <C-W>h
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-l> <C-W>l

inoremap <c-h> <left>
inoremap <c-j> <down>
inoremap <c-k> <up>
inoremap <c-l> <right>

nnoremap <c-w>k :abo split <cr>
nnoremap <c-w>h :abo vsplit <cr>
nnoremap <c-w>j :rightbelow split <cr>
nnoremap <c-w>l :rightbelow vsplit <cr>

nnoremap <Up> :resize +2<cr>
nnoremap <Down> :resize -2<cr>
nnoremap <Left> :vertical resize +2<cr>
nnoremap <Right> :vertical resize +2<cr>

xnoremap K :move '<-2'<cr>gv-gv
xnoremap J :move '>+1'<cr>gv-gv

nnoremap <silent> <leader>tn :tabnew<cr>
nnoremap <silent> <leader>tc :tabclose<cr>

nnoremap <silent> <leader>bn :bn<CR>
nnoremap <silent> <leader>bp :bp<CR>

vnoremap  <leader>y  "+y
nnoremap  <leader>Y  "+yg_
nnoremap  <leader>y  "+y
nnoremap  <leader>yy  "+yy

nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

nmap <leader>gs :G<CR>
nmap <leader>gd :Gvdiffsplit<CR>
nmap <leader>gf :diffget //2<CR>
nmap <leader>gj :diffget //3<CR>

map <F3> :NERDTreeToggle<CR>

" }}}
