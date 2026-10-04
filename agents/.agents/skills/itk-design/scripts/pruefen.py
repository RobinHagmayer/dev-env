#!/usr/bin/env python3
"""
pruefen - Prüft eine erzeugte HTML-Datei gegen die zählbaren Regeln des
IT-Kompass Designsystems.

Das Skript ersetzt keine Sichtprüfung. Bildwirkung, Komposition und Ton
beurteilt es nicht. Es fängt ausschließlich das, was sich zählen oder
vergleichen lässt – und das zuverlässig, unabhängig davon, wie gerade
gesucht wird.

Aufruf:

    python3 scripts/pruefen.py seite.html
    python3 scripts/pruefen.py seite.html --assets /pfad/zu/assets

Rückgabewert 1, wenn Fehler gefunden wurden, sonst 0.
"""
import argparse
import glob
import os
import re
import sys

PALETTE = {
    "#000854": "Dunkelblau", "#0026ff": "Tiefblau", "#f39200": "Orange",
    "#ffbf33": "Hellorange", "#2facb9": "Türkis", "#83cfed": "Hellblau",
    "#333333": "Dunkelgrau", "#cccccc": "Hellgrau", "#ff5500": "Hellrot",
    "#3caa31": "Hellgrün", "#ffffff": "Weiß", "#f5f7fb": "Papier",
    "#0a0f2c": "Tinte",
}
LOGO_FARBEN = {"#f8a100", "#f9c24d", "#b7b8b9"}
ICON_ALT = "#29434c"

SKALA_DESKTOP = {11, 13, 14, 16, 18, 22, 32, 48}   # 14 = Buttons
SKALA_MOBIL = {11, 13, 14, 16, 18, 24, 26, 30, 32, 38}
PADDING_AUSNAHMEN = {11, 22, 20}   # dokumentierte Komponentenwerte

FLIESSTEXT_SEL = re.compile(r"\.lead\b|\bp\b|\bbody\b|\.text\b")


class Bericht:
    def __init__(self):
        self.fehler, self.hinweise, self.ok = [], [], []

    def f(self, thema, text):
        self.fehler.append((thema, text))

    def h(self, thema, text):
        self.hinweise.append((thema, text))

    def gut(self, text):
        self.ok.append(text)

    def ausgeben(self):
        if self.fehler:
            print("FEHLER")
            for t, x in self.fehler:
                print(f"  [{t}] {x}")
        if self.hinweise:
            print("\nHINWEISE")
            for t, x in self.hinweise:
                print(f"  [{t}] {x}")
        if self.ok:
            print("\nOHNE BEFUND")
            for x in self.ok:
                print(f"  {x}")
        print(f"\n{len(self.fehler)} Fehler, {len(self.hinweise)} Hinweise")
        return 1 if self.fehler else 0


# ------------------------------------------------------------------ CSS lesen
def css_bloecke(css):
    """Liefert (selektor, koerper, media) für alle Regeln, auch in @media.
    Klammern werden gezählt, nicht per Muster geraten – sonst werden
    verschachtelte Blöcke falsch zugeordnet."""
    aus = []
    i, n = 0, len(css)
    while i < n:
        j = css.find("{", i)
        if j < 0:
            break
        kopf = css[i:j].strip()
        tiefe, k = 1, j + 1
        while k < n and tiefe:
            if css[k] == "{":
                tiefe += 1
            elif css[k] == "}":
                tiefe -= 1
            k += 1
        koerper = css[j + 1:k - 1]
        if kopf.startswith("@media"):
            for sel, kp, _ in css_bloecke(koerper):
                aus.append((sel, kp, kopf))
        elif kopf.startswith("@"):
            pass
        else:
            for sel in kopf.split(","):
                aus.append((sel.strip(), koerper, None))
        i = k
    return aus


def spezifitaet(sel):
    ids = len(re.findall(r"#[\w-]+", sel))
    kl = len(re.findall(r"\.[\w-]+|\[[^\]]*\]|:(?!:)(?!not)[\w-]+", sel))
    el = len(re.findall(r"(?:^|[\s>+~])([a-z][\w-]*)", sel))
    return (ids, kl, el)


def deklarationen(koerper):
    d = {}
    for teil in koerper.split(";"):
        if ":" in teil:
            k, v = teil.split(":", 1)
            d[k.strip().lower()] = " ".join(v.split())
    return d


# ------------------------------------------------------------------- Prüfungen
def pruefe_farben(html, css, b):
    treffer = list(re.finditer(r"#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b", html))
    fremd = {}
    for m in treffer:
        h = m.group(0).lower()
        if len(h) == 4:
            h = "#" + "".join(c * 2 for c in h[1:])
        if h in PALETTE:
            continue
        # innerhalb eines SVG? -> Logofarben sind dort erlaubt
        auf = html.rfind("<svg", 0, m.start())
        zu = html.rfind("</svg>", 0, m.start())
        in_svg = auf > zu
        if h in LOGO_FARBEN and in_svg:
            continue
        if h == ICON_ALT:
            b.f("Icons", f"{h} ist die Ursprungsfarbe der Icons und keine Markenfarbe")
            continue
        fremd.setdefault(h, 0)
        fremd[h] += 1
    for h, n in fremd.items():
        wo = "außerhalb eines SVG" if h in LOGO_FARBEN else ""
        b.f("Farben", f"{h} steht {n}x im Dokument und ist nicht in der Palette {wo}".strip())
    if not fremd:
        b.gut(f"Farben: nur Palettenwerte, {len(treffer)} Vorkommen geprüft")


def pruefe_keyvisual(html, assets, b):
    quellen = {}
    for f in sorted(glob.glob(os.path.join(assets, "keyvisual", "arc-*.svg"))):
        t = open(f, encoding="utf-8").read()
        pf = [" ".join(d.split()) for d in re.findall(r'\sd="([^"]+)"', t)]
        if pf:
            name, anz, alt = quellen.get(pf[0], ("", len(pf), pf))
            neu = os.path.basename(f)
            quellen[pf[0]] = (f"{name}/{neu}" if name else neu, anz, alt)
    if not quellen:
        b.h("Key Visual", f"keine Bogen-Dateien unter {assets}/keyvisual gefunden, Prüfung übersprungen")
        return
    gefunden = 0
    for m in re.finditer(r'<(\w+)[^>]*class="[^"]*\bkv\b[^"]*"[^>]*>', html):
        gefunden += 1
        # vollständigen SVG-Bereich suchen, nicht nur ein Zeichenfenster
        s0 = html.find("<svg", m.end())
        s1 = html.find("</svg>", s0)
        if s0 < 0 or s1 < 0:
            b.h("Key Visual", "Element mit Klasse kv enthält kein SVG")
            continue
        seg = html[s0:s1]
        pf = [" ".join(d.split()) for d in re.findall(r'\sd="([^"]+)"', seg)]
        if not pf:
            b.f("Key Visual", "SVG ohne Pfade")
            continue
        name, soll, quellpf = quellen.get(pf[0], (None, None, None))
        if name is None:
            b.f("Key Visual", "erster Pfad stimmt mit keiner Bogen-Datei überein – "
                              "die Grafik wurde nachgezeichnet statt eingesetzt")
            continue
        if len(pf) != soll:
            b.f("Key Visual", f"{name}: {len(pf)} von {soll} Konturlinien im Dokument – "
                              "die Datei wurde ausgedünnt")
        else:
            fehl = [i for i, d in enumerate(quellpf) if d not in pf]
            if fehl:
                b.f("Key Visual", f"{name}: Pfadzahl stimmt, aber {len(fehl)} Pfade weichen ab")
            else:
                b.gut(f"Key Visual: {name} vollständig mit {soll} Konturlinien")
        if re.search(r"\sopacity=", seg):
            b.f("Key Visual", f"{name}: Einzelpfade tragen opacity-Attribute – "
                              "alle Linien müssen gleich stark sein")
    if gefunden == 0:
        b.h("Key Visual", "kein Element mit Klasse kv gefunden")


def pruefe_masken(css, b):
    n = 0
    for m in re.finditer(r"(-webkit-)?mask-image:\s*([^;}]+)", css):
        wert = m.group(2)
        if "radial-gradient" not in wert:
            continue
        n += 1
        if " at " not in wert:
            b.f("Key Visual", "Radialmaske ohne at-Angabe: "
                              f"{wert[:70]} – sie ist damit auf die Grafikmitte "
                              "zentriert und blendet nach allen Seiten aus")
    if n and not any(t == "Key Visual" and "at-Angabe" in x for t, x in b.fehler):
        b.gut(f"Masken: {n} Radialmasken, alle mit Ankerpunkt")
    if n == 0:
        b.h("Key Visual", "keine Radialmaske gefunden – Ausblendung anders gelöst oder fehlend")


def enthaelt_button(html, kontext_klasse):
    """Liegt im HTML unterhalb eines Elements mit dieser Klasse ein Button?
    Tag-Tiefe wird mitgezaehlt, damit nur der echte Teilbaum betrachtet wird."""
    if not kontext_klasse:
        return True
    for m in re.finditer(r'<(\w+)[^>]*class="[^"]*\b' + re.escape(kontext_klasse)
                         + r'\b[^"]*"[^>]*>', html):
        tiefe, i = 1, m.end()
        while i < len(html) and tiefe:
            t = re.search(r"<(/?)(\w+)([^>]*)>", html[i:])
            if not t:
                break
            i += t.end()
            if t.group(2).lower() in ("br", "img", "input", "meta", "link", "path",
                                      "use", "circle", "rect", "line", "polyline"):
                continue
            if t.group(3).endswith("/"):
                continue
            tiefe += -1 if t.group(1) else 1
            if tiefe <= 0:
                break
            if 'class="btn' in html[m.end():i]:
                return True
        if 'class="btn' in html[m.end():i]:
            return True
    return False


def pruefe_buttons(html, css, b):
    btn_regeln = []
    link_regeln = []
    for sel, koerper, media in css_bloecke(css):
        d = deklarationen(koerper)
        if "color" not in d:
            continue
        if re.search(r"\.btn", sel):
            btn_regeln.append((sel, spezifitaet(sel), d))
        elif re.search(r"(?:^|[\s>+~])a(?![\w-])", sel) and ":not(.btn" not in sel:
            link_regeln.append((sel, spezifitaet(sel), d))
    for lsel, lspec, ld in link_regeln:
        betroffen = [bs for bs, bspec, _ in btn_regeln if bspec <= lspec]
        if not betroffen:
            continue
        kontext = re.findall(r"\.([\w-]+)", lsel)
        trifft = enthaelt_button(html, kontext[0] if kontext else None)
        text = (f"Linkregel `{lsel}` (Spezifität {lspec}) überschreibt "
                f"{len(betroffen)} Buttonregel(n) wie `{betroffen[0]}`. "
                "Buttons ausnehmen: a:not(.btn)")
        if trifft:
            b.f("Buttons", text)
        else:
            b.h("Buttons", text + " (derzeit liegt kein Button in diesem Bereich)")
    if link_regeln and not any(t == "Buttons" for t, _ in b.fehler):
        b.gut("Buttons: keine Linkregel überschreibt eine Buttonfarbe")
    # Konturbutton: Schriftfarbe gleich Konturfarbe
    for sel, koerper, media in css_bloecke(css):
        d = deklarationen(koerper)
        rand = d.get("border") or d.get("border-color") or ""
        farbe = d.get("color", "")
        if not (re.search(r"\.btn", sel) and rand and farbe):
            continue
        if "transparent" in d.get("background", "") or d.get("background") is None:
            rv = re.search(r"var\(--[\w-]+\)", rand)
            fv = re.search(r"var\(--[\w-]+\)", farbe)
            if rv and fv and rv.group(0) != fv.group(0) and "hover" not in sel:
                b.f("Buttons", f"`{sel}`: Kontur {rv.group(0)} und Schrift {fv.group(0)} "
                               "unterscheiden sich – bei Konturbuttons müssen sie gleich sein")


def pruefe_dunkle_flaechen(css, b):
    for sel, koerper, media in css_bloecke(css):
        if ".on-dark" not in sel and ".dark" not in sel:
            continue
        d = deklarationen(koerper)
        if d.get("color", "").find("--c-hellblau") < 0:
            continue
        rest = sel.split(".on-dark")[-1].strip()
        if FLIESSTEXT_SEL.search(rest) and ":not" not in rest:
            b.f("Textfarben", f"`{sel}` setzt Fließtext auf dunklem Grund in Hellblau – "
                              "Fließtext ist weiß, Hellblau nur für Sublines und Hervorhebungen")


def pruefe_schriftgroessen(css, b):
    ausser = {}
    for sel, koerper, media in css_bloecke(css):
        d = deklarationen(koerper)
        fs = d.get("font-size")
        if not fs or "clamp" in fs or "var(" in fs:
            continue
        m = re.match(r"(\d+(?:\.\d+)?)px", fs)
        if not m:
            continue
        px = float(m.group(1))
        erlaubt = SKALA_MOBIL if media else SKALA_DESKTOP
        if px not in erlaubt:
            ausser.setdefault(px, []).append(sel + (f"  @{media}" if media else ""))
    for px, wo in sorted(ausser.items()):
        b.h("Typografie", f"{px:g}px liegt nicht in der Skala – {wo[0]}"
                          + (f" und {len(wo)-1} weitere" if len(wo) > 1 else ""))
    if not ausser:
        b.gut("Typografie: alle Schriftgrößen aus der Skala")


def pruefe_abstaende(css, b):
    schlecht = {}
    for sel, koerper, media in css_bloecke(css):
        for prop, wert in deklarationen(koerper).items():
            if prop.split("-")[0] not in ("padding", "margin", "gap"):
                continue
            for z in re.findall(r"(?<![\w.-])(\d+)px", wert):
                v = int(z)
                if v % 4 and v not in PADDING_AUSNAHMEN:
                    schlecht.setdefault(v, []).append(f"{sel} {{ {prop} }}")
    for v, wo in sorted(schlecht.items()):
        b.h("Abstände", f"{v}px ist kein Vielfaches von 4 – {wo[0]}"
                        + (f" und {len(wo)-1} weitere" if len(wo) > 1 else ""))
    if not schlecht:
        b.gut("Abstände: Viererraster eingehalten")


def pruefe_mikrotypografie(html, b):
    """Deutsche Gaensefuesschen sind korrekt und werden nicht beanstandet.
    Beanstandet werden Geviertstriche und englische Anfuehrungszeichen sowie
    gerade Zollzeichen im sichtbaren Text."""
    import html as _html
    ohne = re.sub(r"<(script|style)[^>]*>.*?</\1>", "", html, flags=re.S)
    sichtbar = _html.unescape(re.sub(r"<[^>]+>", " ", ohne))

    n_geviert = sichtbar.count("\u2014")
    if n_geviert:
        b.f("Mikrotypografie", f"{n_geviert}x Geviertstrich – im Deutschen "
                               "gehoert der Halbgeviertstrich mit Leerzeichen (&ndash;)")

    # Englische Anfuehrungszeichen: oeffnendes " statt „
    n_engl = max(0, sichtbar.count("\u201c") - sichtbar.count("\u201e"))
    if n_engl:
        b.f("Mikrotypografie", f"{n_engl}x englische Anfuehrungszeichen – im Deutschen "
                               "oeffnet \u201e unten und schliesst \u201c oben")

    # Gerade Zollzeichen im sichtbaren Text
    gerade = [m for m in re.finditer(r'"([^"\n]{1,60})"', sichtbar)]
    echte = [m for m in gerade if not m.group(1).strip().startswith("#")]
    if echte:
        beispiel = echte[0].group(0)[:50]
        b.f("Mikrotypografie", f"{len(echte)}x gerade Anfuehrungszeichen im Textkoerper, "
                               f"z. B. {beispiel} – im laufenden Text gehoeren deutsche "
                               "Gaensefuesschen hin, gerade nur in Code und Attribute")

    if not (n_geviert or n_engl or echte):
        b.gut("Mikrotypografie: deutsche Anfuehrungszeichen, keine Geviertstriche")


def pruefe_fokus_und_mobil(css, b):
    if not re.search(r"\.btn[^{]*:focus-visible", css):
        b.f("Barrierefreiheit", "kein :focus-visible für .btn – der Fokusring darf nie fehlen")
    if not re.search(r"a[^{]*:focus-visible", css):
        b.h("Barrierefreiheit", "kein :focus-visible für Links gefunden")
    versteckt = any(".kv" in sel and deklarationen(k).get("display") == "none"
                    for sel, k, media in css_bloecke(css) if media)
    if ".kv" in css and not versteckt:
        b.h("Key Visual", "kein Ausblenden des Key Visual in einer Media Query – "
                          "unter 980 px sollte es entfallen")


DETAILREICH = {"speichervirtualisierung", "trojaner", "webinar", "sales-gespraech",
               "notiz_speicherung", "firewall", "pdf-anleitungen",
               "verschluesselung-backup", "software", "guenstiger-preis",
               "teams-smartphone"}


def icon_herkunft(assets):
    """Ordnet den ersten Pfad jeder Icon-Datei ihrem Set zu."""
    karte = {}
    for satz, muster in (("ui", "ui-icons/*.svg"), ("ui", "ui-icons/boxed/*.svg"),
                         ("brand", "brand-icons/*.svg")):
        for f in glob.glob(os.path.join(assets, "icons", muster)):
            t = open(f, encoding="utf-8").read()
            d = re.search(r'\sd="([^"]+)"', t)
            if d:
                karte.setdefault(" ".join(d.group(1).split()),
                                 (satz, os.path.basename(f)[:-4]))
    return karte


def pruefe_icon_groessen(html, css, assets, b):
    karte = icon_herkunft(assets)
    if not karte:
        return
    # Brand-Icon-Groessen aus CSS: Regeln, die eine Breite unter 48px setzen
    for sel, koerper, media in css_bloecke(css):
        d = deklarationen(koerper)
        w = d.get("width", "")
        if "brand" not in sel:
            continue
        m = re.match(r"(\d+(?:\.\d+)?)px", w)
        if m and float(m.group(1)) < 48:
            b.f("Icons", f"`{sel}` rendert ein Brand-Icon mit {m.group(1)}px – "
                         "Mindestgröße ist 48 px, darunter gehört ein UI-Icon hin")
    # Sortenmischung je Abschnitt
    for m in re.finditer(r"<section\b", html):
        ende = html.find("</section>", m.start())
        seg = html[m.start(): ende if ende > 0 else len(html)]
        satz = {}
        for d in re.findall(r'\sd="([^"]+)"', seg):
            treffer = karte.get(" ".join(d.split()))
            if treffer:
                satz.setdefault(treffer[0], set()).add(treffer[1])
        if len(satz) > 1:
            b.f("Icons", "Abschnitt enthält beide Icon-Sorten: "
                         f"UI ({', '.join(sorted(satz['ui'])[:3])}) und "
                         f"Brand ({', '.join(sorted(satz['brand'])[:3])}). "
                         "Pro Abschnitt ist nur eine Sorte zulässig")
        for name in satz.get("brand", ()):
            if name in DETAILREICH:
                b.h("Icons", f"`{name}` ist detailreich und braucht mindestens 96 px – "
                             "Größe im Rendering prüfen")


def pruefe_ausgeschlossene_bausteine(html, css, b):
    """Die Ansprechpartner-Karte ist in HTML-Dokumenten nicht zulaessig."""
    muster = re.compile(r"\b(contact-card|kontakt-karte|kontaktkarte|ansprechpartner-card)\b", re.I)
    treffer = sorted({m.group(0) for m in muster.finditer(css + html)})
    if treffer:
        b.f("Bausteine", f"Ansprechpartner-Karte gefunden (`{treffer[0]}`) – dieser Baustein "
                         "ist nicht zulässig. Kontaktangaben gehören in den Fließtext, "
                         "formatiert nach dem Kontaktdaten-Skill")


def pruefe_icons(html, b):
    treffer = re.findall(r"[\w-]*-filled\.svg|\b(?:cloud|shield|wrench|zap)-filled\b", html)
    if treffer:
        b.f("Icons", f"Flächen-Icon verwendet: {sorted(set(treffer))[0]} – "
                     "die -filled-Varianten sind entfernt")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("datei")
    ap.add_argument("--assets", default="assets")
    a = ap.parse_args()
    html = open(a.datei, encoding="utf-8", errors="replace").read()
    css = "\n".join(m.group(1) for m in re.finditer(r"<style[^>]*>(.*?)</style>", html, re.S))
    b = Bericht()
    print(f"Prüfung: {a.datei}\n" + "=" * 60)
    pruefe_farben(html, css, b)
    pruefe_keyvisual(html, a.assets, b)
    pruefe_masken(css, b)
    pruefe_buttons(html, css, b)
    pruefe_dunkle_flaechen(css, b)
    pruefe_schriftgroessen(css, b)
    pruefe_abstaende(css, b)
    pruefe_mikrotypografie(html, b)
    pruefe_fokus_und_mobil(css, b)
    pruefe_ausgeschlossene_bausteine(html, css, b)
    pruefe_icons(html, b)
    pruefe_icon_groessen(html, css, a.assets, b)
    sys.exit(b.ausgeben())


if __name__ == "__main__":
    main()
