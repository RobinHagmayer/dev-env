# Druck und professionelles PDF

Ergänzung zu `SKILL.md`. Gilt für Flyer, Datenblätter, Roll-ups, Messewände, Visitenkarten und alles, was in eine Druckerei geht.

## Farbe

- Druck wird in **CMYK** angelegt, nicht in RGB. Die CMYK-Werte stehen in `SKILL.md` Abschnitt 2 und sind verbindlich – nicht aus den HEX-Werten automatisch konvertieren lassen, das ergibt abweichende Töne.
- Für Hellrot, Hellgrün, Papier und Tinte liegen keine freigegebenen CMYK-Werte vor. Diese Farben im Druck vermeiden oder vor der Produktion verbindliche Werte einholen – nicht selbst festlegen.
- Dunkelblau `100/95/30/55` ist ein Tiefdruckton mit hoher Farbdeckung. Auf ungestrichenem Papier fällt er dunkler und matter aus als am Bildschirm.
- Keine Verläufe über große Flächen – sie neigen im Druck zu sichtbaren Stufen. Wenn ein Verlauf nötig ist: nur zwischen Dunkelblau, Tiefblau und Türkis und nur über kleine Flächen.

## Anlage

- Beschnittzugabe **3 mm** an allen Seiten
- Sicherheitsabstand für Inhalte **5 mm** innerhalb des Endformats, bei Roll-ups und Messewänden **mindestens 40 mm** an allen Rändern
- Auflösung platzierter Bilder **300 dpi** im Endformat, bei Großformat ab A1 sind 150 dpi ausreichend
- Schriften einbetten oder in Pfade umwandeln
- Logo als Vektor platzieren, niemals als PNG oder JPG
- Mindestbreite Logo im Druck **25 mm**
- Auf dunkelblauen Flächen ist das farbige Logo zulässig, auf Tiefblau und Türkis nur die Negativvariante. Im Druck zusätzlich beachten: Der Grauton der Wortmarke steht auf ungestrichenem Papier schwächer als am Bildschirm – im Zweifel Negativ

## Satzspiegel und Typografie

Für gesetzte Dokumente – Strategiepapiere, Berichte, Datenblätter, Angebote – gilt derselbe Satzspiegel wie in Word:

| Größe | Wert |
|---|---|
| Format | A4 Hochformat |
| Textspalte | 140 mm (rund 82 Zeichen) |
| Rand oben / unten | 38 mm / 22 mm |
| Rand links / rechts | 30 mm / 40 mm |
| Nummernspalte im Außenrand | 10 mm |
| Fließtext | 11 pt, Zeilenabstand 1,5 (16,5 pt) |
| Abstandsstufen | 8 / 24 / 48 pt, keine Zwischenwerte, keine Addition |

Tabellen und Abbildungen dürfen bis 160 mm in den Außenrand laufen, Fließtext nie.

**Geprüfte Umsetzung:** `scripts/itk_pdf_layout.py` enthält diesen Satzspiegel als reportlab-Modul, einschließlich hängender Abschnittsnummern, Hinweiskästen mit Akzentkante, Merksatz, Prozessschritten, beider Tabellenstile und des Etiketts in Dunkelblau auf Orange. Beim Erzeugen von PDF dieses Modul verwenden statt die Werte neu abzuleiten.

Die Punkt-Skala aus `references/office.md` gilt im Übrigen sinngemäß, mit zwei Abweichungen:

- Reine Druckerzeugnisse ohne Bildschirmnutzung – Flyer, Datenblätter – dürfen auf **9 bis 10 pt** heruntergehen, dann mit Zeilenabstand 140 %
- Negativer Text (hell auf Dunkelblau) einen Schritt kräftiger setzen als positiver Text – feine Linien in Lato Light brechen im Druck auf dunklem Grund weg. Mindestens Regular, besser Bold.

## Tabellen im Druck

Nur **Stil B – Basislinie**. Vollflächige Kopfzeilen und Zebra-Zeilen kosten im Druck Farbe, verlängern die Trocknung und wirken auf ungestrichenem Papier fleckig. Die Sonderform Dunkelgrund ist im Druck nicht zulässig.

## Key Visual auf Titelseiten

Die Grafik mit `scripts/keyvisual.py` erzeugen, nicht die SVG direkt platzieren:

    python3 scripts/keyvisual.py arc-bl titel.png --size 2200 --color "#2FACB9" \
        --opacity 28 --sides lb

`--sides` nennt die Seiten, auf denen ausgeblendet wird – also die zum Seiteninneren zeigenden. An der Ankerkante bleibt das Cluster voll und läuft über den Seitenrand hinaus. Bogen im Sichtfeld. Auf hellen Titelseiten `--color "#CCCCCC" --opacity 30`. Zwei überlagerte Cluster nur auf dunklem Grund, dann mit `--second`.

## Key Visual im Druck

- Strichstärken nicht unter **0,25 mm** – dünnere Linien reißen im Offsetdruck ab
- Bei Großformat Strichstärke proportional mitskalieren, nicht konstant lassen
- Maximal drei Cluster, bei Roll-ups wegen der Betrachtungsentfernung nur eines

## Icons im Druck

- Brand-Icons ohne Box, Mindestkantenlänge **13 mm**; die elf detailreichen Icons nicht unter 25 mm. Bei Roll-ups und Großformat wegen der Betrachtungsentfernung mindestens 25 mm.
- Unter 13 mm ein UI-Icon einsetzen statt das Brand-Icon zu verkleinern
- Strichstärke der Icons prüfen: bei starker Verkleinerung fällt sie unter 0,25 mm und reißt im Druck ab. Dann größer setzen oder weglassen.
- UI-Icons sind für Bildschirmgrößen gezeichnet und im Druck nur in Anleitungen und Bedienhinweisen sinnvoll, nicht als Schmuckelement.
- Icons in CMYK umstellen, nicht in RGB platzieren.

## Vor der Abgabe prüfen

PDF nach dem Erzeugen rendern und ansehen. Am Bild gezielt gegenprüfen:

- Zeilenabstand 1,5 und Textspalte nicht breiter als 140 mm?
- Nur die drei Abstandsstufen, Abschnittswechsel deutlich sichtbar?
- Abschnittsnummern im Außenrand, alle Textzeilen auf einer Kante?
- Key Visual von einer Seitenkante angeschnitten, blasser als die Überschrift, nicht mittig?
- Fokus-Sechseck nur mit Bezugsobjekt, sonst gar nicht?
- Text auf Orange in Dunkelblau, nicht in Weiß?
- Hinweiskästen mit 3 pt Akzentkante links, weiße Fläche, linke Ecken eckig?

Anschließend die vollständige Prüf-Checkliste aus `SKILL.md` Abschnitt 11 durchgehen. Dieser Schritt ist verbindlich, nicht optional.

## Was nicht geregelt ist

Papiersorten, Grammaturen, Veredelungen und Sonderfarben sind nicht Teil dieses Regelwerks. Bei entsprechenden Fragen darauf hinweisen, dass hierzu keine Vorgabe vorliegt.
