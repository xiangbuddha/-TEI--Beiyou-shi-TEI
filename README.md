# 北遊詩（Beiyou shi）TEI Critical Edition

本倉庫收錄《北遊詩》之 TEI 編碼校錄本，由魏翔（Xiang Wei，Temple University）編製。此數字版本以古香樓抄本（GX）為底本，互校振綺堂抄本（ZQ）與眠雲精舍抄本（MY），並以可機器處理（machine-actionable）的方式保存主讀、異文、抄寫增刪改痕跡、以及編者按語。另知味夢軒抄本（WM）殘破嚴重，未納入本次逐行互校。

This repository contains a TEI-encoded critical edition of *Beiyou shi* prepared by Xiang Wei (Temple University). The edition uses the Guxianglou manuscript (GX) as copy-text and collates the Zhenqitang (ZQ) and Mianyun jingshe (MY) manuscripts. It encodes adopted readings, textual variants, scribal interventions, and editor-authored notes in a machine-actionable form. A fourth known witness (WM) is excluded due to severe damage and illegibility.

## Repository Structure

- `tei/` — TEI XML source (currently: `beiyou-shi.xml`)
- `xslt/` — XSLT stylesheets (currently: `beiyou-shi-overview.xsl`)
- `assets/` — presentation resources (CSS, etc.)

## Witnesses & Consulted Editions

Collated manuscript witnesses (included in the line-by-line negative apparatus):
- **GX**（古香樓抄本 / Guxianglou manuscript）— copy-text（底本）
  - 北京，北京國家圖書館（National Library of China）, call no. **A00664**
- **ZQ**（振綺堂抄本 / Zhenqitang manuscript）
  - 臺北，國家圖書館（National Central Library）, call no. **000519988**
- **MY**（眠雲精舍抄本 / Mianyun jingshe manuscript）
  - 南京，南京圖書館（Nanjing Library）, call no. **GJ/EB/113750**

Known but excluded witness:
- **WM**（味夢軒抄本 / Weimeng xuan manuscript）— excluded due to severe damage/illegibility

Consulted modern editions (reference/critique only; not treated as collated apparatus witnesses):
- **Bao**：吳定中、鮑翔麟校注《楚石北遊詩》（浙江古籍出版社，2010）
- **Yu**：余德隆點校《楚石梵琦全集》（九州出版社，2017）

Editorial witness:
- **ed**：編者校訂（Editor’s emendation; Xiang Wei）

## Extent (Work Coverage)

各抄本所收《北遊詩》之終止處不同：
- **ZQ、MY** 止於 `by317`
- **GX** 於 `by317` 後續錄五首：`by318`–`by322`

Witness extent differs:
- ZQ and MY end at `by317`
- GX continues with five additional poems: `by318`–`by322`

## Encoding & Editorial Principles (TEI)

### Copy-text and Adopted Readings
- 底本原則：以 **GX** 為底本（copy-text）。
- 若 GX 被判定有誤，參酌 **ZQ** 或 **MY** 取其善者。
- 若三抄本皆不足以立主讀（例如三本同誤、三本皆不可讀、或需依史料/語義/格律/旁證整合裁定），則以 **編者校訂**（`#ed`）明示於 `app/lem`，並固定標記 `wit="#ed"` 與 `resp="#Xiang"`。機器處理不需推斷觸發條件，只需檢查 `lem/@wit` 是否包含 `#ed`。

GX serves as copy-text. Where GX is judged erroneous, readings from ZQ or MY may be adopted. Where all three manuscripts are insufficient, the adopted reading is declared in `app/lem` with fixed attribution `wit="#ed"` and `resp="#Xiang"`. Machine processing should treat `lem` as the main reading source; if `lem/@wit` contains `#ed`, it is an editor’s emendation.

### Apparatus: Negative Apparatus (負排錄)
- 本次 apparatus 僅涵蓋 **GX / ZQ / MY** 三抄本。
- 同意主讀：以 `rdg` 保留見證位置並標記 `ana="#agree"`。
- 缺文：以 `gap` 區分 `gap[@reason="omission"]` 與 `gap[@reason="illegible"]`（必要時配合 `ana="#omitted"`），避免與同意讀混淆。
- 超出見證本收錄範圍：以 `ana="#unattested"` 明示。

A negative apparatus is used for GX/ZQ/MY. Agreement is explicitly marked on `rdg` with `ana="#agree"`. Missing text is encoded with `gap`, distinguishing omission vs. illegibility; passages outside a witness’s extent are marked `ana="#unattested"`.

### Selective Variant Encoding
雖逐行互校三抄本，然 `app` 異文採選擇性收錄：凡涉通假、可能影響義讀/語法/典故/格律/修辭，或屬形近易訛且需校勘者，立為異文條目；純字形異體而語義等同者，不必然另立異文（邊界情形則以編者按語說明）。

Although GX/ZQ/MY are collated line by line, the apparatus is selectively populated when variants may affect interpretation or require editorial adjudication.

### Glyph Normalization & Gaiji
- 為便閱讀與檢索，罕見字形可用 `choice/orig/reg` 記錄：`orig` 為見證字形，`reg` 為顯示/檢索用字形；必要時亦可用 `standOff` 的 `linkGrp[@type="glyph-normalization"]` 建立對應。
- Unicode 未收錄或字體不支援之罕見/異體字形，以 `<g>` 標記，`ref` 使用教育部《異體字字典》ID（`moe:` 前綴），並以 `@norm` 提供可檢索正字。機器處理應以 `@norm` 作為正規化文本。

Rare forms may be normalized with `choice/orig/reg` (orig = witness form; reg = display/search form). Unencoded/unsupported glyphs are encoded as `<g>` with MOE IDs (`moe:` prefix) and a canonical searchable form in `@norm`.

### Physical Condition & Scribal Interventions
為保存抄本文獻證據，本檔案於轉錄層使用 `damage / del / unclear / gap / add` 等元素；必要時以 `@resp="#Xiang"` 與 `@corresp` 指向見證（如 `#GX`）以利後續抽取與對齊。

The transcription layer encodes physical condition and interventions using `damage / del / unclear / gap / add`, with responsibility and witness linkage when applicable.

### Punctuation
三抄本原無標點。本版本所見標點皆為編者補入，以 `pc` 標記並加 `resp="#Xiang"` 與 `ana="#punct-added"`。

All punctuation is editorially supplied and encoded as `pc` with `resp="#Xiang"` and `ana="#punct-added"`.

## Authority Control

`persName/@key` 採外部權威識別：僧侶人名優先連結 DILA Authority Database（例如 `A001082`），一般人物連結 Inindex Biographical Database（例如 `124318`）。

Personal names use external identifiers in `persName/@key`, prioritizing DILA for monastics and Inindex for other figures.

## Reproducible Transformation (XML → HTML)

Example (Saxon):

```bash
saxon -s:tei/beiyou-shi.xml -xsl:xslt/beiyou-shi-overview.xsl -o:index.html

If the generated HTML links to CSS in assets/, ensure the output location preserves correct relative paths.

Availability, Rights, and Licensing

No manuscript images are included in this repository. Any rights pertaining to the original physical manuscripts remain with their respective holding institutions.

IMPORTANT NOTE (alignment between TEI header and open release):

The current TEI <publicationStmt>/<availability> in the file states it is a dissertation appendix draft and “for academic research purposes only.”

If you are viewing this repository as a public open release, please rely on the repository LICENSE files and tagged Releases for reuse terms.

The TEI header will be updated in subsequent releases to reflect the open licensing terms consistently.

License:

This repository currently uses the MIT License (see LICENSE).

If you later separate licenses for data vs. code (common practice: data = CC BY 4.0; code = MIT), that change will be documented in Releases and reflected in the TEI header.

Citation

Wei, Xiang. Beiyou shi (北遊詩) TEI Critical Edition. GitHub repository.
For a stable citation, cite a tagged release (e.g., v0.1.0) and/or commit hash.

Versioning Policy

Daily updates overwrite files in place (Git retains full history). Citable milestones are fixed via Git tags / GitHub Releases (e.g., v0.1.0, v0.2.0, v1.0.0).

Keywords

Poetry; Travel writing; Buddhist literature; Yuan-dynasty literature; Authorship attribution; Textual criticism
詩歌；遊記；佛教文學；元代文學；作者歸屬；文獻校勘
