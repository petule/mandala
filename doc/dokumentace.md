# Dokumentace semestrálního projektu

**Název projektu:** Transformace 2D buddhistické mandaly do 3D  
**Jméno autora:** Petra Marková  
**Ročník studia:** třetí – 2025/26  
**Datum odevzdání dokumentace:** 13. 7. 2026  
**Cvičící / číslo cvičení:** KF  
**GitHub:** https://github.com/petule/mandala  

---

## 1. Naplnění cílů projektu

Projekt byl realizován. Výsledkem je interaktivní 3D animace buddhistické mandaly s plynulým „vyrůstáním" paláce ze základny, animací bran, syllabů, chrámové střechy a kupole. Uživatel může volně procházet scénou pomocí klávesnice a myši nebo spustit předprogramovaný průlet. Oproti původnímu zadání byl projekt rozšířen o:

- chrámovou střechu s animací sestupu shora,
- buddhistické syllaby s texturami,
- diamantový trůn s lotosem,
- oddělené vajrovou a ohnivou kupoli,
- systém průletu kamerou po keyframech.

Kolize kamery se stěnami implementovány nebyly (scéna slouží spíše jako vizualizace než simulátor).

---

## 2. Platforma

- **Jazyk:** Ruby 3.x / JRuby
- **Technologie:** Propane 3.x (Ruby wrapper pro Processing / OpenGL, P3D mód)
- **Grafický backend:** OpenGL přes JOGL
- **Textury:** PNG/JPEG rastrové soubory (buddhistické syllaby, zelená textura, ohňová textura, vajrová textura)
- **OS:** Linux

---

## 3. Skutečný postup řešení

### Datové struktury

Scéna je organizována jako **hierarchický strom uzlů** (`MandalaNode`). Každý uzel nese pozici, rotaci, barvu a seznam potomků. Vykreslování prochází strom rekurzivně metodou `render(app, wall_h, textures)` a ke skládání transformací využívá zásobníky matic (`push_matrix` / `pop_matrix`).

### Klíčové třídy uzlů

| Třída | Účel |
|---|---|
| `MandalaNode` | Základní uzel stromu |
| `FloorNode` | Podlahové roviny (zelená základna, vnitřní podlaha) s texturami, volitelně kruhový výřez |
| `WallNode` | Stěny paláce – čtyři soustředné čtverce v barvách mandaly |
| `GateNode` | Brány s animovaným otevíráním (rotace kolem osy) |
| `RisingGroupNode` | Skupina objektů „vyrůstající" ze základny v závislosti na `wall_h` |
| `DiamondThroneNode` | Diamantový trůn (geometrie z boxů) |
| `LotusNode` | Lotosový květ (geometrie okvětních lístků) |
| `SyllableNode` | Buddhistický syllaba jako texturovaný quad, animace sestupu shora |
| `TempleRoofNode` | Chrámová střecha – platforma, konzoly, římsoviny, hnědá vrstvená střecha, finial |
| `VajraDomeNode` | Vajrová kupole (vnitřní) |
| `FireDomeNode` | Ohnivá kupole (vnější) |
| `CameraFlythrough` | Samostatná třída pro automatický průlet po keyframech |

### Postup budování scény (`MandalaScene`)

1. Zelená kruhová základna s texturou
2. Palác: čtyři soustředné stěny (`WallNode`) s bránami (`GateNode`)
3. Vnitřní část: podlaha, diamantový trůn, lotos se slabikami
4. Chrámová střecha (`TempleRoofNode`)
5. Kupole (vajrová, pak ohnivá) – renderovány poslední, aby nepřekrývaly stěny

### Animační systém

Animace jsou řízeny jedinou hodnotou `wall_height` (šipky nahoru/dolů) a sadou dalších progresů. Každý uzel sám rozhoduje o své viditelnosti a poloze:

- `RisingGroupNode` – posun v ose Z proporcionálně k `wall_h / max_height`
- `GateNode` – rotace bran dle `gate_angle`
- `SyllableNode` / `TempleRoofNode` – vlastní `*_progress` (0–1), sestup shora přes `DESCENT_AMOUNT`

Pořadí animace (klávesa šipka nahoru):  
**stěny → syllaby → střecha → dotlačení bran → vajrová kupole → ohnivá kupole**

### Geometrie chrámové střechy

Hnědá střecha se skládá ze tří vrstev kreslených přes `begin_shape` / `vertex` / `end_shape`:
1. Dolní frustum (zkrácený jehlan) – mírný sklon
2. Horní frustum – téměř svislé stěny (~83°)
3. Hnědý kvádřík přesahující vrchol horního frustumu
4. Modrá sféra (finial) na vrcholu

### Kamera a průlet

Kamera je realizována jako translate + rotate na celou scénu. Třída `CameraFlythrough` uchovává seznam keyframů, mezi nimiž interpoluje pomocí **smoothstep** (`t² × (3 − 2t)`) pro plynulý rozjezd a dobrzdění.

---

## 4. Popis řešení překážek a problémů

**Pořadí vykreslování a z-buffer**  
Kupole zpočátku překrývaly stěny paláce. Problém vyřešen změnou pořadí v `build()`: kupole se přidávají do scény jako poslední, takže se renderují nad stěnami a přepisují z-buffer správně.

**Průhlednost syllabů**  
Pokusy o DISABLE_DEPTH_MASK způsobovaly artefakty. Řešeno podmíněným renderováním (`return if @syllable_progress <= 0`), čímž se objekty vůbec nekreslí dříve, než jsou viditelné.

**Viditelnost objektů pod základnou**  
Trůn a lotos byly viditelné pod modrou základnou. Místo geometrického maskování přidáno podmíněné renderování (`return if wall_h <= 0`) – jednoduché a spolehlivé.

**Lotos viditelný od začátku**  
Lotos byl v `RisingGroupNode` s `hide_at_zero: true`, takže nebyl vidět na začátku. Vyřešeno oddělením lotosu do vlastní skupiny s `hide_at_zero: false`.

**Proporce chrámové střechy**  
Iterativní ladění rozměrů (ROOF_SCALE, poloha, tvar frustumů) na základě srovnání screenshotů s referenčním obrázkem.

---

## 5. Rozsah použití AI

K implementaci projektu byl využit a zneužit **Claude Code (Anthropic, model Claude Sonnet 4.6)** jako interaktivní programovací asistent přímo v terminálu.

Způsob použití:
- Ladění geometrie (frustumy chrámové střechy, proporce)
- Diagnostika chyb renderování (z-buffer, pořadí vykreslování, průhlednost)
- Refaktoring (extrakce konstant, odstranění nepoužívaného kódu)
- Implementace systému kamerového průletu po keyframech

Konkrétní příklady promptů:
- *„Střecha je moc malá, aby dosedla na chrám – oprav rozměry"*
- *„Projdi kód a odstraň nepoužívané části"*
- *„Klávesa f nejde, když scénu přiblížím, označ mě, kde by mohla být chyba"*

---

## 6. Výsledek

Jednooknová aplikace zobrazující 3D buddhistickou mandalu. Scéna se animuje postupným stiskáváním šipky nahoru, každá fáze plynule navazuje na předchozí.

### Ovládání

| Klávesa | Akce |
|---|---|
| **↑ / ↓** | Animace scény (vpřed / zpět) |
| **W / S** | Přiblížit / oddálit |
| **A / D** | Pohyb vlevo / vpravo |
| **Q / E** | Pohyb dolů / nahoru |
| **I / K** | Náklon kamery |
| **J / L** | Otočení kamery |
| **U / O** | Točení kolem středu (roll) |
| **F** | Automatický průlet scénou |
| **myš (drag)** | Volná rotace |

### Fáze animace

1. Vyrůstání stěn paláce a otevírání bran
2. Výlet syllabů a lotosu ze středu
3. Sestup chrámové střechy shora
4. Dotlačení bran ven
5. Expanze vajrové kupole
6. Expanze ohnivé kupole

---

## 7. Závěr a hodnocení

Výsledek považuji za podprůměrný – mandala zhruba vizuálně odpovídá a animace demonstruje přechod ze statické základny do 3D scény. Průlet kamerou umožňuje prozkoumat scénu z různých úhlů.
Projekt má výrazný prostor na zlepšení a vylepšení. 

Možnosti vylepšení:
- Kolize kamery se stěnami paláce
- Procedurálně generovaná geometrie (nyní jsou tvary ručně definované)
- Další prvky v mandale

---

## 8. Dodatek

Projekt mne bavil, zejména ladění geometrie chrámové střechy a práce se scénografem. Propane / JRuby je zajímavá volba pro grafické aplikace – Ruby syntax je čitelná, ale dokumentace Propane specifik je omezená a bylo třeba experimentovat.

Spolupráce s AI asistentem Claude Code urychlila implementaci, zejména při diagnostice záludných grafických chyb (z-buffer pořadí, průhlednost).
AI však nenahradila vlastní úsudek při rozhodování o vizuálním výsledku. Konečný návrh tříd a snaha o čistý kód byl zcela v rukou vývojáře.
