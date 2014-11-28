set guifont=Envy\ Code\ R\ 12
set tabstop=4
set shiftwidth=4
set softtabstop=4
set viminfo=""
set nobackup
set nowritebackup
set noswapfile
set fileformat=unix
set paste
set pastetoggle=<F5>
set expandtab
retab
set guioptions-=T
set laststatus=2
set statusline=%02n:%t[%{strlen(&fenc)?&fenc:'none'},%{&ff}]%h%m%r%y%=%c,%l/%L\ %P
set showtabline=0

syntax on
filetype plugin indent on

vnoremap <C-X> "+x
vnoremap <S-Del> "+x

vnoremap <C-C> "+y
vnoremap <C-Insert> "+y

map <C-V> "+p
map <S-Insert> "+p

cmap <C-V> <C-R>+
cmap <S-Insert> <C-R>+

map <F2> :set fileencoding=utf-8<CR>:set fileformat=unix<CR>:w<CR>
map <F8> :set expandtab<CR>:retab<CR>

if $COLORTERM == 'gnome-terminal'
  set t_Co=256
endif

colorscheme ron
highlight Normal guibg=#2E3336 guifg=white

