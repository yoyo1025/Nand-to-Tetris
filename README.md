# nand2tetris workspace

『The Elements of Computing Systems（コンピュータシステムの理論と実装）』の演習用ワークスペースです。`projects` 以下の雛形を編集し、`tools` 以下に同梱されている公式ツールで動作を確認します。

このREADMEでは、各章の解答や実装手順ではなく、ワークスペース全体に共通する使い方だけを説明します。各課題の仕様は、書籍と `projects` 内の雛形・テストファイルを確認してください。

## セットアップ

このディレクトリをターミナルで開き、Javaと付属ツールを確認します。

```sh
make doctor
```

最後に次のメッセージが表示されれば準備完了です。

```text
nand2tetris tools: OK
```

公式ツールはJavaで動作します。別途npmパッケージなどをインストールする必要はありません。

## ディレクトリ構成

```text
.
├── Makefile             公式ツールを呼び出すための共通コマンド
├── README.md            このファイル
├── projects/            章ごとの課題、テスト、期待値
├── tools/               公式シミュレータ、コンパイラ、組み込み部品
└── software package.pdf 付属ツールの説明書
```

基本的に編集するのは `projects` 以下です。`tools` 以下は公式ツール一式なので、課題の実装先として変更しません。

## 共通コマンド

利用できるコマンドと引数は次のコマンドで確認できます。

```sh
make help
```

`list`、`test`、`clean` では `CHAPTER` の指定が必須です。対象を明示することで、意図しない章のファイルを実行・削除することを防ぎます。

### テストの確認と実行

指定した章にあるテストスクリプトを一覧表示します。

```sh
make list CHAPTER=2
```

Hardware Simulator向けのテストを章単位で実行します。テストは名前順に実行され、最初の失敗で停止します。

```sh
make test CHAPTER=2
```

チップ名またはテストファイルを指定して、対象を絞ることもできます。

```sh
make test CHAPTER=2 CHIP=HalfAdder
make test CHAPTER=3 TEST=projects/3/a/Bit.tst
```

`make test` はHardware Simulatorを使います。CPU EmulatorやVM Emulator向けのテストには、後述の専用コマンドを使ってください。

### 期待値との比較

`.cmp` などの期待値と、ツールが生成した実際の出力を比較します。

```sh
make compare EXPECTED=path/to/Expected.cmp ACTUAL=path/to/Actual.out
```

指定した章以下の `.out` を削除する場合は、次を実行します。

```sh
make clean CHAPTER=2
```

### 公式ツール

GUIを起動するコマンドは次のとおりです。

```sh
make gui
make gui-cpu
make gui-vm
```

ファイルを指定して各ツールを実行する場合は、次のコマンドを使います。

```sh
make cpu TEST=path/to/Test.tst
make vm TEST=path/to/Test.tst
make assemble INPUT=path/to/Program.asm
make compile INPUT=path/to/Program.jack
make compile INPUT=path/to/Directory
```

- `cpu`: CPU Emulatorでテストを実行します。
- `vm`: VM Emulatorでテストを実行します。
- `assemble`: Hackアセンブリを `.hack` へ変換します。
- `compile`: Jackファイルまたはディレクトリをコンパイルします。

## テストファイルの関係

公式テストでは、主に次のファイルを組み合わせて動作を確認します。

| 拡張子 | 役割 |
| --- | --- |
| `.tst` | ツールへ入力や実行手順を指示するテストスクリプト |
| `.cmp` | 期待される出力 |
| `.out` | テスト実行時に生成される実際の出力 |

通常は課題の実装ファイルを編集し、配布された `.tst` と `.cmp` は変更しません。成功時は次のように表示されます。

```text
End of script - Comparison ended successfully
```

## 基本的な作業の流れ

1. 書籍と課題ファイルで仕様を確認する。
2. `projects` 以下の対象ファイルを編集する。
3. 対応する公式ツールで個別テストを実行する。
4. 節目で対象範囲のテストをまとめて実行する。
5. `git status` と差分を確認してコミットする。

生成物を含め、どのファイルをコミットするかはリポジトリの既存履歴に合わせてください。

## トラブルシューティング

### `Comparison failure` と表示される

ツールは動作していますが、生成された出力と期待値が一致していません。表示された行と対応する入力を確認してください。

### 構文エラーや行番号が表示される

対象言語の構文、名前の大文字・小文字、入出力の指定を確認してください。詳しい仕様は各ファイルのコメントと付属ドキュメントにあります。

### `Javaが見つかりません` と表示される

Java Runtime Environmentをインストールし、ターミナルで `java -version` が実行できる状態にしてください。

### `.sh` を直接実行すると権限エラーになる

Makefileは付属スクリプトを `sh` 経由で起動するため、通常はMakeコマンドを使ってください。直接起動する場合も次の形式で実行できます。

```sh
sh tools/HardwareSimulator.sh path/to/Test.tst
```
