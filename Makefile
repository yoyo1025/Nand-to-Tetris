SHELL := /bin/sh

.DEFAULT_GOAL := help

CHAPTER ?= 1
CHIP ?=
TEST ?=
INPUT ?=
EXPECTED ?=
ACTUAL ?=

PROJECT_DIR := projects/$(CHAPTER)
TOOLS_DIR := tools
HARDWARE_SIMULATOR := $(TOOLS_DIR)/HardwareSimulator.sh
CPU_EMULATOR := $(TOOLS_DIR)/CPUEmulator.sh
VM_EMULATOR := $(TOOLS_DIR)/VMEmulator.sh
ASSEMBLER := $(TOOLS_DIR)/Assembler.sh
JACK_COMPILER := $(TOOLS_DIR)/JackCompiler.sh
TEXT_COMPARER := $(TOOLS_DIR)/TextComparer.sh

.PHONY: help doctor list test gui gui-hardware gui-cpu gui-vm cpu vm assemble compile compare clean

help: ## 利用できるコマンドを表示する
	@printf '%s\n' \
		'nand2tetris helper commands' \
		'' \
		'  make doctor' \
		'      Javaと付属ツールを確認します。' \
		'' \
		'  make list [CHAPTER=1]' \
		'      指定した章のテストスクリプトを一覧表示します。' \
		'' \
		'  make test CHIP=Not [CHAPTER=1]' \
		'      projects/<章>/<チップ>.tst をHardware Simulatorで実行します。' \
		'' \
		'  make test TEST=projects/3/a/Bit.tst' \
		'      指定したテストスクリプトをHardware Simulatorで実行します。' \
		'' \
		'  make test [CHAPTER=1]' \
		'      指定した章にある全.tstをHardware Simulatorで順に実行します。' \
		'' \
		'  make gui | gui-cpu | gui-vm' \
		'      各シミュレータをGUIモードで起動します。' \
		'' \
		'  make cpu TEST=<file.tst>' \
		'  make vm TEST=<file.tst>' \
		'  make assemble INPUT=<file.asm>' \
		'  make compile INPUT=<file.jack-or-directory>' \
		'      後続の章で使うツールを実行します。' \
		'' \
		'  make compare EXPECTED=<expected> ACTUAL=<actual>' \
		'      2ファイルを付属のTextComparerで比較します。' \
		'' \
		'  make clean [CHAPTER=1]' \
		'      指定した章以下に生成された.outファイルを削除します。'

doctor: ## Javaと付属ツールの存在を確認する
	@set -eu; \
	command -v java >/dev/null 2>&1 || { echo 'error: Javaが見つかりません。' >&2; exit 1; }; \
	for tool in \
		"$(HARDWARE_SIMULATOR)" \
		"$(CPU_EMULATOR)" \
		"$(VM_EMULATOR)" \
		"$(ASSEMBLER)" \
		"$(JACK_COMPILER)" \
		"$(TEXT_COMPARER)"; do \
		test -f "$$tool" || { echo "error: $$tool が見つかりません。" >&2; exit 1; }; \
	done; \
	echo 'Java:'; \
	java -version; \
	echo; \
	echo 'nand2tetris tools: OK'

list: ## 指定した章の.tstファイルを一覧表示する
	@set -eu; \
	test -d "$(PROJECT_DIR)" || { echo "error: $(PROJECT_DIR) が見つかりません。" >&2; exit 1; }; \
	find "$(PROJECT_DIR)" -type f -name '*.tst' -print | LC_ALL=C sort

test: ## Hardware Simulatorで単体または章内の全テストを実行する
	@set -eu; \
	if [ -n "$(TEST)" ]; then \
		test_file="$(TEST)"; \
	elif [ -n "$(CHIP)" ]; then \
		test_file="$(PROJECT_DIR)/$(CHIP).tst"; \
	else \
		test_file=''; \
	fi; \
	if [ -n "$$test_file" ]; then \
		test -f "$$test_file" || { echo "error: $$test_file が見つかりません。" >&2; exit 1; }; \
		echo "==> $$test_file"; \
		sh "$(HARDWARE_SIMULATOR)" "$$test_file"; \
	else \
		test -d "$(PROJECT_DIR)" || { echo "error: $(PROJECT_DIR) が見つかりません。" >&2; exit 1; }; \
		test_count=$$(find "$(PROJECT_DIR)" -type f -name '*.tst' -print | wc -l | tr -d ' '); \
		test "$$test_count" -gt 0 || { echo "error: $(PROJECT_DIR) に.tstファイルがありません。" >&2; exit 1; }; \
		find "$(PROJECT_DIR)" -type f -name '*.tst' -print | LC_ALL=C sort | \
		while IFS= read -r current_test; do \
			echo "==> $$current_test"; \
			sh "$(HARDWARE_SIMULATOR)" "$$current_test" || exit $$?; \
		done; \
	fi

gui: gui-hardware ## Hardware SimulatorをGUIモードで起動する

gui-hardware:
	@sh "$(HARDWARE_SIMULATOR)"

gui-cpu: ## CPU EmulatorをGUIモードで起動する
	@sh "$(CPU_EMULATOR)"

gui-vm: ## VM EmulatorをGUIモードで起動する
	@sh "$(VM_EMULATOR)"

cpu: ## CPU EmulatorでTESTを実行する
	@set -eu; \
	test -n "$(TEST)" || { echo 'error: TEST=<file.tst> を指定してください。' >&2; exit 2; }; \
	test -f "$(TEST)" || { echo "error: $(TEST) が見つかりません。" >&2; exit 1; }; \
	sh "$(CPU_EMULATOR)" "$(TEST)"

vm: ## VM EmulatorでTESTを実行する
	@set -eu; \
	test -n "$(TEST)" || { echo 'error: TEST=<file.tst> を指定してください。' >&2; exit 2; }; \
	test -f "$(TEST)" || { echo "error: $(TEST) が見つかりません。" >&2; exit 1; }; \
	sh "$(VM_EMULATOR)" "$(TEST)"

assemble: ## INPUTで指定した.asmをアセンブルする
	@set -eu; \
	test -n "$(INPUT)" || { echo 'error: INPUT=<file.asm> を指定してください。' >&2; exit 2; }; \
	test -f "$(INPUT)" || { echo "error: $(INPUT) が見つかりません。" >&2; exit 1; }; \
	sh "$(ASSEMBLER)" "$(INPUT)"

compile: ## INPUTで指定した.jackまたはディレクトリをコンパイルする
	@set -eu; \
	test -n "$(INPUT)" || { echo 'error: INPUT=<file.jack-or-directory> を指定してください。' >&2; exit 2; }; \
	test -e "$(INPUT)" || { echo "error: $(INPUT) が見つかりません。" >&2; exit 1; }; \
	sh "$(JACK_COMPILER)" "$(INPUT)"

compare: ## EXPECTEDとACTUALで指定したファイルを比較する
	@set -eu; \
	test -n "$(EXPECTED)" || { echo 'error: EXPECTED=<expected-file> を指定してください。' >&2; exit 2; }; \
	test -n "$(ACTUAL)" || { echo 'error: ACTUAL=<actual-file> を指定してください。' >&2; exit 2; }; \
	test -f "$(EXPECTED)" || { echo "error: $(EXPECTED) が見つかりません。" >&2; exit 1; }; \
	test -f "$(ACTUAL)" || { echo "error: $(ACTUAL) が見つかりません。" >&2; exit 1; }; \
	sh "$(TEXT_COMPARER)" "$(EXPECTED)" "$(ACTUAL)"

clean: ## 指定した章以下の.outファイルを削除する
	@set -eu; \
	test -d "$(PROJECT_DIR)" || { echo "error: $(PROJECT_DIR) が見つかりません。" >&2; exit 1; }; \
	find "$(PROJECT_DIR)" -type f -name '*.out' -print -delete
