# Home Defenders（ホーディ）

3D TPS × タワーディフェンス × オンライン協力アクション。**Godot 4.3** で開発し、**Vercel** に WebGL ビルドを配信します。

> 押し寄せる魔王軍から「おうち」を守れ。  
> どこにでも建てられる防衛タワー、全 40 職のアクションスキル、最大 4 人の WebRTC 協力プレイ。

## クイックスタート（デスクトップ）

1. [Godot 4.3](https://godotengine.org/) をインストール。
2. `project.godot` を開いて **F5** で起動。
3. 職業を選択 → ゲーム開始。
   - **WASD**: 移動
   - **マウス**: 視点・照準
   - **左クリック**: 通常攻撃
   - **Shift**: 回避ロール（無敵時間あり）
   - **Q / E / F**: スキル
   - **B**: 建設モード切替（1/2/3 でタワー種別選択、左クリックで設置）
   - **ESC**: カーソル開放

## Web ビルド

```bash
godot --headless --export-release "Web" public/index.html
cd public && python3 -m http.server 8000
```

Web 実行には `Cross-Origin-Embedder-Policy: require-corp` と
`Cross-Origin-Opener-Policy: same-origin`（`SharedArrayBuffer` の有効化）が必要です。
同梱の `vercel.json` で設定済みです。

### Vercel デプロイ設定

- `vercel.json` の `outputDirectory` は `public` を指しています。
- 実ビルドは GitHub Actions（`.github/workflows/deploy.yml`）が
  Godot Headless で生成し、Vercel にデプロイします。
- リポジトリの `public/index.html` は **CI 未完了時のプレースホルダ**です。
- Vercel ダッシュボードで以下のシークレットを設定してください:
  `VERCEL_TOKEN` / `VERCEL_ORG_ID` / `VERCEL_PROJECT_ID`。

## マルチプレイ（WebRTC）

- タイトル画面で Room ID を入力するとホスト／参加が可能です。
- シグナリングのデフォルト URL は `wss://YOUR-VERCEL-DEPLOYMENT/api/signal`。
  `signaling/api/signal.ts` をデプロイ後、
  `scripts/autoload/network_manager.gd` の `SIGNALING_URL_DEFAULT` を更新してください。
- 現状の同期範囲: 位置のみ RPC（第一弾）。
  クライアント側予測（CSP）は TODO として `network_manager.gd` に明示。

## データ駆動のバランス調整

ゲーム内数値はすべて `data/*.json` で一元管理。コード改修なしで再調整可能です。

| ファイル | 役割 |
| --- | --- |
| `data/jobs.json` | 全 40 職のステータス |
| `data/enemies.json` | 敵アーキタイプ |
| `data/towers.json` | タワー種別（Arrow / Cannon / Slow） |
| `data/waves.json` | ウェーブ構成 |
| `data/balance.json` | 全体調整値 |

## プロジェクト構成

```
scenes/      Title / Game / HUD / Player / Enemy / Tower / Home / Projectile / Settings
scripts/     GDScript ゲームロジック
  autoload/  GameState, EventBus, DataLoader, JobRegistry, SaveSystem,
             ObjectPool, NetworkManager, SettingsManager
  jobs/      職業ごとのスキル実装（5 職は専用、残り 35 職は共通スタブ）
data/        JSON でのバランス・コンテンツ定義
signaling/   WebRTC 用 Vercel Edge Function
tests/       GUT による単体テスト
.github/     CI/CD（Godot Headless ビルド + Vercel デプロイ）
```

## ロードマップ

今回のコミットは **Phase 1（コア機構）** と **Phase 2 の骨格**
（全 40 職定義、5 職に専用スキル、35 職は AOE スタブ）を含みます。

今後の作業:

- WebRTC の完全な ICE/SDP 折衝とクライアント側予測
- 残り 35 職の専用スキルロジック
- 複数エリアのレベル設計と 50 ウェーブ・サバイバル
- ハイクオリティな 3D アセット・VFX・SE への差し替え
- Sentry によるエラー収集、Vercel KV / Postgres を用いたクラウドセーブ
