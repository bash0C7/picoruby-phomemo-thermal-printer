# picoruby-phomemo-thermal-printer

Phomemo T02 感熱プリンターを BLE で制御する PicoRuby の mrbgem。使い方は `README.md`。Mac アプリと CLI は `bash0C7/thermal-printer` にある。

## 安全規則（プリンターを守る）

- `1f 11 <op>` は `op` が 0x14 以下のものだけを送る。理由を問わない。
- gem は allowlist（`mrblib/phomemo_thermal_printer/command.rb`）のコマンドだけを組み立てる。プリンターへ書く公開 API は、allowlist のコマンドを受け取るものに限る。
- allowlist へ足すときは、根拠の資料を確かめ、ユーザーに確認する。
- BLE の write 呼び出しは `mrblib/phomemo_thermal_printer/transport.rb` の `write_chunk` と、`session.rb` の `emit` の 2 か所に置く。`rake check:send_paths` が検査する。

## 開発規律

- t-wada 流 TDD。コードには How、テストには What、コミットログには Why を書く。コードは名前と構造だけで読める形にする。
- Ruby は mise の 4.0.5（`mise exec ruby@4.0.5 -- rake ...`）。rake は直接起動し、repo の中を cwd にする。
- gem 内は `while` と明示 index で書く（`each` / `times` / `map` の代わり）。ivar を 3 回以上参照するなら local に取る。
- `mrbgem.rake` は ASCII で書く。
- `vendor/` と `build/` は生成物で、git の管理外。
- picoruby-ble は、公開 API と、上書き用のフック（`advertising_report_callback`、`packet_callback`）だけで使う。内部変数、非公開メソッド、`start` の中身の複製には触れない。`rake check:send_paths` が内部名を検査する。
- BLE のループは別の `Task` で回し、`Session` はメイン側で逐次に動かす。Task のブロックには、インスタンス変数でなくローカル変数を渡す。
- `Transport` が使う接続番号とパケットの読み取りは、フックに渡るパケットから取る。
- `port-darwin` は commit を固定せず先頭に追従する。`port-darwin` 自体の改修が要ると判断したら、手を入れる前にユーザーに相談する。
- コード内にコメントを置かない（コードと乖離するため）。理由はコミットメッセージに書く。ドキュメント生成のための型情報と説明は書いてよい。
- README.md と CLAUDE.md には、最新のスナップショットだけを書く。
- 実機への印字は、毎回その 1 回についてユーザーの明示の許可を得てから行う。

## テスト

```
mise exec ruby@4.0.5 -- rake vendor:setup      # R2P2-darwin と picoruby を取得
mise exec ruby@4.0.5 -- rake test              # picotest、tools/test、check:send_paths
FILTER=command mise exec ruby@4.0.5 -- rake test:ruby
```

picoruby 上で動くコードは、`rake test:ruby` が起動する picotest で picoruby VM 上に実行する。BLE のないテスト VM には `transport.rb` を読み込まない。CRuby の minitest は picoruby 上で動かない `tools/test` に限る。
