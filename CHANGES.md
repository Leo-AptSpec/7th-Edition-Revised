# Divergences from upstream

Every change to the data from archived
[BSData/wh40k-7th-edition](https://github.com/BSData/wh40k-7th-edition)
(upstream last commit February 2021), newest first.

Rebuild upstream's view of any file with
`git diff upstream/master -- "<file>"`.

---

## Chaos Space Marines — Codex (2012)

File: `Chaos Space Marines - Codex.cat` · catalogue revision 2026 → 2027

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
- **Magnus the Red, Ahriman and Abaddon are ungated** in Lord of the
  Legion's Pick One group, so Abaddon can currently be taken in a Death
  Guard Vectorium.
- **Death Guard is broadly under-implemented.** Black Legion is referenced
  23 times in this catalogue, Death Guard 10. Expect more gaps.

## Verifying before commit

```sh
python -c "import xml.etree.ElementTree as ET; ET.parse('Chaos Space Marines - Codex.cat')"
```

Bump the catalogue's `revision` attribute on every data change, or clients
serve a cached copy.
