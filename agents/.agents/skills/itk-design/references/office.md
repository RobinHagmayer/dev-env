# PowerPoint, Word und Excel

Ergänzung zu `SKILL.md`. Enthält die Gestaltungswerte für Office-Dokumente und ihre Umsetzung in den Werkzeugen, mit denen Claude diese Dateien erzeugt.

## Rollenverteilung – zuerst lesen

Dieser Skill legt fest, **welche** Werte gelten. Die Skills `docx`, `pptx` und `xlsx` legen fest, **wie** eine Datei technisch entsteht. Beide zusammen anwenden.

| Ziel | Werkzeug |
|---|---|
| Word neu erzeugen | `docx-js` (npm) |
| Word bestehendes bearbeiten | OOXML in `word/document.xml` |
| PowerPoint neu erzeugen | `pptxgenjs` (npm) |
| PowerPoint aus Vorlage | OOXML in `ppt/slides/slideN.xml` |
| Excel | `openpyxl` |

Bei Widersprüchen gilt: für die Mechanik der jeweilige Office-Skill, für Farben, Größen und Gestaltung dieser hier.

**Ausdrücklicher Vorrang gegenüber dem xlsx-Skill:** Dessen Standardvorgabe „professionelle Schrift wie Arial oder Times New Roman“ wird hier überschrieben. Für IT-Kompass gilt Lato mit Arial als Ersatzschrift. Times New Roman ist nie zulässig.

## Inhalt

1. Farbwerte je Werkzeug
2. Schriften
3. Punkt-Skala und Einheitenfallen
4. PowerPoint
5. Word
6. Excel
7. Tabellen umsetzen
7b. Merksatz und Prozessschritte
8. Diagramme
9. Icons und Grafiken einfügen
10. Ergebnis prüfen
11. PDF-Export

---

## 1. Farbwerte je Werkzeug

Jedes Werkzeug erwartet ein eigenes Format. Immer die passende Spalte verwenden, nie die `#`-Notation aus dem Web übernehmen.

| Farbe | Web | docx-js / pptxgenjs | openpyxl |
|---|---|---|---|
| Dunkelblau | `#000854` | `"000854"` | `"FF000854"` |
| Tiefblau | `#0026FF` | `"0026FF"` | `"FF0026FF"` |
| Orange | `#f39200` | `"F39200"` | `"FFF39200"` |
| Hellorange | `#FFBF33` | `"FFBF33"` | `"FFFFBF33"` |
| Türkis | `#2FACB9` | `"2FACB9"` | `"FF2FACB9"` |
| Hellblau | `#83CFED` | `"83CFED"` | `"FF83CFED"` |
| Dunkelgrau | `#333333` | `"333333"` | `"FF333333"` |
| Hellgrau | `#CCCCCC` | `"CCCCCC"` | `"FFCCCCCC"` |
| Papier | `#F5F7FB` | `"F5F7FB"` | `"FFF5F7FB"` |
| Weiß | `#FFFFFF` | `"FFFFFF"` | `"FFFFFFFF"` |

Die Kontrastregeln aus `SKILL.md` Abschnitt 2 gelten unverändert: Auf Orange und Hellorange steht Text in Dunkelblau, weiße Schrift nur auf Dunkelblau oder Tiefblau.

## 2. Schriften

Lato durchgehend, Ersatzschrift Arial. Nie Calibri, nie Times New Roman.

Die Schrift wird im Dokument nur **benannt**. Ist sie auf dem öffnenden Gerät nicht installiert, ersetzt Office sie selbst – Layouts dürfen deshalb nicht auf Lato-spezifische Laufweiten angewiesen sein. Spaltenbreiten und Textrahmen mit Reserve auslegen.

Caveat wird in Office-Dokumenten **nicht** als Schrift gesetzt. Sie erscheint ausschließlich als Teil des Logos, und das ist eine Bilddatei. Grund: Fehlt Caveat auf dem Gerät, tauscht Office sie gegen eine beliebige Ersatzschrift und der Slogan sieht falsch aus.

Die Dateien unter `assets/fonts/` dienen nicht der Installation auf Arbeitsplätzen, sondern dem Einbetten, wenn Claude ein PDF oder eine Grafik erzeugt.

## 3. Punkt-Skala und Einheitenfallen

| Stufe | PowerPoint | Word | Gewicht |
|---|---|---|---|
| Cover / Titelfolie | 40 pt | 27 pt | Black 900 |
| Abschnittsüberschrift | 28 pt | 20 pt | Black 900 |
| Unterüberschrift | 20 pt | 13 pt | Bold 700 |
| Lead-Absatz | 18 pt | 12,5 pt | Regular 400 |
| Fließtext | 16 pt | **11 pt** | Regular 400 |
| Aufzählung 2. Ebene | 14 pt | 10,5 pt | Regular 400 |
| Tabellenkopf | 9 pt | 8 pt | Bold, Großbuchstaben |
| Tabellenzelle | 10 pt | 10 pt | Regular 400 |
| Bildunterschrift | 10 pt | 8,5 pt | Regular 400 |
| Fußzeile | 9 pt | 8 pt | Regular 400 |

**Zeilenabstand: Word 1,5 (also 16,5 pt bei 11 pt), Folien 1,15.** Der Wert 1,5 ist nicht verhandelbar für Dokumente, die gelesen und nicht überflogen werden; er entspricht der Web-Skala des Designsystems (16/25 px).

Die Abstände zwischen Absätzen und Abschnitten folgen den drei Stufen aus `SKILL.md` Abschnitt 4 – 8 / 24 / 48 pt, keine Zwischenwerte, keine Addition. Keine Leerzeilen als Abstandsmittel.

Run-in-Label wie „Dafür:“ oder „Ergebnis:“ werden als fetter Navy-Textanfang im selben Absatz gesetzt, nicht als eigener Absatz mit Abstand.

**Drei Einheitenfallen, die Gestaltung stillschweigend zerstören:**

- **docx-js rechnet Schriftgrößen in Halbpunkten.** `size: 21` ergibt 10,5 pt, nicht 21 pt. Jeden Wert aus der Tabelle oben verdoppeln.
- **docx-js rechnet Maße in DXA**, 1440 DXA = 1 Zoll = 25,4 mm. Millimeter also mit 56,7 multiplizieren.
- **pptxgenjs rechnet in Zoll**, nicht in Zentimetern. Zentimeter durch 2,54 teilen.

Mindest-Schriftgrad 6 pt ist eine absolute Untergrenze für Rechtstexte, kein normaler Wert.

Eyebrow-Laufweite: Office kennt keine prozentuale Laufweite. Stattdessen den Zeichenabstand erweitern – in docx-js über `characterSpacing` in Zwanzigstel-Punkt, bei 9 pt Text also etwa `30`.

## 4. PowerPoint

- Foliengröße 16:9, 33,87 × 19,05 cm. In pptxgenjs ist das `pptx.layout = "LAYOUT_WIDE"` (13,333 × 7,5 Zoll). Kein 4:3 und **nicht** `LAYOUT_16x9` – letzteres ist mit 10 × 5,625 Zoll kleiner, wodurch alle Punktgrößen im Verhältnis zur Folie zu groß wirken.
- Sicherheitsrand 1,2 cm (0,472 Zoll) an allen Rändern, dort keine Inhalte
- Titelzone oben 3,2 cm (1,26 Zoll) hoch
- Logo unten rechts, Breite 3,2 cm (1,26 Zoll), Abstand zum Rand mindestens ein Schutzraum
- **Welche Logovariante:** auf weißen Folien `itk-logo-rgb`, auf Dunkelblau **ebenfalls `itk-logo-rgb`** – das farbige Logo ist dort zulässig und war bisher zu Unrecht durch die Negativvariante ersetzt. Auf Tiefblau, Türkis und unruhigen dunklen Bildern `itk-logo-negativ`. Kriterium und Begründung in `SKILL.md` Abschnitt 5.
- Seitenzahl unten mittig, 9 pt, Dunkelgrau
- Zwei Folienhintergründe: Dunkelblau für Titel, Kapiteltrenner und Abschluss, Weiß für Inhaltsfolien. Papier `F5F7FB` nur für Karten und Tabellenzeilen auf weißen Folien, nie als Folienfläche.
- Key Visual auf Titel- und Kapitelfolien, maximal ein Cluster pro Folie
- Eine Kernaussage pro Folie, keine Textblöcke über fünf Zeilen
- Keine Folienübergänge, keine Animationen

**Key Visual auf Folien**

- Die Grafik mit `scripts/keyvisual.py` erzeugen und als PNG einfügen – nicht die SVG direkt platzieren, sonst fehlt die Randausblendung
- Werte und Platzierungsregeln stehen in `SKILL.md` Abschnitt 6. Auf Titel- und Kapitelfolien in Türkis 28 % auf Dunkelblau, auf weißen Inhaltsfolien in Hellgrau 30 %
- Verankerung: Titelfolien obere rechte Ecke, Inhaltsfolien untere rechte Ecke, jeweils über die Folienkante hinausragend. `--sides` nur mit den zum Folieninneren zeigenden Seiten belegen, sonst schwebt die Grafik.
- **Nicht auf jede Folie.** Auf Titel-, Kapitel- und Abschlussfolien sowie auf Folien mit viel Freiraum. Auf dichten Zahlen- und Tabellenfolien weglassen, sonst wird es Tapete.
- Text darf über der Grafik liegen; sie gehört in den Hintergrund. Deckkraft nirgends über 50 %

**Zwei Fallen bei Formen in pptxgenjs**

- **`line: { width: 0 }` entfernt die Kontur nicht** – LibreOffice und PowerPoint zeichnen weiterhin eine Haarlinie. Richtig ist `line: { type: "none" }`.
- Beim Hinweiskasten bekommt die farbige Akzentkante **keine eigene Kontur**, und sie muss die linke Rahmenlinie der weißen Fläche vollständig verdecken. Praktisch: weißes Rechteck mit Rahmen zeichnen, darüber die Kante mit `line: { type: "none" }` und einer Breite, die die Rahmenlinie überdeckt, um einen halben Linienbreitenwert nach links versetzt.

## 5. Word

- A4 Hochformat. In docx-js ist A4 die Voreinstellung und muss nicht gesetzt werden.
- **Satzspiegel:** Textspalte 140 mm, das sind rund 82 Zeichen bei 11 pt. Ränder in DXA: oben `2155` (38 mm, Logo-Zone), unten `1247` (22 mm), links `1701` (30 mm), rechts `2268` (40 mm).
- Der breite Außenrand rechts ist gewollt und begrenzt die Zeilenlänge. Er ist zugleich die Fläche für Eyebrow-Marker und Randnotizen.
- **Tabellen und Abbildungen dürfen in den Außenrand hineinlaufen** und bis 160 mm Breite nutzen. Fließtext nie.
- **Nummerierte Überschriften mit hängender Nummer:** `indent: { left: 567, hanging: 567 }` – 567 DXA sind 10 mm und reichen für zweistellige Nummern. Die Nummer steht damit links der Textkante, alle Überschriftenzeilen liegen auf der Kante des Fließtextes.
- Logo in der Kopfzeile rechts, Breite 30 mm, Mindestbreite 25 mm beachten. Variante `itk-logo-rgb`, da die Kopfzeile auf weißem Grund liegt
- Fußzeile mit Seitenzahl und Dokumenttitel, 8 pt (`size: 16`), Dunkelgrau, darüber eine Absatz-Unterkante in Hellgrau
- **Keine Tabelle als Trennlinie verwenden** – stattdessen die Unterkante eines Absatzes. Das deckt sich mit der Vorgabe des docx-Skills.
- Überschriften über `HeadingLevel.*` setzen, nicht als manuell formatierte Absätze. Sonst fehlt das Inhaltsverzeichnis und die Navigation funktioniert nicht.
- Überschriften in Dunkelblau, Fließtext in Dunkelgrau
- Keine farbigen Flächen hinter Absätzen. Hervorhebungen als Kasten mit 1 pt Rand in Hellgrau und Papier-Füllung.
- Tabellen brauchen in docx-js Breiten doppelt: `columnWidths` an der Tabelle **und** `width` an jeder Zelle, beide in DXA
- Tabellenfüllung immer mit `ShadingType.CLEAR`, nie `SOLID` – letzteres rendert schwarz

## 6. Excel

- `ws.sheet_view.showGridLines = False`, wenn das Blatt weitergegeben wird
- Kopfzeile nach Tabellenstil A: `PatternFill(start_color="FF000854", end_color="FF000854", fill_type="solid")`, Schrift `Font(name="Lato", bold=True, size=9, color="FF83CFED")`, Kopfzeile über `ws.freeze_panes` fixieren
- Zahlenformate konsequent, Tausenderpunkt, Dezimalstellen nur wo nötig. Währungssymbol in die Spaltenüberschrift, nicht in jede Zelle.
- Zahlenspalten rechtsbündig, Textspalten linksbündig. Die openpyxl-Voreinstellung ist bereits richtig, sie nicht überschreiben.
- Bedingte Formatierung nur mit Hellgrün und Hellrot, nie mit Farbskalen über mehrere Töne
- Keine verbundenen Zellen in Datenbereichen – sie zerstören Sortierung und Filter

## 7. Tabellen umsetzen

Beide Stile aus `SKILL.md` Abschnitt 9 gelten. Der kritische Punkt in Office: **Senkrechte Rahmenlinien sind in allen drei Werkzeugen die Voreinstellung und müssen ausdrücklich abgeschaltet werden.** Wird das übersehen, entsteht das Gittertabellen-Aussehen, das das Designsystem ausschließt.

**Stil A – Vollton-Kopf**

- Kopfzeile Dunkelblau, Schrift Hellblau, 9 pt Bold, Großbuchstaben
- Zeilen im Wechsel Weiß und Papier
- Nur waagerechte Linien, 1 pt Hellgrau. Senkrechte Kanten je Zelle ausdrücklich abschalten – in docx-js über `borders` pro Zelle mit `BorderStyle.NONE`, in openpyxl über `Border(left=Side(style=None), right=Side(style=None), bottom=Side(style="thin", color="FFCCCCCC"))`.
- Optionale Summenzeile mit 2 pt Oberkante in Dunkelblau
- In Word als Überschriftenzeile markieren, damit sie beim Seitenumbruch wiederholt wird
- Zeilen nicht über Seiten hinweg trennen lassen

**Stil B – Basislinie**

- Alle Rahmen entfernen, nur unter der Kopfzeile eine 1 pt Linie in Türkis
- Kopfzeile im Eyebrow-Stil in Türkis
- Zeilenabstand über den Zellinnenabstand oben herstellen, etwa 4 pt, nicht über Leerzeilen

**Abgerundete Zellecken sind in keinem Office-Format möglich.** Stil A eckig umsetzen und nicht mit übergelegten Formen nachbauen – das bricht beim Sortieren, Kopieren und beim PDF-Export.

Die Sonderform Dunkelgrund ist in Word und Excel nicht zulässig, auf Folien schon.

## 7b. Merksatz und Prozessschritte

Die Muster sind in `SKILL.md` Abschnitt 10b festgelegt. Hier die Umsetzung in Office.

### Merksatz

**PowerPoint:** Textfeld mit dem Satz in 20 pt Regular, Dunkelblau auf weißer Folie, Weiß auf dunkler. Links daneben ein Rechteck von 0,1 cm Breite in Türkis über die Höhe des Textfeldes, mit `line: { type: "none" }`. Abstand zwischen Kante und Text 0,5 cm. **Keine Füllung hinter dem Text.**

**Word:** Absatz mit linker Rahmenlinie. In docx-js über `border: { left: { style: BorderStyle.SINGLE, size: 18, color: "2FACB9" } }` – `size` rechnet in Achtelpunkt, 18 ergibt also 2,25 pt. Dazu `indent: { left: 340 }` für 6 mm Abstand und `size: 28` für 14 pt Schrift. Keine Schattierung.

Nicht als Tabelle mit einer Zelle bauen. Der docx-Skill schließt Tabellen als Mittel für Linien aus, und beim Kopieren in andere Dokumente bricht die Konstruktion.

### Prozessschritte

**PowerPoint:** Zwei bis vier Textfelder in einer Reihe, gleiche Breite, Abstand 0,8 cm. Über jedem eine waagerechte Linie in Hellgrau, 0,75 pt, über die Spaltenbreite. Darunter Nummer 28 pt Black in Türkis, Titel 16 pt Bold in Dunkelblau, Erläuterung 14 pt Regular in Dunkelgrau.

**Word:** Tabelle mit zwei bis vier Spalten, **nur Oberkante** sichtbar – alle übrigen Rahmen je Zelle mit `BorderStyle.NONE`. Je Zelle drei Absätze: Nummer `size: 40` Black Türkis, Titel `size: 24` Bold Dunkelblau, Erläuterung `size: 22` Dunkelgrau. Spaltenbreiten in DXA an Tabelle **und** Zellen setzen.

Die Verbote aus `SKILL.md` gelten unverändert: keine Kreise um die Nummer, keine Verbindungspfeile, keine Rahmen um die Spalten, keine farbigen Flächen.

**SmartArt wird grundsätzlich nicht verwendet** – es bringt eigene Farben, Formen und Schatten mit und lässt sich nicht auf die Palette zwingen. Ablaufgrafiken entstehen aus Textfeldern und Linien.

## 8. Diagramme

- Reihenfolge der Reihenfarben, Gitterlinien und Verbote wie in `SKILL.md` Abschnitt 10
- Die Standardpalette des Werkzeugs vollständig ersetzen, nicht nur einzelne Reihen umfärben – sonst kommen bei zusätzlichen Reihen fremde Farben hinzu
- Zeichnungsfläche und Diagrammfläche ohne Füllung und ohne Rahmen
- Achsenlinien 0,5 pt Hellgrau, Teilstriche entfernen, Achsenbeschriftung 9 pt Dunkelgrau
- Keine 3D-Effekte, keine Schatten, keine Verläufe in Flächen, keine Musterfüllungen
- Legende weglassen, wenn nur eine Datenreihe vorhanden ist, und stattdessen direkt beschriften
- Datenlabels statt Werteachse, wenn es wenige Werte sind
- Kreisdiagramme nur bis fünf Segmente, sonst Balken
- Keine Sekundärachse, wenn ein zweites Diagramm klarer wäre

## 9. Icons und Grafiken einfügen

**In Office werden Icons als PNG eingefügt, nicht als SVG.** Grund: Die SVG-Dateien tragen keine eigene Farbe, sondern erben sie über `currentColor` vom Umfeld. In einer Office-Datei fehlt dieses Umfeld, das Icon erscheint schwarz.

Die gebrauchten PNG deshalb **vor dem Schreiben der Datei erzeugen**:

```
python3 scripts/svg2png.py assets/icons/ui-icons/shield.svg shield.png --size 256 --color "#000854"
```

Nur die Icons erzeugen, die das Dokument tatsächlich braucht – meist drei bis sechs.

| Verwendung | `--color` | `--size` |
|---|---|---|
| UI-Icon auf hellem Grund | `#000854` | 256 |
| UI-Icon auf dunklem Grund | `#ffffff` | 256 |
| UI-Icon als Akzent | `#2FACB9` | 256 |
| Brand-Icon | `#000854` oder `#ffffff` | 512 |
| Key Visual | `#2FACB9` oder `#000854` | 1024 |

Logo und Fokus-Sechseck liegen unter `assets/png/` bereits fertig, weil ihre Farben festliegen. Diese nicht neu erzeugen und nicht umfärben.

Sind mehr als etwa zwölf Icons nötig, `scripts/build_pngs.py` in einem Durchlauf verwenden.

**Einsatzgrößen im Dokument**

- UI-Icons in Aufzählungen und Tabellen ohne Box, in Icon-Kacheln auf Folien mit Box aus `assets/icons/ui-icons/boxed/`
- Brand-Icons immer ohne Box, nicht kleiner als 0,8 cm Kantenlänge
- Auf Folien Brand-Icons mit 1,5 bis 2,5 cm, in Word mit 1,3 bis 2,0 cm. Wo weniger Platz ist, ein UI-Icon einsetzen
- Pro Abschnitt oder Folie nur eine Icon-Sorte, die Sorten nie nebeneinander
- Einzeln stehende UI-Icons entweder gerahmt (Variante aus `boxed/`) oder in einer getönten Kachel ohne Rahmen: Fläche in der Akzentfarbe bei 10 % Deckkraft, Icon in derselben Farbe volldeckend, Kachel 2,5 × Iconkante
- In einer Kachelreihe alle Icons auf identische Kantenlänge setzen, nicht optisch angleichen
- Beim Einfügen nur eine Kante angeben oder beide im Originalverhältnis, damit nichts verzerrt
- In docx-js braucht `ImageRun` die Angabe `type: "png"`

**Zwei Brand-Icons sind in Office nicht verwendbar:** `mission.svg` enthält ein Textelement, `veraltete-software.svg` einen Beschneidungspfad. Der Rasterizer stellt beides nicht dar. Für diese Motive ein anderes Brand-Icon wählen, statt ein unvollständiges PNG zu erzeugen.

## 10. Ergebnis prüfen

Die Office-Skills sehen vor, das Ergebnis nach dem Schreiben zu rendern und anzusehen. Diesen Schritt für die Gestaltung mitnutzen, nicht nur für die Technik. Am gerenderten Bild gezielt gegenprüfen:

- Senkrechte Tabellenlinien wirklich verschwunden?
- Icons in Markenfarbe statt schwarz?
- Orange an höchstens zwei Stellen und nicht als Fläche?
- Text auf Orange in Dunkelblau, nicht in Weiß?
- Schriftgrößen wie in der Skala – insbesondere nicht versehentlich doppelt oder halbiert durch die Halbpunkt-Falle?
- Logo unverzerrt, über Mindestgröße und in der zum Untergrund passenden Variante?

Anschließend die vollständige Prüf-Checkliste aus `SKILL.md` Abschnitt 11 durchgehen.

## 11. PDF-Export

Für digitale Weitergabe: Bilder nicht unter 150 dpi, Lesezeichen aus Überschriften, Dokumenttitel in den Eigenschaften setzen.

Für professionellen Druck gilt `references/print-pdf.md`. Ein Office-Export ist dafür nicht geeignet.
