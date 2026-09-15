# Divergences from upstream

Every change to the data from archived
[BSData/wh40k-7th-edition](https://github.com/BSData/wh40k-7th-edition)
(upstream last commit February 2021), newest first.

Rebuild upstream's view of any file with
`git diff upstream/master -- "<file>"`.

---

## Chaos Space Marines — Codex (2012)

File: `Chaos Space Marines - Codex.cat` · catalogue revision 2030 → 2032

### Follow-up: revision 2031 fix wasn't enough — a dead "always hidden" modifier on the same entry (confirmed live by Leo)

The root `entryLink` added in revision 2031 (below) was necessary but not sufficient.
`Force Options` itself carried a second, independent problem: a `modifier`
unconditionally setting `hidden="true"` on the entry —

```xml
<modifier type="set" field="hidden" value="true">
  <repeats/>
  <conditions/>
  <conditionGroups>
    <conditionGroup type="or">
      <conditions/>
      <conditionGroups/>
    </conditionGroup>
  </conditionGroups>
</modifier>
```

— with both the `<conditions/>` list and the nested `<conditionGroup type="or">`
completely empty. Under strict boolean logic an empty `or` group should be a vacuous
false (never satisfied), which is what I reasoned when I left it alone in 2031 —
under that reading the modifier could never fire and the entry's own declared
`hidden="false"` would stand. That reasoning was wrong for whatever engine New
Recruit actually runs: Leo confirmed live that Force Options was still not showing up
after the 2031 fix went out (and after the push that made it live), even though the
entryLink now correctly routes to it. The only thing left that could explain a
still-hidden entry is this modifier evaluating as "always hide" in practice — most
likely because the engine treats a fully empty `conditionGroup` as trivially
satisfied/ignored rather than as a formal empty disjunction.

Confirmed via `git log -p` and `git diff upstream/master` (again) that this exact
block is original, unchanged BSData authorship — not something the 2.00→2.03
conversion or session 1 mark. It has zero real conditions, so it cannot ever have been
intended to fire selectively; it reads as leftover cruft from a BattleScribe editor
session (deleting a condition group's contents without deleting the group itself).
There is no way to recover "what it was originally meant to gate on" from the data —
removing it outright is the only defensible fix, and it now matches Space Marines'
own `Chapter Tactics` wrapper, which carries no hidden modifier at all.

**Fix.** Replaced the entry's `<modifiers>...</modifiers>` block with `<modifiers/>`,
leaving the entry at its plain declared `hidden="false"`. Revision 2031 → 2032.

**Not yet independently verified live** — this is a second attempt after the first
didn't take; please confirm in New Recruit before treating this as closed.

---

### Fixed: "Force Options" (the legion/Select force picker) unreachable in any detachment — confirmed bug

**Symptom (Leo, live in New Recruit).** Building a new Chaos Space Marines Combined
Arms Detachment, there is no "Force Options" entry anywhere in the picker — meaning
no way to reach "Select force" and choose a legion (Black Legion, Death Guard, World
Eaters, etc.) at all. Every legion-gated fix from earlier sessions (Marks of Chaos,
Typhus, the Death Guard exclusivity restrictions) sits downstream of this picker and
is unreachable without it.

**Root cause.** `Force Options (Supplement options here)` (`3203-e3d9-6d38-9131`) is a
catalogue-root-level `selectionEntry` (declared `hidden="false"`, own min1/max1
force-scope constraint) that wraps the `Select force` group. It is a genuine dead
entry: confirmed via `git log -p` across this file's *entire* history, and in
upstream's own copy, that **no `entryLink` anywhere in the catalogue has ever pointed
at it** — it's referenced 20+ times as a `childId` inside *other* entries' conditions
(checking "is Force Options NOT selected"), but nothing ever links to it as a target,
so nothing ever exposes it to a detachment's picker. This is the same class of bug as
the Session 3 Terminus Ultra lesson: a `selectionEntry` needs an `entryLink` in the
catalogue's root `<entryLinks>` list (not just its own `hidden="false"`/constraints)
to actually be offered by a detachment. Confirmed this is how the *working* case looks
by cross-checking Space Marines' equivalent — `Chapter Tactics`
(`8ec7-bc59-b859-378c`) — which has exactly such a root `entryLink` (`be08-c306-51ff-
4b42`, with a `No Force Org Slot` categoryLink and its own min1/max1 constraints).
CSM's `Force Options` had no counterpart at all. Confirmed present in upstream
unchanged (`git diff upstream/master` shows no prior touch to this id) — this is an
original BSData data gap that predates every session on this project, not something
introduced by the 2.00→2.03 conversion or any prior fix here.

**Fix.** Added `entryLink id="d4a1-7f2e-9c3b-5e68"` (`targetId` = `3203-e3d9-6d38-
9131`) to the catalogue's root `<entryLinks>` list, with `categoryEntryId="ff36a6f3-
19bf-4f48-8956-adacfd28fe74"` (`No Force Org Slot`) — mirroring Space Marines'
Chapter Tactics link. No extra constraints needed on the link itself since the target
entry already self-constrains to exactly one pick per force. Revision 2030 → 2031.

**Space Marines — checked, did NOT find the same bug.** Leo reported this affects SM
too. Audited the equivalent path (`Chapter Tactics` → its `Chapter Tactics`
`selectionEntryGroup` → the individual Chapter entries) end to end: the root
`entryLink` exists (`be08-c306-51ff-4b42`, see above), the intermediate `entryLink`
into the `selectionEntryGroup` is intact (`c0e3-bfb4-269a-4da3`), and the group itself
(`15bc-de81-7154-282c`) has a normal min1/max1 constraint and real Chapter entries
underneath (Red Scorpions, Carcharodons, etc. — checked a sample), no stray hidden
conditions. Nothing structurally missing was found on static reading. **Not yet
resolved for SM — needs more specifics from Leo** (does "Chapter Tactics" not appear
in the picker at all, or does it appear but show no chapters underneath, or something
else?) before guessing at a fix, since the CSM bug's exact shape (a fully orphaned
entry) does not appear to be present here.

---

### Fixed: Mark of Tzeentch not reliably mandatory for Thousand Sons — confirmed bug

**Background.** An earlier session's "Marks of Chaos hidden under every non-vanilla
legion" theory (see the dual-id issue further down this file) was fixed for visibility
across all four Marks, but left an open question: whether the same dual-id treatment
had been applied consistently to the *mandatory* trigger (not just the *visibility*
trigger) for every legion, not just Death Guard. This session audited all four Marks'
"make mandatory" modifiers specifically for Khorne (World Eaters), Tzeentch (Thousand
Sons) and Slaanesh (Emperor's Children), per Leo's request.

**Finding.** Every Mark's *visibility* unhide condition already correctly lists both
id forms (the `entryLink` id from the "Select force" picker and the target
`selectionEntry` id) for its own matching legion — confirmed for all four Marks, in
both the shared entries and their inline copies (e.g. under Chaos Lord). That part was
already fixed project-wide, not just for Death Guard.

The *mandatory* modifier (the one that sets each Mark's `minSelections` to 1 when its
legion is chosen) is a different story:
- Mark of Khorne's mandatory condition uses World Eaters' `selectionEntry` id
  (`ef71-058b-3f36-592f`) — correct form.
- Mark of Nurgle's uses Death Guard's `selectionEntry` id (`9c55-dd66-6f7b-8bc8`) —
  correct form.
- Mark of Slaanesh's uses Emperor's Children's `selectionEntry` id
  (`c183-8bf0-8c4b-6ffb`) — correct form.
- **Mark of Tzeentch's uses only Thousand Sons' `entryLink` id
  (`6d47-164c-da91-85bc`) — the form that, per the confirmed Death Guard precedent
  (`fa0f0e7`), the engine does not reliably match.** Present in both the shared entry
  (`894b-0234-79e0-3aa8`) and its inline copy (`7862-8d6f-5fd1-8620`, under a Sorcerer
  or similar HQ). Mark of Tzeentch would therefore likely appear as selectable under
  Thousand Sons (visibility is fine) but not be enforced as mandatory, unlike the
  other three legion/Mark pairs.

**Fix.** Added Thousand Sons' `selectionEntry` id (`78c6-3dd8-6697-4ba8`) as an extra
OR-condition alongside the existing entryLink-id condition, in both the shared and
inline Mark of Tzeentch mandatory modifiers — mirroring the form already used by
Khorne/Nurgle/Slaanesh. Purely additive (widens an OR list), so it cannot make the
Mark harder to trigger than before, only more reliable.

**Not yet independently verified** (same caveat as the original Death Guard fix):
static reading of the XML conditions, not a confirmed live test in New Recruit. Before
trusting this fully, build a Thousand Sons Combined Arms Detachment and check Mark of
Tzeentch shows as mandatory (min 1), the same falsifying test used for Death Guard.

---

## Whole repo — BattleScribe 2.00 → 2.03 format conversion

Files: **all 44 `.cat` files + `Warhammer40K.gst`** · every file's `revision`
bumped · `gameSystemRevision` re-pointed to the new `.gst` revision (2043) ·
`battleScribeVersion` 2.00 → 2.03 on the 44 files that declared 2.00

### Why

New Recruit — which is what this fork is actually used in — only parses the
**modern (2.03)** form of several constructs. Every file except
`Space Marines - Codex (2015).cat` was still in the **legacy (2.00)** form,
so New Recruit silently failed to read them. Verified live in New Recruit
before the conversion, on a stock Orks list:

- **Unit stats garbled** — a Big Mek displayed `6+` in WS, BS, S, T, W, I,
  A, Ld *and* Save (every column showing the last characteristic's value).
- **Weapon stats garbled** the same way (this is the bug that started the
  investigation, via the Terminus Ultra's lascannons).
- **All points missing** — the Big Mek, every wargear option and the roster
  total all showed no cost at all, i.e. the entire army costed 0.
- **Profile group headers blank** instead of "Weapon" / "Unit" / etc.

In other words every faction except Space Marines was effectively unusable
in New Recruit. (BattleScribe itself reads both forms, which is why the
archived upstream project never hit this.)

### What changed

Three mechanical, purely-syntactic rewrites — no rules, stats, points or
structure were altered:

| Construct | Legacy (2.00) | Modern (2.03) | Count |
|---|---|---|---|
| characteristic | `<characteristic name="Range" characteristicTypeId="T" value="48&quot;"/>` | `<characteristic name="Range" typeId="T">48"</characteristic>` | 43,613 |
| cost | `costTypeId="points"` | `typeId="points"` | 22,120 |
| profile | `profileTypeId="T"` (+`profileTypeName`) | `typeId="T" typeName="Weapon"` | 8,976 |

`typeName` was filled in from the `profileType` definitions; all 8,976
legacy profiles referenced a defined profile type, so none were guessed.
Attribute values were already XML-escaped and escaped text is equally valid
as element content, so values carried over verbatim.

**Deliberately left alone:** `categoryEntryId` (22,810 occurrences). New
Recruit reads it correctly — verified that force-org slots populate and
units land in the right slot in a legacy catalogue — so it was not worth
the risk of a structural change.

### Verification

- All 45 files re-parse as well-formed XML.
- Zero legacy attributes remain (`characteristicTypeId`, `costTypeId`,
  `profileTypeId`, `profileTypeName`, `battleScribeVersion="2.00"` all 0).
- All 9,623 profiles now carry both `typeId` and `typeName`.
- Characteristic element count unchanged (46,392 = 43,613 converted + 2,779
  already modern) — nothing dropped or duplicated.
- `git diff` is exactly symmetric: 74,755 insertions / 74,755 deletions,
  i.e. every touched line is a 1:1 rewrite, no lines added or removed.
- Semantic read-back through a real XML parser: the shared BRB Lascannon
  profile returns Range `48"`, Strength `9`, AP `2`, Type `Heavy 1`.
- Re-checked in New Recruit after the change (see session notes).

The script that performed it is kept at
`tools/convert-legacy-to-2.03.ps1` so it can be re-run if legacy-format
data is ever pulled in from upstream again. Note it also bumps revisions
each run, so re-running it on already-converted data is a no-op conversion
but still bumps revisions.

---

## Space Marines — Codex (2015)

File: `Space Marines - Codex (2015).cat` · catalogue revision 2053 → 2054

### Fixed: Terminus Ultra weapon stats — root cause was a legacy characteristic format

**Root cause (verified live in New Recruit, not theorised).** This data set
stores profile characteristics in two different formats:

- **Legacy (BattleScribe 2.00):** `<characteristic name="Range"
  characteristicTypeId="…" value="48&quot;"/>` — value in an *attribute*.
- **Modern (BattleScribe 2.03):** `<characteristic name="Range"
  typeId="…">48"</characteristic>` — value as *element text*.

**New Recruit only reads the modern form.** Given a legacy-form profile it
renders every stat column as the same value (whatever the last/Type
characteristic holds), which is why a Lascannon displayed as `Heavy 1` in
Range, Strength, AP *and* Type.

Counts: `Warhammer40K.gst` is 100% legacy (1025 characteristics, 0 modern).
`Space Marines - Codex (2015).cat` is 100% modern (2775, 0 legacy). That
split explains everything observed:

| Profile | Defined in | Form | Renders |
|---|---|---|---|
| Terminus Ultra vehicle stats | SM `.cat` | modern | correct |
| Hunter-killer Missile | SM `.cat` (written by us) | modern | correct |
| Lascannon / Heavy Bolter / Boltgun | `Warhammer40K.gst` | legacy | **broken** |

So every weapon in the entire game system that `infoLink`s a `.gst` profile
displays wrong — on stock units too (confirmed on an untouched plain Land
Raider and a plain Tactical Squad). It was never specific to Terminus Ultra,
and it is *not* a New Recruit bug in the sense of something we can't fix —
it's a data-format issue on our side.

**Fix:** replaced Terminus Ultra's two weapon `entryLink`s (which pointed at
the shared `.gst`-backed entries `c092-b766-018e-4523` /
`253c-b2c6-1345-e619`) with two **local** `selectionEntry`s carrying
**local, modern-form profiles**, mirroring the Hunter-killer Missile that
was already rendering correctly:

- `Lascannon` — min 2 / max 2 — 48" / S9 / AP2 / Heavy 1
- `Twin-Linked Lascannon` — min 3 / max 3 — 48" / S9 / AP2 / Heavy 1,
  Twin-Linked — plus an `infoLink` to the shared Twin-Linked rule
  (`3002-de38-7230-fbc6`)

Both zero-costed; the 300pt base is unchanged. Verified in New Recruit
against this exact commit — the unit now renders `Lascannon (x2)` at
48"/9/2/Heavy 1 and `Twin-Linked Lascannon (x3)` at 48"/9/2/Heavy 1,
Twin-Linked. Revision 2053 → 2054.

**Open opportunity (not done):** converting `Warhammer40K.gst`'s 1025 legacy
characteristics — and the legacy characteristics still present in 43 other
`.cat` files — to the modern form would fix weapon/wargear stat display
across the *entire* game system in New Recruit. It's a mechanical
transform (`characteristicTypeId=`/`value=` attribute → `typeId=` + element
text; profiles also use `profileTypeId=` where the modern form uses
`typeId=`/`typeName=`), but it touches 44 files and thousands of lines, so
it needs a deliberate decision and careful verification before attempting.

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
