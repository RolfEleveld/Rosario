# Rosario

An EPUB of the Holy Rosary that can be read from beginning to end. The Spanish edition is the source. Companion editions follow it in Latin, German, Italian, and English.

## Languages

Each prayer, mystery, intention, and weekday page exists in five languages. File names keep the Spanish base name and add a language suffix:

| Code | Language | Suffix | Example |
| --- | --- | --- | --- |
| es | Español | *(none)* | `Resos/Avemaria.xhtml` |
| la | Latine | `-la` | `Resos/Avemaria-la.xhtml` |
| de | Deutsch | `-de` | `Resos/Avemaria-de.xhtml` |
| it | Italiano | `-it` | `Resos/Avemaria-it.xhtml` |
| en | English | `-en` | `Resos/Avemaria-en.xhtml` |

Every page starts with a language switch (`es`, `la`, `de`, `it`, `en`) so the same prayer or mystery can be opened in another language. Weekday pages also link to the sibling day that uses the same mysteries.

The book opens on [OEBPS/main.xhtml](OEBPS/main.xhtml), which lists the seven weekdays for each language. [OEBPS/nav.xhtml](OEBPS/nav.xhtml) lists the weekdays and the prayers. [toc.ncx](toc.ncx) follows the same order: mysteries by language, then prayers by language.

## Contents

| Folder | What it holds |
| --- | --- |
| `OEBPS/Navigation` | One page per weekday, and the same page in each companion language |
| `OEBPS/Misterios` | The twenty mysteries: Gozoso, Doloroso, Glorioso, and Luminoso |
| `OEBPS/Resos` | The prayers recited during the Rosary |
| `OEBPS/Intensiones` | Intentions for the Rosary |
| `OEBPS/styles` | The shared stylesheet |

Weekday mysteries:

| Day | Mysteries |
| --- | --- |
| Monday and Saturday | Joyful (Gozoso) |
| Tuesday and Friday | Sorrowful (Doloroso) |
| Wednesday and Sunday | Glorious (Glorioso) |
| Thursday | Luminous (Luminoso) |

## Sequence

The spine repeats the same source pages so each weekday can be read straight through without duplicating the files.

1. Sign of the Cross
2. Prayer to the Holy Spirit
3. Creed
4. Our Father
5. Hail Mary
6. Hail Mary
7. Hail Mary
8. Glory Be
9. Mystery 1
10. Our Father
11. Hail Mary ×10
12. Glory Be
13. Aspiration
14. Mysteries 2 to 5, each with steps 10 to 13
15. Litany of the Blessed Virgin Mary
16. Closing of the mysteries
17. Divine Providence
18. Guardian Angel
19. Prayer to Saint Michael the Archangel
20. Under Your Protection
21. Prayer of Saint Gertrude
22. Saint Joseph

## ePUB

The publication uses the EPUB container so the same page can appear more than once in the reading order without storing a second copy. The binder places every page in sequence and groups each weekday as one Rosary.

Reference: [EPUB 3 specification](https://www.w3.org/publishing/epub3/epub-spec.html).

`content.opf` is the manifest and spine. `Manifest.xlsx` and `ManifestManipulations.ps1` are the source used to regenerate it. Regenerating the package from the workbook drops any language rows that have not been added there.

## Compile

Create the book with:

```PowerShell
Compress-Archive -Path . -DestinationPath ./Rosario.epub -Force
```