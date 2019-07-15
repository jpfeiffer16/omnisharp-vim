if !OmniSharp#util#CheckCapabilities() | finish | endif
if get(g:, 'loaded_ctrlp_OmniSharp_findsymbols', 0) | finish | endif
let g:loaded_ctrlp_OmniSharp_findsymbols = 1

" Add this extension's settings to g:ctrlp_ext_vars
"
" Required:
"
" + init: the name of the input function including the brackets and any
"         arguments
"
" + accept: the name of the action function (only the name)
"
" + lname & sname: the long and short names to use for the statusline
"
" + type: the matching type
"   - line : match full line
"   - path : match full line like a file or a directory path
"   - tabs : match until first tab character
"   - tabe : match until last tab character
"
" Optional:
"
" + enter: the name of the function to be called before starting ctrlp
"
" + exit: the name of the function to be called after closing ctrlp
"
" + opts: the name of the option handling function called when initialize
"
" + sort: disable sorting (enabled by default when omitted)
"
" + specinput: enable special inputs '..' and '@cd' (disabled by default)
"
call add(g:ctrlp_ext_vars, {
\ 'init': 'ctrlp#OmniSharp#switchsolution#init()',
\ 'accept': 'ctrlp#OmniSharp#switchsolution#accept',
\ 'lname': 'Switch Solution',
\ 'sname': 'switch solution',
\ 'type': 'tabs',
\ 'sort': 1,
\ 'nolim': 1,
\ })


function! ctrlp#OmniSharp#switchsolution#setsolutions(solutions) abort
  let s:buffer = bufnr('%')
  let s:solutions = []
  for solution in a:solutions
    call add(s:solutions, solution)
  endfor
endfunction

" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#OmniSharp#switchsolution#init() abort
  return s:solutions
endfunction


" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#OmniSharp#switchsolution#accept(mode, str) abort
  call ctrlp#exit()
  call OmniSharp#SetSolution(s:buffer, a:str)
endfunction

" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#OmniSharp#switchsolution#id() abort
  return s:id
endfunction

" vim:et:sw=2:sts=2
