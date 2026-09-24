# nand2tetris workspace

『The Elements of Computing Systems（コンピュータシステムの理論と実装）』の演習用ワークスペースです。`projects` 以下の雛形を編集し、`tools` 以下に同梱されている公式ツールで動作を確認します。

このREADMEでは、解答そのものには触れず、ローカル環境の使い方と日々の作業手順を説明します。

## 最初に確認すること

このディレクトリをターミナルで開き、次を実行してください。

```sh
make doctor
```

Javaのバージョンと付属ツールの存在が表示され、最後に次のメッセージが出れば準備完了です。

```text
nand2tetris tools: OK
```

この環境ではOpenJDK 26と付属のデスクトップ版ツールで、コマンドラインテストが動作することを確認済みです。別途npmパッケージなどをインストールする必要はありません。

## ディレクトリ構成

```text
.
├── Makefile             よく使うコマンドの短縮形
├── README.md            このファイル
├── projects/            各章で編集するファイル
│   ├── 1/               第1章: 論理ゲート
│   ├── 2/               第2章: 加算器とALU
│   └── ...
├── tools/               公式シミュレータ、コンパイラ、組み込みチップ
└── software package.pdf 付属ツールの説明書
```

基本的に編集するのは `projects` 以下です。`tools/builtInChips` にはシミュレータが利用する組み込み実装がありますが、演習の解答としてここを編集したり、内容を `projects` にコピーしたりする必要はありません。

## 第1章の進め方

### 1. 実装するゲートを選ぶ

最初は `projects/1/Not.hdl` から始めるのがおすすめです。第1章は、次の順番なら作成済みのゲートを再利用しながら進められます。

1. `Not`
2. `And`
3. `Or`
4. `Xor`
5. `Mux`
6. `DMux`
7. `Not16`
8. `And16`
9. `Or16`
10. `Mux16`
11. `Or8Way`
12. `Mux4Way16`
13. `Mux8Way16`
14. `DMux4Way`
15. `DMux8Way`

第1章の土台となる `Nand` はシミュレータに組み込まれています。`projects/1/Nand.hdl` を作る必要はありません。

### 2. `.hdl` の `PARTS` を編集する

各 `.hdl` には、次のような雛形があります。

```hdl
CHIP Example {
    IN inputPin;
    OUT outputPin;

    PARTS:
    //// Replace this comment with your code.
}
```

`PARTS` 以下に、既存チップと配線の接続を記述します。一般形は次のとおりです。

```hdl
PARTS:
    ExistingChip(itsInput=inputPin, itsOutput=internalWire);
```

- `=` の左側は、利用するチップ側のピンです。
- 右側は、現在実装しているチップの入出力または内部配線です。
- 内部配線は事前に宣言する必要がありません。
- 各チップ呼び出しの末尾には `;` が必要です。
- 16ビットなどのバスは `in[16]`、個々のビットは `in[0]` のように表します。
- HDLは処理手順ではなく、回路の接続関係を表します。

入出力の仕様は各 `.hdl` 冒頭のコメントに書かれています。

### 3. 1つのゲートをテストする

例えば `Not.hdl` をテストするには、次を実行します。

```sh
make test CHIP=Not
```

成功時は次のように表示されます。

```text
End of script - Comparison ended successfully
```

失敗時は、比較に失敗した行番号またはHDLの構文エラーが表示されます。

```text
Comparison failure at line 3
```

### 4. 第1章をまとめてテストする

```sh
make test
```

`CHAPTER` の既定値は `1` です。章内の `.tst` を名前順に実行し、最初の失敗で停止します。

別の章を指定する場合は次のようにします。

```sh
make test CHAPTER=2
```

`make test` はHardware Simulator用です。主に第1、2、3、5章で使用します。

サブディレクトリ内など、特定のテストを直接指定することもできます。

```sh
make test TEST=projects/3/a/Bit.tst
```

## テストファイルの関係

例として `And` には次のファイルがあります。

| ファイル | 役割 |
| --- | --- |
| `And.hdl` | 自分で編集する回路定義 |
| `And.tst` | 入力値を設定して回路を実行するテスト |
| `And.cmp` | 正しい出力結果 |
| `And.out` | テストで生成された実際の出力 |

通常は `.hdl` だけを編集します。`.tst` と `.cmp` はテスト用なので変更しません。

失敗時に期待値と実際の出力を詳しく比較するには、次を実行できます。

```sh
make compare EXPECTED=projects/1/And.cmp ACTUAL=projects/1/And.out
```

生成された `.out` を指定した章から削除するには、次を実行します。

```sh
make clean
```

別の章を掃除するときは `make clean CHAPTER=2` のように指定します。

## GUIを使う

Hardware SimulatorをGUIモードで起動するには、次を実行します。

```sh
make gui
```

GUIでは `.hdl` と `.tst` を読み込み、ピンの値や回路の状態を確認しながら実行できます。配線を考えるときはGUI、繰り返し確認するときは `make test` を使うと便利です。

後続章のGUIは次のコマンドで起動できます。

```sh
make gui-cpu
make gui-vm
```

## 後続章で使うコマンド

Makefileには、同梱されている他のツールへの入口も用意しています。

```sh
# HackアセンブリをCPU Emulatorでテスト
make cpu TEST=projects/4/mult/Mult.tst

# VMプログラムをテスト
make vm TEST=projects/7/StackArithmetic/SimpleAdd/SimpleAdd.tst

# .asmを.hackへ変換
make assemble INPUT=path/to/Program.asm

# Jackファイルまたはディレクトリをコンパイル
make compile INPUT=path/to/JackProgram
```

利用できるコマンドの一覧はいつでも確認できます。

```sh
make help
```

## トラブルシューティング

### `Comparison failure` と表示される

シミュレータ自体は動作していますが、生成された `.out` と正解の `.cmp` が一致していません。表示された行を確認し、対応する入力に対して回路が何を出力したか調べてください。

### HDLの行番号とエラーが表示される

ピン名、バス幅、括弧、カンマ、セミコロンを確認してください。チップ名とファイル名の大文字・小文字もそろえます。

### `Javaが見つかりません` と表示される

Java Runtime Environmentをインストールし、ターミナルで `java -version` が実行できる状態にしてください。

### `.sh` を直接実行すると権限エラーになる

このワークスペースのMakefileは内部で `sh tools/...` として起動するため、スクリプトへ実行権限を追加しなくても利用できます。Makefileを使わず直接起動する場合も、次の形式で実行できます。

```sh
sh tools/HardwareSimulator.sh projects/1/Not.tst
```
