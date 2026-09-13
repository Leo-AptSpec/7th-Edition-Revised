Warhammer 40,000 7th Edition
============================

> ## Personal fork
>
> Fork of the archived [BSData/wh40k-7th-edition](https://github.com/BSData/wh40k-7th-edition),
> kept alive to fix gaps in 7th edition units and formations. Upstream was
> abandoned in February 2021 when 8th edition landed.
>
> Data-only fork — no app code. **New Recruit is the target app** — the data
> has been converted to the BattleScribe 2.03 format New Recruit requires
> (see [CHANGES.md](CHANGES.md)); it still loads in BattleScribe too.
>
> ### Installing / updating in New Recruit
>
> **Install:** Games → *Add more games* → **Add from Github** → set version to
> **`Latest Commit (Head)`** → repository `Leo-AptSpec/7th-Edition-Revised` →
> *Add*.
>
> > ⚠️ **Do not use the default `Latest Release` option.** This fork inherited
> > 338 tags from the archived upstream project (newest `v7.0.1`), so a
> > release-pinned install serves 2021-era data and none of the fixes here.
>
> **Update after a change is pushed:** Games → tick
> ***Clear all game data before updating*** → **Update All**. The tickbox
> matters: without it the cached copy can persist and you will silently keep
> using old data. Saved lists are not deleted by this — only cached
> catalogue files are.
>
> **Verify which version you actually have:** open a list → *Export* → the
> file header states `gameSystemRevision` and `catalogueRevision`. Compare
> against the `revision=` attribute at the top of `Warhammer40K.gst` and the
> relevant `.cat` file in this repo. If they differ, the update did not take.
>
> See [CHANGES.md](CHANGES.md) for every divergence from upstream and why.
>
> Original upstream README follows.

[![Join the chat at https://gitter.im/BSData/wh40k](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/BSData/wh40k?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) <- talk to us!

## Important ##

### This repo is no longer maintained. Current edition data is in [wh40k repo](https://github.com/BSData/wh40k) ###

__BattleScribe v1.15 users Notice__: _All the files in their last revisions for BattleScribe v1.15 are available in [release v4.18.7](https://github.com/BSData/wh40k-7th-edition/releases/tag/v4.18.7). Downloading .bsr file (one of the Downloads) and importing it in BattleScribe v1.15 will allow you to use these no-longer-maintained datafiles._

__6th ed users Notice__: _All the files in their last revisions for 6th are available in [release v3.1.4](https://github.com/BSData/wh40k-7th-edition/releases/tag/v3.1.4). Downloading .bsr file (green button) and importing it in BattleScribe_ __won't__ _mess with 7th ed files._

#### Contents ####

* [Important][]
* [Overview][]
* [Links][]

[Important]: #important
[Overview]: #overview
[Links]: #links


## Overview ##

* __What's this?__
  
  _BSData organisation created this project. It's GitHub repository of datafiles. Created by community, in no way endorsed by BattleScribe._

* __Okay, nice project. Is it actually working?__ I just want those files...
  
  _Yeah! We have it hosted on AppSpot. Take a look: [BattleScribe Data on Appspot][]_

## Links ##

* [BattleScribe homepage][]
* [BattleScribe Data on Appspot][]
* [Getting Started wiki][]


[BattleScribe homepage]: http://www.battlescribe.net/
[BattleScribe Data on Appspot]: http://battlescribedata.appspot.com/#/repos
[Getting Started wiki]: https://github.com/BSData/bsdata/wiki/Home#getting-started
