# 審閱單：Preface ＋ Chapter 1

用途：Ryan 不用逐字讀英文，只看這張表就能確認語意沒跑掉。
對應檔案：`book-en/index.qmd`、`book-en/01-why-supply-chain.qmd`（render 2/2 零 error）

---

## 1. 術語對照（往後全書統一用這組）

| 中文 | 英文 | 備註 |
|---|---|---|
| 信任不是被算出來的，是被授予的 | Trust is not computed. It is granted. | 全書主線，**不要改寫** |
| 原語 | primitive | |
| 雜湊 | hash | |
| 數位簽章 | digital signature | |
| 訊息鑑別碼 | MAC | 首次出現不展開，Ch.2 再解釋 |
| 信任錨點 | trust anchor | |
| 憑證鏈 | certificate chain / chain of trust | |
| 遞移依賴 | transitive dependency | |
| 爆炸半徑 | blast radius | |
| 成品 | artifact | 不譯成 product |
| 套件源 | feed / registry | |
| 來源證明 | provenance | |
| 誠實邊界 | honest boundaries | |
| 先預測 → 實測 → 為什麼 | predict → test → explain | |
| 本章帶走的東西 | What to take away | |
| 某金融機構／典型銀行環境 | a financial institution / a typical banking environment | **去識別用語，固定不變** |

## 2. 我沒有逐字翻譯的地方（要你確認）

| 位置 | 中文原稿 | 英文處理 | 為什麼 |
|---|---|---|---|
| 前言〈這本書的主線〉 | 「第一部（本卷）…第二部（撰寫中）」 | 改成 Part I／II／III 的現況描述 | **中文版這段已經過時**——第二部早就寫完、第三部已開工。中文版也該同步修 |
| 序章〈本書路線圖〉 | 「第二部（撰寫中）把原語套到真實供應鏈」 | 改寫成第二部已完成、第三部處理依賴 | 同上 |
| 前言 | 「天天在 npm install、mvn package、拉 container image」 | `npm install`, `mvn package`, `docker pull` | 英文讀者的慣用寫法 |
| 序章結尾 | — | 補上 honest boundaries callout | 中文版把這段放在〈誠實邊界〉小節，英文版收成 callout，內容不變 |

## 3. 🔴 你真正該擋的三件事——逐項確認

### (1) 術語譯錯
上表 16 個術語，有任何一個你覺得不對就改，**現在改比第五章再改便宜**。

### (2) 去識別漏網
兩章全文掃過：**無**機構名、人名、內部系統代號、IP、token。
唯一的人名是公開報導裡的攻擊者化名 "Jia Tan"（xz 事件），與 CVE 編號一樣屬公開資訊。

### (3) 宣稱被翻譯放大 ← 最危險的一類
| 中文 | 英文 | 檢查 |
|---|---|---|
| 「幾乎每個 Java 專案都在用」 | "so ubiquitous that nobody remembers adopting it" | 沒有變成 every，✅ |
| 「嚴格說，Log4Shell 不是供應鏈攻擊」 | "Strictly speaking Log4Shell was not a supply-chain *attack*" | 保留了保留語氣 ✅ |
| 「離全面鋪開只差幾週」 | "weeks away from broad rollout" | ✅ |
| 「這條路上幾乎沒有驗證」 | "almost nothing on that path is verified" | 保住了 almost，沒變成 nothing ✅ |
| 「我盡力驗證過，但請帶著懷疑讀」 | "I verified the conclusions as best I could — but read them sceptically" | ✅ |

**規則**：只要看到 all／every／always／fully／guarantees／prevents，就停下來對中文。這本書的價值在誠實邊界，翻譯放大等於把賣點翻掉。

## 4. 口試題（中文作答，答得出來這兩章才算過）

1. 前言主張「信任不是被算出來的，是被授予的」。請用 Log4Shell **反駁**這句話——它看起來像是「沒有人授予任何信任」的案例，你怎麼圓？
2. 六個攻擊面裡，xz-utils 同時打中兩格。是哪兩格，為什麼一個事件會橫跨兩格？
3. 序章說攻擊者不必打防火牆。那麼在什麼情況下，打防火牆仍然是比走依賴更划算的路？（答得出來代表你沒有把結論當口號）
