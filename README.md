# picoruby-phomemo-thermal-printer

PicoRuby の mrbgem です。Phomemo T02 感熱プリンターを BLE で制御して、幅 384 dot の白黒ラスタ（PBM）を印字します。

- 印字の 1 ジョブ（初期化、濃度、ラスタ、紙送り）を組み立てて、チャンクに分けて送ります。
- 状態（紙、カバー、電池、温度）を取得します。
- 送るコマンドは allowlist にあるものだけです。`1f 11 <op>` は、`op` が 0x14 以下のものだけを送ります。
- BLE は `picoruby-ble` の公開 API と、上書き用のフック（`advertising_report_callback`、`packet_callback`）だけで使います。
- 実機での動作は、macOS の R2P2-darwin（port-darwin）で確かめています。

Mac アプリと CLI は [bash0C7/thermal-printer](https://github.com/bash0C7/thermal-printer) にあります。

## 構成

| ファイル | 内容 |
|---|---|
| `mrblib/phomemo_thermal_printer/command.rb` | allowlist のコマンドの組み立てと判定 |
| `mrblib/phomemo_thermal_printer/pbm_reader.rb` | PBM（P4）を 255 行以下のブロックに読む |
| `mrblib/phomemo_thermal_printer/job.rb` | 1 ジョブのセグメント列 |
| `mrblib/phomemo_thermal_printer/chunker.rb` | セグメントをチャンクに分ける |
| `mrblib/phomemo_thermal_printer/session.rb` | `PrintSession`、`StatusSession`。送信と通知の処理 |
| `mrblib/phomemo_thermal_printer/status.rb` | 通知の解釈 |
| `mrblib/phomemo_thermal_printer/result.rb` | 結果の JSON |
| `mrblib/phomemo_thermal_printer/png_writer.rb` | プレビュー用の PNG |
| `mrblib/phomemo_thermal_printer/transport.rb` | `Transport`。picoruby-ble を使った接続、購読、書き込み |
| `mrblib/phomemo_thermal_printer/packet.rb` | `Packet`。HCI パケットと GATT の読み取り |

## 使い方

```ruby
class Clock
  def now_ms
    Machine.board_millis
  end
end

class Sleeper
  def sleep_ms(ms)
    Kernel.sleep_ms(ms)
  end
end

file = File.open("card.pbm", "rb")
reader = PhomemoThermalPrinter::PbmReader.new(file)
job = PhomemoThermalPrinter::Job.new(reader, density: 4, feed: 1)
session = PhomemoThermalPrinter::PrintSession.new(
  PhomemoThermalPrinter::Transport.new,
  clock: Clock.new, sleeper: Sleeper.new, device: "T02"
)
result = session.run(job)
```

`StatusSession#query` は、印字せずに状態だけを取得します。

transport は `connect`、`gatt_report`、`subscribe`、`write_chunk`、`poll_notifications`、`disconnect` を持つオブジェクトです（`sig/phomemo_thermal_printer.rbs`）。テストでは `test/mock/fake_transport.rb` に置き換えます。

## ビルドに加える

R2P2-darwin のビルド設定に、gem のディレクトリを足します。

```ruby
conf.gem core: "picoruby-ble"
conf.gem core: "hal-task-darwin"
conf.gem gemdir: "/path/to/picoruby-phomemo-thermal-printer"
```

## テスト

```
mise exec ruby@4.0.5 -- rake vendor:setup   # R2P2-darwin と picoruby を取得
mise exec ruby@4.0.5 -- rake test
```

- `rake test:ruby` は、BLE なしのテスト VM を `rake picotest:build` で作り、`test/` を picotest で実行します。`FILTER` でファイルを絞り込めます。picoruby-ble を必要とする `transport.rb` は、テスト VM に読み込みません。
- `rake test:tools` は、`tools/test` の CRuby のテストを実行します。
- `rake check:send_paths` は、BLE の書き込み呼び出しが決めた場所にだけあること、`picoruby-ble` の内部名に触れていないことを検査します。

どれも実機なしで動きます。

## ライセンス

MIT。`LICENSE` を参照してください。
