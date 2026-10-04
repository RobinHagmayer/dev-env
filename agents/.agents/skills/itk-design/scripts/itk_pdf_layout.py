#!/usr/bin/env python3
"""
itk_pdf_layout - Geprüfte Satzumsetzung für IT-Kompass Dokumente mit reportlab.

Enthält Satzspiegel, Schriftskala, Abstandsstufen, hängende Abschnittsnummern,
Hinweiskästen und die beiden Tabellenstile. Die Werte stammen aus
`SKILL.md` und `references/print-pdf.md` und sind an einem Testsatz geprüft.

Für Word und PowerPoint gelten dieselben Werte, aber nicht dieser Code —
dort `references/office.md` verwenden.

Verwendung:

    from itk_pdf_layout import Doc, BODY, LEAD, callout, pull, steps, table_b

    d = Doc("ausgabe.pdf", titel="...", untertitel="...", eyebrow="...")
    d.section("1", "Zweck dieses Papiers")
    d.p("Fließtext ...", LEAD)
    d.p("Weiterer Absatz ...")
    d.sub("Option A – Status quo")
    d.callout("Kernaussage", ["Satz eins ...", ("Fettsatz.", True)])
    d.build()
"""
from reportlab.lib.colors import HexColor
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (BaseDocTemplate, Flowable, Frame, NextPageTemplate,
                                PageBreak, PageTemplate, Paragraph, Spacer, Table,
                                TableStyle)

# --------------------------------------------------------------------- Marke
NAVY = HexColor("#000854")
DEEPBLUE = HexColor("#0026FF")
TEAL = HexColor("#2FACB9")
LBLUE = HexColor("#83CFED")
ORANGE = HexColor("#F39200")
DGREY = HexColor("#333333")
LGREY = HexColor("#CCCCCC")
PAPER = HexColor("#F5F7FB")
WHITE = HexColor("#FFFFFF")

FONT_DIR = "assets/fonts/Lato"


def register_fonts(font_dir=FONT_DIR):
    pdfmetrics.registerFont(TTFont("Lato", f"{font_dir}/Lato-Regular.ttf"))
    pdfmetrics.registerFont(TTFont("Lato-Bold", f"{font_dir}/Lato-Bold.ttf"))
    pdfmetrics.registerFont(TTFont("Lato-Black", f"{font_dir}/Lato-Black.ttf"))


# ---------------------------------------------------------------- Satzspiegel
PW, PH = A4
M_L, M_R, M_T, M_B = 20 * mm, 20 * mm, 38 * mm, 22 * mm
NUM_SLOT = 10 * mm                              # Nummernspalte im Außenrand
TEXT_IND = NUM_SLOT                             # Textkante bei 30 mm
TEXT_W = 140 * mm                               # 82 Zeichen bei 11 pt
FRAME_W = PW - M_L - M_R
RIGHT_IND = FRAME_W - TEXT_IND - TEXT_W

BODY_SIZE, BODY_LEAD = 11, 16.5                 # Zeilenabstand 1,5
S_PARA, S_SUB, S_SEC = 8, 24, 48                # die drei Abstandsstufen


def _st(name, **kw):
    base = dict(fontName="Lato", fontSize=BODY_SIZE, leading=BODY_LEAD,
                textColor=DGREY, alignment=TA_LEFT, leftIndent=TEXT_IND,
                rightIndent=RIGHT_IND, spaceBefore=0, spaceAfter=S_PARA)
    base.update(kw)
    return ParagraphStyle(name, **base)


BODY = _st("body")
LEAD = _st("lead", fontSize=12.5, leading=18.75)
H2 = _st("h2", fontName="Lato-Black", fontSize=20, leading=25, textColor=NAVY,
         leftIndent=0, rightIndent=0, spaceAfter=0)
H3 = _st("h3", fontName="Lato-Bold", fontSize=13, leading=17.5, textColor=NAVY,
         spaceBefore=S_SUB, spaceAfter=6)
H3_FIRST = _st("h3f", fontName="Lato-Bold", fontSize=13, leading=17.5,
               textColor=NAVY, spaceBefore=0, spaceAfter=6)
EYEBROW = _st("eyebrow", fontName="Lato-Bold", fontSize=8, leading=11,
              textColor=TEAL, spaceAfter=6)
CALL_EB = ParagraphStyle("ceb", fontName="Lato-Bold", fontSize=8, leading=11,
                         textColor=TEAL, spaceAfter=0)
CALL_TX = ParagraphStyle("ctx", fontName="Lato", fontSize=BODY_SIZE,
                         leading=BODY_LEAD, textColor=DGREY, spaceAfter=S_PARA)
CALL_BD = ParagraphStyle("cbd", fontName="Lato-Bold", fontSize=BODY_SIZE,
                         leading=BODY_LEAD, textColor=NAVY, spaceAfter=0)
PULL = _st("pull", fontSize=15, leading=21, textColor=NAVY, leftIndent=0,
           rightIndent=0, spaceAfter=0)
STEP_NUM = ParagraphStyle("stepnum", fontName="Lato-Black", fontSize=20, leading=22,
                          textColor=TEAL, spaceAfter=0)
STEP_TIT = ParagraphStyle("steptit", fontName="Lato-Bold", fontSize=12, leading=16,
                          textColor=NAVY, spaceAfter=4)
STEP_TXT = ParagraphStyle("steptxt", fontName="Lato", fontSize=10, leading=15,
                          textColor=DGREY, spaceAfter=0)
TBL_HEAD = ParagraphStyle("th", fontName="Lato-Bold", fontSize=8, leading=11, textColor=TEAL)
TBL_CELL = ParagraphStyle("tb", fontName="Lato", fontSize=10, leading=15, textColor=DGREY)
TBL_KEY = ParagraphStyle("tk", fontName="Lato-Bold", fontSize=10, leading=15, textColor=NAVY)

_NOPAD = [("LEFTPADDING", (0, 0), (-1, -1), 0), ("RIGHTPADDING", (0, 0), (-1, -1), 0),
          ("TOPPADDING", (0, 0), (-1, -1), 0), ("BOTTOMPADDING", (0, 0), (-1, -1), 0)]


def spaced(text):
    """Sperrsatz für Eyebrow — reportlab kennt kein letter-spacing."""
    return "&nbsp;".join(text.upper())


class _Indent(Flowable):
    """Hält einen Flowable auf der Textkante statt am Rahmenrand."""
    def __init__(self, inner, dx=TEXT_IND):
        Flowable.__init__(self)
        self.inner, self.dx = inner, dx

    def wrap(self, aw, ah):
        w, h = self.inner.wrap(aw - self.dx, ah)
        return aw, h

    def draw(self):
        self.inner.drawOn(self.canv, self.dx, 0)


class Pill(Flowable):
    """Etikett: Dunkelblau auf Orange. Weiß auf Orange ist unzulässig (2,4:1)."""
    def __init__(self, text, fs=8.5):
        Flowable.__init__(self)
        self.text, self.fs = text, fs
        self.w = pdfmetrics.stringWidth(text, "Lato-Bold", fs) + 20
        self.h = fs + 9

    def wrap(self, aw, ah):
        return self.w, self.h

    def draw(self):
        c = self.canv
        c.setFillColor(ORANGE)
        c.roundRect(0, 0, self.w, self.h, self.h / 2, stroke=0, fill=1)
        c.setFillColor(NAVY)
        c.setFont("Lato-Bold", self.fs)
        c.drawString(10, (self.h - self.fs) / 2 + 1.5, self.text)


def callout(label, paras, accent=TEAL):
    """Hinweiskasten: weiße Fläche, Rand Hellgrau, 3 pt Akzentkante links."""
    rows = [[Paragraph(spaced(label), CALL_EB)]]
    for item in paras:
        txt, bold = item if isinstance(item, tuple) else (item, False)
        rows.append([Paragraph(txt, CALL_BD if bold else CALL_TX)])
    inner = Table(rows, colWidths=[TEXT_W - 3 - 16 * mm])
    inner.setStyle(TableStyle(_NOPAD + [("BOTTOMPADDING", (0, 0), (0, 0), 9)]))
    box = Table([["", inner]], colWidths=[3, TEXT_W - 3])
    box.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (0, 0), accent),
        ("BACKGROUND", (1, 0), (1, 0), WHITE),
        ("LINEABOVE", (1, 0), (1, 0), 0.6, LGREY),
        ("LINEBELOW", (1, 0), (1, 0), 0.6, LGREY),
        ("LINEAFTER", (1, 0), (1, 0), 0.6, LGREY),
        ("LEFTPADDING", (0, 0), (0, 0), 0), ("RIGHTPADDING", (0, 0), (0, 0), 0),
        ("TOPPADDING", (0, 0), (0, 0), 0), ("BOTTOMPADDING", (0, 0), (0, 0), 0),
        ("LEFTPADDING", (1, 0), (1, 0), 8 * mm), ("RIGHTPADDING", (1, 0), (1, 0), 8 * mm),
        ("TOPPADDING", (1, 0), (1, 0), 7 * mm), ("BOTTOMPADDING", (1, 0), (1, 0), 7 * mm),
        ("VALIGN", (0, 0), (-1, -1), "TOP")]))
    return _Indent(box)


def pull(text, accent=TEAL):
    """Merksatz: Akzentkante links, keine Flaeche, kein Rahmen."""
    inner = Table([[Paragraph(text, PULL)]], colWidths=[TEXT_W - 3 - 8 * mm])
    inner.setStyle(TableStyle(_NOPAD))
    box = Table([["", inner]], colWidths=[3, TEXT_W - 3])
    box.setStyle(TableStyle(_NOPAD + [
        ("BACKGROUND", (0, 0), (0, 0), accent),
        ("LEFTPADDING", (1, 0), (1, 0), 8 * mm),
        ("VALIGN", (0, 0), (-1, -1), "TOP")]))
    return _Indent(box)


def steps(etappen):
    """Prozessschritte: zwei bis vier Etappen, nur Oberkante, keine Rahmen.
    etappen: [(nummer, titel, text), ...]"""
    if not 2 <= len(etappen) <= 4:
        raise ValueError("Prozessschritte: zwei bis vier Etappen, bei fuenf und mehr "
                         "gehoert der Ablauf in eine Tabelle nach Stil B")
    n = len(etappen)
    breite = (TEXT_W - (n - 1) * 6 * mm) / n
    spalten = []
    for nummer, titel, text in etappen:
        z = Table([[Paragraph(str(nummer), STEP_NUM)],
                   [Paragraph(titel, STEP_TIT)],
                   [Paragraph(text, STEP_TXT)]], colWidths=[breite])
        z.setStyle(TableStyle(_NOPAD + [("BOTTOMPADDING", (0, 0), (0, 0), 5)]))
        spalten.append(z)
    reihe = []
    for i, sp in enumerate(spalten):
        reihe.append(sp)
        if i < n - 1:
            reihe.append("")
    widths = []
    for i in range(n):
        widths.append(breite)
        if i < n - 1:
            widths.append(6 * mm)
    t = Table([reihe], colWidths=widths)
    stil = [("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("LEFTPADDING", (0, 0), (-1, -1), 0), ("RIGHTPADDING", (0, 0), (-1, -1), 0),
            ("TOPPADDING", (0, 0), (-1, -1), 8), ("BOTTOMPADDING", (0, 0), (-1, -1), 0)]
    for i in range(0, 2 * n - 1, 2):
        stil.append(("LINEABOVE", (i, 0), (i, 0), 0.75, LGREY))
    t.setStyle(TableStyle(stil))
    return _Indent(t)


def table_b(header, rows, widths):
    """Stil B — Basislinie: keine Gitterlinien, eine Haarlinie in Türkis."""
    data = [[Paragraph(spaced(h), TBL_HEAD) for h in header]]
    for r in rows:
        data.append([Paragraph(r[0], TBL_KEY)] + [Paragraph(x, TBL_CELL) for x in r[1:]])
    t = Table(data, colWidths=widths)
    t.setStyle(TableStyle([
        ("LINEBELOW", (0, 0), (-1, 0), 0.8, TEAL),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 0),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6 * mm),
        ("BOTTOMPADDING", (0, 0), (0, 0), 7),
        ("TOPPADDING", (0, 1), (-1, -1), 11),
        ("BOTTOMPADDING", (0, 1), (-1, -1), 0)]))
    return _Indent(t)


def table_a(header, rows, widths):
    """Stil A — Vollton-Kopf: Kopfzeile Dunkelblau, Zebra, keine Senkrechten."""
    data = [[Paragraph(spaced(h), ParagraphStyle("ah", parent=TBL_HEAD, textColor=LBLUE))
             for h in header]]
    for r in rows:
        data.append([Paragraph(r[0], TBL_KEY)] + [Paragraph(x, TBL_CELL) for x in r[1:]])
    t = Table(data, colWidths=widths)
    style = [("BACKGROUND", (0, 0), (-1, 0), NAVY),
             ("VALIGN", (0, 0), (-1, -1), "TOP"),
             ("LEFTPADDING", (0, 0), (-1, -1), 4 * mm),
             ("RIGHTPADDING", (0, 0), (-1, -1), 4 * mm),
             ("TOPPADDING", (0, 0), (-1, -1), 6),
             ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
             ("LINEBELOW", (0, 1), (-1, -1), 0.5, LGREY)]
    for i in range(1, len(data)):
        if i % 2 == 0:
            style.append(("BACKGROUND", (0, i), (-1, i), PAPER))
    t.setStyle(TableStyle(style))
    return _Indent(t)


# ------------------------------------------------------------------ Dokument
class Doc:
    def __init__(self, pfad, titel, untertitel="", eyebrow="", meta=None,
                 fusszeile="", hinweise=(), keyvisual=None, logo_dir="assets/png/logo",
                 font_dir=FONT_DIR, deckblatt_logo="rgb"):
        """deckblatt_logo: "rgb" fuer das farbige Logo auf Dunkelblau (zulaessig,
        siehe SKILL.md Abschnitt 5), "negativ" fuer die weisse Variante."""
        register_fonts(font_dir)
        self.titel, self.untertitel, self.eyebrow = titel, untertitel, eyebrow
        self.meta = meta or []
        self.fusszeile = fusszeile or titel
        self.hinweise = hinweise
        self.keyvisual = keyvisual
        self.logo_dir = logo_dir
        self.deckblatt_logo = "negativ" if deckblatt_logo == "negativ" else "rgb"
        self.story = []
        self._pending_section = False
        self.doc = BaseDocTemplate(pfad, pagesize=A4, leftMargin=M_L, rightMargin=M_R,
                                   topMargin=M_T, bottomMargin=M_B, title=titel)
        frame = Frame(M_L, M_B, FRAME_W, PH - M_T - M_B, id="f", leftPadding=0,
                      rightPadding=0, topPadding=0, bottomPadding=0)
        self.doc.addPageTemplates([
            PageTemplate("cover", [frame], onPage=self._cover),
            PageTemplate("inner", [frame], onPage=self._inner)])
        self.story += [NextPageTemplate("inner"), PageBreak()]

    # -- Bausteine ---------------------------------------------------------
    def section(self, nummer, text):
        """Abschnittsüberschrift. Nummer hängt im Außenrand."""
        t = Table([[Paragraph(f'<font color="#2FACB9">{nummer}</font>', H2),
                    Paragraph(text, H2)]],
                  colWidths=[NUM_SLOT, TEXT_W + RIGHT_IND])
        t.setStyle(TableStyle(_NOPAD + [("VALIGN", (0, 0), (-1, -1), "TOP")]))
        # Abstände addieren sich nicht: der größere gilt
        if self.story and not isinstance(self.story[-1], PageBreak):
            self.story.append(Spacer(1, S_SEC))
        self.story += [t, Spacer(1, 12)]
        self._pending_section = True

    def sub(self, text, pill=None):
        """Unterüberschrift. Direkt nach einer Abschnittsüberschrift ohne Zusatzabstand."""
        style = H3_FIRST if self._pending_section else H3
        if pill:
            if not self._pending_section:
                self.story.append(Spacer(1, S_SUB))
            row = Table([[Paragraph(text, ParagraphStyle("p", parent=style, leftIndent=0,
                                                         spaceBefore=0, spaceAfter=0)),
                          Pill(pill)]],
                        colWidths=[TEXT_W - 32 * mm, 32 * mm])
            row.setStyle(TableStyle(_NOPAD + [("VALIGN", (0, 0), (-1, -1), "MIDDLE")]))
            self.story += [_Indent(row), Spacer(1, 6)]
        else:
            self.story.append(Paragraph(text, style))
        self._pending_section = False

    def p(self, text, style=None):
        self.story.append(Paragraph(text, style or BODY))
        self._pending_section = False

    def label(self, wort, text):
        """Run-in-Label wie 'Dafür:' — kein Zusatzabstand, im Textfluss."""
        self.p(f'<font name="Lato-Bold" color="#000854">{wort}</font> {text}')

    def pull(self, text, accent=TEAL):
        self.story += [Spacer(1, S_SUB - S_PARA), pull(text, accent), Spacer(1, S_SUB - S_PARA)]
        self._pending_section = False

    def steps(self, etappen):
        self.story += [Spacer(1, S_SUB - S_PARA), steps(etappen)]
        self._pending_section = False

    def callout(self, label, paras, accent=TEAL):
        self.story += [Spacer(1, S_SUB - S_PARA), callout(label, paras, accent)]
        self._pending_section = False

    def table(self, header, rows, widths, stil="b"):
        self.story.append((table_a if stil == "a" else table_b)(header, rows, widths))
        self._pending_section = False

    def eyebrow_line(self, text):
        self.story.append(Paragraph(spaced(text), EYEBROW))

    def page_break(self):
        self.story.append(PageBreak())

    def build(self):
        self.doc.build(self.story)

    # -- Seitenrahmen ------------------------------------------------------
    def _cover(self, c, doc):
        c.setFillColor(NAVY)
        c.rect(0, 0, PW, PH, stroke=0, fill=1)
        if self.keyvisual:
            # Grafik muss mit keyvisual.py erzeugt sein: gleiche Deckkraft aller
            # Linien, Randausblendung, Türkis 28 % auf Dunkelblau
            size = 210 * mm
            c.drawImage(self.keyvisual, PW - size * 0.62, PH - size * 0.80,
                        width=size, height=size, mask="auto")
        x = 30 * mm
        if self.eyebrow:
            c.setFont("Lato-Bold", 8.5)
            c.setFillColor(TEAL)
            c.drawString(x, 118 * mm, "  ".join(self.eyebrow.upper()))
        c.setFont("Lato-Black", 27)
        c.setFillColor(WHITE)
        c.drawString(x, 100 * mm, self.titel)
        if self.untertitel:
            c.setFont("Lato", 12)
            c.setFillColor(LBLUE)
            for i, zeile in enumerate(self.untertitel.split("\n")):
                c.drawString(x, (88 - i * 6.5) * mm, zeile)
        c.setStrokeColor(TEAL)
        c.setLineWidth(1.4)
        c.line(x, 70 * mm, x + 22 * mm, 70 * mm)
        y = 56 * mm
        for k, v in self.meta:
            c.setFont("Lato", 9); c.setFillColor(TEAL); c.drawString(x, y, k)
            c.setFont("Lato", 9.5); c.setFillColor(WHITE); c.drawString(x + 27 * mm, y, v)
            y -= 6.2 * mm
        # Auf Dunkelblau ist das farbige Logo zulaessig, siehe SKILL.md Abschnitt 5.
        # Die graue Wortmarke erreicht dort 4,57:1 und bleibt lesbar.
        c.drawImage(f"{self.logo_dir}/itk-logo-{self.deckblatt_logo}.png", x, 20 * mm,
                    width=38 * mm, height=38 * mm * 371 / 1200, mask="auto")
        c.setFont("Lato", 8); c.setFillColor(LBLUE)
        for i, t in enumerate(self.hinweise):
            c.drawRightString(PW - 30 * mm, 27 * mm - i * 4.6 * mm, t)

    def _inner(self, c, doc):
        c.setFillColor(WHITE)
        c.rect(0, 0, PW, PH, stroke=0, fill=1)
        h = 32 * mm * 371 / 1200
        c.drawImage(f"{self.logo_dir}/itk-logo-rgb.png", PW - 30 * mm - 32 * mm,
                    PH - 20 * mm - h, width=32 * mm, height=h, mask="auto")
        c.setStrokeColor(LGREY); c.setLineWidth(0.5)
        c.line(30 * mm, M_B - 6 * mm, PW - 20 * mm, M_B - 6 * mm)
        c.setFont("Lato", 8); c.setFillColor(DGREY)
        c.drawString(30 * mm, M_B - 11 * mm, self.fusszeile)
        c.drawRightString(PW - 20 * mm, M_B - 11 * mm, f"Seite {doc.page - 1}")
