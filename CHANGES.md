# Divergences from upstream

Every change to the data from archived
[BSData/wh40k-7th-edition](https://github.com/BSData/wh40k-7th-edition)
(upstream last commit February 2021), newest first.

Rebuild upstream's view of any file with
`git diff upstream/master -- "<file>"`.

---

## Space Marines — Codex (2015)

File: `Space Marines - Codex (2015).cat` · catalogue revision 2051 → 2052

### Changed: Terminus Ultra weapon list now shows as plain quantities

Leo asked for the weapon list to read as "2 Lascannons and 3 Twin-linked
Lascannons, with the Twin-linked keyword attached" instead of the bundled,
custom-named entries from Session 3 (`Two Sponson-mounted Twin-linked
Lascannons`, `Two Sponson-mounted Lascannons`, `Hull-mounted Twin-linked
Lascannon` — one selection each, standing in for 2, 2, and 1 weapon
respectively via naming only).

**Change:** replaced those 3 renamed/bundled `entryLink`s with 5 plain,
unrenamed ones — three targeting the shared `Twin-Linked Lascannon` entry
(`c092-b766-018e-4523`) and two targeting the shared `Lascannon` entry
(`253c-b2c6-1345-e619`) — each a separate min1/max1 selection, still
zero-costed (price baked into the 300pt base). No change to points, stats,
or anything else. Sponson vs. hull-mounted flavor text is gone from the
weapon names; the unit still has the same 5 lascannons total (2 plain, 3
twin-linked). Revision 2051 → 2052.

### Fixed: Land Raider Terminus Ultra wasn't actually selectable anywhere

Leo reported that after updating, the Terminus Ultra (added last session,
`74b5548`) didn't show up as a Lord of War choice in an Ultramarines Combined
Arms Detachment — or in any detachment at all.

**Root cause:** this catalogue doesn't make a unit choosable in a generic
Combined Arms/Allied Detachment just by giving its master `selectionEntry`
its own `<categoryLinks>`. Every other unit in the file (Land Raider
Crusader, Land Raider Redeemer, the `(FW) Mastodon Heavy Assault Transport`,
etc.) is *also* wired into the catalogue's root-level `<entryLinks>` list
(a direct child of `<catalogue>`, not nested in any `forceEntry`) with its
own `categoryLink` — that root list is what actually populates the "add
unit" picker for the base Force Org categories. Terminus Ultra had a
`categoryLink` on its own `selectionEntry` (`7ffa-1c2e-8f4d-a004`, targeting
the shared Lords of War category) but no entry in that root list at all, so
nothing ever offered it as a pickable option — it was invisible from every
Chapter's Combined Arms Detachment, not just Ultramarines.

Confirmed this by checking Mastodon's own wiring: it has the *identical*
self-declared `categoryLink` pattern Terminus Ultra used, **plus** a
one-line `entryLink` (`b586-d5d9-053f-00bb`) in the root list with its own
`categoryLink` to Lords of War. Session 2's Terminus Ultra writeup only
verified the self-declared-`categoryLink` half of Mastodon's pattern and
missed the root `entryLink` half.

**Fix:** added `entryLink id="7ffa-1c2e-8f4d-a012"` (`targetId` = Terminus
Ultra's `7ffa-1c2e-8f4d-a001`) to the catalogue's root `<entryLinks>` list,
directly after Mastodon's own entry, with a `categoryLink` to the shared
Lords of War category (`c888f08a-6cea-4a01-8126-d374a9231554`) — an exact
mirror of Mastodon's entry, id-prefixed to match the rest of the Terminus
Ultra family. No other change to the unit itself.

---

File: `Space Marines - Codex (2015).cat` · catalogue revision 2049 → 2050 · game
system revision reference bumped 2041 → 2042 (see game system rename, below)

### Added: Land Raider Terminus Ultra (Lord of War) — *custom addition, not upstream data*

Not an errata fix — this is new content Leo asked for, reconstructed from a
photo of a (non-BSData) Terminus Ultra datasheet, cross-checked against this
catalogue's own Land Raider/Predator/Razorback Lascannon profiles for the
weapon stats. Recorded here so it's clear this unit's stats come from a
different provenance than the rest of the file and aren't a book-verified
fix like everything else in this changelog.

**Source:** user-supplied photo of a Terminus Ultra card (partially cropped —
Hull Points and points cost were not visible in the photo and were supplied
by Leo directly rather than read off the card).

**What it is:** `7ffa-1c2e-8f4d-a001`, inserted as a sibling of Land Raider /
Land Raider Crusader / Land Raider Redeemer. BS4, Front/Side/Rear 14/14/14,
HP4, `Vehicle (Tank)` (no Transport — Leo confirmed no transport capacity),
300 points. Special rules: Power of the Machine Spirit (shared BRB rule,
same infoLink the other Land Raiders use) plus a unique "Power Overload"
rule (verbatim from the card: 4+ unmodified to-hit rolls of 1 in a single
Shooting phase before twin-linked re-rolls inflicts a penetrating hit on
itself after shooting resolves).

**Weapons** (all fixed loadout, no choices — three entryLinks into the
catalogue's existing shared weapon entries, renamed and zero-costed since
baked into the 300pt price, mirroring how the regular Land Raider already
reuses `c092-b766-018e-4523` for its own sponsons):
- Two sponson-mounted Twin-Linked Lascannons (`c092-b766-018e-4523`)
- Two sponson-mounted (single) Lascannons (`253c-b2c6-1345-e619`)
- One hull-mounted Twin-Linked Lascannon (`c092-b766-018e-4523` again)
- Searchlight and Smoke Launchers (`eb53-cd56-7d70-e009`, the same bundled
  item every other Land Raider variant uses)
- Optional Hunter-killer Missile, +10pts (own inline copy — matches the
  existing `fbb8-7479-39a7-6674` HK Missile profile: Range Infinite, S8,
  AP3, Heavy 1, One Use — priced at 10pts on the card, same as this entry)

**Force Org:** single `categoryLink` to the shared "Lords of War" category
(`c888f08a-6cea-4a01-8126-d374a9231554`, defined in `Warhammer40K.gst`) —
same one-link pattern the "(FW) Mastodon Heavy Assault Transport" entry
already uses. No Chapter/Faction-specific gating, so it's available to any
Space Marines Combined Arms Detachment from the start, per Leo's request.
Deliberately does **not** carry the `Super-heavy Vehicle` unit type or any
of its universal rules (ignoring Crew Shaken/Stunned, etc.) — Leo was
explicit this unit is a Lord of War in Force Org slot only, and should
otherwise play as an ordinary Tank.

**Open/unconfirmed:** the 300pt cost and HP4 came from Leo directly, not
from a fully-legible source card — worth double-checking against the
original Forge World/Index Astartes publication if that ever surfaces.

## Game system rename — `Warhammer40K.gst`

Renamed the declared game system name from "Warhammer 40,000 7th Edition"
to "Warhammer 40,000 7th Edition Revised" (revision 2041 → 2042), so tools
that display a data source by its declared name (New Recruit, BattleScribe)
show this fork as visibly distinct from the unmodified upstream BSData
files, rather than appearing identical. Catalogue files need their
`gameSystemRevision` attribute bumped to 2042 to match — done so far only
for `Space Marines - Codex (2015).cat`; every other `.cat` file in this repo
still references the old revision number and should be bumped the same way
before this is fully consistent (cosmetic staleness only, not a functional
break).

---

## Chaos Space Marines — Codex (2012)

File: `Chaos Space Marines - Codex.cat` · catalogue revision 2026 → 2028

### 1. Typhus missing from Lord of the Legion — *confirmed*

**Symptom.** No HQ option for Typhus when building a Death Guard Vectorium.

**Cause.** The Vectorium, like every Traitor Legions warband detachment,
exposes only Core / Command / Auxiliary categories — no HQ. Individual
characters are therefore reached through the Command slot's
**Lord of the Legion** formation (`93c3-09e1-6c81-5fb6`). Its "Pick One"
group listed Magnus the Red, Exalted Sorcerer, Ahriman, Daemon Prince,
Chaos Lord, Sorcerer, Dark Apostle and Abaddon the Despoiler — every
other legion's named character, but not Typhus.

**Fix.** Added entryLink `7d41-0c9e-b2a6-5e13` → Typhus
(`178b-a991-19ba-d4e2`) to the Pick One group, hidden unless Death Guard
is the selected legion.

*Not* a bug, though it looks like one: Lord of the Legion's own link
(`5ca2-e8d2-d9e6-b8a8`) carries `instanceOf: CSM Black Crusade Detachment`
on a `set hidden=true` modifier. That hides it **in** the Black Crusade
Detachment — which has its own HQ handling — and leaves it available
everywhere else, Vectorium included. Read `instanceOf` on a
`hidden=true` modifier as "hide *when*", `notInstanceOf` as "hide *unless*".

### 2. Marks of Chaos hidden under every non-vanilla legion — *unconfirmed*

**Symptom.** Selecting Force Options → Select force → Death Guard in a
Combined Arms Detachment leaves all four Marks of Chaos unavailable, when
Mark of Nurgle should be available and in fact mandatory.

**Cause (theory).** Each mark carries two modifiers that reference the same
subfaction by *different* identifiers:

| modifier | references legions by |
|---|---|
| `set hidden=false` (visibility) | entry**Link** id — e.g. `4635-d223-be9f-4960` |
| `set <constraint>=1` (mandatory) | selection**Entry** id — e.g. `9c55-dd66-6f7b-8bc8` |

Only one form can be what the engine matches. The single exception in all
four unhide lists is `No unique force (Vanilla CSM Codex)`, which is
declared inline and so is referenced by entry id. If the engine matches
entry ids and not link ids, every mark is hidden under every legion except
vanilla — Death Guard, Black Legion, Word Bearers and Crimson Slaughter
alike. That matches the symptom, including all four marks vanishing rather
than just Nurgle.

The VotLW trigger is probably incidental. Nothing in the catalogue reacts
to Veterans of the Long War except 19 `+1 Ld` stat modifiers
(`4a42059d-…` is the Ld characteristic type, not a constraint). Ticking it
forces a recompute, during which Mark of Nurgle's mandatory gate — the
entry-id one, which *does* fire — takes effect.

**Fix.** Added 31 conditions across 8 mark entries (4 shared plus inline
copies on Chaos Lord and others) so each unhide gate matches both the link
id and the entry id of Death Guard, Black Legion, Word Bearers and Crimson
Slaughter. Widening an OR list can only make a mark appear, never
disappear, so this is safe even if the theory is wrong.

**Falsifying test.** Under Death Guard, Mark of Nurgle should now appear
and be mandatory while the other three stay hidden (Death Guard appears
only in Nurgle's unhide list). Check **Black Legion** too — the theory
predicts marks were equally broken there. If Black Legion marks worked
fine before this change, the engine does resolve link ids, the theory is
dead, and the real cause is still open.

### 3. Magnus, Ahriman and Abaddon selectable in a Death Guard Vectorium — *confirmed*

**Symptom.** Codex: Traitor Legions p.116 says a Death Guard Detachment
"cannot include any Unique units other than Typhus" — every other named
character is forbidden. But Lord of the Legion's Pick One group (see fix
#1 above) still let Magnus the Red, Ahriman and Abaddon the Despoiler
through under Death Guard, since only Typhus's own entry was gated (fix
#1) and the group's other three named-character entries carried no
legion condition at all.

**Cause.** `b924-f681-c206-ebb9` → Magnus the Red, `3b05-e6d8-eca6-6f71` →
Ahriman, and `5118-d1bb-6e11-bf0a` → Abaddon the Despoiler each had an
empty `<modifiers/>`. Nothing hid them under any legion, Death Guard
included. (This is correct and intentional for every *other* legion —
Codex: Chaos Space Marines lets any Traitor Legion army take any of these
three; Death Guard is the one legion with an explicit exclusivity clause.)

**Fix.** Added a `set hidden=true` modifier to all three entryLinks,
firing when Death Guard is selected. Matched Typhus's own fix (#1) for
robustness against the dual-id issue in #2: the condition is an OR of
both id forms seen for Death Guard elsewhere in this file — entryLink id
`4635-d223-be9f-4960` and selectionEntry id `9c55-dd66-6f7b-8bc8` — so it
fires regardless of which form the engine actually resolves in a given
Force Org context.

Chaos Lord, Sorcerer and Daemon Prince entries in the same Pick One group
were deliberately left alone — they're generic HQ choices, not unique
units, and the book's own Vectorium description (p.118) lists them as
legal Death Guard picks.

---

## Known issues, not yet fixed

Found while investigating the above; left alone deliberately.

- **Two Command formations can never be selected.** `The Chosen of Abaddon`
  (entryLink `2a33-f6e4-4e07-c464`) and `The Bringers of Despair`
  (`62b3-0b04-5efe-402c`) both have base `hidden="true"` *and* a modifier
  whose only effect is to set `hidden=true`. Nothing can reveal them. The
  fix is to flip the base attribute to `false` and let the modifier gate
  them, matching the working links around them.
- **Typhus is `type="upgrade"`.** Abaddon, Magnus, Ahriman and Chaos Lord
  are all `type="model"`. Affects per-model points modifiers and how he
  renders. He is linked from five places, so changing it touches all of
  them — do it deliberately, not as a side effect.
- **Death Guard is broadly under-implemented.** Black Legion is referenced
  23 times in this catalogue, Death Guard 10. Expect more gaps. Not yet
  checked: Daemon Princes forced to have Daemon of Nurgle, and the
  Vectorium's own Core/Auxiliary/Command formation composition (pp.118-119)
  against what the catalogue actually offers.

## Verifying before commit

Confirm the file is still well-formed XML. `python` is not guaranteed to be
on the machine (it wasn't, this session) — either of these works:

```sh
python -c "import xml.etree.ElementTree as ET; ET.parse('Chaos Space Marines - Codex.cat')"
```

```powershell
try { [xml](Get-Content -Raw "Chaos Space Marines - Codex.cat"); "XML VALID" } catch { "XML INVALID: $($_.Exception.Message)" }
```

Bump the catalogue's `revision` attribute on every data change, or clients
serve a cached copy.
