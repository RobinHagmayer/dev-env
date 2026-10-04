#!/usr/bin/env python3
"""
svg2png - Minimaler SVG-Rasterizer fuer die IT-Kompass Assets.

Deckt genau ab, was in den Dateien vorkommt: path (M L H V C S Q T A Z),
rect, circle, ellipse, line, polyline, polygon, Gruppen mit translate/rotate,
Attribut-Vererbung, opacity, fill-Regel even-odd, Strich mit runden Enden.

Aufruf:
    python3 svg2png.py <in.svg> <out.png> --size 512 [--color "#000854"]

--color ersetzt nur currentColor. Fest eingetragene Farben bleiben.
"""
import math
import re
import sys
import xml.etree.ElementTree as ET

from PIL import Image, ImageChops, ImageDraw

SS = 4  # Kantenglaettung durch vierfache Ueberabtastung

NAMED = {
    "black": (0, 0, 0), "white": (255, 255, 255), "gray": (128, 128, 128),
    "grey": (128, 128, 128), "red": (255, 0, 0), "none": None,
}


# ---------------------------------------------------------------- Hilfsmittel
def parse_color(v, current):
    if v is None:
        return None
    v = v.strip().lower()
    if v in ("none", "transparent"):
        return None
    if v == "currentcolor":
        return parse_color(current, "#000000")
    if v.startswith("#"):
        h = v[1:]
        if len(h) == 3:
            h = "".join(c * 2 for c in h)
        if len(h) == 6:
            return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))
        return None
    m = re.match(r"rgb\(\s*(\d+)[,\s]+(\d+)[,\s]+(\d+)", v)
    if m:
        return tuple(int(g) for g in m.groups())
    return NAMED.get(v)


def mat_mul(a, b):
    return (a[0] * b[0] + a[2] * b[1], a[1] * b[0] + a[3] * b[1],
            a[0] * b[2] + a[2] * b[3], a[1] * b[2] + a[3] * b[3],
            a[0] * b[4] + a[2] * b[5] + a[4], a[1] * b[4] + a[3] * b[5] + a[5])


def parse_transform(s):
    m = (1, 0, 0, 1, 0, 0)
    for name, args in re.findall(r"(\w+)\s*\(([^)]*)\)", s or ""):
        n = [float(x) for x in re.findall(r"-?[\d.]+(?:e-?\d+)?", args)]
        if name == "translate":
            m = mat_mul(m, (1, 0, 0, 1, n[0], n[1] if len(n) > 1 else 0))
        elif name == "scale":
            sx = n[0]; sy = n[1] if len(n) > 1 else sx
            m = mat_mul(m, (sx, 0, 0, sy, 0, 0))
        elif name == "rotate":
            a = math.radians(n[0]); c, s_ = math.cos(a), math.sin(a)
            r = (c, s_, -s_, c, 0, 0)
            if len(n) == 3:
                r = mat_mul(mat_mul((1, 0, 0, 1, n[1], n[2]), r),
                            (1, 0, 0, 1, -n[1], -n[2]))
            m = mat_mul(m, r)
        elif name == "matrix" and len(n) == 6:
            m = mat_mul(m, tuple(n))
    return m


def apply(m, p):
    return (m[0] * p[0] + m[2] * p[1] + m[4], m[1] * p[0] + m[3] * p[1] + m[5])


def mat_scale(m):
    return math.sqrt(abs(m[0] * m[3] - m[1] * m[2])) or 1.0


# ------------------------------------------------------------- Pfad-Zerlegung
def flat_cubic(p0, p1, p2, p3, n=16):
    out = []
    for i in range(1, n + 1):
        t = i / n; u = 1 - t
        out.append((u * u * u * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t * t * t * p3[0],
                    u * u * u * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t * t * t * p3[1]))
    return out


def flat_quad(p0, p1, p2, n=12):
    out = []
    for i in range(1, n + 1):
        t = i / n; u = 1 - t
        out.append((u * u * p0[0] + 2 * u * t * p1[0] + t * t * p2[0],
                    u * u * p0[1] + 2 * u * t * p1[1] + t * t * p2[1]))
    return out


def flat_arc(p0, rx, ry, rot, laf, sf, p1, n=24):
    if rx == 0 or ry == 0 or p0 == p1:
        return [p1]
    rx, ry = abs(rx), abs(ry)
    phi = math.radians(rot)
    cp, sp = math.cos(phi), math.sin(phi)
    dx2, dy2 = (p0[0] - p1[0]) / 2, (p0[1] - p1[1]) / 2
    x1p, y1p = cp * dx2 + sp * dy2, -sp * dx2 + cp * dy2
    lam = x1p ** 2 / rx ** 2 + y1p ** 2 / ry ** 2
    if lam > 1:
        s = math.sqrt(lam); rx, ry = rx * s, ry * s
    num = rx ** 2 * ry ** 2 - rx ** 2 * y1p ** 2 - ry ** 2 * x1p ** 2
    den = rx ** 2 * y1p ** 2 + ry ** 2 * x1p ** 2
    co = math.sqrt(max(0.0, num / den)) if den else 0.0
    if laf == sf:
        co = -co
    cxp, cyp = co * rx * y1p / ry, -co * ry * x1p / rx
    cx = cp * cxp - sp * cyp + (p0[0] + p1[0]) / 2
    cy = sp * cxp + cp * cyp + (p0[1] + p1[1]) / 2

    def ang(ux, uy, vx, vy):
        d = math.hypot(ux, uy) * math.hypot(vx, vy)
        a = math.acos(max(-1, min(1, (ux * vx + uy * vy) / d))) if d else 0
        return -a if ux * vy - uy * vx < 0 else a

    th1 = ang(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry)
    dth = ang((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry)
    if not sf and dth > 0:
        dth -= 2 * math.pi
    elif sf and dth < 0:
        dth += 2 * math.pi
    out = []
    for i in range(1, n + 1):
        t = th1 + dth * i / n
        xp, yp = rx * math.cos(t), ry * math.sin(t)
        out.append((cp * xp - sp * yp + cx, sp * xp + cp * yp + cy))
    return out


NUM = r"[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?"
NUM_RE = re.compile(NUM)
TOKEN = re.compile(r"[MmLlHhVvCcSsQqTtAaZz]|" + NUM)


def scan_path(d):
    """Zerlegt d in Befehle. Bogen-Flags werden einzeln gelesen, weil sie
    ohne Trennzeichen aneinanderhaengen koennen (a5 5 0 015 5)."""
    d = d or ""
    i = 0; n = len(d); out = []
    def skip():
        nonlocal i
        while i < n and d[i] in " ,\t\r\n":
            i += 1
    def num():
        nonlocal i
        skip()
        m = NUM_RE.match(d, i)
        if not m:
            i += 1; return 0.0
        i = m.end(); return float(m.group())
    def flag():
        nonlocal i
        skip()
        if i < n and d[i] in "01":
            v = int(d[i]); i += 1; return v
        return int(num())
    cmd = None
    while i < n:
        skip()
        if i >= n:
            break
        if d[i].isalpha():
            cmd = d[i]; i += 1
            if cmd in "Zz":
                out.append((cmd, [])); cmd = None
                continue
        if cmd is None:
            i += 1; continue
        C = cmd.upper()
        cnt = {"M": 2, "L": 2, "H": 1, "V": 1, "C": 6, "S": 4, "Q": 4, "T": 2}.get(C)
        if C == "A":
            args = [num(), num(), num(), flag(), flag(), num(), num()]
        else:
            args = [num() for _ in range(cnt)]
        out.append((cmd, args))
        if C == "M":
            cmd = "l" if cmd.islower() else "L"
    return out


def path_subpaths(d):
    """Zerlegt ein d-Attribut in Teilpfade: [(punkte, geschlossen), ...]"""
    ops = scan_path(d)
    cur = (0.0, 0.0); start = (0.0, 0.0)
    pts = []; subs = []; prev_ctrl = None
    def flush(closed=False):
        nonlocal pts
        if len(pts) > 1:
            subs.append((pts, closed))
        pts = []
    for c, a in ops:
        rel = c.islower(); C = c.upper()
        if C == "M":
            x, y = a
            if rel: x, y = cur[0] + x, cur[1] + y
            flush(); cur = start = (x, y); pts = [cur]; prev_ctrl = None
        elif C == "L":
            x, y = a
            if rel: x, y = cur[0] + x, cur[1] + y
            cur = (x, y); pts.append(cur); prev_ctrl = None
        elif C == "H":
            x = a[0] + (cur[0] if rel else 0)
            cur = (x, cur[1]); pts.append(cur); prev_ctrl = None
        elif C == "V":
            y = a[0] + (cur[1] if rel else 0)
            cur = (cur[0], y); pts.append(cur); prev_ctrl = None
        elif C in ("C", "S"):
            if C == "C":
                x1, y1, x2, y2, x, y = a
                if rel: x1, y1 = cur[0] + x1, cur[1] + y1
            else:
                x2, y2, x, y = a
                x1, y1 = (2 * cur[0] - prev_ctrl[0], 2 * cur[1] - prev_ctrl[1]) if prev_ctrl else cur
            if rel: x2, y2, x, y = cur[0] + x2, cur[1] + y2, cur[0] + x, cur[1] + y
            if not pts: pts = [cur]
            pts += flat_cubic(cur, (x1, y1), (x2, y2), (x, y))
            prev_ctrl = (x2, y2); cur = (x, y)
        elif C in ("Q", "T"):
            if C == "Q":
                x1, y1, x, y = a
                if rel: x1, y1 = cur[0] + x1, cur[1] + y1
            else:
                x, y = a
                x1, y1 = (2 * cur[0] - prev_ctrl[0], 2 * cur[1] - prev_ctrl[1]) if prev_ctrl else cur
            if rel: x, y = cur[0] + x, cur[1] + y
            if not pts: pts = [cur]
            pts += flat_quad(cur, (x1, y1), (x, y))
            prev_ctrl = (x1, y1); cur = (x, y)
        elif C == "A":
            rx, ry, rot, laf, sf, x, y = a
            if rel: x, y = cur[0] + x, cur[1] + y
            if not pts: pts = [cur]
            pts += flat_arc(cur, rx, ry, rot, int(laf), int(sf), (x, y))
            cur = (x, y); prev_ctrl = None
        elif C == "Z":
            if pts: pts.append(start)
            flush(True); cur = start; prev_ctrl = None
    flush()
    return subs


# ------------------------------------------------------------ Formen sammeln
STROKE_KEYS = ("stroke", "stroke-width", "fill", "opacity", "stroke-opacity", "fill-opacity")


def collect(el, inherit, mat, shapes):
    tag = el.tag.split("}")[-1]
    st = dict(inherit)
    for k in STROKE_KEYS:
        if el.get(k) is not None:
            st[k] = el.get(k)
    style = el.get("style")
    if style:
        for kv in style.split(";"):
            if ":" in kv:
                k, v = kv.split(":", 1)
                if k.strip() in STROKE_KEYS:
                    st[k.strip()] = v.strip()
    m = mat_mul(mat, parse_transform(el.get("transform")))

    subs = None
    if tag == "path":
        subs = path_subpaths(el.get("d"))
    elif tag == "rect":
        x, y = float(el.get("x", 0)), float(el.get("y", 0))
        w, h = float(el.get("width", 0)), float(el.get("height", 0))
        r = float(el.get("rx") or el.get("ry") or 0)
        if r > 0:
            r = min(r, w / 2, h / 2); q = []
            for (cx, cy, a0) in ((x + w - r, y + r, -90), (x + w - r, y + h - r, 0),
                                 (x + r, y + h - r, 90), (x + r, y + r, 180)):
                for k in range(13):
                    a = math.radians(a0 + 90 * k / 12)
                    q.append((cx + r * math.cos(a), cy + r * math.sin(a)))
            q.append(q[0]); subs = [(q, True)]
        else:
            subs = [([(x, y), (x + w, y), (x + w, y + h), (x, y + h), (x, y)], True)]
    elif tag in ("circle", "ellipse"):
        cx, cy = float(el.get("cx", 0)), float(el.get("cy", 0))
        if tag == "circle":
            rx = ry = float(el.get("r", 0))
        else:
            rx, ry = float(el.get("rx", 0)), float(el.get("ry", 0))
        q = [(cx + rx * math.cos(2 * math.pi * k / 48), cy + ry * math.sin(2 * math.pi * k / 48))
             for k in range(49)]
        subs = [(q, True)]
    elif tag == "line":
        subs = [([(float(el.get("x1", 0)), float(el.get("y1", 0))),
                  (float(el.get("x2", 0)), float(el.get("y2", 0)))], False)]
    elif tag in ("polyline", "polygon"):
        n = [float(x) for x in NUM_RE.findall(el.get("points", ""))]
        q = list(zip(n[0::2], n[1::2]))
        if tag == "polygon" and q:
            q = q + [q[0]]
        subs = [(q, tag == "polygon")]

    if subs:
        shapes.append((subs, st, m))
    for ch in el:
        if ch.tag.split("}")[-1] in ("defs", "metadata", "clipPath", "title", "desc"):
            continue
        collect(ch, st, m, shapes)


# ------------------------------------------------------------------- Rendern
def render(svg_path, out_path, size, color=None):
    tree = ET.parse(svg_path)
    root = tree.getroot()
    vb = root.get("viewBox")
    if vb:
        n = [float(x) for x in re.findall(r"-?[\d.]+", vb)]
        vx, vy, vw, vh = n
    else:
        vw = float(re.sub(r"[^\d.]", "", root.get("width", "100")) or 100)
        vh = float(re.sub(r"[^\d.]", "", root.get("height", "100")) or 100)
        vx = vy = 0.0

    k = size / max(vw, vh) * SS
    W, H = max(1, round(vw * k)), max(1, round(vh * k))
    base = mat_mul((k, 0, 0, k, -vx * k, -vy * k), (1, 0, 0, 1, 0, 0))

    shapes = []
    init = {"fill": root.get("fill"), "stroke": root.get("stroke"),
            "stroke-width": root.get("stroke-width")}
    for ch in root:
        if ch.tag.split("}")[-1] in ("defs", "metadata", "clipPath", "title", "desc"):
            continue
        collect(ch, init, base, shapes)

    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    benutzt = set()
    for subs, st, m in shapes:
        op = float(st.get("opacity", 1) or 1)
        fill = parse_color(st.get("fill"), color or "#000000")
        if st.get("fill") is None:
            fill = parse_color("#000000", color or "#000000")
        stroke = parse_color(st.get("stroke"), color or "#000000")
        sw = float(st.get("stroke-width", 1) or 1) * mat_scale(m)
        tp = [([apply(m, p) for p in pts], cl) for pts, cl in subs]

        if fill:
            mask = Image.new("1", (W, H), 0)
            for pts, _ in tp:
                if len(pts) < 3:
                    continue
                sub = Image.new("1", (W, H), 0)
                ImageDraw.Draw(sub).polygon(pts, fill=1)
                mask = ImageChops.logical_xor(mask, sub)
            a = mask.convert("L")
            if op < 1:
                a = a.point(lambda v: int(v * op))
            benutzt.add(fill)
            img.paste(Image.new("RGBA", (W, H), fill + (255,)), (0, 0), a)

        if stroke and sw > 0:
            benutzt.add(stroke)
            lay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
            d = ImageDraw.Draw(lay)
            col = stroke + (int(255 * op),)
            r = sw / 2
            for pts, _ in tp:
                if len(pts) < 2:
                    continue
                d.line(pts, fill=col, width=max(1, round(sw)), joint="curve")
                if sw > 2:
                    for p in (pts[0], pts[-1]):
                        d.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=col)
            img = Image.alpha_composite(img, lay)

    out = size if vw >= vh else round(size * vw / vh)
    outh = size if vh >= vw else round(size * vh / vw)
    final = img.resize((max(1, out), max(1, outh)), Image.LANCZOS)
    save_png(final, out_path, farbe=list(benutzt)[0] if len(benutzt) == 1 else None)
    return out_path


def save_png(im, out_path, farbe=None, levels=64):
    """Einfarbige Strichgrafik als Palettenbild speichern - rund ein Drittel
    der Groesse gegenueber RGBA, ohne sichtbaren Qualitaetsverlust.
    Mehrfarbige Bilder werden unveraendert als RGBA gespeichert."""
    im = im.convert("RGBA")
    if farbe is None:
        im.save(out_path, optimize=True)
        return
    c = tuple(farbe)
    a = im.getchannel("A")
    idx = a.point(lambda v: min(levels - 1, v * levels // 256))
    p = Image.new("P", im.size)
    p.putdata(list(idx.getdata()))
    p.putpalette(list(c) * levels + [0, 0, 0] * (256 - levels))
    step = 256 // levels
    trans = bytes([min(255, i * step + step - 1) for i in range(levels)] + [0] * (256 - levels))
    p.save(out_path, transparency=trans, optimize=True)


if __name__ == "__main__":
    a = sys.argv[1:]
    size = 512; color = None
    if "--size" in a:
        size = int(a[a.index("--size") + 1])
    if "--color" in a:
        color = a[a.index("--color") + 1]
    render(a[0], a[1], size, color)
