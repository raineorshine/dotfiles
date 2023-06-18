"=== Raine's's custom vimrc ============================================

" use Vim settings rather then Vi settings (essential)
" this must be set first because it changes other options as a side effect
set nocompatible

"== Font and Color Settings ============================================
" set Windows font
if has("win32")
  set guifont=DejaVu_Sans_Mono:h8
endif

" turn off menu and toolbar 
set	guioptions-=m
set	guioptions-=T

" turn syntax on
if &t_Co > 2 || has("gui_running")
  syntax on
endif

" === Key Mappings =====================================================

" quick preferences (edit this file)
nmap	<M-r>		:tabe $VIM/_vimrc<CR>

" == FILES, BUFFERS, WINDOWS, TABS... ==
" file's working directory
cmap	%/			<C-R>=expand("%:p:h")."\\"<CR>

" quick save, save as, open, and quit
nmap	s			:w<CR>
nmap	<M-s>		:browse confirm sav<CR>
nmap	<M-S-s>		:browse confirm sav %/<CR><CR>
nmap	<M-q>		:q<CR>

" tabbed editing
nmap	<M-e>		:browse tabe %/<CR><CR>
nmap	<M-S-e>		:browse tabe<CR>
nmap	<M-n>		:tabn<CR>
nmap	<M-b>		:tabp<CR>

" browser style tab switching
nmap	<C-Tab>		:tabn<CR>
nmap	<C-S-Tab>	:tabp<CR>
nmap	<C-T>		:tabnew<CR>

" close (buffer delete)
nmap	<M-d>		:bd<CR>

" == Window Editing ==
" open a new window vertically on the right
nmap	<M-v>		:rightbelow vnew<CR>

" reinstate old 'M-e' for editing
nmap	<M-f>		<M-e>
nmap	<M-S-f>		<M-S-e>


" easier switching between modes
nmap	<M-Space>	i
imap	<M-Space>	<Right><Esc>
vmap	<M-Space>	<Esc>
cmap	<M-Space>	<Esc>

noremap	<C-Space>	i
imap	<C-Space>	<Right><Esc>
vmap	<C-Space>	<Esc>
cmap	<C-Space>	<Esc>

" == MOVEMENT ===============

" must be done before i is remapped
noremap k		i

" Regular movement (colemak)
noremap n		gj
noremap e		gk
noremap i		l

" Move between windows (colemak)
"nmap	<C-W>n		<C-W><Down>
"nmap	<C-W>e		<C-W><Up>
"nmap	<C-W>i		<C-W><Right>
"nmap	<C-W><C-n>	<C-W><Down>
"nmap	<C-W><C-e>	<C-W><Up>
"nmap	<C-W><C-i>	<C-W><Right>

" when a line wraps, move up or down by a display line, not the actual line
"noremap	j		gj
"noremap k		gk

" alternate movement in insert mode
" NOTE: <M-h> must be mapped in gvimrc to override the help menu shortcut
imap	<M-h>		<Left>
imap	<M-n>		<Down>
imap	<M-e>		<Up>
imap	<M-i>		<Right>

" command map arrow keys to h,j,k,l (or h,n,e,i in Colemak) for quicker access to previous commands
cmap	<M-h>		<Left>	
cmap	<M-n>		<Down>
cmap	<M-e>		<Up>
cmap	<M-i>		<Right>

" easier movement Home and End in insert mode
imap	<M-S-h>		<Home>
imap	<M-0>		<Home>
imap	<M-a>		<End>
nmap	<M-i>		<S-i>
nmap	<M-a>		<S-a>

" non-blank end complements '0' in normal mode
nmap	-		g_

" exit insert mode and undo (nice for undoing commands like 'c' that end up in insert mode)
imap	<M-u>		<Esc>u
nmap	<M-u>		u

" switch 'jump to marked line' and 'jump to marked character'
noremap	'		`
noremap	`		'

" switch the 'start of line' commands
noremap	0		^
noremap	^		0

" Search (colemak)
noremap	k			n
noremap <S-k>		<S-n>

" half-page scroll
" TODO: Why won't this work?
" noremap <M-k>		<C-Down>
" noremap <M-e>		<C-Up>

" == EDITING ================

" join up
nmap	<M-j>		mz:m-2<CR>J'z

" alternate delete
imap	<M-x>		<Delete>
imap	<M-z>		<Backspace>

" delete whole word in insert mode
imap	<C-Backspace>	<Esc>mzbd'za<Backspace>
imap	<C-Del>		<C-o>dE

" provide alternate 'o' and 'O' functionality insert mode
imap	<C-CR>		<C-o>o
imap	<C-S-CR>	<C-o>O

" fast indent in normal mode
nnoremap	<	<<
nnoremap	>	>>

" Windows-style select all, cut, copy, paste, undo
nmap	<C-a>		ggVG

map		<C-Z>		u

vmap	<C-X>		"+x
vmap	<C-C>		"+y
cmap	<C-V>		<C-R>+
map		<C-V>		"+gP
imap	<C-V>		<Esc>"+gpa
"
" Use Ctrl-B for visual block (formerly Ctrl-V)
noremap  <C-B>		<C-V>

" Put (Paste) in insert mode
imap	<M-p>		<C-o>P

" Replace the word under the cursos with whatever is in the registry
"(totally doesn't work)
"nmap	<M-r>		"_diwP

" toggle line numbers
map	<F9>		:set number!<CR>

" display RGB colour under the cursor
map  <F10>  :echo "name:" . synIDattr(synID(line("."),col("."),1),"name") . ", trans-name:" . synIDattr(synIDtrans(synID(line("."), col("."),1)), "name") . ", fg:" .  synIDattr(synIDtrans(synID(line("."), col("."),1)), "fg") . " (" .synIDattr(synIDtrans(synID(line("."), col("."),1)), "fg#") . "), bg:" .  synIDattr(synIDtrans(synID(line("."), col("."),1)), "bg") . " (" . synIDattr(synIDtrans(synID(line("."), col("."),1)), "bg") . ")"<CR>

" === Options ==========================================================
set	showcmd		" show (partial) command in status line.
set	history=500	" more history for undo
set	scrolloff=3	" always keep a few lines of context around the cursor when scrolling
set	showmatch	" show matching brackets.
set	autowrite	" automatically save before commands like :bn
set	nobackup	" turn off backup
set	nowritebackup
set	updatecount=0 " turn off spap file
set	textwidth=0	" do not force text wrap
set	smartindent	" when you start a new line with CR or O, indent to match the previous line

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" search options
set	incsearch	" search as you type
set	ignorecase	" do case insensitive matching
set	nohls		" turn off search highlighting

" tab options
set	tabstop=4	" keep tabstop at default 8
set	softtabstop=4	" make tabs feel like 4 during editing
set	shiftwidth=4	" shiftwidth should equal softtabstop
set	noexpandtab	" do not expand tabs into spaces

" fold options
set nofoldenable " disable folding
"set	foldcolumn=1		" display a column on the left side of the screen that shows folding
"set foldmethod=indent	" create folds at all indents
"set foldminlines=3		" folds are not created if they are too small
"set foldopen=all		" open fold when cursor enters
"set foldclose=all		" close fold when cursor leaves

" Pathogen - A simple library for manipulating comma delimited path options
" (needed for CoffeeScript)
"filetype off
"call pathogen#runtime_append_all_bundles()

" turn filetype plugin detection on to enable omni completion
"filetype plugin indent on

"autocmd BufWritePost *.coffee call xolox#shell#execute('coffee ' . expand('%') . ' ' . expand('%') . '.js', 0)

" Why I can't use Unicode in Vim even though I'd like to
"   (see :help map-alt-keys, and :help beos-meta)
" ------------------------------------------------------
" The ALT key is not passed to applications like the CTRL and SHIFT keys are (then how does foobar2000/Opera/etc. use it?).  Vim assumes that pressing
" the ALT key sets the 8th bit of a typed character.  In ASCII, the 8th bit is not used, so there is no problem
" using the ALT key in key mappings.  In Unicode, however, the 8th bit is definitely used, and this apparently
" precludes the use of ALT in any key mappings.  (latin1 does use the 8th bit, so I'm not sure why this
" problem occurs with unicode and not latin1...)

" NOTE: slate may not be installed in some versions of vim
" set color scheme
colo slate

" NOTE: autocmd may not be available in some versions of vim
" default filetype is markdown
autocmd BufEnter * if &filetype == "" | setlocal ft=mkd | endif
