# Neovim Setup

## macOS

### 1. 사전 준비

Homebrew가 없으면 먼저 설치한다.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Nerd Font 설치

플러그인 아이콘 표시에 Nerd Font가 필요하다.

```sh
brew install --cask font-d2coding-nerd-font
```

또는 https://www.nerdfonts.com/font-downloads 에서 원하는 폰트를 다운로드한다.

설치 후 터미널 앱의 폰트를 Nerd Font로 변경한다.

### 3. 필수 도구 설치

```sh
brew install neovim go tree-sitter-cli ripgrep python3
```

Go 도구는 go install로 설치한다.

```sh
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest
```

`~/go/bin`이 PATH에 포함되어 있는지 확인한다.

```sh
echo $PATH | tr ':' '\n' | grep go
# 없으면 셸 설정에 추가
# export PATH="$HOME/go/bin:$PATH"
```

### 4. 설정 파일 배치

이 저장소를 클론하고 Neovim 설정 디렉토리에 심볼릭 링크를 건다.

```sh
git clone <repo-url> ~/tools/vimrc
ln -s ~/tools/vimrc/nvim ~/.config/nvim
```

이미 `~/.config/nvim`이 있으면 백업하거나 삭제한 뒤 진행한다.

## Ubuntu 서버

### 1. 필수 패키지 설치

```sh
sudo apt update
sudo apt install -y git curl build-essential python3 python3-pip python3-venv
```

### 2. Neovim 설치

Ubuntu 기본 저장소의 Neovim은 버전이 낮다. Pre-built 아카이브를 사용한다.

```sh
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm nvim-linux-x86_64.tar.gz
```

셸 설정(`~/.bashrc` 또는 `~/.zshrc`)에 PATH를 추가한다.

```sh
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
```

### 3. Go 설치 (g 버전 매니저)

[voidint/g](https://github.com/voidint/g)로 Go를 설치하고 버전을 관리한다.

```sh
curl -sSL https://raw.githubusercontent.com/voidint/g/master/install.sh | bash
source ~/.bashrc
```

`g` 명령이 다른 프로그램에 연결되어 있으면 alias로 강제 지정한다.

```sh
alias g='~/.g/bin/g'
```

설치 가능한 stable 버전을 확인하고 원하는 버전을 설치한다.

```sh
g ls-remote stable
g install 1.24.2
```

Go 도구를 설치한다.

```sh
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest
```

### 4. tree-sitter CLI 설치

```sh
sudo apt install -y npm
sudo npm install -g tree-sitter-cli
```

### 5. 설정 파일 배치

```sh
git clone <repo-url> ~/tools/vimrc
mkdir -p ~/.config
ln -s ~/tools/vimrc/nvim ~/.config/nvim
```

이미 `~/.config/nvim`이 있으면 백업하거나 삭제한 뒤 진행한다.

## 공통 (macOS / Ubuntu)

### 플러그인 설치

Neovim을 처음 실행하면 lazy.nvim이 자동으로 부트스트랩되고 플러그인을 설치한다.

```sh
nvim
```

설치 완료 후 `:Lazy` 명령으로 플러그인이 모두 로드되었는지 확인한다.

| 플러그인 | 역할 |
|---------|------|
| folke/lazy.nvim | 플러그인 매니저 |
| folke/flash.nvim | 화면 내 빠른 점프 (easymotion) |
| neovim/nvim-lspconfig | LSP 클라이언트 설정 |
| mason-org/mason.nvim | LSP/도구 설치 관리 |
| mason-org/mason-lspconfig.nvim | Mason + lspconfig 연동 |
| hrsh7th/nvim-cmp | 자동완성 엔진 |
| hrsh7th/cmp-nvim-lsp | LSP 자동완성 소스 |
| hrsh7th/cmp-buffer | 버퍼 단어 자동완성 소스 |
| nvim-telescope/telescope.nvim | fuzzy finder (파일, 심볼, 텍스트 검색) |
| nvim-telescope/telescope-fzf-native.nvim | telescope용 fzf 정렬 알고리즘 (C) |
| nvim-lua/plenary.nvim | telescope 의존 라이브러리 |
| nvim-treesitter/nvim-treesitter | 구문 하이라이팅/인덴트 |
| nvim-treesitter/nvim-treesitter-context | 함수/구조체 이름 상단 고정 |
| mrjones2014/smart-splits.nvim | 분할 창 이동/리사이즈 |
| nvim-tree/nvim-tree.lua | 파일 탐색기 |
| nvim-tree/nvim-web-devicons | 파일 아이콘 (Nerd Font 필요) |
| akinsho/toggleterm.nvim | 통합 터미널 (float, horizontal, vertical) |
| folke/persistence.nvim | 세션 자동 저장/복원 (디렉토리별, 필요 시 브랜치별 분리) |
| stevearc/aerial.nvim | 코드/문서 아웃라인 (목차 사이드바) |
| MeanderingProgrammer/render-markdown.nvim | 마크다운 버퍼 내 렌더링 |
| numToStr/Comment.nvim | 코드 주석 토글 (`gcc`, `gc`, `gbc`, `gb`) |
| kylechui/nvim-surround | 괄호/따옴표 등 감싸기 추가/변경/삭제 |
| stevearc/conform.nvim | 포매터 통합 관리 (저장 시 자동 포맷) |
| linux-cultist/venv-selector.nvim | Python 가상환경 선택 |
| mfussenegger/nvim-dap | DAP(Debug Adapter Protocol) 클라이언트 |
| rcarriga/nvim-dap-ui | 디버깅 UI (변수, 콜스택, 브레이크포인트 등) |
| nvim-neotest/nvim-nio | nvim-dap-ui 의존 라이브러리 (비동기 IO) |
| leoluz/nvim-dap-go | Go 디버깅 어댑터 (delve) |
| mfussenegger/nvim-dap-python | Python 디버깅 어댑터 (debugpy) |
| lewis6991/gitsigns.nvim | git 변경 표시, hunk 탐색/스테이징, blame |
| folke/which-key.nvim | 키맵 팝업 (기본 비활성, `<Space>k`로 토글) |
| lukas-reineke/indent-blankline.nvim | 들여쓰기 가이드라인 (Python 파일 전용) |
| nvim-lualine/lualine.nvim | 상태바 (모드, git branch, diagnostics, 파일 정보) |
| folke/todo-comments.nvim | TODO/FIXME/HACK 하이라이팅 및 검색 |
| kevinhwang91/nvim-ufo | 모던 fold (treesitter 기반 접기/펼치기/미리보기) |
| kevinhwang91/promise-async | nvim-ufo 의존 라이브러리 |

### Mason으로 LSP/도구 확인

Mason이 LSP 서버를 자동 설치하도록 설정되어 있다 (`ensure_installed = { "gopls", "pyright", "ruff" }`).
시스템에 이미 해당 도구가 있으면 그대로 사용되고, 없으면 Mason이 설치한다.

goimports, delve(Go 디버거), debugpy(Python 디버거)는 자동 설치 대상이 아니므로 수동 설치한다.

```vim
:MasonInstall goimports
:MasonInstall delve
:MasonInstall debugpy
```

### Treesitter 파서 확인

tree-sitter CLI가 설치되어 있으면 첫 실행 시 Go 관련 파서가 자동 설치된다.
수동으로 확인하려면:

```vim
:lua print(vim.inspect(require("nvim-treesitter").get_installed()))
```

go, gomod, gosum, gotmpl, json, lua, markdown, markdown_inline, python, query, toml, vim, vimdoc 파서가 있어야 한다.

### 동작 확인 (Go)

Go 프로젝트 디렉토리에서 `.go` 파일을 열어 다음을 확인한다.

```sh
cd ~/your-go-project
nvim main.go
```

- **LSP**: `gd`(정의 이동), `gr`(참조 찾기), `K`(호버) 동작 확인
- **자동완성**: Insert 모드에서 `.` 입력 시 완성 목록 표시
- **Format on save**: `:w` 시 goimports가 자동 적용 (import 정리 + 포맷)
- **Treesitter**: 구문 하이라이팅 적용 확인
- **Sticky context**: 긴 함수/구조체 스크롤 시 이름이 상단에 고정 표시
- **파일 탐색기**: `<Space>e`로 nvim-tree 열기/포커스, 트리 안에서 `q`로 닫기
- **들여쓰기**: Go 파일에서 탭 기반 들여쓰기 (`noexpandtab`, `tabstop=4`)

### 동작 확인 (Python)

Python 프로젝트 디렉토리에서 `.py` 파일을 열어 다음을 확인한다.

```sh
cd ~/your-python-project
nvim main.py
```

- **LSP**: `gd`(정의 이동), `gr`(참조 찾기), `K`(호버) 동작 확인
- **자동완성**: Insert 모드에서 `.` 입력 시 완성 목록 표시
- **Format on save**: `:w` 시 ruff가 자동 적용 (import 정리 + 포맷)
- **Treesitter**: 구문 하이라이팅 적용 확인
- **린팅**: ruff 린터가 코드 문제를 진단으로 표시
- **들여쓰기**: Python 파일에서 스페이스 기반 들여쓰기 (`expandtab`, `tabstop=4`)
- **가상환경**: `<Space>vs`로 venv/conda 환경 선택

## 공통 기능 가이드

### 키맵 찾기 (which-key.nvim)

기본적으로 비활성화되어 있다. 키맵이 헷갈릴 때 `<Space>k`로 켜면 `<Space>` 등
prefix 키를 누르고 잠시 기다렸을 때 사용 가능한 키맵 목록이 팝업으로 표시된다.
다시 `<Space>k`를 누르면 비활성화된다.

```
<Space>k           which-key 토글 (ON/OFF)
<Space>?           현재 버퍼의 키맵 목록 (which-key 상태와 무관하게 항상 동작)
```

팝업에서 다음 키를 누르면 해당 그룹의 하위 키맵이 표시된다.

### 설정 자동 업데이트

여러 컴퓨터에서 같은 vimrc 저장소를 공유할 때, 다른 컴퓨터에서 푸시한 변경사항을
자동으로 받아오는 기능이다. nvim 시작 시 백그라운드에서 `git fetch`를 실행하고,
워킹트리가 깨끗하면 `git merge --ff-only`로 fast-forward한 뒤 알림을 띄운다.

- **저장소 경로**: `~/tools/vimrc` (고정)
- **실행 시점**: `VimEnter` autocmd. 시작 시간에 영향 없음 (async)
- **빈도 제한**: 1시간에 1회. stamp 파일 `~/.cache/nvim/vimrc-last-fetch`에 기록
- **워킹트리 더러움 / fast-forward 불가**: merge 생략, 알림만 표시

알림 예시:

```
vimrc 업데이트됨 (3 커밋), nvim 재시작 권장
vimrc 업데이트 2개 있음 (워킹트리 변경사항 있어 자동 merge 생략)
vimrc merge 실패 (fast-forward 불가, 수동 merge 필요)
```

수동으로 즉시 fetch하고 싶으면 stamp 파일을 지우고 nvim을 재시작한다.

```sh
rm ~/.cache/nvim/vimrc-last-fetch
```

구현은 `lua/config/auto_update.lua`에 있다.

### 파일 경로 복사

현재 파일의 경로와 라인 번호(또는 선택 범위)를 시스템 클립보드에 복사한다.

```
<Space>yp    상대 경로:라인 복사       예: lua/config/keymaps.lua:14
<Space>yP    절대 경로:라인 복사       예: /Users/z/tools/vimrc/nvim/lua/config/keymaps.lua:14
```

Visual 모드에서 범위를 선택한 뒤 사용하면 라인 범위가 포함된다.

```
<Space>yp    상대 경로:범위 복사       예: lua/config/keymaps.lua:14-20
<Space>yP    절대 경로:범위 복사       예: /Users/z/tools/vimrc/nvim/lua/config/keymaps.lua:14-20
```

### Git 변경 표시 (gitsigns.nvim)

편집 중인 파일의 git 변경 사항을 gutter(줄 번호 옆)에 표시한다. lazygit과
함께 사용하면 편집기 안에서 git 워크플로우를 완결할 수 있다.

**Hunk 탐색** — 변경된 코드 블록(hunk) 사이를 이동한다.

```
]c    다음 hunk로 이동
[c    이전 hunk로 이동
```

**Hunk 조작**

```
<Space>gs    hunk 스테이징 (git add 부분 적용)
<Space>gr    스테이징 취소 (git reset)
<Space>gu    hunk 되돌리기 (변경 취소, undo)
<Space>gp    hunk 미리보기 (팝업)
```

Visual 모드에서 `<Space>gs`/`<Space>gu`를 사용하면 선택한 줄만 스테이징/되돌리기할
수 있다.

**Blame**

```
<Space>gb    현재 줄의 blame 정보 팝업 (커밋 해시, 작성자, 날짜, 메시지)
<Space>gB    인라인 blame 토글 (각 줄 끝에 blame 표시)
```

**Diff**

```
<Space>gd    현재 파일을 index(스테이징 영역)와 비교
```

### TODO 주석 (todo-comments.nvim)

아무 영문 대문자 단어를 인식하는 것은 아니며, 미리 정의된 키워드와 alias만
하이라이팅한다.

기본 키워드는 `TODO`, `FIX`, `HACK`, `WARN`, `PERF`, `NOTE`, `TEST`다.

기본 alias로 `FIXME`, `BUG`, `FIXIT`, `ISSUE`, `WARNING`, `XXX`, `OPTIM`,
`PERFORMANCE`, `OPTIMIZE`, `INFO`, `TESTING`, `PASSED`, `FAILED`도 함께 인식한다.

기본 형식은 `키워드:` 형태다. 예: `TODO:`, `FIXME:`, `HACK:`, `NOTE:`

기본 설정은 대소문자를 구분하므로 `TODO:`는 하이라이팅되지만 `todo:`는 하이라이팅되지 않는다.

```
]t              다음 TODO 주석으로 이동
[t              이전 TODO 주석으로 이동
<Space>ft       프로젝트 전체 TODO 검색 (telescope)
```

### 코드 주석 토글 (Comment.nvim)

기본 설정으로 활성화되어 있으며 `commentstring`을 사용하는 파일타입에서는 별도 설정 없이
라인 주석과 블록 주석을 토글할 수 있다.

**기본 토글**

```
gcc             현재 줄 라인 주석 토글
gbc             현재 줄 블록 주석 토글
[count]gcc      현재 줄부터 count개 줄 라인 주석 토글
[count]gbc      현재 줄부터 count개 줄 블록 주석 토글
gc{motion}      motion 범위를 라인 주석 토글
gb{motion}      motion 범위를 블록 주석 토글
```

Visual 모드에서 선택한 범위에도 바로 적용할 수 있다.

```
gc              선택 영역 라인 주석 토글
gb              선택 영역 블록 주석 토글
```

**주석 줄 추가**

```
gco             현재 줄 아래에 주석 줄 추가 후 Insert 모드 진입
gcO             현재 줄 위에 주석 줄 추가 후 Insert 모드 진입
gcA             현재 줄 끝에 주석 추가 후 Insert 모드 진입
```

자주 쓰는 예시는 다음과 같다.

```
gcap            현재 문단 전체 라인 주석 토글
gc2j            현재 줄 포함 아래 2줄 범위 라인 주석 토글
gbaf            함수 전체 블록 주석 토글
```

## Go 소스코드 편집 가이드

### 빠른 점프 (flash.nvim)

easymotion과 같은 역할. 화면에 보이는 아무 위치로 빠르게 이동한다.

**`s` + 검색 문자** — Normal 모드에서 `s`를 누르면 검색 모드에 진입한다.
이동하려는 곳의 글자를 입력하면 화면의 모든 매칭 위치에 라벨이 표시된다.
라벨 문자를 누르면 해당 위치로 즉시 점프한다.

```
s + {검색 문자} + {라벨}    해당 위치로 점프
S                           treesitter 노드 단위로 선택 (함수, 블록 등)
```

`d`, `c`, `y` 같은 operator와 조합할 수도 있다. 예: `ds{검색}{라벨}`로 커서부터 해당 위치까지 삭제.

### 감싸기 편집 (nvim-surround)

괄호, 따옴표, 태그 등을 추가, 변경, 삭제한다. Vim의 vim-surround와 동일한
키바인딩을 사용한다.

**추가** — `ys{motion}{char}`

```
ysiw"       단어를 "로 감싸기          hello → "hello"
ysiw)       단어를 ()로 감싸기         hello → (hello)
ysiw}       단어를 {}로 감싸기         hello → {hello}
ys2aw"      단어 2개를 "로 감싸기
yss"        줄 전체를 "로 감싸기
```

여는 괄호(`(`, `{`, `[`)를 쓰면 안쪽에 공백이 추가되고, 닫는 괄호(`)`, `}`,
`]`)를 쓰면 공백 없이 감싼다.

```
ysiw(       hello → ( hello )
ysiw)       hello → (hello)
```

**변경** — `cs{old}{new}`

```
cs"'        "hello" → 'hello'
cs)]        (hello) → [hello]
cs"<div>    "hello" → <div>hello</div>
```

**삭제** — `ds{char}`

```
ds"         "hello" → hello
ds)         (hello) → hello
dst         <div>hello</div> → hello
```

**Visual 모드** — 선택 영역을 감싸기

```
S"          Visual 모드에서 선택한 텍스트를 "로 감싸기
S)          Visual 모드에서 선택한 텍스트를 ()로 감싸기
```

### 코드 탐색

**정의로 이동** — 함수, 변수, 타입 이름의 정의 위치로 이동한다.

```
gd    definition을 다른 창에서 열기 (창이 하나면 세로 분할 생성, 여러 창이어도 현재 커서 기준으로 조회)
gzd   definition을 새 탭에서 열기
gD    definition을 현재 창에서 열기
```

**타입 정의로 이동** — 변수 위에서 그 변수의 타입 정의로 바로 이동한다.

```
gy    type definition을 다른 창에서 열기 (창이 하나면 세로 분할 생성, 여러 창이어도 현재 커서 기준으로 조회)
gzt   type definition을 새 탭에서 열기
gY    type definition을 현재 창에서 열기
<Space>yt    현재 심볼의 타입 문자열을 unnamed register와 system clipboard에 복사
```

**함수 정의로 이동** — 함수 호출 위에 커서를 놓고:

```
gd    함수 정의를 다른 창에서 열기
gzd   함수 정의를 새 탭에서 열기
gD    함수 정의를 현재 창에서 열기
K     함수 시그니처와 문서를 팝업으로 확인
```

이동 후 `Ctrl+o`로 이전 위치로 돌아간다. `Ctrl+i`로 다시 앞으로 간다.

**참조 검색** — 심볼이 사용된 모든 곳을 찾는다.

```
gr    커서 아래 심볼을 참조하는 모든 위치를 목록으로 표시
```

quickfix 목록이 열리면 `j`/`k`로 이동, `Enter`로 해당 위치를 열면서 quickfix에 포커스를 유지한다.
해당 파일로 포커스를 옮기려면 `o`를 누른다. `:cclose`로 목록을 닫는다.

### 자동완성

Insert 모드에서 자동으로 완성 후보가 표시된다.

```
Ctrl+Space    수동으로 완성 목록 호출
Ctrl+n        다음 항목 선택
Ctrl+p        이전 항목 선택
Enter         선택한 항목 확정
Ctrl+e        완성 취소
```

gopls가 함수 파라미터 placeholder도 함께 삽입한다 (`usePlaceholders = true`).
Tab으로 다음 placeholder 위치로 이동할 수 있다.

### 파일 탐색기 (nvim-tree)

```
<Space>e     파일 트리 열기/포커스 (이미 열려 있으면 포커스만 이동)
<Space>fe    현재 파일을 트리에서 찾아 하이라이트
```

트리 내에서 사용하는 키:

```
Enter    파일 열기 / 디렉토리 열기·접기
a        새 파일 또는 디렉토리 생성 (이름 끝에 /를 붙이면 디렉토리)
r        이름 변경
d        삭제
x        상위 디렉토리 접기
q        트리 닫기 (<Space>e로 다시 열기)
```

### 검색 (telescope.nvim)

VS Code의 Command Palette(`Cmd+P`)처럼 파일명, 심볼, 텍스트를 fuzzy 검색한다.
검색창에서 입력하면 실시간으로 결과가 필터링된다.

**파일 검색** — 프로젝트 내 파일을 이름으로 찾는다.

```
<Space>ff    파일명 fuzzy 검색 (VS Code Cmd+P와 동일)
```

**텍스트 검색** — 파일 내용을 ripgrep으로 실시간 검색한다.

```
<Space>fg    파일 내용 검색 (VS Code Cmd+Shift+F와 동일, ripgrep 필요)
```

**심볼 검색** — LSP를 통해 함수, 타입, 변수 등 심볼을 이름으로 검색한다.

```
<Space>fs    현재 파일의 심볼 목록 (VS Code Cmd+Shift+O와 동일)
<Space>fS    워크스페이스 전체 심볼 검색 (VS Code Cmd+T와 동일)
```

**기타 검색**

```
<Space>fb    열린 버퍼 목록에서 선택
<Space>fd    진단(에러/경고) 목록
<Space>fr    마지막 검색을 이어서 진행
```

**검색창 안에서 조작**

```
Ctrl+n / Ctrl+p    다음/이전 항목 선택
Enter              선택한 항목 열기
Ctrl+x             선택한 항목을 수평 분할로 열기
Ctrl+v             선택한 항목을 수직 분할로 열기
Esc                검색 닫기
```

### 창 분할

**분할 생성**

```
:split          수평 분할 (위아래)     단축: Ctrl+w s
:vsplit         수직 분할 (좌우)       단축: Ctrl+w v
:split foo.go   특정 파일을 수평 분할로 열기
:vsplit foo.go  특정 파일을 수직 분할로 열기
```

**분할 간 이동** — smart-splits 플러그인:

```
Ctrl+h    왼쪽 창으로
Ctrl+j    아래 창으로
Ctrl+k    위 창으로
Ctrl+l    오른쪽 창으로
```

**창 크기 조정** — smart-splits 플러그인:

```
Alt+h     왼쪽으로 줄이기
Alt+j     아래로 늘리기
Alt+k     위로 늘리기
Alt+l     오른쪽으로 늘리기
```

**창 최대화 토글** — 현재 창을 최대화하거나 이전 레이아웃으로 복원한다.

```
Ctrl+w m    현재 창 최대화 / 원래 레이아웃 복원 (토글)
```

**창 크기 균등화**

```
Ctrl+w =    모든 창 크기를 같게
```

**창 닫기**

```
:close      현재 창 닫기 (버퍼는 유지)    단축: Ctrl+w c
:only       현재 창만 남기고 나머지 닫기    단축: Ctrl+w o
```

### 버퍼 / 윈도우 / 탭 개념

VS Code에서 넘어오면 가장 헷갈리는 부분이다. Neovim은 보통 `탭 > 윈도우 > 버퍼`
구조로 이해하면 된다.

- **버퍼(buffer)**: 열린 파일 내용 자체. 파일 탭에 가장 가까운 개념.
- **윈도우(window)**: 화면에 보이는 칸. split 창 하나가 window 하나다.
- **탭(tabpage)**: 여러 window 배치를 묶는 바깥 레이아웃.

관계는 대략 이렇게 보면 된다.

```text
탭
  ├─ 윈도우
  │    └─ 버퍼
  └─ 윈도우
       └─ 버퍼
```

핵심 차이:

- VS Code는 그룹 안에 파일 탭이 있는 느낌에 가깝다.
- Neovim은 탭 안에 split window가 있고, 각 window가 어떤 buffer를 보여줄지 정한다.
- 같은 buffer를 여러 window에서 동시에 열 수 있다.
- window를 닫아도 buffer는 남을 수 있다.
- buffer 번호는 모든 window와 tab에서 공유된다.

실전에서는 이렇게 생각하면 편하다.

- 파일 사이를 오가고 싶으면 buffer를 바꾼다.
- 파일을 동시에 보고 싶으면 window를 나눈다.
- 작업 맥락 자체를 분리하고 싶으면 tab을 만든다.

### 버퍼

**버퍼 열기/닫기**

```
:e foo.go       파일을 새 버퍼로 열기
:enew           빈 버퍼 생성
:bd             현재 버퍼 닫기
:bd foo.go      특정 버퍼 지정 닫기
:BufOnlyVisible 현재 보이는 버퍼만 남기고 나머지 listed buffer 닫기
:BufOnlyVisible! 수정된 hidden buffer도 강제로 닫기
:ls             열린 버퍼 목록과 번호 확인
```

**버퍼 이동**

```
[b           이전 버퍼
]b           다음 버퍼
<Space>bd    창은 유지하고 현재 버퍼만 닫기
```

**버퍼를 다른 창에서 열기** — 분할과 조합:

```
:split #3       3번 버퍼를 수평 분할로 열기
:vsplit #3      3번 버퍼를 수직 분할로 열기
```

### 기타 유용한 LSP 기능

```
<Space>rn    심볼 이름 일괄 변경 (rename)
<Space>ca    코드 액션 (import 추가, 인터페이스 구현 등)
[d           이전 진단(에러/경고)으로 이동
]d           다음 진단(에러/경고)으로 이동
```

저장(`:w`) 시 goimports가 자동 실행되어 import 정리와 코드 포맷이 적용된다.

## Python 소스코드 편집 가이드

### LSP 구성

Python은 두 개의 LSP 서버가 동시에 동작한다.

- **pyright**: 타입 체킹, 자동완성, 정의 이동, 호버 정보
- **ruff**: 린팅 (코드 스타일, 잠재적 버그 검출), 코드 액션 (자동 수정)

코드 탐색, 자동완성, 키맵 등은 Go와 동일하게 작동한다 (`gd`, `gr`, `K`,
`<Space>rn`, `<Space>ca` 등).

### Format on save (conform.nvim)

저장(`:w`) 시 conform.nvim이 ruff를 실행하여 자동 포맷팅한다.

1. **ruff fix** — 자동 수정 가능한 린트 이슈 해결, import 정리
2. **ruff format** — 코드 포맷팅 (black 호환 스타일)

`:ConformInfo`로 현재 파일에 적용되는 포매터 상태를 확인할 수 있다.

### 가상환경 (venv-selector.nvim)

pyright가 올바른 패키지를 인식하려면 프로젝트의 가상환경을 선택해야 한다.

```
<Space>vs    가상환경 목록을 telescope로 검색하여 선택
```

venv, virtualenv, conda, poetry 등 다양한 환경을 자동 탐지한다. 선택하면
pyright가 해당 환경의 패키지를 인식하여 자동완성과 타입 체킹이 정상 동작한다.

### 들여쓰기

Python 파일은 스페이스 4칸 들여쓰기가 자동 적용된다 (`expandtab`, `tabstop=4`,
`shiftwidth=4`).

## 디버깅 (nvim-dap)

DAP(Debug Adapter Protocol)를 통해 에디터 안에서 직접 디버깅할 수 있다.
Go(delve)와 Python(debugpy) 디버깅이 설정되어 있다.

### 사전 준비

Go 디버깅에는 delve, Python 디버깅에는 debugpy가 필요하다. Mason으로 설치한다.

```vim
:MasonInstall delve debugpy
```

### 기본 키맵

```
<Space>db    브레이크포인트 토글
<Space>dc    디버깅 시작 / 계속 (continue)
<Space>di    step into (함수 안으로)
<Space>do    step over (다음 줄)
F10          step over (다음 줄)
<Space>dO    step out (함수 밖으로)
<Space>dr    재시작
<Space>dt    종료
<Space>df    현재 실행 위치로 커서 이동
<Space>du    DAP UI 토글
<Space>dT    커서 위치의 테스트 함수 디버깅 (Go: delve, Python: debugpy)
```

### 실행 구성 (Go)

`<Space>dc`로 디버깅을 시작하면 아래 목록에서 선택한다.

| # | 이름 | 대상 | 모드 |
|---|------|------|------|
| 1 | Debug (debug/main.go) | `${workspaceFolder}/debug` | debug |
| 2 | Debug | 현재 파일 | debug |
| 3 | Debug (Arguments) | 현재 파일 + args 입력 | debug |
| 4 | Debug (Arguments & Build Flags) | 현재 파일 + args + build flags 입력 | debug |
| 5 | Debug Package | 현재 파일의 패키지 디렉토리 | debug |
| 6 | Attach | 실행 중인 프로세스에 연결 | local |
| 7 | Debug test | 현재 파일 | test |
| 8 | Debug test (go.mod) | 상대 경로 기준 패키지 | test |

- debug 모드: 해당 경로에 `package main`과 `main()` 함수가 필요하다
- test 모드: `go test`로 실행되므로 `main()` 없이 `Test*` 함수가 실행된다
- 1번은 프로젝트 루트(`go.mod` 위치)에 `debug/main.go`를 만들어 디버깅 진입점으로 사용한다

### 실행 구성 (Python)

Python 파일에서 `<Space>dc`로 디버깅을 시작하면 아래 목록에서 선택한다.

| # | 이름 | 대상 |
|---|------|------|
| 1 | Launch file | 현재 파일 |
| 2 | Launch file with arguments | 현재 파일 + args 입력 |
| 3 | Attach remote | 실행 중인 debugpy 서버에 연결 |
| 4 | Run doctests in file | 현재 파일의 doctest 실행 |

- debugpy는 Mason으로 설치한다 (`:MasonInstall debugpy`)
- 프로젝트의 가상환경을 사용하려면 venv-selector (`<Space>vs`)로 먼저 선택한다

### 사용 흐름

1. 디버깅할 코드에서 `<Space>db`로 브레이크포인트를 설정한다
2. `<Space>dc`로 디버깅을 시작하고 실행 구성을 선택한다
   - 테스트 함수를 디버깅하려면 커서를 테스트 함수 안에 놓고 `<Space>dT`를 누른다
3. 브레이크포인트에서 멈추면 DAP UI가 자동으로 열린다
4. `<Space>di`/`<Space>do`/`<Space>dO`로 코드를 한 줄씩 실행한다
5. DAP UI에서 변수 값, 콜스택, 브레이크포인트 목록을 확인한다
6. `<Space>dt`로 디버깅을 종료하면 DAP UI가 자동으로 닫힌다

### DAP UI 패널

디버깅이 시작되면 자동으로 UI가 열리며 다음 패널이 표시된다.

- **Scopes**: 현재 스코프의 지역/전역 변수 값
- **Breakpoints**: 설정된 브레이크포인트 목록
- **Stacks**: 콜스택 (함수 호출 경로)
- **Watches**: 감시 표현식 (수동 추가)

`<Space>du`로 UI를 수동으로 열고 닫을 수 있다.

### 변수 검사 (hover eval)

디버그 세션 중에는 `K`가 LSP 호버 대신 DAP eval로 전환된다. 커서 아래 변수의
런타임 값을 float 창으로 표시한다. 디버깅이 종료되면 `K`는 LSP 호버로 자동 복귀한다.

```
K           변수의 런타임 값을 float 창으로 표시 (디버그 세션 중)
K (한 번 더) float 창 안으로 커서 이동 (중첩 속성 탐색/복사 가능)
```

Visual 모드에서 표현식을 선택한 뒤 `K`를 누르면 해당 표현식을 평가한다.

Watches 패널에서는 `i`로 감시할 표현식을 추가하고, `d`로 삭제한다. 매 스텝마다
등록된 표현식의 값이 자동 갱신된다.

### 통합 터미널 (toggleterm.nvim)

VS Code의 통합 터미널처럼 Neovim 안에서 터미널을 열고 닫을 수 있다.

**터미널 열기/닫기**

```
F12           active 터미널 토글 (기본 대상: 1번)
<Space>ta     F12가 가리킬 active 터미널 지정
<Space>tf     float 터미널 (화면 중앙에 떠 있는 창)
<Space>th     horizontal 터미널 (하단 분할)
<Space>tv     vertical 터미널 (우측 분할)
<Space>tt     tab 터미널 (전체화면)
<Space>tg     lazygit (lazygit 설치 필요)
<Space>ts     터미널 목록에서 선택
```

float은 빠르게 명령 하나 실행하고 닫을 때, horizontal은 코드를 보면서 실행 결과를
확인할 때 적합하다. tab은 터미널 작업에 집중하고 싶을 때 전체화면으로 쓴다.
`go test ./...` 같은 명령은 horizontal이 편하다. `F12`는 마지막에 지정하거나 직접
토글한 active 터미널 번호를 기억하며, 그 터미널의 기존 방향(float/vertical/horizontal/tab)을
그대로 유지한다. 터미널 창이 열릴 때는 자동으로 input mode로 들어간다.

**터미널 안에서 조작**

```
F12           active 터미널 닫기/다시 열기
Ctrl+\ Ctrl+n 터미널 입력 모드 → Neovim Normal 모드
i 또는 a      Normal 모드로 빠져나온 뒤 다시 터미널 입력 모드로 진입
Ctrl+h/j/k/l  터미널에서 다른 창으로 이동
```

Normal 모드로 전환하면 터미널 출력을 Vim 방식으로 스크롤하거나 텍스트를 복사할 수
있다.

터미널 안에서 다시 `vim` 또는 `nvim`을 실행한 경우에는 계층이 하나 더 생긴다.

```
바깥 Neovim 일반 버퍼         Esc                insert → normal
toggleterm 터미널            Ctrl+\ Ctrl+n      terminal-mode → Neovim normal
터미널 안의 vim/nvim         Esc                inner editor insert → normal
```

즉, 터미널 버퍼 자체를 빠져나올 때만 `Ctrl+\ Ctrl+n`이 필요하고, 터미널 안에서 실행한
inner `vim`/`nvim`에서는 평소처럼 `Esc`를 쓴다.

**여러 터미널 관리**

번호를 붙여서 여러 터미널 인스턴스를 동시에 관리할 수 있다. 번호별로 독립적인
셸 세션이 유지된다.

```
2<Space>th    2번 터미널을 horizontal로 열기
3<Space>tv    3번 터미널을 vertical로 열기
2F12          현재 터미널을 닫고 2번 터미널로 전환, 이후 F12 대상도 2번으로 변경
2<Space>ta    F12가 가리킬 active 터미널을 2번으로 지정
<Space>ts     열린 터미널 목록에서 선택
```

같은 방향(예: horizontal)의 터미널은 하나의 창을 공유한다. `2<Space>th` 후
`3<Space>th`를 하면 같은 하단 창에서 3번 터미널로 교체된다. 동시에 나란히
보여주는 것이 아니라, 한 창 안에서 번호를 전환하는 방식이다. `2F12`처럼 번호를
직접 붙이면 현재 열려 있는 터미널 창을 닫고 지정한 번호의 터미널을 그 방향으로
다시 연다. 그 번호가 새 active 터미널이 되어 이후 plain `F12`가 그 번호를 따른다.
단, terminal-mode에서는 plain `F12`만 지원한다.

**활용 예시**

- `<Space>th`로 하단 터미널을 열고 `go run .` / `go test ./...` 실행
- `<Space>tg`로 lazygit을 열어 커밋, 브랜치 관리
- `<Space>tf`로 float 터미널을 열어 빠르게 명령 실행 후 `F12`로 닫기
- 여러 터미널이 필요하면 `2<Space>th`, `3<Space>th`로 번호 전환
- `2<Space>ta`로 "이제부터 F12는 2번"이라고 지정해 두고 plain `F12`만 사용
- `1F12`, `2F12`처럼 번호별 전용 토글로 바로 전환
- `<Space>ts`로 터미널 목록을 보고 원하는 터미널 선택

### 세션 관리 (persistence.nvim)

tmux의 resurrect처럼 Neovim 종료 시 작업 상태를 자동 저장하고, 다시 열 때 복원할
수 있다. 세션은 `~/.local/state/nvim/sessions/`에 저장된다.

기본 단위는 작업 디렉토리(cwd)다. 즉 같은 프로젝트라도 Neovim을 어느 디렉토리에서
열었는지에 따라 별도 세션이 생긴다.

Git 저장소에서는 브랜치명도 함께 반영된다. 단, `main`과 `master`는 예외로 보고
디렉토리 세션을 그대로 사용하며, 그 외 브랜치에서는 같은 디렉토리여도 브랜치별
세션 파일이 따로 저장된다.

**저장**: 종료 시 버퍼가 2개 이상이면 `Save session?` 확인을 묻는다.
Yes를 선택하면 저장, No면 저장하지 않고 종료한다.
버퍼가 1개 이하면 확인 없이 저장을 건너뛴다.
버퍼 목록, 윈도우 레이아웃, 탭, 커서 위치가 포함된다.

**복원하기**: 같은 디렉토리에서 Neovim을 열고 `<Space>sr`을 누르면 이전 상태가
복원된다. 현재 브랜치가 `main`/`master`가 아니면 해당 브랜치 세션을 우선 찾고,
없으면 디렉토리 기본 세션을 불러온다.

```
<Space>sr    현재 디렉토리의 세션 복원
<Space>sl    마지막 세션 복원 (어떤 디렉토리였든)
<Space>ss    세션 수동 저장
```

**제한사항**: 터미널(toggleterm) 상태는 복원되지 않는다. Neovim의 `mksession`
자체 한계이므로 터미널은 복원 후 다시 열어야 한다.

**활용 예시**

- Go 프로젝트에서 여러 파일을 열고 split 배치한 상태로 작업 → 종료 → 다음 날
  같은 디렉토리에서 `nvim` + `<Space>sr` → 어제 레이아웃 그대로 복원
- 여러 프로젝트를 오가며 작업할 때 디렉토리별로 세션이 분리되어 편리
- 같은 프로젝트에서 `feature/a`와 `feature/b`를 번갈아 작업할 때 브랜치별로
  다른 레이아웃과 버퍼 목록을 유지 가능

## 마크다운 편집 가이드

### 아웃라인 / 목차 (aerial.nvim)

마크다운 파일의 헤딩을 트리 형태로 사이드바에 표시한다. 목차를 보면서 원하는
섹션으로 빠르게 이동할 수 있다. Go 코드에서도 함수/타입 목록으로 사용 가능하다.

```
<Space>o     아웃라인 사이드바 토글
```

사이드바 안에서 조작:

```
Enter        선택한 항목으로 이동
{  /  }      이전/다음 심볼로 이동
[[ / ]]      이전/다음 상위 항목으로 이동
o / za       트리 노드 접기/펼치기
l  /  h      노드 열기/닫기
zr / zm      전체 펼침 깊이 조정
q            사이드바 닫기
?            도움말
```

### 마크다운 렌더링 (render-markdown.nvim)

버퍼 안에서 마크다운을 직접 렌더링한다. 헤딩 강조, 체크박스, 테이블 정렬,
코드블록 하이라이트 등이 적용된다. 커서가 있는 줄은 원본 소스로 표시되어
편집이 가능하고, 나머지 줄은 렌더링된 상태로 보인다.

```
<Space>m     렌더링 토글 (소스 모드 ↔ 렌더링 모드)
```

마크다운 파일을 열면 자동으로 렌더링이 활성화된다. `<Space>m`으로 끄면
일반 소스 코드로 편집할 수 있고, 다시 누르면 렌더링 모드로 돌아간다.

## JSON 편집

### 포맷팅 (jq)

JSON 파일에서 `formatprg`와 `equalprg`가 모두 `jq .`로 설정되어 있어 `gq` 또는
`=` 명령으로 pretty print할 수 있다. `jq`가 시스템에 설치되어 있어야 한다.

```
gggqG        파일 전체를 jq로 포맷팅 (gg: 처음, gq: 포맷, G: 끝까지)
ggVG=        파일 전체를 jq로 포맷팅 (visual select 후 =)
:%!jq .      위와 동일한 결과 (Ex 명령 방식)
```

Visual 모드로 범위를 선택한 뒤 `gq` 또는 `=`를 누르면 선택한 부분만 포맷팅할
수도 있다.

`=`의 기본 동작인 `indentexpr` 기반 들여쓰기 재계산은 수천 줄 규모의 JSON에서
매우 느려 에디터가 멈춘 것처럼 보일 수 있다. `equalprg`를 `jq .`로 지정해
두었기 때문에 이 경우에도 외부 포매터로 즉시 처리된다.

## 코드 접기 (nvim-ufo)

`nvim-ufo`가 treesitter 기반으로 fold를 생성한다. JSON, Go, Python, Lua 등
treesitter 파서가 설치된 파일에서 객체/배열/함수 단위로 부드럽게 접고 펼 수 있다.
파서가 없는 파일은 `indent` provider로 자동 폴백한다.

기본 동작:

- 파일을 열면 모든 fold가 **펼쳐진 상태**로 시작한다 (`foldlevelstart=99`).
- fold 컬럼은 표시하지 않는다 (`foldcolumn=0`). 접힌 영역은 ufo의 인라인
  placeholder로 표시된다.
- fold 위에서 `zK`를 누르면 접힌 내용을 팝업으로 미리보기 할 수 있고, 팝업
  안에서 `<C-u>`/`<C-d>`로 스크롤, `[`/`]`로 처음/끝 이동이 된다.

fold 키맵:

```
za           커서 위치 fold 토글
zo / zc      fold 펼치기 / 접기
zR           모든 fold 펼치기          (ufo.openAllFolds)
zM           모든 fold 접기            (ufo.closeAllFolds)
zj / zk      다음 / 이전 fold로 이동
zK           접힌 내용 미리보기 팝업    (ufo.peekFoldedLinesUnderCursor)
```

`zr`/`zm`은 재매핑하지 않는다. `foldlevelstart=99`이기 때문에 vim 내장 `zr`/`zm`
(한 단계 증감)도 실질적으로 체감되지 않으므로, 레벨 기반으로 접고 싶으면
`:set foldlevel=N`을 직접 사용한다. (예: `:set foldlevel=1`은 최상위 fold만
남기고 모두 접음. `:set foldlevel=99`로 전부 펼침.)

JSON의 긴 배열은 파일을 열자마자 접히도록 `close_fold_kinds_for_ft.json = {"array"}`로
설정되어 있다. 전체를 펼치려면 `zR`.

## 주요 키맵 요약

| 키 | 모드 | 동작 |
|----|------|------|
| `<Space>w` | Normal | 저장 |
| `<Space>q` | Normal | 종료 |
| `<Space>e` | Normal | 파일 탐색기 열기/포커스 |
| `<Space>fe` | Normal | 현재 파일 탐색기에서 찾기 |
| `gd` | Normal | 정의를 다른 창에서 열기 |
| `gzd` | Normal | 정의를 새 탭에서 열기 |
| `gD` | Normal | 정의를 현재 창에서 열기 |
| `gr` | Normal | 참조 목록 |
| `K` | Normal | 호버 정보 (디버그 중에는 변수 런타임 값 표시) |
| `gy` | Normal | 타입 정의를 다른 창에서 열기 |
| `gzt` | Normal | 타입 정의를 새 탭에서 열기 |
| `gY` | Normal | 타입 정의를 현재 창에서 열기 |
| `<Space>yt` | Normal | 현재 심볼의 타입 문자열 복사 |
| `<Space>rn` | Normal | 심볼 이름 변경 |
| `<Space>ca` | Normal/Visual | 코드 액션 |
| `<Space>bd` | Normal | 창은 유지하고 현재 버퍼만 닫기 |
| `[b` / `]b` | Normal | 이전/다음 버퍼 |
| `[d` / `]d` | Normal | 이전/다음 진단 |
| `Ctrl+h/j/k/l` | Normal | 분할 창 이동 |
| `Alt+h/j/k/l` | Normal | 분할 창 리사이즈 |
| `Ctrl+w =` | Normal | 창 크기 균등화 |
| `Ctrl+w s` / `Ctrl+w v` | Normal | 수평/수직 분할 |
| `Ctrl+w c` | Normal | 현재 창 닫기 |
| `Ctrl+o` / `Ctrl+i` | Normal | 이전/다음 위치로 이동 |
| `<Space>ff` | Normal | 파일명 fuzzy 검색 |
| `<Space>fg` | Normal | 파일 내용 검색 (live grep) |
| `<Space>fb` | Normal | 열린 버퍼 목록 |
| `<Space>fs` | Normal | 현재 파일 심볼 검색 |
| `<Space>fS` | Normal | 워크스페이스 심볼 검색 |
| `<Space>fd` | Normal | 진단 목록 |
| `<Space>fr` | Normal | 마지막 검색 재개 |
| `<Space>o` | Normal | 아웃라인 사이드바 토글 |
| `<Space>m` | Normal | 마크다운 렌더링 토글 |
| `s` | Normal/Visual/Operator | flash 점프 (easymotion) |
| `S` | Normal/Visual/Operator | flash treesitter 선택 |
| `ys{motion}{char}` | Normal | 감싸기 추가 (surround) |
| `cs{old}{new}` | Normal | 감싸기 변경 |
| `ds{char}` | Normal | 감싸기 삭제 |
| `S{char}` | Visual | 선택 영역 감싸기 |
| `Ctrl+\`` | Normal/Terminal | 터미널 토글 |
| `<Space>tf` | Normal | float 터미널 |
| `<Space>th` | Normal | horizontal 터미널 |
| `<Space>tv` | Normal | vertical 터미널 |
| `<Space>tt` | Normal | tab 터미널 (전체화면) |
| `<Space>tg` | Normal | lazygit |
| `<Space>ts` | Normal | 터미널 목록 선택 |
| `Ctrl+\ Ctrl+n` | Terminal | Neovim Normal 모드 전환 |
| `<Space>yp` | Normal/Visual | 상대 경로:라인(범위) 복사 |
| `<Space>yP` | Normal/Visual | 절대 경로:라인(범위) 복사 |
| `Alt+z` | Normal | 워드 랩 토글 |
| `<Space>sr` | Normal | 세션 복원 (현재 디렉토리) |
| `<Space>sl` | Normal | 마지막 세션 복원 |
| `<Space>ss` | Normal | 세션 수동 저장 |
| `<Space>vs` | Normal | Python 가상환경 선택 |
| `<Space>db` | Normal | 브레이크포인트 토글 |
| `<Space>dc` | Normal | 디버깅 시작/계속 |
| `<Space>di` | Normal | step into |
| `<Space>do` | Normal | step over |
| `<F10>` | Normal | step over |
| `<Space>dO` | Normal | step out |
| `<Space>dr` | Normal | 디버깅 재시작 |
| `<Space>dt` | Normal | 디버깅 종료 |
| `<Space>df` | Normal | 현재 실행 위치로 커서 이동 |
| `<Space>du` | Normal | DAP UI 토글 |
| `<Space>dT` | Normal | 커서 위치 테스트 함수 디버깅 |
| `<Space>k` | Normal | which-key 토글 (기본 OFF) |
| `<Space>?` | Normal | 버퍼 키맵 목록 (which-key) |
| `]c` / `[c` | Normal | 다음/이전 git hunk |
| `<Space>gs` | Normal/Visual | hunk 스테이징 |
| `<Space>gr` | Normal | 스테이징 취소 (reset) |
| `<Space>gu` | Normal/Visual | hunk 되돌리기 (undo) |
| `<Space>gp` | Normal | hunk 미리보기 |
| `<Space>gb` | Normal | blame 팝업 |
| `<Space>gB` | Normal | 인라인 blame 토글 |
| `<Space>gd` | Normal | diff (index 비교) |
| `]t` / `[t` | Normal | 다음/이전 TODO |
| `<Space>ft` | Normal | TODO 검색 (telescope) |
| `za` | Normal | fold 토글 |
| `zR` / `zM` | Normal | 모든 fold 펼치기 / 접기 (ufo) |
| `zj` / `zk` | Normal | 다음 / 이전 fold로 이동 |
| `zK` | Normal | 접힌 내용 미리보기 팝업 (ufo) |
