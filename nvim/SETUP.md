# Neovim Setup for Go Development

새 Mac에서 이 설정을 적용하는 절차.

## 1. 사전 준비

Homebrew가 없으면 먼저 설치한다.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 2. 필수 도구 설치

```sh
brew install neovim go tree-sitter
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

## 3. 설정 파일 배치

이 저장소를 클론하고 Neovim 설정 디렉토리에 심볼릭 링크를 건다.

```sh
git clone <repo-url> ~/tools/vimrc
ln -s ~/tools/vimrc/nvim ~/.config/nvim
```

이미 `~/.config/nvim`이 있으면 백업하거나 삭제한 뒤 진행한다.

## 4. 플러그인 설치

Neovim을 처음 실행하면 lazy.nvim이 자동으로 부트스트랩되고 플러그인을 설치한다.

```sh
nvim
```

설치 완료 후 `:Lazy` 명령으로 14개 플러그인이 모두 로드되었는지 확인한다.

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
| nvim-treesitter/nvim-treesitter | 구문 하이라이팅/인덴트 |
| nvim-treesitter/nvim-treesitter-context | 함수/구조체 이름 상단 고정 |
| akinsho/bufferline.nvim | 버퍼 탭라인 |
| mrjones2014/smart-splits.nvim | 분할 창 이동/리사이즈 |
| nvim-tree/nvim-tree.lua | 파일 탐색기 |
| nvim-tree/nvim-web-devicons | 파일 아이콘 (비활성화, Nerd Font 불필요) |

## 5. Mason으로 gopls 확인

Mason이 gopls를 자동 설치하도록 설정되어 있다 (`ensure_installed = { "gopls" }`).
시스템에 이미 gopls가 있으면 그대로 사용되고, 없으면 Mason이 설치한다.

goimports는 자동 설치 대상이 아니므로, 2단계에서 `go install`로 설치하지 않았다면 Mason에서 수동 설치한다.

```vim
:MasonInstall goimports
```

## 6. Treesitter 파서 확인

tree-sitter CLI가 설치되어 있으면 첫 실행 시 Go 관련 파서가 자동 설치된다.
수동으로 확인하려면:

```vim
:lua print(vim.inspect(require("nvim-treesitter").get_installed()))
```

go, gomod, gosum, gotmpl, lua, query, vim, vimdoc 파서가 있어야 한다.

## 7. 동작 확인

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

### 코드 탐색

**타입 정의로 이동** — 변수 위에서 그 변수의 타입 정의로 바로 이동한다.

```
gd    타입 이름(MyStruct 등) 위에 커서를 놓고 누르면 해당 타입 정의로 이동
```

변수 위에서 누르면 변수가 선언된 곳으로 간다. 변수의 타입 정의로 가려면:

```vim
:lua vim.lsp.buf.type_definition()
```

**함수 정의로 이동** — 함수 호출 위에 커서를 놓고:

```
gd    함수가 정의된 위치로 이동 (다른 파일이어도 동작)
K     함수 시그니처와 문서를 팝업으로 확인
```

이동 후 `Ctrl+o`로 이전 위치로 돌아간다. `Ctrl+i`로 다시 앞으로 간다.

**참조 검색** — 심볼이 사용된 모든 곳을 찾는다.

```
gr    커서 아래 심볼을 참조하는 모든 위치를 목록으로 표시
```

quickfix 목록이 열리면 `j`/`k`로 이동, `Enter`로 해당 위치를 연다.

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

**창 크기 균등화**

```
Ctrl+w =    모든 창 크기를 같게
```

**창 닫기**

```
:close      현재 창 닫기 (버퍼는 유지)    단축: Ctrl+w c
:only       현재 창만 남기고 나머지 닫기    단축: Ctrl+w o
```

### 버퍼 (탭)

bufferline이 열린 버퍼를 화면 상단에 탭처럼 표시한다.

**버퍼 열기/닫기**

```
:e foo.go       파일을 새 버퍼로 열기
:enew           빈 버퍼 생성
:bd             현재 버퍼 닫기 (탭에서 제거)
:bd foo.go      특정 버퍼 지정 닫기
```

**버퍼 이동**

```
<Space>bn    다음 버퍼 (오른쪽 탭)
<Space>bp    이전 버퍼 (왼쪽 탭)
```

**버퍼를 다른 창에서 열기** — 분할과 조합:

```
:split #3       3번 버퍼를 수평 분할로 열기
:vsplit #3      3번 버퍼를 수직 분할로 열기
:ls             열린 버퍼 목록과 번호 확인
```

### 기타 유용한 LSP 기능

```
<Space>rn    심볼 이름 일괄 변경 (rename)
<Space>ca    코드 액션 (import 추가, 인터페이스 구현 등)
[d           이전 진단(에러/경고)으로 이동
]d           다음 진단(에러/경고)으로 이동
```

저장(`:w`) 시 goimports가 자동 실행되어 import 정리와 코드 포맷이 적용된다.

## 주요 키맵 요약

| 키 | 모드 | 동작 |
|----|------|------|
| `<Space>w` | Normal | 저장 |
| `<Space>q` | Normal | 종료 |
| `<Space>e` | Normal | 파일 탐색기 열기/포커스 |
| `<Space>fe` | Normal | 현재 파일 탐색기에서 찾기 |
| `gd` | Normal | 정의로 이동 |
| `gr` | Normal | 참조 목록 |
| `K` | Normal | 호버 정보 |
| `<Space>rn` | Normal | 심볼 이름 변경 |
| `<Space>ca` | Normal/Visual | 코드 액션 |
| `[d` / `]d` | Normal | 이전/다음 진단 |
| `<Space>bn` / `<Space>bp` | Normal | 다음/이전 버퍼 |
| `Ctrl+h/j/k/l` | Normal | 분할 창 이동 |
| `Alt+h/j/k/l` | Normal | 분할 창 리사이즈 |
| `Ctrl+w =` | Normal | 창 크기 균등화 |
| `Ctrl+w s` / `Ctrl+w v` | Normal | 수평/수직 분할 |
| `Ctrl+w c` | Normal | 현재 창 닫기 |
| `Ctrl+o` / `Ctrl+i` | Normal | 이전/다음 위치로 이동 |
| `s` | Normal/Visual/Operator | flash 점프 (easymotion) |
| `S` | Normal/Visual/Operator | flash treesitter 선택 |
