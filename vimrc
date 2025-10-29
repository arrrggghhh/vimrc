" =============================================================================
" 기본 설정: 클립보드 연동
" - 목적: OS 시스템 클립보드(+ 레지스터)를 기본으로 사용
" - 가드: Vim이 clipboard 기능을 지원하는 경우에만 적용
" =============================================================================
if has('clipboard')
  set clipboard=unnamedplus
endif

" =============================================================================
" 기능: 붙여넣기 시 CRLF(\r\n) → LF(\n) 정규화
" - 배경: 윈도우에서 복사한 텍스트는 CRLF를 포함하여 유닉스 버퍼에서 ^M로 보일 수 있음
" - 대상: Normal/Visual 모드 put(p/P/gp/gP), Insert 모드 <C-r>+/*/"
" - 방식: 레지스터 내용의 "\r\ze\n"(LF 앞의 CR)만 제거, 레지스터 타입 보존
" - 멱등성: 이미 LF만 있으면 변화 없음
" - 예외: 터미널/GUI가 Vim을 우회하는 붙여넣기(마우스 중클릭, 메뉴 등)는 제어 불가
" - 토글
"   * 영구 끄기: vimrc에 `let g:clip_normalize_crlf = 0`
"   * 일시 끄기(세션 중): `:let g:clip_normalize_crlf = 0`
"   * 다시 켜기: `:let g:clip_normalize_crlf = 1`
" =============================================================================
if !exists('g:clip_normalize_crlf')
  let g:clip_normalize_crlf = 1
endif

" 내부 함수: 주어진 레지스터의 CRLF를 LF로 정규화
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

" put 래퍼: 카운트/레지스터를 보존하면서 정규화 후 본연의 키 실행
function! s:MapPut(key) abort
  call s:NormalizeRegCRLF(v:register)
  return v:count ? v:count . a:key : a:key
endfunction

" Normal/Visual 모드: 일반적인 붙여넣기 전 레지스터 정규화
nnoremap <expr> p  <SID>MapPut('p')
nnoremap <expr> P  <SID>MapPut('P')
nnoremap <expr> gp <SID>MapPut('gp')
nnoremap <expr> gP <SID>MapPut('gP')

xnoremap <expr> p  <SID>MapPut('p')
xnoremap <expr> P  <SID>MapPut('P')
xnoremap <expr> gp <SID>MapPut('gp')
xnoremap <expr> gP <SID>MapPut('gP')

if has('clipboard')
  " Insert 모드: <C-r>{레지스터}로 삽입 전 정규화
  function! s:MapInsert(reg) abort
    call s:NormalizeRegCRLF(a:reg)
    return "\<C-r>" . a:reg
  endfunction
  inoremap <expr> <C-r>+ <SID>MapInsert('+')
  inoremap <expr> <C-r>* <SID>MapInsert('*')
  inoremap <expr> <C-r>" <SID>MapInsert('"')
endif
