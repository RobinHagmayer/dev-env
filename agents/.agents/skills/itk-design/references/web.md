# Web, HTML und Newsletter

Ergänzung zu `SKILL.md`. Diese Datei enthält die konkreten CSS-Werte. Keine Farb- oder Größenwerte hart in Komponenten schreiben – immer über die Tokens.

## Geltungsbereich

Diese Datei gilt für **HTML-Dokumente zu einem abgegrenzten Thema** – Onepager, Infoblatt, Themenübersicht – und für Newsletter. Nicht für Webseiten, Unterseiten von it-kompass.com, Navigation oder mehrseitige Strukturen. Siehe `SKILL.md`, Abschnitt Zweck.

**Die Bausteinliste ist geschlossen.** Zulässig sind ausschließlich die unten beschriebenen Bausteine: Tokens, Schrifteinbindung, Layout-Container, Abschnittshintergründe, Typografie, Buttons, dunkle Flächen, Badges, Eingabefelder, Feature Card, Hinweiskasten, Merksatz, Prozessschritte, Tabellen in den Stilen A und B, Key Visual und Icon-Kachel. Ausdrücklich nicht zulässig ist eine Ansprechpartner-Karte, siehe Abschnitt 8d. Fehlt ein Muster, wird der nächstliegende dokumentierte Baustein verwendet. Passt keiner, ist darauf hinzuweisen – **es wird kein neuer Baustein erfunden**. Ein Dokument, das eigene Gestaltungselemente einführt, verlässt den Designkorridor, auch wenn Farben und Schrift stimmen.

## Inhalt

1. Tokens
1b. Schrifteinbindung
2. Layout
3. Typografie in CSS
4. Buttons
4b. Dunkle Flächen
5. Badges und Status
6. Eingabefelder
7. Feature Card
8. Hinweise und Alerts
8b. Merksatz
8c. Prozessschritte
8d. Nicht zulässig: Ansprechpartner-Karte
9. Tabellen
10. Key Visual
10b. Mobile Schriftstufen
11. Vor der Abgabe prüfen
12. Newsletter – Sonderfall

---

## 1. Tokens

```css
:root {
  --c-dunkelblau: #000854;
  --c-tiefblau:   #0026FF;
  --c-orange:     #f39200;
  --c-hellorange: #FFBF33;
  --c-tuerkis:    #2FACB9;
  --c-hellblau:   #83CFED;
  --c-dgrau:      #333333;
  --c-hgrau:      #CCCCCC;
  --c-rot:        #ff5500;
  --c-gruen:      #3caa31;
  --c-white:      #ffffff;
  --c-paper:      #F5F7FB;
  --c-ink:        #0A0F2C;

  --space-1:  4px;
  --space-2:  8px;
  --space-3:  12px;
  --space-4:  16px;
  --space-6:  24px;
  --space-8:  32px;
  --space-12: 48px;
  --space-16: 64px;
  --space-24: 96px;

  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 14px;
  --radius-pill: 999px;

  --shadow-sm: 0 1px 2px rgba(0,8,84,0.06), 0 1px 1px rgba(0,8,84,0.04);
  --shadow-md: 0 6px 18px rgba(0,8,84,0.08), 0 2px 4px rgba(0,8,84,0.04);
  --shadow-lg: 0 24px 60px rgba(0,8,84,0.18), 0 8px 16px rgba(0,8,84,0.08);
}
```

## 1b. Schrifteinbindung

**Lato und Caveat werden selbst gehostet.** Die Schriftdateien liegen in `assets/fonts/` und werden mit der Datei ausgeliefert oder im Zielprojekt abgelegt.

```css
@font-face { font-family: 'Lato'; font-weight: 400; font-display: swap;
             src: url('fonts/Lato-Regular.ttf') format('truetype'); }
@font-face { font-family: 'Lato'; font-weight: 700; font-display: swap;
             src: url('fonts/Lato-Bold.ttf') format('truetype'); }
@font-face { font-family: 'Lato'; font-weight: 900; font-display: swap;
             src: url('fonts/Lato-Black.ttf') format('truetype'); }
```

**Keine Einbindung über Google Fonts oder ein anderes fremdes CDN.** Beim Laden einer Schrift von einem fremden Server wird die IP-Adresse des Besuchers dorthin übertragen. Für ein deutsches Unternehmen ist das ohne Einwilligung datenschutzrechtlich angreifbar – das Landgericht München I hat 2022 in dieser Konstellation Schadensersatz zugesprochen. Das gilt auch für eine Datei, die nur per Mail weitergegeben wird, sobald sie in einem Browser geöffnet wird.

Ist ein Mitliefern der Schriftdateien nicht möglich, wird **ohne Webfont** gearbeitet: `font-family: 'Lato', Arial, sans-serif`. Dann greift auf Firmengeräten das installierte Lato und anderswo Arial. Das ist zulässig – eine Einbindung von einem fremden Server ist es nicht.

Die OFL verlangt, dass die Lizenzdatei mitgeführt wird. Werden die Schriftdateien weitergegeben, gehört `OFL.txt` dazu.

## 2. Layout

```css
body { font-family: 'Lato', Arial, sans-serif; color: var(--c-ink); background: var(--c-paper); font-weight: 400; line-height: 1.55; }
.wrap { max-width: 1280px; margin: 0 auto; padding: 0 var(--space-12); }
@media (max-width: 720px) { .wrap { padding: 0 20px; } }
```

Abschnittsabstände: 96 px oben und unten auf Desktop, 48 px auf Mobil.

Für Abschnittshintergründe die beiden Klassen verwenden, keine Inline-Styles:

```css
.bg-weiss  { background: var(--c-white); }
.bg-papier { background: var(--c-paper); }
```

Weiß und Papier wechseln sich über die Abschnitte ab, damit die Gliederung ohne Linien erkennbar wird. Dunkle Abschnitte tragen `.on-dark` (Abschnitt 4b). Andere Hintergrundfarben sind nicht zulässig.

## 3. Typografie in CSS

```css
h1 { font-weight: 900; font-size: clamp(44px, 6.5vw, 88px); line-height: 1.0; letter-spacing: -0.02em; }
h2 { font-weight: 900; font-size: 48px; line-height: 50px; letter-spacing: -0.015em; }
h3 { font-weight: 700; font-size: 32px; line-height: 38px; }
h4 { font-weight: 700; font-size: 22px; line-height: 28px; }
.lead    { font-size: 18px; line-height: 28px; }
body     { font-size: 16px; line-height: 25px; }
.caption { font-size: 13px; line-height: 19px; }
.eyebrow { font-size: 11px; line-height: 14px; font-weight: 700; letter-spacing: 0.18em; text-transform: uppercase; color: var(--c-tuerkis); }
```

Der Eyebrow bekommt optional eine 28 px breite, 1 px hohe Vorlauflinie in Türkis über `::before`.

## 4. Buttons

Basis für alle Varianten:

```css
.btn {
  font-family: 'Lato', sans-serif; font-weight: 700;
  border-radius: var(--radius-pill);
  padding: 12px 22px;
  font-size: 14px;
  letter-spacing: 0.02em;
  border: 1px solid transparent;
  cursor: pointer;
  transition: all 0.15s ease;
  display: inline-flex; align-items: center; gap: 8px;
}
```

| Variante | Ruhezustand | Hover |
|---|---|---|
| `.btn-primary` | Fläche Orange, Schrift **Dunkelblau** | Fläche Hellorange, Schrift Dunkelblau |
| `.btn-secondary` | Fläche Dunkelblau, Schrift Weiß | Fläche Tiefblau, Schrift Weiß |
| `.btn-ghost` | transparent, 2 px Rand Dunkelblau, Schrift Dunkelblau | Fläche Dunkelblau, Schrift Weiß |
| `.btn-ghost-light` | transparent, 2 px Rand Hellorange, Schrift Hellorange | Fläche Hellorange, Schrift Dunkelblau |
| `.btn-ghost-white` | transparent, 2 px Rand Weiß, Schrift Weiß | Fläche Weiß, Schrift Dunkelblau |
| `.btn-link` | transparent, Schrift Tiefblau, kein waagerechtes Padding | Schrift Orange |

**Zwei Grundsätze:**

- Gefüllte Buttons: Schrift in Dunkelblau. Weiß auf Orange erreicht nur 2,4:1 und ist nicht zulässig.
- **Konturbuttons: Schriftfarbe gleich Konturfarbe.** Weiße Kontur, weiße Schrift. Hellorange Kontur, hellorange Schrift. Eine dritte Farbe macht den Button bunt.

Bei `.btn-ghost-white` im Hover Dunkelblau statt Türkis verwenden – die Fläche ist dann weiß.

### Kaskadenfalle: Linkregeln überschreiben Buttonfarben

Buttons sind in der Regel `<a>`-Elemente. Eine Linkregel wie `.on-dark a { color: var(--c-hellblau) }` hat die Spezifität (0,1,1) und schlägt damit `.btn-primary` mit (0,1,0) – **alle Buttons auf dunklem Grund bekommen dann Linkfarbe**, obwohl die Buttonregel korrekt geschrieben ist. Das ist von außen kaum zu sehen und im Code leicht zu übersehen.

Deshalb Linkregeln immer Buttons ausnehmen:

```css
.on-dark a:not(.btn) { color: var(--c-hellblau); }
```

Nach jeder Änderung an Linkfarben die Buttons im Rendering nachsehen, nicht nur im CSS.

**Pro Dokument ein Primary Button**, nicht pro Abschnitt und nicht pro Bildschirmausschnitt. Ein Onepager mit sieben Abschnitten hat genau einen – die eine Handlung, die er auslösen soll. Alles Weitere ist Secondary, Ghost oder Link.

Wiederholt sich dieselbe Handlung am Ende noch einmal, ist die Wiederholung ein Ghost-Button, nicht ein zweiter Primary.

### Zustände, die ergänzt werden müssen

```css
.btn:focus-visible { outline: none; box-shadow: 0 0 0 3px rgba(0,38,255,0.35); }
.btn:disabled { background: var(--c-hgrau); color: #6b6b6b; border-color: transparent; cursor: not-allowed; }
.btn:active { transform: scale(0.98); }
```

Der Fokusring ist Tiefblau und gilt für alle interaktiven Elemente, nicht nur Buttons. Er darf nie entfernt werden.

## 4b. Dunkle Flächen

```css
.on-dark { background: var(--c-dunkelblau); color: var(--c-white); }
.on-dark .lead { color: var(--c-white); }          /* nicht hellblau */
.on-dark .eyebrow { color: var(--c-hellblau); }
.on-dark .subline, .on-dark .caption { color: var(--c-hellblau); }
.on-dark a:not(.btn) { color: var(--c-hellblau); }
.on-dark em, .on-dark .mark { color: var(--c-hellblau); font-style: normal; }
```

**Fließtext und Lead-Absätze auf Dunkelblau sind weiß.** Hellblau ist für Sublines, Rollenbezeichnungen, Bildunterschriften, Links und die Hervorhebung einzelner Passagen. Wird der ganze Lead hellblau gesetzt, verliert die Farbe ihre Auszeichnungsfunktion.

## 5. Badges und Status

Pill-Form, 12 px, Bold, Padding 3 px 10 px.

| Bedeutung | Fläche | Schrift |
|---|---|---|
| Standard / funktional | Papier | Dunkelblau |
| In Bearbeitung | Hellblau | Dunkelblau |
| Aktiv / Erfolg | Hellgrün bei 15 % auf Weiß | Dunkelgrün-Variante oder Hellgrün ab 12 px Bold |
| Fokus | Orange | **Dunkelblau** |
| Kritisch | Hellrot bei 15 % auf Weiß | Hellrot ab 12 px Bold |

Auf dunklem Grund: Fläche in Weiß bei 12 % Deckkraft, Schrift Hellblau.

## 6. Eingabefelder

```css
.field {
  font-family: 'Lato', sans-serif; font-size: 16px;
  padding: 12px 16px;
  border: 1px solid var(--c-hgrau);
  border-radius: var(--radius-md);
  background: var(--c-white); color: var(--c-ink);
}
.field:hover { border-color: var(--c-tuerkis); }
.field:focus { outline: none; border-color: var(--c-tiefblau); box-shadow: 0 0 0 3px rgba(0,38,255,0.15); }
.field::placeholder { color: #8a8a8a; }
.field-hint { font-size: 13px; color: var(--c-dgrau); margin-top: var(--space-2); }
.field-error { border-color: var(--c-rot); }
```

Label immer sichtbar über dem Feld, 13 px Bold, Dunkelblau. Placeholder ersetzt kein Label.

## 7. Feature Card

Weiße Fläche, 1 px Rand Hellgrau, Radius 8 px, Padding 24 px, `--shadow-sm`. Aufbau von oben: Eyebrow · H4-Titel · Body · optionaler Link-Button. Icon im Linien-Stil oben links, 32 px, Dunkelblau. Im Hover Rand auf Türkis und `--shadow-md`.

### Icons einbinden

Icons als Inline-SVG einsetzen, nicht als `<img>` – nur inline lässt sich die Strichfarbe über CSS steuern.

```css
.icon { width: 24px; height: 24px; stroke-width: 1.4; fill: none; color: var(--c-dunkelblau); }
.icon-boxed { width: 40px; height: 40px; fill: none; color: var(--c-dunkelblau); }
.icon-brand { width: 48px; height: 48px; fill: none; color: var(--c-dunkelblau); }
.on-dark .icon, .on-dark .icon-boxed, .on-dark .icon-brand { color: var(--c-hellblau); }
```

Alle Icons führen `stroke="currentColor"`, die Farbe kommt also aus `color`. Diese Angabe ist Pflicht – ohne sie erbt das Icon eine beliebige Textfarbe.

Aus `assets/icons/ui-icons/` die Variante ohne Box für Buttons, Listen und Tabellen. Aus `assets/icons/ui-icons/boxed/` die Variante für Kacheln und Icon-Raster, dort mit `width: 40px; height: 40px` – und keinen zusätzlichen CSS-Rahmen um das Element legen, die Box ist der Rahmen.


Brand-Icons aus `assets/icons/brand-icons/` nie unter **48 px** rendern, auch nicht in responsiven Verkleinerungen. Reicht der Platz nicht, ein UI-Icon einsetzen statt das Brand-Icon zu verkleinern.

### Einzeln stehende UI-Icons: gerahmt oder getönt

```css
/* Fassung A: Rahmen – Box-Variante aus assets/icons/ui-icons/boxed/ */
.icon-boxed { width: 40px; height: 40px; fill: none; color: var(--c-dunkelblau); }

/* Fassung B: getoente Fläche, kein Rahmen. Kachel = 2,5 x Iconkante. */
.icon-tile {
  width: 60px; height: 60px; border-radius: var(--radius-lg);
  display: grid; place-items: center; border: none;
}
.icon-tile .icon { width: 24px; height: 24px; }
.icon-tile-tuerkis   { background: rgba(47,172,185,0.10);  color: var(--c-tuerkis); }
.icon-tile-tiefblau  { background: rgba(0,38,255,0.10);    color: var(--c-tiefblau); }
.icon-tile-dunkelblau{ background: rgba(0,8,84,0.10);      color: var(--c-dunkelblau); }
.icon-tile-orange    { background: rgba(243,146,0,0.10);   color: var(--c-orange); }
```

Die Tönung liegt bei **10 Prozent**, das Icon trägt dieselbe Farbe volldeckend, und die Kachel bekommt **keinen** Rahmen. Innerhalb einer Gruppe wird nicht zwischen den beiden Fassungen gewechselt. `.icon-tile-orange` höchstens einmal je Gruppe.

Getönte Kacheln nur mit Beschriftung daneben oder darunter – das Icon allein erreicht auf der Tönung nicht den Mindestkontrast für bedeutungstragende Grafik.


## 8. Hinweise und Alerts

Vier Stufen: Info, OK, Warn, Danger. Aufbau in beiden Themes identisch: Icon links · Eyebrow-Label mit Quelle · fette Kurzaussage · Body · rechts Zeitstempel in Caption.

| Stufe | Akzentfarbe |
|---|---|
| Info | Hellblau |
| OK | Hellgrün |
| Warn | Orange (zählt zur Orange-Regel) |
| Danger | Hellrot |

**Light Theme:** Fläche Weiß, 1 px Rand Hellgrau, 3 px linke Kante in der Akzentfarbe, Radius 8 px – bei einseitigem Rand die linken Ecken eckig lassen.

**Die Akzentkante bekommt keine eigene Kontur.** Der Rahmen umschließt nur die weiße Fläche; die farbige Kante ersetzt die linke Rahmenlinie und wird nicht zusätzlich umrandet. In CSS also `border: 1px solid var(--c-hgrau); border-left: 3px solid <akzent>` – nicht die Kante als eigenes Element mit eigenem Rand.
**Dark Theme:** Fläche Dunkelblau, Rand Hellblau bei 22 %, Text Weiß, sekundärer Text Hellblau.

## 8b. Merksatz

Ein hervorgehobener Satz im Textfluss, der die Kernaussage eines Abschnitts trägt. **Keine Fläche, kein Rahmen** – nur eine Akzentkante links. Das unterscheidet ihn vom Hinweiskasten, der eine weiße Fläche mit Rahmen hat.

```css
.pull {
  border-left: 3px solid var(--c-tuerkis);
  padding: 0 0 0 var(--space-6);
  margin: var(--space-8) 0;
  font-size: 22px; line-height: 28px; font-weight: 400;
  color: var(--c-dunkelblau);
}
.on-dark .pull { color: var(--c-white); }
```

Ein Merksatz je Abschnitt, höchstens zwei je Dokument. Länge: ein bis zwei Sätze. Wird er länger, gehört der Inhalt in den Fließtext oder in einen Hinweiskasten.

## 8c. Prozessschritte

Nummerierte Spalten für einen Ablauf in zwei bis vier Etappen.

```css
.steps { display: grid; grid-template-columns: repeat(4, 1fr); gap: var(--space-8); }
.step { border-top: 1px solid var(--c-hgrau); padding-top: var(--space-4); }
.step-num {
  font-size: 32px; line-height: 38px; font-weight: 900;
  color: var(--c-tuerkis); display: block; margin-bottom: var(--space-2);
}
.step h4 { font-size: 18px; line-height: 28px; font-weight: 700;
           color: var(--c-dunkelblau); margin: 0 0 var(--space-2); }
.step p  { font-size: 16px; line-height: 25px; color: var(--c-dgrau); margin: 0; }
@media (max-width: 720px) { .steps { grid-template-columns: 1fr; } }
```

Die Nummer steht in Türkis und ist das einzige farbige Element – kein Kreis, kein gefüllter Punkt, keine Verbindungslinie zwischen den Schritten. Die Oberkante ersetzt jede weitere Umrahmung.

**Höchstens vier Schritte.** Bei fünf und mehr wird der Ablauf zur Tabelle nach Stil B, sonst werden die Spalten zu schmal.

## 8d. Nicht zulässig: Ansprechpartner-Karte

Ein eigener Kontaktbaustein mit Name, Rolle, Mail und Telefon wird in HTML-Dokumenten **nicht gebaut**. Grund: Kontaktdaten unterliegen dem separaten Kontaktdaten-Skill, und ein zweiter Ort für dieselbe Information läuft mit der Zeit auseinander.

Stattdessen: Der Ansprechpartner steht im Fließtext oder im Schlussabsatz, formatiert nach den Regeln des Kontaktdaten-Skills. Ein Link auf die Kontaktseite ist ein normaler Link, keine Karte.

## 9. Tabellen

### Stil A – Vollton-Kopf

```css
.tbl-a { width: 100%; border-collapse: collapse; font-size: 14px; }
.tbl-a thead th {
  background: var(--c-dunkelblau); color: var(--c-hellblau);
  font-size: 11px; font-weight: 700; letter-spacing: 0.18em; text-transform: uppercase;
  text-align: left; padding: 11px 16px;
}
.tbl-a thead th:first-child { border-radius: var(--radius-md) 0 0 0; }
.tbl-a thead th:last-child  { border-radius: 0 var(--radius-md) 0 0; }
.tbl-a tbody td { padding: 12px 16px; color: var(--c-dgrau); border-bottom: 1px solid var(--c-hgrau); }
.tbl-a tbody tr:nth-child(even) { background: var(--c-paper); }
.tbl-a .num { text-align: right; font-variant-numeric: tabular-nums; }
.tbl-a tfoot td { border-top: 2px solid var(--c-dunkelblau); border-bottom: none; color: var(--c-dunkelblau); font-weight: 700; }
```

### Stil B – Basislinie

```css
.tbl-b { width: 100%; border-collapse: collapse; font-size: 14px; }
.tbl-b thead th {
  color: var(--c-tuerkis);
  font-size: 11px; font-weight: 700; letter-spacing: 0.18em; text-transform: uppercase;
  text-align: left; padding: 0 4px 10px; border-bottom: 1px solid var(--c-tuerkis);
}
.tbl-b tbody td { padding: 14px 4px 0; color: var(--c-dgrau); border: none; }
.tbl-b .num { text-align: right; font-variant-numeric: tabular-nums; }
```

### Sonderform Dunkelgrund

Container `background: var(--c-dunkelblau)`, Radius 8 px, Padding 22 px 24 px. Kopfzeile Türkis mit `border-bottom: 2px solid var(--c-tuerkis)`, Werte Weiß, Sekundärwerte Hellblau, Trennlinien `1px solid rgba(131,207,237,0.22)`.

Bei mehr als sechs Spalten `table-layout: fixed` setzen und Spaltenbreiten definieren, sonst läuft die Tabelle aus dem Container.

`font-variant-numeric: tabular-nums` ist bei Zahlenspalten Pflicht – sonst haben die Ziffern unterschiedliche Breiten und die Spalte flimmert.

## 10. Key Visual

Das SVG inline einbinden, Farbe über `color` und `currentColor`, Deckkraft und Ausblendung über CSS. Die Deckkraftstufen sind aus den Asset-Dateien entfernt – alle Linien sind gleich stark, und das muss so bleiben.

```css
.kv { position: absolute; pointer-events: none; z-index: 0;
      color: var(--c-tuerkis); opacity: 0.28; }
.kv-hell { color: var(--c-hgrau); opacity: 0.30; }

/* Ausblendung gerichtet zum Flächeninneren.
   Der Mittelpunkt der Maske liegt am Ankerpunkt, nicht in der Grafikmitte. */
.kv-br { right: -8%; bottom: -12%;
  -webkit-mask-image: radial-gradient(130% 130% at 100% 100%, #000 28%, transparent 78%);
          mask-image: radial-gradient(130% 130% at 100% 100%, #000 28%, transparent 78%); }
.kv-tr { right: -8%; top: -12%;
  -webkit-mask-image: radial-gradient(130% 130% at 100% 0%, #000 28%, transparent 78%);
          mask-image: radial-gradient(130% 130% at 100% 0%, #000 28%, transparent 78%); }
.kv-r  { right: -6%; top: 50%; transform: translateY(-50%);
  -webkit-mask-image: radial-gradient(130% 130% at 100% 50%, #000 28%, transparent 78%);
          mask-image: radial-gradient(130% 130% at 100% 50%, #000 28%, transparent 78%); }

@media (max-width: 980px) { .kv { display: none; } }
```

**Der häufigste Fehler:** `radial-gradient(closest-side, #000 26%, transparent 62%)` ohne `at`-Angabe. Die Maske ist dann auf die Grafikmitte zentriert, blendet nach allen Seiten aus und die Grafik kann keine Kante erreichen. Sie wirkt als schwebendes Objekt mit Schein – genau die Wirkung, die das Designsystem ausschließt. Die `at`-Angabe ist deshalb Pflicht.

Weitere Anforderungen aus `SKILL.md` Abschnitt 6: alle 22 Konturlinien der Asset-Datei verwenden und nicht ausdünnen, Bogen im Sichtfeld, Deckkraft nirgends über 50 Prozent. Text darf über dem Key Visual liegen – es gehört mit `z-index: 0` hinter den Inhalt.

Unter 980 px Breite ausblenden: Bei schmaler Darstellung gibt es keine freie Fläche, und die Grafik käme unter den Text, ohne noch als Fläche zu wirken.

## 10b. Mobile Schriftstufen

Die Skala in `SKILL.md` gilt ab 720 px. Darunter:

| Stufe | Desktop | Mobil |
|---|---|---|
| Display / H1 | clamp(44–88) | greift automatisch |
| H1-Ebene (48/50) | 48 / 50 | **32 / 38** |
| H2-Ebene (32/38) | 32 / 38 | **24 / 30** |
| H3-Ebene (22/28) | 22 / 28 | **18 / 26** |
| Body, Caption, Eyebrow | unverändert | unverändert |

Andere Zwischenwerte sind nicht zulässig. `.wrap` bekommt unter 720 px 20 px Innenabstand statt 48.

## 11. Vor der Abgabe prüfen

Jede erzeugte HTML-Datei durch das Prüfskript laufen lassen:

    python3 scripts/pruefen.py seite.html --assets assets

Es prüft, was zählbar ist: Hexwerte außerhalb der Palette (Logofarben nur innerhalb des Logo-SVG), Vollständigkeit und Zuordnung der Key-Visual-Pfade gegen die Quelldateien, `at`-Angabe in jeder Radialmaske, Linkregeln die Buttonfarben überschreiben (mit Spezifitätsvergleich), Fließtext in Hellblau auf dunklem Grund, Schriftgrößen außerhalb der Skala getrennt nach Haltepunkt, Abstände außerhalb des Viererrasters, Geviertstriche und geschwungene Anführungszeichen, fehlende Fokusringe, fehlendes Ausblenden des Key Visual auf schmalen Breiten, entfernte Flächen-Icons.

Rückgabewert 1 bedeutet Fehler. Hinweise sind Punkte, die von der Umgebung abhängen – etwa eine Linkregel, die Buttons überschreiben *könnte*, unter der aktuell aber keiner liegt.

**Das Skript ersetzt die Sichtprüfung nicht.** Komposition, Bildwirkung und ob das Key Visual als Gelände oder als Objekt liest, sieht es nicht. Beides zusammen: erst das Skript, dann das Rendering ansehen.

## 12. Newsletter – Sonderfall

E-Mail-Programme unterstützen moderne CSS-Eigenschaften unzuverlässig. Deshalb dort abweichend:

- Feste Breite 600 px, Tabellen-Layout statt Flexbox oder Grid
- Keine CSS-Variablen – Farbwerte direkt als HEX schreiben
- Keine Radien und keine Schatten
- Webfonts nicht voraussetzen: `font-family: 'Lato', Arial, sans-serif` und Layout so bauen, dass Arial nichts zerbricht
- Buttons als Tabellenzelle mit Hintergrundfarbe, nicht als `<button>`
- Key Visual nur als vorbereitetes PNG, nicht als Inline-SVG
