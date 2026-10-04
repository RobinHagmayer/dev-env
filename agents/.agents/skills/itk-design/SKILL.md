---
name: itk-design
description: Verbindliches Design-Regelwerk der IT-Kompass GmbH (Corporate Design 2026.1) für alle visuellen Ergebnisse – Farben, Typografie, Logo, Key Visual, Icons, Abstände, Komponenten, Tabellen und Diagramme. Verwende diesen Skill immer dann, wenn etwas Sichtbares für IT-Kompass entsteht oder verändert wird – Präsentationen und Folien, Word-Dokumente, PDFs, Angebote, Excel-Tabellen, Diagramme und Charts, Onepager und Infoblätter als HTML-Datei, Social-Media-Grafiken, Newsletter, Messe- und Druckmaterial sowie KI-generierte Bilder, intern wie extern. Auch anwenden, wenn der Nutzer nur „mach mir eine Folie“, „bau eine Tabelle“, „erstelle ein Diagramm“ oder „gestalte das schöner“ schreibt, ohne Marke oder Design ausdrücklich zu erwähnen. Nicht vorgesehen für den Bau von Webseiten oder Unterseiten von it-kompass.com.
---

# IT-Kompass Design-System 2026.1

Verbindliche Gestaltungsgrundlage für alle Medien der IT-Kompass GmbH (Cloud & Systemhaus, Donzdorf). Ein System für Web, Office, Print, Social und KI-generiertes Material – damit jedes Ergebnis erkennbar zur Marke gehört.

## Zweck

Dieser Skill ist der Ausgangspunkt für jedes visuelle Ergebnis, das Claude für IT-Kompass erzeugt – Folien, Word-Dokumente, PDF, Tabellen, Grafiken und Onepager als HTML-Datei. Er stellt sicher, dass alles im Corporate Design entsteht, ohne dass es jedes Mal neu erklärt werden muss.

### Wofür HTML in diesem Skill gedacht ist – und wofür nicht

HTML ist hier ein **Präsentationsformat für ein abgegrenztes Thema**: Onepager, Infoblatt, Themenübersicht, Entscheidungsgrundlage – zur internen oder externen Weitergabe. Ein solches Dokument ist derselben Kategorie wie eine Folie oder ein PDF, es besteht nur zufällig aus HTML.

**Der Bau von Webseiten ist ausdrücklich nicht Aufgabe dieses Skills.** Keine Unterseiten von it-kompass.com, keine Navigation, keine mehrseitigen Strukturen, kein Anspruch auf Webseitenqualität oder den Seitenaufbau der Website. Dafür gibt es einen eigenen, getrennten Weg.

Die Grenze ist mit einer Frage entscheidbar: **Bekommt das Ergebnis eine URL auf it-kompass.com und einen Platz in der Navigation?** Ist die Antwort ja, ist es hier nicht vorgesehen – dann darauf hinweisen, statt es zu bauen.

Das Regelwerk richtet sich an Claude, nicht an Menschen, die ein Programm bedienen. Alle Vorgaben sind deshalb so formuliert, dass sie beim programmatischen Erzeugen der Dateien anwendbar sind. Sind mehrere Wege möglich, gilt der, der ohne Nachbearbeitung durch Menschen auskommt.

## Was dieser Skill regelt – und was nicht

**Geregelt:** Farben, Typografie, Abstände, Formen, Logo-Anwendung, Key Visual, Icons, Bildsprache, UI-Komponenten, Tabellen, Diagramme, Formate je Medium.

**Nicht geregelt – hier bewusst keine Vorgaben machen:**

- Wording, Tonalität, Textstil und Anrede. Diese hängen vom jeweiligen Dokument und Medium ab und werden vom Nutzer oder Kontext bestimmt. Formuliere Texte niemals nach diesem Skill um.
- Produktdaten und Preise → stammen ausschließlich aus den freigegebenen CSV-Dateien im Website-Repository.
- Kontaktdaten, Ansprechpartner, E-Mail- und Telefonformate → dafür gilt der separate Kontaktdaten-Skill. Nicht hier duplizieren.

Einzige Ausnahme an der Grenze zum Text: **Mikrotypografie**. Sie betrifft, wie Zeichen aussehen, nicht was gesagt wird.

Der Zweck dieser Regeln ist, dass ein Text nicht nach maschineller Erzeugung aussieht. Sprachmodelle setzen standardmäßig Geviertstriche und englische Anführungszeichen; daran erkennt man KI-Text. Die Abwehr dagegen darf aber nicht in die deutsche Rechtschreibung eingreifen.

- **Anführungszeichen:** in laufendem deutschem Text die deutschen Gänsefüßchen `„…“`, verschachtelt `‚…‘`. Englische `“…”` sind unzulässig. Gerade Zollzeichen `"` gehören ausschließlich in technische Zusammenhänge: Code, HTML-Attribute, CSS-Werte, JSON, Dateinamen, Befehlszeilen.
- **Gedankenstrich:** Halbgeviertstrich mit Leerzeichen (` – `, `&ndash;`). Der Geviertstrich (`—`, `&mdash;`) wird nicht verwendet, auch nicht mit Leerzeichen.
- **Bindestrich:** normaler Bindestrich, keine Sonderzeichen.

Zur Herkunft: Das Corporate Design 2026.1 formuliert unter Tonalität „ASCII-Zeichensetzung: gerade Anführungszeichen" und untersagt „KI-typische Geviertstriche, geschwungene Anführungszeichen". Der eigene Text des Dokuments verwendet an beiden Stellen deutsche Gänsefüßchen. Die Regel hier setzt die erkennbare Absicht um, nicht den Wortlaut.

## Welche Referenzdatei lesen

Lies zusätzlich zu dieser Datei genau die Referenz, die zum Zielmedium passt:

| Zielmedium | Datei |
|---|---|
| Onepager und Infoblätter als HTML, Newsletter | `references/web.md` |
| PowerPoint, Word, Excel, PDF aus Office | `references/office.md` |
| Druck, professionelles PDF, Messe, Roll-up | `references/print-pdf.md` |
| Instagram, LinkedIn, Profilbilder | `references/social.md` |
| Bildgenerierung per KI | `references/ki-bilder.md` |

Bei mehreren Zielmedien alle betroffenen Dateien lesen.

Für Word, PowerPoint, Excel und PDF gilt zusätzlich der jeweilige Anthropic-Skill (`docx`, `pptx`, `xlsx`, `pdf`). Arbeitsteilung: Jener liefert die Mechanik des Dateiformats, dieser die Gestaltungswerte. Bei Widerspruch hat für die Technik der Format-Skill Vorrang, für Farben, Größen und Gestaltung dieser hier. Eine Ausnahme ist ausdrücklich geregelt: Die Schriftvorgabe des `xlsx`-Skills wird durch Lato überschrieben.

Video und Motion Design sind noch nicht geregelt – bei solchen Anfragen darauf hinweisen, dass dafür keine Vorgabe vorliegt, statt eine zu erfinden.

## Wo die Originaldateien liegen

Logo, Key Visual, Icons und Schriften liegen als Dateien im Skill. Sie sind immer zu verwenden – Markenelemente werden nie nachgebaut, nachgezeichnet oder generiert.

```
assets/
├── ASSETS.md    Bestandsverzeichnis und Prüfhinweise
├── logo/        itk-logo-rgb.svg · itk-logo-dunkelblau.svg · itk-logo-negativ.svg
│                itk-bildmarke.svg · itk-logo-cmyk.eps
├── keyvisual/   arc-a.svg · arc-bl.svg · arc-l.svg · arc-r.svg
│                hexagon-fokus.svg
├── icons/
│   ├── ui-icons/        43 Funktions-Icons ohne Box, 24 × 24 px
│   │   └── boxed/       dieselben 43 Icons mit umschließender Kontur, 40 × 40 px
│   └── brand-icons/     76 illustrative Icons, immer ohne Box
├── png/                 nur Logo und Fokus-Sechseck, da farblich festgelegt
└── fonts/               Lato Regular/Bold/Black, Caveat Regular, je mit OFL

scripts/
├── svg2png.py           SVG in beliebiger Farbe und Größe nach PNG rendern
└── build_pngs.py        alle Varianten in einem Durchlauf erzeugen
```

**Welches Format wann:** In Web und Druck immer die SVG. In Word, PowerPoint und Excel PNG – die SVG tragen keine eigene Farbe und erscheinen dort sonst schwarz. Die benötigten PNG werden bei Bedarf mit `scripts/svg2png.py` erzeugt, nicht im Skill vorgehalten. So ist jede Markenfarbe und jede Auflösung möglich. Einzelheiten in `references/office.md`.

Den Dateinamen eines gesuchten Icons durch Auflisten des Ordners ermitteln, nicht raten – die Namen sind inhaltlich vergeben und nicht durchgehend einheitlich geschrieben.

Alle SVG-Dateien außer `hexagon-fokus.svg` und den Logos verwenden `stroke="currentColor"`. Die Strichfarbe wird also über die Textfarbe des umgebenden Elements gesetzt und muss dort ausdrücklich auf eine Markenfarbe festgelegt werden – sonst erbt das Icon eine beliebige Farbe.

---

## 1. Grundhaltung der Gestaltung

Drei Sätze, aus denen sich im Zweifelsfall jede Entscheidung ableiten lässt:

1. **Hierarchie statt Buntheit.** Blau ist Fläche, Orange ist Punkt.
2. **Grafik führt, Bild unterstützt.** Fotos sind eine Ebene von mehreren, nie das Hauptelement.
3. **Linie, Geometrie, Ruhe.** Konstante Strichstärken, definierte Abstände, keine Effekte.

Wenn eine Gestaltung unruhig, bunt oder effektlastig wirkt, ist sie falsch – auch wenn jede Einzelregel eingehalten wurde.

---

## 2. Farben

### Palette

| Rolle | Name | HEX | RGB | CMYK | Verwendung |
|---|---|---|---|---|---|
| Primary · Base | Dunkelblau | `#000854` | 0 8 84 | 100/95/30/55 | Haupthintergrund, Headline-Flächen, dominante Trägerfläche |
| Primary · Dynamic | Tiefblau | `#0026FF` | 0 38 255 | 100/85/0/0 | Dynamische Elemente, Links, Verlaufspartner |
| Accent · Focus | Orange | `#F39200` | 243 146 0 | 0/50/100/0 | Fokuszone, Icon-Highlight, CTA, Logo |
| Accent · Soft | Hellorange | `#FFBF33` | 255 191 51 | 0/30/85/0 | Verlaufspartner zu Orange, sekundärer Warmton |
| Secondary · Bridge | Türkis | `#2FACB9` | 47 172 185 | 75/15/30/0 | Konturlinien auf hellem Grund, Slogan |
| Secondary · Light | Hellblau | `#83CFED` | 131 207 237 | 45/5/0/0 | Aufhellungen, helle Ebenen |
| Grey · Body | Dunkelgrau | `#333333` | 51 51 51 | 0/0/0/80 | Fließtext auf hellem Grund |
| Grey · Surface | Hellgrau | `#CCCCCC` | 204 204 204 | 0/0/0/20 | Trenner, dezente Flächen, Icon-Outlines |
| Status · Alert | Hellrot | `#FF5500` | 255 85 0 | – | Warnhinweise, kritische Status |
| Status · Success | Hellgrün | `#3CAA31` | 60 170 49 | – | Erfolg, aktiver Status |
| Neutral | Weiß | `#FFFFFF` | – | 0/0/0/0 | Negativraum |
| Neutral | Papier | `#F5F7FB` | 245 247 251 | – | Ruhige Hintergrundfläche, Zebra-Zeilen |
| Neutral | Tinte | `#0A0F2C` | 10 15 44 | – | Fließtext auf Papier-Flächen im Web |

### Mengenverteilung

Blau dominiert als Trägerfläche. Weiß und Papier schaffen Atmung. Türkis verbindet. Grau strukturiert.

**Orange-Regel, verbindlich und prüfbar:** Orange und Hellorange erscheinen pro Motiv oder pro Seite an **maximal zwei Stellen** und füllen zusammen **nie mehr als 5 % der sichtbaren Fläche**. Zulässig als Füllung sind ausschließlich: Buttons, Badges, Statuspunkte, das Fokus-Sechseck im Key Visual sowie Icon-Highlights. Niemals als Hintergrundfläche, Kopfzeilenband, Spaltenfläche oder Folienhintergrund.

**Was als „Stelle“ zählt:** Jede sichtbare Verwendung von Orange oder Hellorange – als Füllung, als Kontur, als Schriftfarbe oder als Linie. Ein hellorange umrandeter Button mit hellorange Schrift ist **eine** Stelle, nicht zwei, weil Kontur und Schrift zum selben Element gehören. Zwei solcher Buttons nebeneinander sind zwei Stellen und damit das Maximum.

Rot und Grün sind ausschließlich funktional. Sie zeigen einen Status an und werden nie dekorativ eingesetzt.

### Verläufe

Nur ambient und nur zwischen Dunkelblau, Tiefblau und Türkis. Kein Warmanteil in Verläufen, kein Orange, keine mehrfarbigen Verläufe. Zulässige Kombinationen: Dunkelblau → Tiefblau, Dunkelblau → Türkis, radiales Mesh auf Dunkelblau.

### Lesbarkeit – verbindliche Textfarbregeln

Gemessene Kontrastwerte der Markenfarben (WCAG-Mindestwert 4,5:1 für normalen Text, 3:1 für große Schrift ab 24 px bzw. 18,5 px fett):

| Kombination | Kontrast | Zulässig |
|---|---|---|
| Weiß auf Dunkelblau | 18,1:1 | ja |
| Hellblau auf Dunkelblau | 10,4:1 | ja |
| Dunkelblau auf Hellorange | 11,0:1 | ja |
| Dunkelgrau auf Weiß | 12,6:1 | ja |
| Tiefblau auf Weiß | 7,7:1 | ja |
| Dunkelblau auf Orange | 7,7:1 | ja |
| Dunkelblau auf Türkis | 6,6:1 | ja |
| Weiß auf Orange | 2,4:1 | **nein** |
| Weiß auf Türkis | 2,7:1 | **nein** |
| Weiß auf Hellorange | 1,7:1 | **nein** |
| Orange auf Weiß | 2,4:1 | nur als Fläche/Linie, nicht als Text |
| Türkis auf Weiß | 2,7:1 | nur Eyebrow und Linien, kein Fließtext |
| Hellrot / Hellgrün auf Weiß | 3,2 / 3,0:1 | nur ab 18,5 px fett |

Daraus die drei Regeln, die immer gelten:

1. **Auf Orange und Hellorange steht Text immer in Dunkelblau** – nie in Weiß. Das betrifft insbesondere den Primary Button.
2. **Weiße Schrift nur auf Dunkelblau oder Tiefblau.**
3. **Türkis und Orange sind keine Fließtextfarben.** Türkis ist für Eyebrows, Linien und den Slogan reserviert.

### Textfarben auf dunklem Grund

| Rolle | Farbe |
|---|---|
| Fließtext, Lead-Absätze, Überschriften | **Weiß** |
| Sublines, Rollenbezeichnungen, Bildunterschriften | Hellblau |
| Hervorhebung einzelner Passagen | Hellblau |
| Links | Hellblau |
| Eyebrow | Türkis oder Hellblau |

**Hellblau ist eine Auszeichnungsfarbe, keine Textfarbe.** Wird der Fließtext auf Dunkelblau hellblau gesetzt, verliert die Hervorhebung ihre Funktion und die Fläche wirkt insgesamt flau. Sobald mehr als einzelne Passagen hellblau sind, ist die Farbe falsch eingesetzt.

### Buttons mit Kontur

Bei Buttons ohne Füllung trägt die Schrift **dieselbe Farbe wie die Kontur**. Weiße Kontur, weiße Schrift. Hellorange Kontur, hellorange Schrift. Dunkelblaue Kontur, dunkelblaue Schrift. Eine dritte Farbe im Button macht das Bild bunt und schwächt die Hierarchie.

---

## 3. Typografie

### Schriften

- **Lato** – Hausschrift. Gewichte 100 Thin, 300 Light, 400 Regular, 700 Bold, 900 Black, jeweils auch kursiv.
- **Caveat** – Slogan-Schrift, handgeschrieben. Gewichte 400, 600, 700. Ausschließlich für den Slogan und einzelne Fokus-Hervorhebungen. Nie für Fließtext, Überschriften oder Tabellen.

Fallback, wenn Lato nicht verfügbar ist: **Arial**. Nie Calibri, nie Helvetica-Substitute, nie serifenbetonte Ersatzschriften.

Mindest-Schriftgrad über alle Medien: **6 pt**.

### Skala für Web (Größe / Zeilenhöhe in px)

| Stufe | Größe | Gewicht | Laufweite | Einsatz |
|---|---|---|---|---|
| Display | 64 / 64 | Black 900 | −2 % | Hero, Cover |
| H1 | 48 / 50 | Black 900 | −1,5 % | Section-Headlines |
| H2 | 32 / 38 | Bold 700 | normal | Subsection |
| H3 | 22 / 28 | Bold 700 | normal | Card-Titel |
| Body L | 18 / 28 | Regular 400 | normal | Lead-Absätze |
| Body | 16 / 25 | Regular 400 | normal | Standard-Text |
| Caption | 13 / 19 | Regular 400 | normal | Meta, Bildunterschrift |
| Eyebrow | 11 / 14 | Bold 700 | +18 %, UPPERCASE | Kategorie-Label |

Der Eyebrow ist die einzige Stelle, an der Großbuchstaben zulässig sind.

Die Entsprechungen in Punkt für Office-Dokumente stehen in `references/office.md`. Rechne px-Werte nicht selbst um – nutze die dort festgelegte Skala.

---

## 4. Abstände und Formen

### Abstandsskala

Alle Abstände sind Vielfache von 4: **4, 8, 12, 16, 24, 32, 48, 64, 96**. Zwischenwerte sind nicht zulässig. Innerhalb einer Komponente die kleinen Werte (4–16), zwischen Komponenten die mittleren (24–48), zwischen Abschnitten die großen (64–96).

Ausnahme: Die **Innenabstände einzelner Komponenten** sind in `references/web.md` festgelegt und folgen dort der Optik, nicht dem Raster – Buttons `12px 22px`, Tabellenköpfe `11px 16px`. Diese Werte gelten wie dokumentiert. Die Viererregel betrifft Layout-Abstände zwischen Elementen, nicht die Innenmaße bestehender Komponenten.

### Abstandshierarchie im Fließtext

Für Dokumente mit längeren Texten – Berichte, Strategiepapiere, Angebote, Artikel – gelten genau **drei** Stufen. Mehr Stufen zerstören die Wirkung, weil das Auge ähnliche Werte nicht als Rangordnung liest, sondern als Ungenauigkeit.

| Zweck | Abstand |
|---|---|
| Zwischen Absätzen desselben Gedankens | **8 pt** |
| Vor einer Unterüberschrift | **24 pt** darüber, 6 pt darunter |
| Vor einem Abschnitt oder einer nummerierten Überschrift | **48 pt** darüber, 12 pt darunter |

Das Verhältnis 1 : 3 : 6 ist die Untergrenze, ab der die Stufen als verschiedene Ebenen erkennbar sind.

Drei Regeln, ohne die die Stufen nicht wirken:

1. **Andere Werte sind unzulässig.** Kein 10, kein 14, kein 18. Run-in-Label wie „Dafür:“ oder „Ergebnis:“ erhalten keinen Zusatzabstand und laufen im Textfluss mit.
2. **Abstände addieren sich nicht – es gilt der größere.** Folgt eine Abschnittsüberschrift auf einen Hinweiskasten, entstehen nicht 24 + 48 pt, sondern 48 pt. Sonst reißt ein Loch in die Seite.
3. **Die erste Unterüberschrift direkt nach einer Abschnittsüberschrift erhält keinen Zusatzabstand.** Sonst löst sie sich von ihrem Abschnitt.

### Satzspiegel für Textdokumente

| Größe | Wert |
|---|---|
| Breite der Textspalte | **140 mm**, entspricht rund 82 Zeichen bei 11 pt Lato |
| Zeilenabstand im Fließtext | **1,5** |
| Nummernspalte im Außenrand | 10 mm |

Die Zeilenlänge ist der wichtigste Hebel für Lesbarkeit. Der Korridor liegt bei 55 bis 85 Zeichen; darüber muss der Blick am Zeilenende so weit zurückspringen, dass Zeilen übersprungen werden. **Zeilenlänge und Zeilenabstand hängen zusammen** – wird die Spalte breiter, muss der Zeilenabstand mitwachsen. Bei mehr als 85 Zeichen ist stattdessen die Schrift zu vergrößern oder die Spalte zu verschmälern.

Nummerierte Überschriften: **Die Nummer hängt in den Außenrand**, alle Textzeilen liegen auf einer Kante. Dadurch bilden die Nummern eine Navigationsspalte, und bei zweizeiligen Überschriften bleibt die Nummer freistehend. Nummer und Text nie in einer Zeile umbrechen lassen.

### Radien

| Token | Wert | Einsatz |
|---|---|---|
| `--radius-sm` | 4 px | Badges, kleine Marker |
| `--radius-md` | 8 px | Eingabefelder, Karten, Tabellen-Container |
| `--radius-lg` | 14 px | Große Flächen, Modale |
| Pill | 999 px | Buttons, Status-Chips |

### Schatten

| Token | Wert |
|---|---|
| `--shadow-sm` | `0 1px 2px rgba(0,8,84,0.06), 0 1px 1px rgba(0,8,84,0.04)` |
| `--shadow-md` | `0 6px 18px rgba(0,8,84,0.08), 0 2px 4px rgba(0,8,84,0.04)` |
| `--shadow-lg` | `0 24px 60px rgba(0,8,84,0.18), 0 8px 16px rgba(0,8,84,0.08)` |

Schatten sind immer blau eingefärbt, nie neutralschwarz, und werden sparsam eingesetzt. In Print, Office und Icons gar nicht.

---

## 5. Logo

Bild- und Wortmarke werden grundsätzlich als Einheit gesetzt. Die Bildmarke allein ist ausschließlich als Social-Media-Profilbild zulässig. Der Slogan steht stets unterhalb, in Caveat, in Türkis oder Weiß.

### Varianten

| Variante | Datei | Farbe der Datei | Einsatz |
|---|---|---|---|
| Vorzugsversion | `assets/logo/itk-logo-rgb.svg` | mehrfarbig | Standard auf Weiß und Papier – **und auf Dunkelblau**, siehe unten |
| Einfarbig Dunkelblau | `assets/logo/itk-logo-dunkelblau.svg` | `#000854` | Helle Untergründe, wenn einfarbig gewünscht – Dokumentköpfe, Fax, Stempel |
| Negativ | `assets/logo/itk-logo-negativ.svg` | `#ffffff` | Dunkle Untergründe – auf **Tiefblau und Türkis verbindlich**, auf Dunkelblau eine von zwei Möglichkeiten |
| Bildmarke solo | `assets/logo/itk-bildmarke.svg` | mehrfarbig | Ausschließlich Social-Media-Profilbild |
| CMYK für Druck | `assets/logo/itk-logo-cmyk.eps` | CMYK | Druckerei, professionelles PDF |

Achtung bei der Zuordnung: `itk-logo-dunkelblau.svg` ist das Logo **in** Dunkelblau und gehört auf helle Flächen. Für dunkle Flächen wird `itk-logo-negativ.svg` verwendet. Verwechslung macht das Logo unsichtbar.

### Die Logofarben sind eine dauerhafte Ausnahme von der Palette

Die Logodateien enthalten `#f8a100`, `#f9c24d` und `#b7b8b9` – nicht die Palettenwerte Orange `#f39200`, Hellorange `#ffbf33` und Hellgrau `#cccccc`. Das ist eine bewusste, dauerhafte Festlegung und **kein Fehler, der behoben werden soll**. Eine Angleichung an die Palette würde die Binnenkontraste innerhalb der Bildmarke verändern.

Daraus folgen zwei Regeln, die in beide Richtungen gelten:

1. **Das Logo wird nie umgefärbt** – auch nicht zur Angleichung an die Palette, auch nicht teilweise, auch nicht „nur ein bisschen“.
2. **Die Logofarben werden nie in die Gestaltung übernommen.** `#f8a100`, `#f9c24d` und `#b7b8b9` erscheinen ausschließlich innerhalb der Logodateien und nirgends sonst – nicht in Flächen, nicht in Text, nicht in Diagrammen, nicht als Akzent neben dem Logo.

Für alles außerhalb der Logodatei gilt ausnahmslos die Palette aus Abschnitt 2.

### Das farbige Logo auf dunklen Untergründen

Das farbige Logo ist nicht auf helle Flächen beschränkt. Es darf auf dunklen Untergründen stehen, wenn diese ausreichend dunkel sind.

**Der Prüfwert ist der Grauton der Wortmarke.** „IT-KOMPASS" ist in `#808080` gesetzt, also einem mittleren Grau. Es ist der schwächste Bestandteil des Logos und entscheidet damit über die Verwendbarkeit – Orange, Hellorange und Hellgrau sind auf dunklem Grund immer deutlich kräftiger.

**Bedingung:** `#808080` muss gegen den Untergrund mindestens **3 : 1** erreichen. Das entspricht einer relativen Helligkeit des Untergrunds von höchstens **0,04**.

| Untergrund | Kontrast der Wortmarke | Farbiges Logo |
|---|---|---|
| Dunkelblau `#000854` | 4,57 : 1 | **zulässig** |
| Tiefblau `#0026FF` | 1,95 : 1 | **nicht zulässig** |
| Türkis `#2FACB9` | unter 3 : 1 | **nicht zulässig** |

Tiefblau ist mit einer relativen Helligkeit von 0,086 rund zehnmal heller als Dunkelblau mit 0,008 – ein Signalblau, kein dunkler Grund. Auf Tiefblau und Türkis gilt weiterhin ausschließlich die Negativvariante.

**Auf dunklen Fotos** ist das farbige Logo zulässig, wenn die Fläche unter Logo und Schutzraum ruhig ist und ihre **hellste Stelle** die relative Helligkeit von 0,04 nicht überschreitet. Gemessen wird die hellste Stelle, nicht der Durchschnitt – ein einzelner heller Bereich unter der Wortmarke genügt, um sie unlesbar zu machen.

**Im Zweifel die Negativvariante.** Sie ist auf jedem dunklen Grund richtig, das farbige Logo nur auf dem sehr dunklen. Ähnliche dunkle Blautöne außerhalb der Palette werden nach demselben Kriterium geprüft, nicht nach Augenmaß.

### Schutzraum und Mindestgrößen

- Schutzraum: **eine Höheneinheit der Bildmarke** auf allen vier Seiten. Innerhalb dieses Bereichs stehen keine Texte, Grafiken oder anderen Elemente.
- Mindestbreite Print: **25 mm**
- Mindestbreite Digital: **120 px**

### Verboten

- Logo auf Orange oder ähnlichen Warmtönen
- Logo auf grauen oder unruhigen Flächen
- **Farbiges Logo auf Tiefblau, Türkis oder mitteldunklen Flächen** – dort verschwindet die graue Wortmarke
- Farbiges Logo auf unruhigen dunklen Fotos
- Verzerren, Dehnen, Stauchen
- Drehen oder Kippen
- Eigene Farbvarianten, Effekte, Schatten oder Umrandungen

---

## 6. Key Visual – Konturlinien-Topografie

Das visuelle Herzstück: konzentrische Konturlinien wie auf topografischen Karten. Metapher für Orientierung – aus undurchsichtigem Gelände einen klaren Weg sichtbar machen.

### Konstruktionsregeln

1. **Sechseck als Basis** – alle Winkel und Formen sind aus dem Sechseck abgeleitet.
2. **Konzentrische Radien** – gleichbleibende Abstände zwischen den Linien.
3. **Konstante Strichstärke** – kein Gewichtswechsel innerhalb einer Liniengruppe, genaue Deckung bei Überlagerungen.
4. **Gleiche Deckkraft für alle Linien.** Es gibt keinen Verlauf von innen nach außen. Jede Konturlinie eines Clusters ist gleich stark; der sichtbare Verlauf entsteht ausschließlich durch das Ausblenden der Gesamtkonstruktion am Rand.
5. **Keine Glows, kein Chaos** – konstante Steps, definierte Breaks, weiches Auslaufen an den Enden.

### Einsatz

| Untergrund | Linienfarbe | Deckkraft |
|---|---|---|
| Dunkelblau | Türkis `#2FACB9` | **28 %** |
| Weiß oder Papier | Hellgrau `#CCCCCC` | **30 %** |
| Fokuszone | Orange als Sechseck-Highlight | volldeckend, zählt zur Orange-Regel |

Die Werte sind am Designsystem und an der Website gemessen und ergeben im Ergebnis Linien von `#0D3570` auf Dunkelblau und `#F0F0F0` auf Weiß. Sie sind Sollwerte, keine Näherungen – nicht nach Gefühl anpassen.

Auf hellem Grund ist Hellgrau die Regel. Türkis auf Weiß ist bewusst **nicht** vorgesehen, auch nicht in geringer Deckkraft.

### Cluster-Positionen

Vier Randpositionen, Ankerpunkt jeweils in der Mitte des Randes: **ARC_A** oben (`assets/keyvisual/arc-a.svg`), **ARC_BL** unten (`arc-bl.svg`), **ARC_L** links (`arc-l.svg`), **ARC_R** rechts (`arc-r.svg`). **Maximal drei Cluster pro Fläche.** Bögen laufen an den Enden sanft aus.

Die vier Bogen-Dateien liegen auf 500 × 500 Einheiten mit Strichstärke 1,8 und `currentColor` – Farbe also über das umgebende Element setzen.

### Fünf Regeln für die Platzierung

1. **Die Konstruktion wird weich ausgeblendet**, nicht hart abgeschnitten – und zwar **gerichtet zum Flächeninneren hin**. An der Kante, an der das Cluster verankert ist, behält es seine volle Stärke und läuft aus der Fläche heraus; nach innen löst es sich auf.

   Entscheidend ist die Form der Maske, nicht die Position. **Eine auf die Grafik zentrierte Radialmaske ist falsch** – sie macht die Mitte am stärksten und blendet nach allen Seiten aus. Damit kann die Grafik keine Kante erreichen und wirkt als schwebendes Objekt mit Schein. Genau das ist der häufigste Fehler.

   Richtig ist eine Maske, deren Mittelpunkt **am Ankerpunkt** liegt, also außerhalb oder am Rand der Fläche.
2. **Großflächig und eckverankert, nicht zentriert.** Das Key Visual ist Grund, nicht Figur. Ein Cluster sitzt in einer Ecke und darf über die Fläche hinausragen. Ein mittig platzierter, allseitig sichtbarer Cluster liest sich als Emblem und tritt in Konkurrenz zur Überschrift.
3. **Der Bogen muss sichtbar sein.** Zeigt der Ausschnitt nur die geraden Schenkel, wirkt das Key Visual wie ein Vorhang. Die Krümmung ist das Erkennungsmerkmal und muss im Bild liegen.
4. **Text darf über dem Key Visual liegen.** Weil das Cluster nur mit 28 bzw. 30 Prozent Deckkraft und damit sehr geringem Kontrast zum Grund erscheint, beeinträchtigt es die Lesbarkeit nicht. Das Cluster darf deshalb frei über die Fläche laufen und auch hinter Überschriften und Fließtext liegen.

   Die Grenze ist die Deckkraft: **An keiner Stelle darf das Key Visual über 50 Prozent kommen.** Das begrenzt insbesondere Überschneidungen – siehe Regel 5.
5. **Zwei Cluster dürfen sich überlagern** – ganze Elemente, nicht einzelne Linien. Die Überschneidungszone wird dadurch heller und trägt die Betonung; dort liegt gegebenenfalls das Fokus-Sechseck. Die Obergrenze von 50 Prozent entscheidet, wo Überlagerung zulässig ist: Zwei Lagen à 28 Prozent ergeben zusammen rund 48 Prozent und sind erlaubt. Zwei Lagen à 30 Prozent ergeben rund 51 Prozent und sind es nicht. **Überlagerung also nur auf dunklem Grund**, auf hellem Grund immer nur ein Cluster.

Höchstens drei Cluster pro Fläche, in der Regel eines oder zwei.

**Umsetzung:** `scripts/keyvisual.py` erzeugt die Grafik regelkonform – gleiche Deckkraft, Randausblendung, optionale Überlagerung. Die SVG-Dateien nicht direkt platzieren, ohne die Ausblendung zu ergänzen; im Web über `mask-image` mit einem Verlauf.

### Fokus-Sechseck

**Das Fokus-Sechseck wird nur eingesetzt, wenn es etwas zu fokussieren gibt** – ein Foto, eine Aussage, ein Zitat, eine einzelne Zahl. Ohne Bezugsobjekt ist es Dekoration und entfällt. Ein Titel allein ist kein Bezugsobjekt; auf Titelseiten also nur die Konturlinien.

Wird es eingesetzt, sitzt es **deckungsgleich in der innersten Konturlinie**: gleiche Darstellungsgröße, gleiche Strichstärke, nicht skaliert, nicht verschoben. Ein größer gesetztes oder stärker gestrichenes Sechseck liest sich als Ornament und verfehlt den Zweck.

Höchstens ein Fokus-Sechseck pro Motiv.

`hexagon-fokus.svg` ist die einzige Datei mit fest eingetragener Farbe (`#f39200`) und ohne `currentColor`. Das ist gewollt – das Fokus-Sechseck ist immer orange. Es zählt zur Orange-Regel aus Abschnitt 2.

Es liegt auf derselben Zeichenfläche wie die Bögen (500 × 500) und übernimmt deren Geometrie: Kantenwinkel **32,42°**, halbe Breite 86,6, Spitze bei (250, 170), Eckenrundung 18 Einheiten, Strichstärke 1,8. Die obere Hälfte deckt sich damit mit der innersten Konturlinie.

**Bögen und Sechseck werden ohne Umrechnung übereinandergelegt** – gleiche Darstellungsgröße, keine Skalierung, keine Anpassung der Strichstärke. Das Sechseck ist **kein regelmäßiges Sechseck**: Ein regelmäßiges hätte 30°-Kanten und würde die Konturlinien schneiden. Wird das Sechseck neu gezeichnet, ist der Winkel von 32,42° einzuhalten.

Pro Motiv höchstens ein Fokus-Sechseck.

---

## 7. Icons

Es gibt zwei getrennte Sets mit unterschiedlichen Regeln.

**Pro Themenblock oder Abschnitt gilt nur eine Sorte.** Ein Dokument darf beide verwenden, aber nicht innerhalb desselben Blocks – und die beiden Sorten stehen **nie unmittelbar nebeneinander**. Sie sind für unterschiedliche Größen gezeichnet und in derselben Reihe sofort als Stilbruch erkennbar.

### UI-Icons – `assets/icons/ui-icons/`

Funktionale Icons für Bedienelemente, Listen, Navigation, Hinweise und Tabellen.

39 Icons, Raster 24 × 24 px · Strichstärke **1,4** · runde Linienenden und -ecken · `fill="none"` · keine Schatten.

Einsatzgrößen 16, 20, 24 und 32 px. Unter 16 px nicht verwenden.

**Variante ohne Box** – `assets/icons/ui-icons/`, Standard. Für Icons, die neben oder in Text stehen: Buttons, Aufzählungen, Tabellenzellen, Formularhinweise, Fließtext.

**Variante mit Box** – `assets/icons/ui-icons/boxed/`. Dieselben 39 Icons, Raster 40 × 40 px, umschließende Kontur mit Radius 9 px, Innenabstand 8 px. Für Icons, die allein und ohne begleitenden Text als eigenständiges Element auftreten: Karten-Kopfzeilen, Kacheln, Icon-Raster, Navigationsflächen. Die Box ersetzt den Rahmen, den solche Elemente sonst bräuchten.

Die Box-Variante wird bei **40 px** eingesetzt, Untergrenze 32 px. Kontur und Icon haben dieselbe Strichstärke und dieselbe Farbe. Die Box wird nicht separat eingefärbt, nicht gefüllt und nicht mit Schatten versehen. Kein zusätzlicher CSS- oder Office-Rahmen um das Element.

Innerhalb eines Rasters, einer Liste oder einer Kachelgruppe gilt durchgehend dieselbe Variante. Boxed und nicht-boxed nebeneinander in derselben Gruppe ist unzulässig.

### Steht ein UI-Icon allein, braucht es eine Fassung

Als eigenständiges Element – Themenkachel, Kartenkopf, Rasterfeld – erscheint ein UI-Icon **nie frei auf der Fläche**, sondern in einer von genau zwei Fassungen:

**Fassung A – Rahmen.** Die Box-Variante aus `assets/icons/ui-icons/boxed/`. Kontur und Icon in derselben Farbe und Strichstärke, keine Füllung, kein zusätzlicher Rahmen.

**Fassung B – getönte Fläche ohne Rahmen.** Eine gefüllte Kachel in einer Akzentfarbe bei geringer Deckkraft, darin das Icon in derselben Akzentfarbe volldeckend.

| Maß | Wert |
|---|---|
| Füllung der Kachel | Akzentfarbe bei **10 %** Deckkraft |
| Iconfarbe | dieselbe Akzentfarbe, volldeckend |
| Rahmen | **keiner** |
| Eckradius | `--radius-lg`, also 14 px bei einer 60-px-Kachel – rund 20 % der Kachelbreite |
| Kachelgröße | **2,5 × Iconkantenlänge**, bei 24 px Icon also 60 px Kachel |

Zulässige Akzentfarben für die Tönung: Türkis, Tiefblau, Dunkelblau. **Orange höchstens für eine Kachel je Gruppe** – die 10-Prozent-Tönung ist von der Regel „Orange nie als Fläche“ ausgenommen, weil sie bei dieser Deckkraft als Tonwert und nicht als Farbfläche wirkt. Zwei orange Kacheln nebeneinander heben diese Ausnahme auf.

**Die beiden Fassungen werden nicht gemischt.** Eine Gruppe ist entweder gerahmt oder getönt.

Ein Hinweis zur Lesbarkeit: Ein orangefarbenes Icon auf einer orange getönten Kachel erreicht nur etwa 2,3 : 1 Kontrast und liegt damit unter dem Mindestwert von 3 : 1 für bedeutungstragende Grafik. Diese Fassung ist deshalb nur zulässig, **wenn eine Beschriftung neben oder unter der Kachel steht** und die Bedeutung trägt. Als alleiniger Bedeutungsträger – etwa als Schaltfläche ohne Text – ist die getönte Fassung nicht geeignet.

Es gibt **keine Flächen-Varianten**. Frühere Dateien mit der Endung `-filled` wurden entfernt, weil sie dem Linien-Stil widersprechen. Für die betroffenen Motive gelten `cloud.svg`, `shield.svg` bzw. `shield-check.svg`, `wrench.svg` und `zap.svg`.

### Brand-Icons – `assets/icons/brand-icons/`

Illustrative Linien-Icons für inhaltliche Bebilderung – Leistungsübersichten, Themenkacheln, Folien, Datenblätter.

76 Icons, Zeichenfläche rund 500 × 500 Einheiten, Voreinstellung 48 px, Strichstärke 20 Einheiten.

- **Immer ohne Box.** Es gibt keine Box-Variante und es wird keine gebaut – auch nicht durch Untersetzen eines Rahmens, Kreises oder Sechsecks.
- **Mindestkantenlänge 48 px**, im Druck **13 mm**. Darunter laufen die Innenlinien zu: Zahnräder werden Klumpen, Sterne verlieren die Zacken, Textzeilen verschmelzen zu Balken.
- **Empfohlener Bereich 48 bis 96 px.**
- **Elf Icons erst ab 96 px.** Sie sind so detailreich, dass sie darunter Innenzeichnung verlieren: `speichervirtualisierung`, `trojaner`, `webinar`, `sales-gespraech`, `notiz_speicherung`, `firewall`, `pdf-anleitungen`, `verschluesselung-backup`, `software`, `guenstiger-preis`, `teams-smartphone`.
- **Wo weniger als 48 px Platz ist, gehört kein Brand-Icon hin, sondern ein UI-Icon.** Das ist keine Notlösung, sondern die eigentliche Aufteilung: UI-Icons sind für 24 px gezeichnet, Brand-Icons für 500. Ein Brand-Icon auf 32 px zu setzen heißt, eine Zeichnung um den Faktor 15 zu verkleinern.
- Nicht als Ersatz für UI-Icons in Bedienelementen verwenden – ein Brand-Icon in einem Button ist zu detailliert.

Die Grenze von 48 px ist gemessen, nicht geschätzt: Für jedes Icon wurde die engste von Linien eingeschlossene Lücke bestimmt und daraus die Größe berechnet, bei der sie noch mindestens 1,2 Pixel breit bleibt. 42 der 74 Icons sind bei 48 px vollkommen unkritisch, die übrigen verlieren feine Innenzeichnung, bleiben aber erkennbar. Die elf oben genannten nicht.
- Die Dateinamen sind inhaltlich benannt und gemischt mit Bindestrich und Unterstrich geschrieben (`browser-plugin.svg`, `cloud_computing.svg`). Vor dem Einbinden den Ordner auflisten, nicht raten.

### Farbe – für beide Sets

Alle Icons außer den vier Filled-Varianten führen `stroke="currentColor"`. Die Farbe wird über die Textfarbe des umgebenden Elements gesetzt und ist **immer ausdrücklich anzugeben** – ohne Angabe erbt das Icon eine beliebige Farbe aus dem Kontext.

| Untergrund | Strichfarbe |
|---|---|
| Hell | Dunkelblau, Tiefblau oder Türkis |
| Dunkel | Hellblau oder Weiß |

### Verboten

Filled- oder Solid-Stile · gemischte Icon-Stile in einem Dokument · Emoji als Icon-Ersatz · Icons aus fremden Bibliotheken, wenn ein passendes im Set vorhanden ist · Verzerren oder ungleichmäßiges Skalieren · Box um ein Brand-Icon.

---

## 8. Bildsprache

Grafik führt, Bild unterstützt. Fotografie ist eine eingebettete Ebene, nie das Hauptelement.

**So ja:** direkter Bezug zu IT und Arbeitsalltag · authentische Motive mit menschlicher Wärme · maximal zwei bis drei Personen pro Motiv · spannende Blickwinkel statt Frontalperspektive · Hausfarben fließen in die Bildbearbeitung ein.

**So nicht:** gestellte High-Fives · Hochglanz-Konferenzräume · direktes Kameralächeln (Ausnahme Recruiting und Unternehmenskultur) · bunte Farbverläufe als Bildhintergrund · Frosted-Glass- oder Glas-Optik · Bilder als dominantes Element.

### Layer-System

Überlagerung statt Verbindung – Komplexität wird räumlich lesbar gemacht, nicht wegdesignt. Ebenen sind matt, gestaffelt über definierte Opazitätsbänder, ohne harte Grenzen und ohne Glasoptik.

---

## 9. Tabellen

Es gibt genau **zwei verbindliche Tabellenstile** und eine begrenzte Sonderform. Wähle nach Dokumentcharakter, nicht nach Geschmack.

### Stil A – Vollton-Kopf (kräftig)

Für Übersichten, Leistungsvergleiche, Statuslisten, alles mit Signalcharakter.

- Kopfzeile: Fläche Dunkelblau `#000854`, Beschriftung im Eyebrow-Stil in Hellblau `#83CFED`
- Zeilen im Wechsel Weiß und Papier `#F5F7FB`
- Nur waagerechte Trennlinien, 1 px Hellgrau `#CCCCCC` – **keine senkrechten Linien**
- Optionale Summenzeile: 2 px Oberkante in Dunkelblau, Text Dunkelblau Bold
- Container-Radius 8 px, obere Ecken der Kopfzeile mit gerundet
- Statuswerte: Grün oder Rot als Text, Orange nur als Chip mit dunkelblauer Schrift

### Stil B – Basislinie (dezent)

Für Angebote, Protokolle, Anhänge, Fließtext-Dokumente – überall, wo die Tabelle nicht dominieren soll.

- **Keine Flächen, keine Gitterlinien, keine Rahmen**
- Einzige Linie: 1 px Türkis `#2FACB9` unter der Kopfzeile
- Kopfzeile im Eyebrow-Stil in Türkis
- Zellen ohne Trennlinien – die Struktur entsteht durch Zeilenabstand (mindestens 12 px bzw. 4 pt Abstand über der Zelle)
- Fließtext in Dunkelgrau `#333333`

### Sonderform – Dunkelgrund

Tabelle vollflächig auf Dunkelblau, Kopfzeile in Türkis mit 2 px Unterkante, Werte in Weiß und Hellblau, Trennlinien Hellblau bei 22 % Deckkraft.

**Nur zulässig in Web und auf Präsentationsfolien.** In Word, Excel und Druck-PDF nicht verwenden – dunkle Vollflächen sind im Druck problematisch und beim Kopieren von Zeilen fehleranfällig.

### Regeln für alle Tabellen

- **Zahlen, Mengen und Beträge rechtsbündig**, Text linksbündig. Das ist Lesbarkeit, keine Geschmacksfrage: nur untereinanderstehende Einerstellen lassen sich vergleichen.
- Einheiten in die Spaltenüberschrift, nicht in jede Zelle
- Keine senkrechten Linien, keine Rahmen um die Gesamttabelle außer dem Container-Radius bei Stil A
- Keine Schatten, keine 3D-Effekte, keine farbigen Zellen zur Dekoration
- Abgerundete Zellecken sind in Word, Excel und PowerPoint technisch nicht möglich. Dort Stil A mit eckigen Flächen umsetzen und nicht versuchen, Rundungen nachzubauen.

---

## 10. Diagramme

- **Farbreihenfolge der Datenreihen:** 1. Dunkelblau `#000854` · 2. Türkis `#2FACB9` · 3. Hellblau `#83CFED` · 4. Tiefblau `#0026FF` · 5. Hellgrau `#CCCCCC`
- **Orange nur zur Hervorhebung einer einzigen Reihe oder eines einzigen Datenpunkts** – nie als reguläre Reihenfarbe
- Grün und Rot ausschließlich, wenn die Reihe tatsächlich Erfolg oder Warnung bedeutet
- Gitterlinien: nur waagerecht, 0,5 pt Hellgrau. Keine senkrechten Gitterlinien, kein Rahmen um die Zeichenfläche
- Achsenbeschriftung Dunkelgrau, Eyebrow-Stil für Achsentitel
- Keine 3D-Effekte, keine Schatten, keine Verläufe in Flächen, keine Muster-Füllungen
- Legende weglassen, wenn nur eine Datenreihe vorhanden ist – dann direkt beschriften
- Datenlabels bevorzugen gegenüber einer Werteachse, wenn es wenige Werte sind

---

## 10b. Wiederkehrende Inhaltsmuster

Zwei Muster fallen in jedem Medium an. Sie sind hier medienneutral festgelegt; die Umsetzung steht in der Referenz des Zielmediums.

### Merksatz

Ein hervorgehobener Satz, der die Kernaussage eines Abschnitts trägt.

| Merkmal | Vorgabe |
|---|---|
| Aufbau | Akzentkante links in Türkis, daneben der Satz |
| Fläche | **keine** – kein Hintergrund, kein Rahmen |
| Kantenstärke | 3 pt |
| Schriftgröße | eine Stufe über dem Fließtext, Gewicht Regular |
| Farbe | Dunkelblau auf hellem Grund, Weiß auf dunklem |
| Menge | einer je Abschnitt, höchstens zwei je Dokument |
| Länge | ein bis zwei Sätze |

Der Unterschied zum Hinweiskasten ist die Fläche: Der Kasten hat eine weiße Fläche mit Rahmen und trägt Zusatzinformation, der Merksatz hat nur eine Kante und trägt die Hauptaussage. Wird ein Merksatz länger als zwei Sätze, gehört der Inhalt in den Fließtext oder in einen Kasten.

### Prozessschritte

Ein Ablauf in nummerierten Etappen, nebeneinander.

| Merkmal | Vorgabe |
|---|---|
| Anzahl | zwei bis **vier** Etappen |
| Aufbau je Etappe | dünne Oberkante in Hellgrau, darunter Nummer, Titel, Erläuterung |
| Nummer | Türkis, Gewicht Black, zwei Stufen über dem Fließtext |
| Titel | Dunkelblau, Bold, eine Stufe über dem Fließtext |
| Erläuterung | Fließtextgröße, Dunkelgrau |
| Trennung | ausschließlich die Oberkante |

**Verboten**, weil es sich bei Ablaufgrafiken sonst zuverlässig einschleicht: Kreise oder gefüllte Punkte um die Nummer, Verbindungslinien oder Pfeile zwischen den Etappen, Rahmen um die Spalten, farbige Flächen hinter den Etappen, Schatten.

Bei fünf und mehr Etappen wird der Ablauf eine Tabelle nach Stil B – nebeneinander werden die Spalten sonst zu schmal.

## 11. Prüf-Checkliste

Bei HTML zuerst das Prüfskript laufen lassen, es erledigt die zählbaren Punkte automatisch:

    python3 scripts/pruefen.py seite.html --assets assets

Danach in jedem Fall diese Liste durchgehen – sie enthält auch, was kein Skript sehen kann:

- [ ] Nur Farben aus der Palette in Abschnitt 2 verwendet?
- [ ] Orange an maximal zwei Stellen und nicht als Hintergrundfläche?
- [ ] Text auf Orange in Dunkelblau, nicht in Weiß?
- [ ] Weiße Schrift ausschließlich auf Dunkelblau oder Tiefblau?
- [ ] Fließtext auf dunklem Grund weiß, Hellblau nur für Sublines und Hervorhebungen?
- [ ] Bei Konturbuttons Schriftfarbe gleich Konturfarbe?
- [ ] Lato verwendet, sonst Arial als Fallback – kein Calibri?
- [ ] Großbuchstaben nur im Eyebrow?
- [ ] Alle Abstände Vielfache von 4?
- [ ] In Textdokumenten nur die drei Abstandsstufen 8 / 24 / 48 pt, keine Zwischenwerte?
- [ ] Abstände nicht addiert, sondern der größere angewendet?
- [ ] Textspalte höchstens 140 mm bzw. 85 Zeichen, Zeilenabstand 1,5?
- [ ] Nummerierte Überschriften mit Nummer im Außenrand, alle Textzeilen auf einer Kante?
- [ ] Logo als Originaldatei aus `assets/logo/` verwendet, nicht nachgebaut?
- [ ] Richtige Logovariante – Negativ auf dunklem, nicht Dunkelblau auf dunklem Grund?
- [ ] Farbiges Logo nur auf Weiß, Papier, Dunkelblau oder sehr dunklen ruhigen Fotos?
- [ ] Logo mit Schutzraum, über Mindestgröße, nicht verzerrt, nicht auf Orange oder Grau?
- [ ] Key Visual mit konstanter Strichstärke, maximal drei Cluster?
- [ ] Alle Konturlinien gleich stark, Verlauf nur durch die Randausblendung?
- [ ] Ausblendung gerichtet zum Flächeninneren, Maske am Ankerpunkt statt in der Grafikmitte?
- [ ] Bogen sichtbar, nicht nur die geraden Schenkel?
- [ ] Key Visual nirgends über 50 % Deckkraft, auch nicht in Überschneidungen?
- [ ] Deckkraft 28 % auf Dunkelblau bzw. 30 % Hellgrau auf hellem Grund?
- [ ] Key Visual eckverankert, nicht mittig als Emblem?
- [ ] Fokus-Sechseck nur mit Bezugsobjekt und deckungsgleich in der innersten Kontur?
- [ ] Box-Variante innerhalb einer Gruppe durchgehend gleich?
- [ ] Brand-Icons ohne Box und mindestens 48 px bzw. 13 mm groß?
- [ ] Keines der elf detailreichen Brand-Icons unter 96 px?
- [ ] Unter 48 px ein UI-Icon statt eines Brand-Icons?
- [ ] Pro Abschnitt nur eine Icon-Sorte, die Sorten nirgends nebeneinander?
- [ ] Einzeln stehende UI-Icons gerahmt oder getönt, nicht frei auf der Fläche?
- [ ] Getönte Kacheln mit 10 % Füllung, ohne Rahmen, Icon in derselben Farbe?
- [ ] Icon-Strichfarbe ausdrücklich gesetzt, keine geerbte Farbe?
- [ ] Keine der vier Filled-Icon-Varianten verwendet?
- [ ] Logofarben nicht in die Gestaltung übernommen und Logo nicht umgefärbt?
- [ ] Tabelle nach Stil A oder Stil B, ohne senkrechte Linien, Zahlen rechtsbündig?
- [ ] Diagramm ohne 3D, ohne Schatten, Farbreihenfolge eingehalten?
- [ ] Merksatz ohne Fläche und Rahmen, nur mit Akzentkante?
- [ ] Prozessschritte höchstens vier, ohne Kreise, Pfeile, Rahmen oder Flächen?
- [ ] Keine Verläufe mit Warmanteil, keine Glasoptik, keine Glows?
- [ ] Texte inhaltlich unangetastet gelassen – nur Mikrotypografie geprüft?
- [ ] Passende Referenzdatei für das Zielmedium gelesen und deren Formatvorgaben eingehalten?
