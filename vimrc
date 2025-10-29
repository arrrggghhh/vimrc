" Clipboard integration (use system clipboard when available)
if has('clipboard')
  set clipboard=unnamedplus
endif

" Normalize CRLF to LF on paste
if !exists('g:clip_normalize_crlf')
  let g:clip_normalize_crlf = 1
endif

function! s:NormalizeRegCRLF(reg) abort
  if !g:clip_normalize_crlf
    return
  endif
  let l:reg = a:reg ==# '' ? '"' : a:reg
  let l:cont = getreg(l:reg, 1)
  if type(l:cont) != type('') || empty(l:cont)
    return
  endif
  let l:type = getregtype(l:reg)
  let l:norm = substitute(l:cont, '\r\ze\n', '', 'g')
  if l:norm isnot# l:cont
    call setreg(l:reg, l:norm, l:type)
  endif
endfunction

function! s:MapPut(key) abort
  call s:NormalizeRegCRLF(v:register)
  return v:count ? v:count . a:key : a:key
endfunction

nnoremap <expr> p  <SID>MapPut('p')
nnoremap <expr> P  <SID>MapPut('P')
nnoremap <expr> gp <SID>MapPut('gp')
nnoremap <expr> gP <SID>MapPut('gP')

xnoremap <expr> p  <SID>MapPut('p')
xnoremap <expr> P  <SID>MapPut('P')
xnoremap <expr> gp <SID>MapPut('gp')
xnoremap <expr> gP <SID>MapPut('gP')

if has('clipboard')
  function! s:MapInsert(reg) abort
    call s:NormalizeRegCRLF(a:reg)
    return "\<C-r>" . a:reg
  endfunction
  inoremap <expr> <C-r>+ <SID>MapInsert('+')
  inoremap <expr> <C-r>* <SID>MapInsert('*')
  inoremap <expr> <C-r>" <SID>MapInsert('"')
endif
