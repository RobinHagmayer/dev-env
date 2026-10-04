# Asset-Verzeichnis

Bestand der Originaldateien in diesem Skill. Stand 4. August 2026. Markenelemente werden immer aus diesen Dateien verwendet und nie nachgebaut, nachgezeichnet oder per KI generiert.

## Bestand

| Ordner | Inhalt |
|---|---|
| `logo/` | 4 SVG-Varianten, 1 EPS für Druck |
| `keyvisual/` | 4 Bogen-Cluster, 1 Fokus-Sechseck |
| `icons/ui-icons/` | 39 Funktions-Icons, 24 × 24 px |
| `icons/ui-icons/boxed/` | dieselben 39 Icons mit Kontur, 40 × 40 px |
| `icons/brand-icons/` | 76 illustrative Icons, ~500 × 500 Einheiten |
| `png/` | Logo und Fokus-Sechseck als PNG, da farblich festgelegt |
| `fonts/Lato/` | Regular, Bold, Black, mit `OFL.txt` |
| `fonts/Caveat/` | Caveat-Regular, mit `OFL.txt` |

## Logo

| Datei | Farbe | Einsatz |
|---|---|---|
| `itk-logo-rgb.svg` | mehrfarbig | Standard auf Weiß und Papier |
| `itk-logo-dunkelblau.svg` | `#000854` einfarbig | **helle** Untergründe, wenn einfarbig gewünscht |
| `itk-logo-negativ.svg` | `#ffffff` | **dunkle** Untergründe |
| `itk-bildmarke.svg` | mehrfarbig | nur Social-Media-Profilbild |
| `itk-logo-cmyk.eps` | CMYK | Druckerei |

Geprüft: Alle Logodateien enthalten ausschließlich Pfade, keine lebenden Textelemente. Sie stellen sich also auch auf Geräten ohne Lato und Caveat korrekt dar.

**Farbabweichung, dauerhaft festgelegt.** Die Logodateien führen `#f8a100`, `#f9c24d` und `#b7b8b9` statt der Palettenwerte `#f39200`, `#ffbf33` und `#cccccc`. Entscheidung vom 4. August 2026: Die Originalfarben bleiben. Eine Angleichung an die Palette wäre eine zu große Abweichung vom bestehenden Logo und würde die Binnenkontraste innerhalb der Bildmarke verändern.

Das Logo wird deshalb nie umgefärbt. Umgekehrt werden die drei Logofarben nie in die Gestaltung übernommen – außerhalb der Logodateien gilt ausnahmslos die Palette.

## Key Visual

Bögen auf 500 × 500 Einheiten, Strichstärke 1,8, `currentColor`.

**Die Deckkraftstufen wurden am 6. August 2026 entfernt.** Die Dateien trugen je Pfad einen Verlauf von 1,00 auf 0,18 – 22 Stufen pro Datei. Das Designsystem zeigt dagegen alle Konturlinien gleich stark; der sichtbare Verlauf entsteht durch das Ausblenden der Gesamtkonstruktion am Rand. Gemessen an den Screenshots des Designsystems: ein senkrechter Schnitt durch ein Cluster ergibt fünfzehnmal denselben Wert, nicht 22 verschiedene.

Die Randausblendung ist deshalb nicht Teil der Dateien, sondern wird beim Platzieren hergestellt – mit `scripts/keyvisual.py`, im Web über `mask-image`.

`hexagon-fokus.svg` ist die **einzige** Datei mit fester Farbe (`#f39200`) und ohne `currentColor`. Gewollt – das Fokus-Sechseck ist immer orange.

Die Datei wurde am 4. August 2026 neu aufgebaut. Der Vorgängerstand lag auf 380 × 345 Einheiten mit Strichstärke 3, in gedrehter Ausrichtung und mit `vector-effect="non-scaling-stroke"` – dadurch wirkte die Linie bei gleicher Darstellungsgröße etwa doppelt so schwer wie die der Bögen und die Ausrichtung passte nicht zum Key Visual.

Neuer Stand, aus der innersten Konturlinie der Bögen ausgemessen:

| Maß | Wert |
|---|---|
| Zeichenfläche | 500 × 500 |
| Spitze oben | (250, 170) |
| Seitenecken | (163,4 / 225) und (336,6 / 225) |
| Halbe Breite | 86,6 |
| **Kantenwinkel** | **32,42°** – nicht 30° |
| Senkrechte Kanten | 80,6 |
| Gesamtmaß | 173,2 breit × 190,6 hoch |
| Eckenrundung | 18 Einheiten, quadratisch |
| Strichstärke | 1,8 |

Der Kantenwinkel ist der entscheidende Wert. Ein regelmäßiges Sechseck hätte 30°-Kanten und würde die Konturlinien schneiden – genau dieser Fehler lag im ersten Korrekturversuch vor. Die Höhe folgt der Proportion der Marken-Sechseckform aus der Logo-Konstruktionsdatei (Verhältnis 1,100).

Bögen und Sechseck lassen sich damit ohne Umrechnung übereinanderlegen.

## Zwei Icon-Sets, zwei Regelwerke

| | UI-Icons | Brand-Icons |
|---|---|---|
| Anzahl | 39, plus 39 mit Box | 76 |
| Zweck | Bedienelemente, Listen, Tabellen, Navigation | inhaltliche Bebilderung, Themenkacheln, Folien |
| Raster | 24 × 24 px, boxed 40 × 40 px | ~500 × 500 Einheiten, Voreinstellung 48 px |
| Strichstärke | 1,4 fest | 20 Einheiten, skaliert mit der Größe |
| Box-Variante | vorhanden unter `boxed/` | **existiert nicht und wird nicht gebaut** |
| Mindestgröße | 16 px, boxed 32 px | **48 px** digital, 13 mm im Druck |
| Empfohlene Größen | 16, 20, 24, 32 px, boxed 40 px | 48 bis 96 px |

Pro Themenblock oder Abschnitt nur eine Sorte. Ein Dokument darf beide verwenden, die Sorten stehen aber nie unmittelbar nebeneinander.

### Elf Brand-Icons erst ab 96 px

Gemessen wurde je Icon die engste von Linien eingeschlossene Lücke und daraus die Größe, bei der sie noch 1,2 Pixel breit bleibt. Diese elf liegen über 100 px:

| Icon | rechnerischer Bedarf |
|---|---|
| `speichervirtualisierung` | 368 px |
| `trojaner` | 352 px |
| `webinar` | 224 px |
| `sales-gespraech` | 209 px |
| `notiz_speicherung` | 198 px |
| `firewall` | 174 px |
| `pdf-anleitungen` | 163 px |
| `verschluesselung-backup` | 125 px |
| `software` | 124 px |
| `guenstiger-preis` | 108 px |
| `teams-smartphone` | 107 px |

Die Zahlen sind ein Ranking, keine Vorschrift: Das Kriterium verlangt, dass **jede** Innenlücke offen bleibt, auch eine haarfeine. `trojaner` ist bei 48 px erkennbar, verliert dort aber Zeichnung im Gestell. Verbindlich ist die Untergrenze von 96 px für diese elf.

42 der 74 Icons sind bereits bei 48 px vollkommen unkritisch.

### Wann mit Box, wann ohne

Nur UI-Icons haben diese Wahl:

- **ohne Box** – Icon steht neben Text: Buttons, Aufzählungen, Tabellenzellen, Formularhinweise
- **mit Box** – Icon steht allein als eigenständiges Element: Kacheln, Icon-Raster, Karten-Kopfzeilen, Navigationsflächen

Innerhalb einer Gruppe, Liste oder Kachelreihe durchgehend dieselbe Variante. Bei der Box-Variante keinen zusätzlichen Rahmen um das Element legen – die Box ist der Rahmen.

### Strichfarbe

Geprüft: Alle Icons außer den vier Filled-Varianten führen `stroke="currentColor"` und **keine** fest eingetragene Farbe. Die Farbe kommt also aus der Textfarbe des umgebenden Elements und muss dort ausdrücklich gesetzt werden – auf hellem Grund Dunkelblau, Tiefblau oder Türkis, auf dunklem Grund Hellblau oder Weiß. Ohne Angabe erbt das Icon eine beliebige Farbe.

### Entfernte Dateien

`cloud-filled.svg`, `shield-filled.svg`, `wrench-filled.svg` und `zap-filled.svg` wurden am 4. August 2026 aus beiden UI-Ordnern gelöscht und aus der Übersichtsseite entfernt. Grund: Sie widersprachen dem Linien-Stil, enthielten weder `currentColor` noch eine Füllangabe und erschienen deshalb schwarz.

Ersatz: `cloud.svg`, `shield.svg` bzw. `shield-check.svg`, `wrench.svg`, `zap.svg`.

### Dateinamen der Brand-Icons

Die Namen sind inhaltlich vergeben und mischen Bindestrich und Unterstrich: `browser-plugin.svg` neben `cloud_computing.svg`, `email-spoofing.svg` neben `email_achtung.svg`. Vor dem Einbinden den Ordner auflisten und den Namen nachsehen, nicht raten. Eine Vereinheitlichung der Namen würde alle Verweise brechen und ist daher nicht ohne Abstimmung vorzunehmen.

## PNG für Office – bei Bedarf erzeugen, nicht vorhalten

Office kann SVG einfügen, aber die Dateien tragen keine eigene Farbe und erscheinen dort schwarz. Es braucht also PNG mit eingebrannter Markenfarbe.

Diese werden **nicht im Skill vorgehalten**. Grund ist eine harte Grenze: Ein Skill-Paket darf höchstens 200 Dateien enthalten. Eine vollständige PNG-Sammlung wären über 300 zusätzliche Dateien, das Paket ließe sich nicht mehr installieren. Zweiter Grund: Ein Mensch, der von Hand in Word arbeitet, kann ohnehin nicht in ein installiertes Skill-Paket hineingreifen – eine Vorratssammlung darin hätte niemandem genutzt.

Stattdessen liegt der Rasterizer bei und erzeugt genau die gebrauchten Dateien:

    python3 scripts/svg2png.py assets/icons/ui-icons/shield.svg shield.png --size 256 --color "#000854"

Das ist der bessere Weg, weil jede Markenfarbe und jede Auflösung möglich ist, statt nur zwei vorgerenderte Varianten.

Fertig im Paket liegen nur `png/logo/` und `png/keyvisual/hexagon-fokus.png`, weil deren Farben festliegen und nicht über `--color` gesetzt werden.

**Für Menschen, die ohne Claude in Word arbeiten:** Die vollständige PNG-Sammlung gehört nicht in den Skill, sondern in die Organisational Asset Library beziehungsweise auf SharePoint. Sie lässt sich dort mit `scripts/build_pngs.py` in einem Durchlauf erzeugen und ablegen.

**Zwei Icons lassen sich nicht umwandeln:** `mission.svg` enthält ein Textelement („VISION“), `veraltete-software.svg` einen Beschneidungspfad. Beides stellt der Rasterizer nicht dar. Diese zwei in Office als SVG einfügen und manuell einfärben.

## Werkzeuge in `scripts/`

| Datei | Zweck |
|---|---|
| `svg2png.py` | eine SVG in beliebiger Größe und Farbe rendern |
| `build_pngs.py` | die komplette Sammlung in einem Durchlauf erzeugen |

Einzelne Datei in einer Markenfarbe:

    python3 scripts/svg2png.py <in.svg> <out.png> --size 512 --color "#2FACB9"

Komplette Sammlung in ein Zielverzeichnis:

    python3 scripts/build_pngs.py assets <ziel>

`--color` ersetzt nur `currentColor`. Fest eingetragene Farben – Logos und Fokus-Sechseck – bleiben unberührt.

Der Rasterizer braucht nur Python mit Pillow. Er deckt ab, was in diesen Dateien vorkommt: Pfade, Rechtecke, Kreise, Ellipsen, Linien, Polylinien, Polygone, Gruppen mit Verschiebung und Drehung, Attributvererbung, Deckkraft und die Füllregel even-odd. Einfarbige Ergebnisse speichert er als Palettenbild mit 64 Alphastufen, rund ein Drittel der Größe von RGBA ohne sichtbaren Verlust. Textelemente und Beschneidungspfade werden nicht unterstützt.

## Schriften

Beide Familien liegen unter der SIL Open Font License und sind weitergabefähig. Die Lizenztexte liegen bei: `fonts/Lato/OFL.txt` und `fonts/Caveat/OFL.txt`. Die OFL verlangt, dass jede Kopie den Lizenztext mitführt – diese Dateien dürfen nicht entfernt werden.

Enthalten sind nur die tatsächlich gebrauchten Schnitte: Lato Regular, Bold und Black sowie Caveat Regular. Die Kursiven sowie Thin und Light sind wegen der Dateigrenze nicht im Paket; sie liegen in der internen Schriftenablage. Der Zweck der Dateien hier ist nicht die Installation auf Arbeitsplätzen – dafür sind sie zu wenige –, sondern das Einbetten bei der Erzeugung von PDF und Grafiken.

## Änderungen am 4. August 2026

| Was | Status |
|---|---|
| Vier `-filled`-Icons gelöscht, Übersichtsseite bereinigt | erledigt |
| Strichstärke aller UI-Icons von 1,6 auf **1,4** gesetzt | erledigt |
| Fokus-Sechseck auf die Geometrie der Bögen neu aufgebaut | erledigt |
| Doppelte Lato-Dateien entfernt | erledigt |
| Rasterizer und Stapelverarbeitung in `scripts/` aufgenommen | erledigt |
| Deckkraftstufen aus den vier Bogen-Dateien entfernt | erledigt |
| `keyvisual.py` für Randausblendung und Überlagerung aufgenommen | erledigt |
| PNG-Vorratssammlung wieder entfernt wegen 200-Dateien-Grenze | erledigt |
| `index.html`-Übersichten entfernt, `_src-sechseck.svg` entfernt | erledigt |
| Schriften auf Regular, Bold, Black und Caveat Regular reduziert | erledigt |
| Logofarben als dauerhafte Ausnahme festgelegt, keine Korrektur | entschieden |
| Lizenzdateien für Caveat ergänzt | erledigt |

## Offene Punkte darüber hinaus

1. Die Brand-Icons führen Strichstärke 20 auf rund 500 Einheiten, was bei 48 px wie 1,9 px wirkt – also schwerer als die 1,4 der UI-Icons. Solange beide Sets nie im selben Dokument erscheinen, ist das folgenlos. Eine Angleichung auf 14,5 Einheiten wäre möglich, verändert aber alle 76 Dateien und ist nicht entschieden.
