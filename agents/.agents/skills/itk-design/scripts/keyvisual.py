#!/usr/bin/env python3
"""
keyvisual - Erzeugt Key-Visual-Grafiken nach den Regeln des Designsystems.

Zwei Dinge, die die SVG-Dateien selbst nicht abbilden und die dieses Werkzeug
herstellt:

1. **Gleiche Deckkraft für alle Konturlinien.** Die Dateien tragen einen
   Verlauf von 1,00 auf 0,18 je Pfad. Das Designsystem zeigt dagegen alle
   Linien gleich stark; der sichtbare Verlauf entsteht nicht Linie für Linie,
   sondern durch das Ausblenden der Konstruktion am Rand.
2. **Weiches Ausblenden der Gesamtkonstruktion, gerichtet zum Flächeninneren.**
   `--sides` bestimmt, auf welchen Seiten ausgeblendet wird. Bei einem Cluster in
   der unteren rechten Ecke also `--sides lt` — links und oben ausblenden, unten
   und rechts voll stehen lassen, weil dort die Seitenkante liegt. Wird auf allen
   vier Seiten ausgeblendet, entsteht ein schwebendes Objekt mit Schein; das ist
   der häufigste Fehler.

Zwei Cluster dürfen sich überlagern. Die Überlagerung addiert sich und macht
die Überschneidungszone zum hellsten Bereich — dort liegt die Fokuszone.

Aufruf:

    python3 keyvisual.py arc-a out.png --size 1800 --color "#2FACB9" --opacity 28 \\
        --sides lt
    python3 keyvisual.py arc-a out.png --second arc-l --offset 0.35,0.15 \\
        --size 1800 --color "#2FACB9" --opacity 28

Gemessene Werte aus dem Designsystem und der Website:

    dunkler Grund   Türkis    20 bis 30 %, Regelwert 28
    heller Grund    Türkis     8 %                        (wirkt hellblau)
    heller Grund    Hellgrau  60 %                        (wirkt neutralgrau)
"""
import argparse
import os
import re
import sys
import tempfile

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from svg2png import render  # noqa: E402

KV_DIR = "assets/keyvisual"


def uniform_svg(pfad):
    """Entfernt die Deckkraftstufen der Einzelpfade — alle Linien gleich stark."""
    s = open(pfad, encoding="utf-8").read()
    s = re.sub(r'\sopacity="[0-9.]+"', "", s)
    tmp = tempfile.NamedTemporaryFile(suffix=".svg", delete=False, mode="w",
                                      encoding="utf-8")
    tmp.write(s)
    tmp.close()
    return tmp.name


def fade_edges(im, breite=0.28, seiten="lrtb"):
    """Blendet die Konstruktion zum Rand hin aus — weich, nicht abgeschnitten."""
    import numpy as np
    w, h = im.size
    a = np.asarray(im.getchannel("A"), dtype=np.float32)
    fw, fh = max(1.0, w * breite), max(1.0, h * breite)

    def ramp(n, span, vorne):
        i = np.arange(n, dtype=np.float32)
        t = np.clip((i if vorne else (n - 1 - i)) / span, 0.0, 1.0)
        return t * t * (3 - 2 * t)

    fx = np.ones(w, dtype=np.float32)
    fy = np.ones(h, dtype=np.float32)
    if "l" in seiten:
        fx = np.minimum(fx, ramp(w, fw, True))
    if "r" in seiten:
        fx = np.minimum(fx, ramp(w, fw, False))
    if "t" in seiten:
        fy = np.minimum(fy, ramp(h, fh, True))
    if "b" in seiten:
        fy = np.minimum(fy, ramp(h, fh, False))
    a *= fy[:, None] * fx[None, :]
    im.putalpha(Image.fromarray(a.astype("uint8"), mode="L"))
    return im


def cluster(name, size, color, opacity, fade=0.28, seiten="lrtb", kv_dir=KV_DIR):
    quelle = os.path.join(kv_dir, f"{name}.svg")
    tmp_svg = uniform_svg(quelle)
    tmp_png = tempfile.mktemp(suffix=".png")
    render(tmp_svg, tmp_png, size, color)
    im = Image.open(tmp_png).convert("RGBA")
    if opacity < 100:
        im.putalpha(im.getchannel("A").point(lambda v: int(v * opacity / 100)))
    if fade > 0:
        im = fade_edges(im, fade, seiten)
    for f in (tmp_svg, tmp_png):
        try:
            os.remove(f)
        except OSError:
            pass
    return im


def compose(first, second=None, offset=(0.35, 0.15), scale=1.0, **kw):
    """Zwei Cluster überlagern. Die Überschneidungszone wird heller — gewollt."""
    a = cluster(first, **kw)
    if not second:
        return a
    b = cluster(second, **kw)
    if scale != 1.0:
        b = b.resize((int(b.width * scale), int(b.height * scale)), Image.LANCZOS)
    leinwand = Image.new("RGBA", a.size, (0, 0, 0, 0))
    leinwand.alpha_composite(a, (0, 0))
    leinwand.alpha_composite(b, (int(a.width * offset[0]), int(a.height * offset[1])))
    return leinwand


def main():
    p = argparse.ArgumentParser()
    p.add_argument("cluster")
    p.add_argument("out")
    p.add_argument("--second", default=None)
    p.add_argument("--offset", default="0.35,0.15")
    p.add_argument("--scale", type=float, default=1.0)
    p.add_argument("--size", type=int, default=1800)
    p.add_argument("--color", default="#2FACB9")
    p.add_argument("--opacity", type=float, default=28)
    p.add_argument("--fade", type=float, default=0.28)
    p.add_argument("--sides", default="lrtb")
    p.add_argument("--kv-dir", default=KV_DIR)
    a = p.parse_args()
    dx, dy = (float(v) for v in a.offset.split(","))
    im = compose(a.cluster, a.second, (dx, dy), a.scale, size=a.size, color=a.color,
                 opacity=a.opacity, fade=a.fade, seiten=a.sides, kv_dir=a.kv_dir)
    im.save(a.out)
    print(a.out, im.size)


if __name__ == "__main__":
    main()
