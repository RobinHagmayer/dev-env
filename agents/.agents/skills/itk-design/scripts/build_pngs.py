#!/usr/bin/env python3
"""
build_pngs - Erzeugt aus allen SVG-Assets PNG-Dateien fuer Office-Dokumente.

Hintergrund: Word, PowerPoint und Excel koennen SVG einfuegen, muessen es aber
bei jeder Verwendung umwandeln und die Strichfarbe muss jedes Mal manuell
gesetzt werden. Vorgerenderte PNGs mit eingebrannter Markenfarbe entfallen
diesen Schritt.

Aufruf:
    python3 build_pngs.py <assets-verzeichnis> <ziel-verzeichnis>

Weitere Farben oder Groessen spaeter erzeugen:
    python3 svg2png.py <in.svg> <out.png> --size 512 --color "#2FACB9"
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from svg2png import render  # noqa: E402

FARBEN = {"dunkelblau": "#000854", "weiss": "#ffffff"}
KV_FARBEN = {"tuerkis": "#2FACB9", "dunkelblau": "#000854"}

# Dateien mit Textelementen oder Beschneidungspfaden: der Rasterizer stellt
# sie nicht vollstaendig dar, deshalb kein PNG.
AUSNAHMEN = {"mission.svg", "veraltete-software.svg"}

JOBS = [
    ("icons/ui-icons", "png/ui-icons", 256, FARBEN, False),
    ("icons/ui-icons/boxed", "png/ui-icons-boxed", 256, FARBEN, False),
    ("icons/brand-icons", "png/brand-icons", 512, FARBEN, False),
    ("keyvisual", "png/keyvisual", 1024, KV_FARBEN, False),
    ("logo", "png/logo", 1200, None, True),
]


def main(assets, ziel):
    assets, ziel = Path(assets), Path(ziel)
    gesamt = 0
    fehler = []
    uebersprungen = []
    for quelle, out, size, farben, eigene_farben in JOBS:
        src = assets / quelle
        dst = ziel / out
        dst.mkdir(parents=True, exist_ok=True)
        for svg in sorted(src.glob("*.svg")):
            if svg.name in AUSNAHMEN:
                uebersprungen.append(str(svg.relative_to(assets)))
                continue
            if svg.name.startswith("_"):
                uebersprungen.append(str(svg.relative_to(assets)))
                continue
            # Fokus-Sechseck traegt eine feste Farbe, keine Varianten
            fest = svg.name == "hexagon-fokus.svg"
            varianten = {"": None} if (eigene_farben or fest) else farben
            for name, hexwert in varianten.items():
                ziel_datei = dst / (svg.stem + (f"-{name}" if name else "") + ".png")
                try:
                    render(str(svg), str(ziel_datei), size, hexwert)
                    gesamt += 1
                except Exception as e:  # noqa: BLE001
                    fehler.append(f"{svg.name} [{name}]: {type(e).__name__} {e}")
    print(f"Erzeugt: {gesamt} PNG")
    if uebersprungen:
        print(f"Uebersprungen: {len(uebersprungen)} -> {', '.join(uebersprungen)}")
    if fehler:
        print(f"Fehler: {len(fehler)}")
        for f in fehler[:10]:
            print("  ", f)
    return 1 if fehler else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1], sys.argv[2]))
