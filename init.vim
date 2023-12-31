" nvim config

" Preinstall {{{

if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
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

" Appearance
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'gruvbox-community/gruvbox'

" Tools
Plug 'kien/rainbow_parentheses.vim'
Plug 'tpope/vim-surround'
Plug 'Yggdroot/indentLine'
Plug 'preservim/nerdcommenter'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'ryanoasis/vim-devicons'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'voldikss/vim-floaterm'
Plug 'mhinz/vim-startify'
Plug 'babaybus/DoxygenToolkit.vim'
Plug 'easymotion/vim-easymotion'
Plug 'cdelledonne/vim-cmake'
Plug 'alepez/vim-gtest'


" Debug
Plug 'puremourning/vimspector'

" Auto complete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'honza/vim-snippets'

" For c++
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'vim-syntastic/syntastic'
Plug 'rhysd/vim-clang-format'

call plug#end()

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
set ttyfast
set lazyredraw
set belloff=all

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

set tabstop=2
set softtabstop=2
set shiftwidth=2

autocmd FileType python set tabstop=4
autocmd FileType python set softtabstop=4
autocmd FileType python set shiftwidth=4

set autoindent smartindent shiftround
set cindent
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

" Plugins Settings {{{

" RainbowParentheses {{{
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

" }}}

" Auto complete  {{{

let g:coc_global_extensions = [
      \'coc-python', 'coc-json', 'coc-cmake',
      \'coc-git', 'coc-sh', 'coc-markdownlint',
      \'coc-snippets', 'coc-highlight', 'coc-eslint', 'coc-pairs',
      \'coc-prettier',
      \]

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
" set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
    " Recently vim can merge signcolumn and number column into one
    set signcolumn=number
else
    set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-j>'

" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'

" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)


" Use <c-space> to trigger completion.
if has('nvim')
    inoremap <silent><expr> <c-space> coc#refresh()
else
    inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
        call CocActionAsync('doHover')
    else
        execute '!' . &keywordprg . " " . expand('<cword>')
    endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
    nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
    inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
    vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
" nmap <silent> <C-s> <Plug>(coc-range-select)
" xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" }}}

" Airline {{{

let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#fnametruncate = 16
let g:airline#extensions#tabline#fnamecollapse = 2
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#buffer_nr_show = 0
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_powerline_fonts = 1
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'
let g:airline_section_a = airline#section#create(['mode'])
let g:airline#extensions#whitespace#enabled = 0
nmap <silent> <leader>1         <Plug>AirlineSelectTab1
nmap <silent> <leader>2         <Plug>AirlineSelectTab2
nmap <silent> <leader>3         <Plug>AirlineSelectTab3
nmap <silent> <leader>4         <Plug>AirlineSelectTab4
nmap <silent> <leader>5         <Plug>AirlineSelectTab5
nmap <silent> <leader>6         <Plug>AirlineSelectTab6
nmap <silent> <leader>7         <Plug>AirlineSelectTab7
nmap <silent> <leader>8         <Plug>AirlineSelectTab8
nmap <silent> <leader>9         <Plug>AirlineSelectTab9

" }}}

" For Debug: vimspector {{{

nmap <F3> :VimspectorReset<Cr>
nmap <F4> <Plug>VimspectorRestart
nmap <F5> <Plug>VimspectorContinue
nmap <F6> <Plug>VimspectorPause
nmap <F8> <Plug>VimspectorAddFunctionBreakpoint
nmap <F9> <Plug>VimspectorToggleBreakpoint
nmap <F10> <Plug>VimspectorStepOver
nmap <F11> <Plug>VimspectorStepInto
nmap <F12> <Plug>VimspectorStepOut
let g:vimspector_install_gadgets = ['debugpy', 'vscode-cpptools', 'CodeLLDB']

" }}}

" Nerdcommenter {{{

let g:NERDSpaceDelims=1
let g:NERDCreateDefaultMappings = 0

map <leader>cc <plug>NERDCommenterComment
map <leader>cu <plug>NERDCommenterUncomment

" }}}

" Telescope {{{

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" }}}

" Floaterm {{{
  let g:floaterm_keymap_new = '<Leader>ft'
  let g:floaterm_keymap_toggle = '<Leader>t'
  let g:floaterm_position = 'bottom'
  let g:floaterm_width = 1.0
  let g:floaterm_height = 0.6
" }}}

" Startify {{{

let g:startify_bookmarks = [
  \ { 'z': '~/.zshrc' },
  \ { 'v': '~/.config/nvim/init.vim' },
  \ ]

let g:startify_custom_header = [
  \' .____   ______________________.__             .___.__        ',
  \' |    |  \_   _____/\_   _____/|  |   ____   __| _/|__| ____  ',
  \' |    |   |    __)   |    __)_ |  |  /  _ \ / __ | |  |/ __ \ ',
  \' |    |___|     \    |        \|  |_(  <_> ) /_/ | |  \  ___/ ',
  \' |_______ \___  /   /_______  /|____/\____/\____ | |__|\___  >',
  \'         \/   \/            \/                  \/         \/ ',
  \ ]

let g:startify_lists = [
      \ { 'header': ['   Bookmarks'],       'type': 'bookmarks' },
      \ { 'header': ['   MRU'],            'type': 'files' },
      \ { 'header': ['   MRU '. getcwd()], 'type': 'dir' },
      \ ]

" }}}

" highlight {{{

" c++ syntax highlighting
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1

" }}}

" syntastic/lint {{{

let g:syntastic_cpp_checkers = ['cpplint']
let g:syntastic_c_checkers = ['cpplint']
let g:syntastic_cpp_cpplint_exec = 'cpplint'

let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" }}}

" clang-format {{{

" autocmd FileType c,cpp,objc nnoremap <buffer><Leader>f :<C-u>ClangFormat<CR>
" autocmd FileType c,cpp,objc vnoremap <buffer><Leader>f :ClangFormat<CR>

" }}}

" cmake {{{

let g:cmake_link_compile_commands = 1
nmap <leader>cg :CMakeGenerate<cr>
nmap <leader>cb :CMakeBuild<cr>

" }}}

" }}}

" Key binding and autocmd {{{

noremap <esc> <esc>:w<return>:noh<return><esc>
inoremap <esc> <esc>:w<return><esc>

map <F2> :call CompileRunGcc()<CR>
func! CompileRunGcc()
    exec "w"
    :rightbelow vsplit
    :vertical resize -15
    if &filetype == 'c'
        exec "!gcc %"
		:term time ./a.out
    elseif &filetype == 'cpp'
        exec "!g++ % -std=c++17"
		:term time ./a.out
    elseif &filetype == 'sh'
		:term time bash %
    elseif &filetype == 'python'
		:term time python3 %
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
nnoremap <leader>a <C-a>
nnoremap <leader>x <C-x>
map Y y$
nnoremap U <C-r>
nnoremap Q :q<cr>

noremap <C-h> <C-W>h
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-l> <C-W>l

inoremap <c-h> <left>
inoremap <c-l> <right>

nnoremap <c-w>k :abo split <cr>
nnoremap <c-w>h :abo vsplit <cr>
nnoremap <c-w>j :rightbelow split <cr>
nnoremap <c-w>l :rightbelow vsplit <cr>

nnoremap <Up> :resize +2<cr>
nnoremap <Down> :resize -2<cr>
nnoremap <Left> :vertical resize -2<cr>
nnoremap <Right> :vertical resize +2<cr>

xnoremap K :move '<-2'<cr>gv-gv
xnoremap J :move '>+1'<cr>gv-gv
xnoremap < <gv
xnoremap > >gv

nnoremap <silent> <leader>bn :bn<CR>
nnoremap <silent> <leader>bp :bp<CR>
nnoremap J :bp<CR>
nnoremap K :bn<CR>
nnoremap <silent> <leader>bd :bd<CR>
nnoremap <silent> <leader>bl :ls<CR>
nnoremap <silent> <leader>bo :enew<CR>

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

tnoremap <Esc> <C-\><C-n>

" }}}
