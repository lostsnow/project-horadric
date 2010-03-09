"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim settings by lostsnow <lostsnow@gmail.com>
"
" vim:shiftwidth=4:tabstop=4:expandtab
"
" <F2> - 保存 Buffer，并清理当前Buffer 中的行尾空格以及文件尾部的空行
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if v:version < 700
    echoerr 'This configuration file "' . $MYVIMRC . '" requires Vim 7 or later.'
    quit
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set locale
" language en

" Get out of VI's compatible mode..
set nocompatible

" Sets how many lines of history VIM har to remember
set history=400

" Set to auto read when a file is changed from the outside
set autoread

" Have the mouse enabled all the time:
set mouse=a

" Enable filetype plugin
if has("eval")
    filetype plugin on
    filetype indent on
endif

" Set map leader
let mapleader=","
let g:mapleader=","

" Fast saving changes
nmap <Leader>w :w!<CR>

" Fast exit vim saving any changes
nmap <Leader>q :wq!<CR>

" Fast find file with explorer
nmap <Leader>f :find<CR>

" Fast reloading of the .vimrc
nmap <Leader>s :source $MYVIMRC<CR>

" Fast editing of .vimrc
nmap <Leader>e :e! $MYVIMRC<CR>

" When .vimrc is edited, reload it
autocmd! BufWritePost $MYVIMRC source $MYVIMRC


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => File format
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Favorite filetype
set fileformats=unix,dos,mac

" nmap <Leader>fd :se ff=dos<CR>
" nmap <Leader>fu :se ff=unix<CR>

" Set default filetype
set fileformat=unix

" No bomb-Using non-bom utf-8 file format
set nobomb

" Set file encoding
set encoding=utf-8
set fileencoding=utf-8

set textwidth=80

set completeopt=longest,menu

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text option
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set expandtab
set shiftwidth=4
set softtabstop=4

" Using 4 spaces as <Tab> or :retab
set tabstop=4

" 整词换行
set linebreak
" set textwidth=76
set formatoptions+=mM

" Auto indent
set autoindent
set smartindent
set cindent
set wrap

" display tab
set list
" set listchars=tab:>-,trail:-  " 将制表符显示为'>---',将行尾空格显示为'-'
set listchars=tab:>\ ,trail:.   " 将制表符显示为'>   '


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files and backup
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Change the current working directory whenever you open a file, switch
" buffers, delete a buffer or open/close a window.
set autochdir

" Turn backup off
set nobackup
set nowritebackup
set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Folding
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable folding, I find it very useful
set foldenable
set foldmethod=syntax               " fold
set foldlevel=100                   " 启动vim时不要自动折叠代码


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Spell checking
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn off the spell check
set nospell


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlight
syntax enable
syntax on

" Using twice width of ASCII chars with EAST ASIAN Class Ambiguou
" set ambiwidth=double
" 设置字体，字体名称和字号
" set guifont=Lucida\ Sans\ Typewriter\ 9
set guifont=Monaco\ 9

colorscheme desert

" Parse the file when it's loaded to makes syntax highlighting
autocmd BufEnter * :syntax sync fromstart

" Omni menu color
hi Pmenu    guibg=#363636
hi PmenuSel guibg=#555555 guifg=White


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM User Interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Always show current position
set ruler

" The command bar is 2 high
set cmdheight=2

" Show (partial) command in the last line of the screen.
" default: on, off for Unix
set showcmd

" Show line number and width
set number
set numberwidth=5

" Do not redraw, when running macros.. lazyredraw
set lazyredraw

" Change buffer - without saving
set hidden

" Set backspace
set backspace=eol,start,indent

set whichwrap=b,s,<,>,[,]           " 光标从行首和行末时可以跳到另一行去

" Ignore case when searching
" set ignorecase
set incsearch

" Set magic on
set magic

" No sound on errors.
set noerrorbells
set novisualbell
set t_vb=

" When a bracket is inserted, briefly jump to a matching one
set showmatch

" How many tenths of a second to blink
set matchtime=2

" Highlight search thing
set hlsearch


function! CurDir()
    let curdir = substitute(getcwd(), '/home/lost', "~/", "g")
    return curdir
endfunction

" status line
set laststatus=2                    " always show the status line
set statusline=
set statusline+=%f                  " path to the file in the buffer, relative to current directory
set statusline+=\ %h%1*%m%r%w%0*    " flag
set statusline+=\ [%{strlen(&ft)?&ft:'none'}, " filetype
set statusline+=%{&encoding},       " encoding
set statusline+=%{&fileformat}]     " file format
set statusline+=\ CWD:%r%{CurDir()}%h
" set statusline+=\ CWD:%r%{CurDir()}%h
" set statusline+=%y%r%m%*%=[Line:%l/%L,Column:%c][%p%%]
set statusline+=%r%m%*%=[Line:%l/%L,Column:%c][%p%%]

" Remove the Windows ^M
noremap <Leader>m mmHmt:%s/<C-V><CR>//ge<CR>'tzt'm

" Remove indenting on empty line
map <F2> :w<CR>:call CleanupBuffer(1)<CR>:noh<CR>

" 打开当前目录文件列表
map <F3> :tabnew .<CR>

function! CleanupBuffer(keep)
    " Skip binary files
    if (&bin > 0)
        return
    endif

    " Remove spaces and tabs from end of every line, if possible
    silent! %s/\s\+$//ge

    " Save current line number
    let lnum = line(".")

    " number of last line
    let lastline = line("$")
    let n        = lastline

    " while loop
    while (1)
        " content of last line
        let line = getline(n)

        " remove spaces and tab
        if (!empty(line))
            break
        endif

        let n = n - 1
    endwhile

    " Delete all empty lines at the end of file
    let start = n+1+a:keep
    if (start <= lastline)
        execute n+1+a:keep . "," . lastline . "d"
    endif

    " after clean spaces and tabs, jump back
    exec "normal " . lnum . "G"
endfunction


" Don't close window, when deleting a buffer
command! Bclose call <SID>CloseBuffer()

function! <SID>CloseBuffer()
    let l:_currentBufNum = bufnr("%")
    let l:_alternateBufNum = bufnr("#")

    if buflisted(l:_alternateBufNum)
        buffer #
    else
        bnext
    endif

    if bufnr("%") == l:_currentBufNum
        new
    endif

    if buflisted(l:_currentBufNum)
        execute("bdelete! ".l:_currentBufNum)
    endif
endfunction

" Fast move to next line
nmap <SPACE> :exec "normal j"<CR>

" vim: set expandtab tabstop=4 shiftwidth=4:
