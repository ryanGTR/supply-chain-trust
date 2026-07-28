# 書：《供應鏈上的信任：一個銀行 IT 工程師的實作紀錄》

📖 **線上閱讀**：（尚未部署——本專案目前為本機 only，佔位連結：<https://ryangtr.github.io/supply-chain-trust/>）

用 [Quarto](https://quarto.org) 排版的書（O'Reilly 風：serif 內文、紅色強調、callout 旁註）。
從密碼學原語（hash／數位簽章／MAC）出發，一路搭到軟體供應鏈簽章的實作紀錄。
全書主線一句話：**信任不是被算出來的，是被授予的**——密碼學只負責把人為的信任決定
保真地傳遞。

## 書的定位

- **學習與作品集**，不是產品、不是任何環境的安全設計依據。
- 敘事方法：先預測 → 實測 → 為什麼；每章附能力邊界的誠實聲明。
- 場景一律去識別（「某金融機構」／「典型銀行環境」），不含任何真實組織資訊。
- 第一部素材底本：`~/Documents/security-wiki/`（2026-07-15 學習主線）。

## 目錄

| 章 | 檔案 | 內容 |
|---|---|---|
| 前言 | `book/index.qmd` | 這本書是什麼、三條閱讀路徑、誠實邊界 |
| 1 序章 | `book/01-why-supply-chain.qmd` | 攻擊從依賴進來；六個攻擊面 |
| 2 | `book/02-digital-signature.qmd` | 私鑰簽公鑰驗、為何簽 hash、改一個 byte 實驗 |
| 3 | `book/03-pki-trust-chain.qmd` | 憑證、信任鏈、trust anchor、Sigstore |
| 4 | `book/04-authenticated-encryption.qmd` | 順序陷阱、MAC、EtM、AEAD（深入，可略讀） |
| 5 | `book/05-trust-primitives.qmd` | 三原語能力邊界表＋全書地圖 |
| 6 | `book/06-ssdf.qmd` | SSDF＝驗收標準；PS.1/2/3 對回原語 |
| 7 | `book/07-artifact-signing.qmd` | cosign keyed/keyless、簽 digest、build once promote |
| 8 | `book/08-key-custody.qmd` | 金鑰保管四級演進、Vault Transit、adapter 模式 |
| 第三部 | （撰寫中） | 進來的東西：依賴、SBOM |

## 如何 render

需要 [Quarto](https://quarto.org)（Arch：`yay -S quarto-cli-bin`）：

```bash
cd book
quarto preview               # 本機即時預覽（改檔自動 reload）
quarto render --to html      # 產出 _book/（HTML）
quarto render --to pdf       # PDF 需 xelatex + Noto CJK 字型
```

## 範例程式

`book/examples/` 下的腳本純本機可跑、不碰網路：

```bash
book/examples/tiny_sign_verify.sh      # 簽一個檔案→改一個 byte→看驗章失敗（第 2 章）
book/examples/tiny_promote_verify.sh   # build 一次→簽 digest→晉級三環境重驗→掉包被攔（第 7 章）
```

## 結構

```
supply-chain-trust/
├── book/
│   ├── _quarto.yml        # 書本設定（章節、格式、O'Reilly 風）
│   ├── theme.scss         # serif + 紅色強調的樣式
│   ├── index.qmd          # 前言
│   ├── 01..08-*.qmd       # 序章 + 第一部四章 + 第二部三章
│   ├── references.bib     # 書目
│   └── examples/          # 可跑的實驗腳本
├── README.md              # 本檔
└── CLAUDE.md              # 給 Claude 的工作說明
```
