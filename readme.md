# Graphite — Home-Assistant-Theme

Ein HA-Theme im Farbschema des **Graphite**-Standard-Themes aus
[`app_calibri`](https://git.itup.ch/mme/app_calibri) (`src/app/app.css`): helle
Graustufen auf fast weißem Grund bzw. abgesetzte Karten auf fast schwarzem
Grund, Akzent Blau. Keine eigenen Farben — jede Rolle nimmt den Wert aus
`app.css`; ergänzt ist nur, was `app.css` nicht hergibt (Kennzeichnung in der
Datei selbst).

## Einbau

```yaml
# configuration.yaml
frontend:
  themes: !include_dir_merge_named themes
```

`themes/graphite.yaml` nach `config/themes/` kopieren, HA neu starten, dann unter
**Profil → Erscheinungsbild → Theme** wählen.

Drei Themes zur Wahl:

| Theme            | Verhalten                                          |
| ---------------- | -------------------------------------------------- |
| `Graphite`       | folgt dem Hell-/Dunkel-Modus von HA (empfohlen)    |
| `Graphite Hell`  | immer hell (z. B. Dashboard im Eingang)            |
| `Graphite Dunkel`| immer dunkel (z. B. Wandtablet)                    |

## Woher welche Farbe kommt

`app.css` belegt Tailwind-Stufen (`--color-slate-*` heißt dort alles, was
graphite neutral braucht). Die Zuordnung auf die HA-Rollen:

| Rolle (Graphite)            | app.css                | HA-Variable(n)                                   |
| --------------------------- | ---------------------- | ------------------------------------------------ |
| Canvas (Seitenhintergrund)  | `slate-50` / `slate-950` | `primary-background-color`, `lovelace-background` |
| Karte / Seitenleiste        | `bg-white` / `slate-900` | `card-background-color`, `sidebar-background-color`, `app-header-background-color` |
| Füllung / Hover             | `slate-100` / `slate-800` | `secondary-background-color`, `ha-color-fill-neutral-*` |
| Eingabefeld                 | `slate-50` / `slate-800` | `input-fill-color`, `ha-color-form-background`   |
| Rahmen                      | `slate-200` / `slate-800` | `divider-color`, `ha-card-border-color`, `ha-color-border-neutral-quiet` |
| Text                        | `slate-900` / `slate-100` | `primary-text-color`, `ha-color-text-primary`    |
| Gedämpfter Text             | `slate-500`/`slate-400` / `slate-200` | `secondary-text-color`, `state-icon-color` |
| Akzent                      | `--color-emerald-*` (Blau) | `primary-color`, `accent-color`, `ha-color-*-primary` |
| Gefahr / Warnung / Info / Erfolg | `--color-red-*`, `--color-amber-*`, `--color-sky-400`, `--ring-ok` | `error-color`, `warning-color`, `info-color`, `success-color` |
| Text auf Akzent             | `text-white` / `dark:text-slate-950` | `text-primary-color`, `ha-color-on-primary-loud` |

Drei Ebenen, weil HA heute drei Schichten hat (Stand Frontend `20261028.6`):

1. `graphite-*` — die Rollen, Werte 1:1 aus `app.css`.
2. `ha-color-*` — die HA-Paletten (05–95), aus den Rollen abgeleitet: 05–30
   Richtung Textfarbe gemischt, 40/50 Originalwert, 60–95 Richtung Kartenfläche.
   Die `color-mix()`-Stufen aus `app.css` liegen exakt auf 90/95 (hell) bzw.
   80/90/95 (dunkel). Im dunklen Modus ist die Rampenrichtung umgekehrt, damit
   HAs Semantik-Referenzen in beiden Modi gültig bleiben.
3. Semantik + Legacy (`color.globals.ts`) + Komponenten-Variablen — verweisen
   nur noch auf Ebene 1 und 2.

Die semantische Ebene ist **vollständig** ausgeschrieben, auch die Werte, die
HA selbst schon richtig gesetzt hätte: HAs eigener Dunkel-Block würde sonst
einige Graphite-Werte überstimmen.

## Bewusste Entscheidungen

- **Icons nicht eingefärbt.** `state-icon-color` ist Graphite-Grau, nicht Blau —
  genau wie in der App (inaktive Navigation ist `slate-500`/`slate-400`, aktiv
  erst der Akzent). Wer HA-typisch blaue Icons will:
  `state-icon-color: "var(--graphite-accent)"`.
- **Form bleibt HAs Standard.** Kartenradius, Kartenrand, Schalterform und
  Dialogradius sind im Theme absichtlich nicht gesetzt — `app.css` themt nur
  Farben. Der 1-px-Kartenrand, den HA standardmäßig hat, zieht dabei über
  `divider-color` automatisch die Graphite-Rahmenfarbe.
- **Fünf Bunttöne, 54 Serienfarben.** Graphite kennt nur Akzent, Gefahr,
  Warnung, Info, Erfolg. HA braucht für Graphen/Kalender 54 (`--color-1..54`)
  und Community-Karten 14 (`--graph-color-1..14`). Das 14-Ton-Rad darunter ist
  aus den fünf abgeleitet (gleiche Tonlage, gleiche Sättigung), pro Runde über
  vier Tonlagen. Lila/Rosé/Türkis sind damit die einzigen erfundenen Töne.
- **Schrift, Abstände, Radii sonst unverändert** — `app.css` themt nur Farben.

## Aktualisieren

`app.css` ist die Quelle. Wenn sich dort etwas ändert, in `themes/graphite.yaml`
die betroffene Rolle bei den `graphite-*`-Werten beider Modi anpassen — wegen
der `var()`-Ketten ist das meist eine Zeile pro Modus. Rampe, Semantik und
Legacy ziehen automatisch nach.
