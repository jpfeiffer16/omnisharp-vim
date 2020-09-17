if exists('g:OmniSharp_loaded') | finish | endif
let g:OmniSharp_loaded = 1

let g:OmniSharp_lookup_metadata = get(g:, 'OmniSharp_lookup_metadata', 1)

" Default to `1`, except in cygwin defaults to `0`
let g:OmniSharp_server_stdio = get(g:, 'OmniSharp_server_stdio', !has('win32unix'))

let g:OmniSharp_server_display_loading = get(g:, 'OmniSharp_server_display_loading', 1)
let g:OmniSharp_server_loading_timeout = get(g:, 'OmniSharp_server_loading_timeout', 180)

" Use mono to start the roslyn server on *nix
let g:OmniSharp_server_use_mono = get(g:, 'OmniSharp_server_use_mono', 0)

let g:OmniSharp_open_quickfix = get(g:, 'OmniSharp_open_quickfix', 1)

let g:OmniSharp_timeout = get(g:, 'OmniSharp_timeout', 1)

" Default to `0`, except in cygwin
let g:OmniSharp_translate_cygwin_wsl = get(g:, 'OmniSharp_translate_cygwin_wsl', has('win32unix'))

let g:OmniSharp_typeLookupInPreview = get(g:, 'OmniSharp_typeLookupInPreview', 0)

let g:OmniSharp_sln_list_index = get(g:, 'OmniSharp_sln_list_index', -1)

let g:OmniSharp_autoselect_existing_sln = get(g:, 'OmniSharp_autoselect_existing_sln', 0)
let g:OmniSharp_prefer_global_sln = get(g:, 'OmniSharp_prefer_global_sln', 0)
let g:OmniSharp_start_without_solution = get(g:, 'OmniSharp_start_without_solution', 1)

" Automatically start server
let g:OmniSharp_start_server = get(g:, 'OmniSharp_start_server', get(g:, 'Omnisharp_start_server', 1))

let defaultlevel = g:OmniSharp_server_stdio ? 'info' : 'warning'
let g:OmniSharp_loglevel = get(g:, 'OmniSharp_loglevel', defaultlevel)

let g:OmniSharp_runtests_parallel = get(g:, 'OmniSharp_runtests_parallel', 1)
let g:OmniSharp_runtests_echo_output = get(g:, 'OmniSharp_runtests_echo_output', 1)

" Set to 1 when ultisnips is installed
let g:OmniSharp_want_snippet = get(g:, 'OmniSharp_want_snippet', 0)

let g:omnicomplete_fetch_full_documentation = get(g:, 'omnicomplete_fetch_full_documentation', 1)

command! -bar -nargs=? OmniSharpInstall call OmniSharp#Install(<f-args>)
command! -bar -nargs=? OmniSharpOpenLog call OmniSharp#log#Open(<q-args>)
command! -bar -bang OmniSharpStatus call OmniSharp#Status(<bang>0)

" Initialise automatic type and interface highlighting
" Preserve backwards compatibility with older version g:OmniSharp_highlight_types
let g:OmniSharp_highlighting = get(g:, 'OmniSharp_highlighting', get(g:, 'OmniSharp_highlight_types', 2))
if g:OmniSharp_highlighting
  augroup OmniSharp_HighlightTypes
    autocmd!
    autocmd BufEnter *.cs,*.csx
    \ if !pumvisible() && OmniSharp#util#CheckCapabilities() |
    \   call OmniSharp#actions#highlight#Buffer() |
    \ endif

    if g:OmniSharp_highlighting >= 2
      autocmd InsertLeave,TextChanged *.cs,*.csx
      \ if OmniSharp#util#CheckCapabilities() |
      \   call OmniSharp#actions#highlight#Buffer() |
      \ endif
    endif

    if g:OmniSharp_highlighting >= 3
      autocmd TextChangedI *.cs,*.csx
      \ if OmniSharp#util#CheckCapabilities() |
      \   call OmniSharp#actions#highlight#Buffer() |
      \ endif

      if exists('##TextChangedP')
        autocmd TextChangedP *.cs,*.csx
        \ if OmniSharp#util#CheckCapabilities() |
        \   call OmniSharp#actions#highlight#Buffer() |
        \ endif
      endif
    endif
  augroup END
endif

function! s:ALEWantResults() abort
  if !g:OmniSharp_server_stdio | return | endif
  if getbufvar(g:ale_want_results_buffer, '&filetype') ==# 'cs'
    call ale#sources#OmniSharp#WantResults(g:ale_want_results_buffer)
  endif
endfunction

augroup OmniSharp_Integrations
  autocmd!

  " Initialize OmniSharp as an asyncomplete source
  autocmd User asyncomplete_setup call asyncomplete#register_source({
  \ 'name': 'OmniSharp',
  \ 'whitelist': ['cs'],
  \ 'completor': function('asyncomplete#sources#OmniSharp#completor')
  \})

  autocmd User Ncm2Plugin call ncm2#register_source({
  \ 'name': 'OmniSharp-vim',
  \ 'priority': 9,
  \ 'scope': ['cs'],
  \ 'mark': 'OS',
  \ 'subscope_enable': 1,
  \ 'complete_length': 3,
  \ 'complete_pattern': ['\.'],
  \ 'on_complete': function('ncm2#sources#OmniSharp#on_complete')
  \})

  " Listen for ALE requests
  autocmd User ALEWantResults call s:ALEWantResults()
augroup END

if !exists('g:OmniSharp_selector_ui')
  let g:OmniSharp_selector_ui = get(filter(
  \   ['unite', 'ctrlp', 'fzf'],
  \   '!empty(globpath(&runtimepath, printf("plugin/%s.vim", v:val), 1))'
  \ ), 0, '')
endif
if g:OmniSharp_selector_ui ==? 'ctrlp'
  let g:ctrlp_extensions = get(g:, 'ctrlp_extensions', [])
  if !exists('g:OmniSharp_ctrlp_extensions_added')
    let g:OmniSharp_ctrlp_extensions_added = 1
    let g:ctrlp_extensions += ['findsymbols', 'findcodeactions']
  endif
endif
if g:OmniSharp_selector_ui ==? 'fzf'
  let g:OmniSharp_fzf_options = get(g:, 'OmniSharp_fzf_options', {})
endif

" vim:et:sw=2:sts=2
