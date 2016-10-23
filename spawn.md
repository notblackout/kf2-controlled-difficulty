# `SpawnCycle` Draft Docs

Notes from 2016-10-23: This page is a work-in-progress.

The command syntax (CDSpawnDetails, CDSpawnSummaries, CDSpawnPresets) has changed slightly to accommodate more options, support the SpawnCycle preset feature, and to fix a bug where I forgot to display gorefast counts in the spawn summary (doh).  This page has gotten out of date wrt CDSpawnDetails/Summaries/Presets, and I have to update the respective sections and screenshots before release.  Don't pay too much attention to those sections right now.

The only aspect that is stable and extremely unlikely to change is the syntax of SpawnCycleDefs itself.  The language for specifying zed types is pretty much set.  I've been working with the current syntax for a couple of weeks and I'm pretty happy with it.  I may have to add forward-compatible extensionsr depending on what TWI does (e.g. for doublegorefast), but the existing SpawnCycleDef format will not break.

With those caveats, here's the draft documentation...

## Overview

Controlled Difficulty includes the `SpawnCycle` system.  This is optional.  When enabled, it bypasses standard KF2's random zed spawns and instead spawns a user-specified list of zed squads in predictable order.  There are two ways to activate this feature.

* `SpawnCycle=<name_of_preset>` activates one of CD's builtin, standard, handcrafted spawnlists.  The command `CDSpawnPresets` lists all available preset names and the game lengths supported by each preset.  This is easy to use, though the presets are not customizable.
* `SpawnCycle=ini` tells CD to look in KFGame.ini for a spawnlist.  This provides maximum control.  You can control every zed that spawns, in what squads, and in what order, on every wave.  This is highly customizable, though it requires editing KFGame.ini manually.

To turn it off, set `SpawnCycle=unmodded`.  It is off by default.

Crucially, `SpawnCycle` makes zeds spawn in a way that is stable and repeatable.  This removes a significant aspect of luck when comparing challenge runs.  Only selection of spawn locations is left to chance, but that tends to have relatively little importance on linear challenge maps, where zeds come from a single entry point.


## Background

A squad is a predefined group of zeds that the game attempts to spawn simultaneously.  Examples of squads that the standard game can spawn:

* 4 cysts
* 2 slashers, 3 gorefasts, and a scrake
* 3 fleshpounds

Standard KF2 comes with predefined squad definitions, called "archetypes", created by  Tripwire.  A list of archetypes is associated with each combination of difficulty+gamelength+wavenumber.  For a full list of these archetypes, consult [Simple Cat's KF2 spreadsheet](https://docs.google.com/spreadsheets/d/1GDpg2mN1l_86U_RaDug0glFx8cZCuErwxZLiBKl9SyY) or open the KF2 SDK and browse Packages->Gameplay->GP_Spawning_ARCH

When a wave starts, the game creates an initially-empty squadlist.  The game iterates through all "normal squad" archetypes, adding each one to the its list.  The game then randomly selects one "special squad" archetype and adds it to the squadlist.  The game then randomly shuffles the entire squadlist.

The game then spawns each squad in the squadlist.

If the game reaches the end of the squadlist before the wave ends, then it discards the used-up squadlist and repeats entire squadlist-building process from the start.  However, there is one special consideration: on the 2nd, 4th, 6th, ... squadlists, the game only uses "normal squad" archetypes.  It does not spawn a "special squad" archetype on these even-numbered squadlists.  This behavior creates a natural hard-easy-hard-easy-... rhythm.  The beginning of a wave tends to be more hectic because the spawn list includes a special squad, but that is followed by a less hectic spawn list with no special squad, then there is another spawn list with a special squad that makes the game more hectic, etc.

Note that "normal squad" is somewhat misleading.  In later waves on higher difficulties, a "normal squad" may include up to one scrake. For example, there are two separate "normal squad" archetypes on Wave 10 HOE that have one scrake each.  This means even the squadlists without a "special squad" archetype will still have two scrakes, and squadlists with a "special squad" archytpes have two extra scrakes mixed in.

This system removes player control over difficulty.  It has two key problems:

* Special squads are selected totally randomly, but they vary widely in comparative difficulty.

  For instance, Wave 10 HOE special squads vary from 2 SC + 4 Stalkers (probably the easiest) to 2 FP + 3 Scrakes or 3 FP (probably the hardest).
* Shuffling the squad list creates unpredictably distributed big zeds.  They could all spawn at the same time, or they could be evenly-spaced among trash spawns with rest time in between.
  
  Consider the beginning of Wave 10 HOE.  The normal squads guarantee two scrakes in one squad each.  For the sake of discussion, say that the game randomly chooses the 2 FP + 2 SC special squad at the start of the wave.  The game then shuffles the list.  This could result in 6 SC + 2 FP spawning nearly consecutively (if all of those squads happen to randomly shuffle next to each other), or it could result in the squads being spread out over the wave, so that two scrakes march out one at a time with a short break, and then the 2 FP + 2 SC squad emerges alone later.  This variation can actually be even more severe than described, since it is possible that the big zed squads from one list might immediately precede big zed squads from the next list, depending on how the shuffles went.

## Benefits of CD's `SpawnCycle` System

CD lets the user define, for each wave, exactly what squads spawn and in what order.  If the user-provided list is shorter than the wave, then it repeats in order until the wave ends.  This offers both fine control and reproducibility.

**Fine control:** Specify as many or as few squads as you want. Compose squads with whatever combination of zeds you want. CD spawns zeds as listed without shuffling.  This system supports all squads used in the base game, but also permits squads unseen in the base game (e.g. 4 FP), should you wish to use such squads.

**Reproducibility:** This system removes random spawn list shuffling.  The only random aspect is spawnpoint selection.  On solo maps like Hillside or Midnightpark, spawnpoint selection is nearly irrelevant, and only zed spawn order and rate really matters.  This is where deterministic spawns really help.  Once you've set the spawn list and rate, every run presents effectively identical difficulty.  The game doesn't randomly get harder or easier from one attempt to the next depending on random list generation and shuffling, like in the standard game.  This takes a major luck aspect out of challenges.



## Configuration Syntax

All of the following options live under the `[ControlledDifficulty.CD_Survival` section of `KFGame.ini`.

`SpawnCycle` is the most important option.  This tells CD whether to keep standard KF2 behavior, use a hardcoded spawn preset, or read a custom spawn list from `KFGame.ini`.

Values for `SpawnCycle`:

* unmodded: use standard KF2's randomized spawn system
* ini: spawn zeds according to the `SpawnCycleDefs` settings in `KFGame.ini`

`SpawnCycle=<value>` can be appended to the `open` command used to start CD.

`SpawnCycleDefs` can only appear in `KFGame.ini`, not in the `open` command.  This is an array of strings defining a list of squads to spawn in a particular wave.  The first `SpawnCycleDefs` that appears in `KFGame.ini` controls Wave 1, the second controls Wave 2, etc.  The number of `SpawnCycleDefs` must match the game length or an error message will be printed at game startup and CD will revert to unmodded spawn behavior.

A single `SpawnCycleDefs` line for a wave is a comma-separated list of squads.  Squads are comprised of one or more underscore-separated elements, where each element is a number and a zed type.  This allows for heterogeneous squads.

Each squad must contain between one and ten zeds (inclusive).  Each wave defined with `SquadCycleDefs` should have at least one squad.

Here's an artificially simple SpawnCycleDefs line illustrating the basic syntax:

```
SpawnCycleDefs=4ClotA,4Stalker_2Crawler
```

The following zed names are accepted in `SpawnCycleDefs`:

* AL(PHA), CA, ClotA
* B(LOAT)
* CR(AWLER)
* CY(ST), CC, ClotC
* F(LESHPOUND), FP
* G(OREFAST), GF
* H(USK)
* SC(RAKE)
* SI(REN)
* SL(ASHER), CS, ClotS
* ST(ALKER)

Letters in parentheses may be omitted or shortened on the right.  All zed names are completely case-insensitive.

For example, any of the following strings is a valid way to spell a fleshpound:

* fp
* FP
* Fp
* FL
* Fl
* flesh
* FleshPound

Whereas all of the following strings are invalid:

* flp
* FLPOUND


### Albino/Special Zed Variants

At the time this document was last updated, there are two albino or special zed variants:

* AL(PHA)\*, CA\*, ClotA\* (Albino Alpha Clot)
* CR(AWLER)\* (Albino Crawler)

The asterisk suffix makes these zeds albino/special.  For example, "Crawler\*" would spawn a gas grawler and "AL\*" would spawn an alpha clot.  Appending a * character to a zed that has no albino variant generates an error message and causes the SpawnCycle to be rejected.

## Diagnostic Commands

`CDSpawnSummaries` projects the estimated number of zeds per wave, breaking fleshpounds, scrakes, sirens, husks, bloats, and trash into separate counts.  It accounts for the current `FakePlayers` setting automatically.  However, if you want to see what would happen on a particular player count, you can specify an integer argument, which will be interpreted as a player count override.  This command does not consider the boss wave; it only considers regular waves.

`CDSpawnDetails` lists the exact spawn squads scheduled for each wave when not using `SpawnCycle=ini`.  Although the ini-parser prints warning messages to the console whenever it encounters a parse error, this command could be useful in case of an edge case that CD fails to warn about (though that would just be a temporary fix, since I will try to make CD warn about every error case that I know about).

![loading the mod](https://raw.githubusercontent.com/notblackout/kf2-controlled-difficulty/master/img/spawns/0_load.png)

![running cdspawnsummaries](https://raw.githubusercontent.com/notblackout/kf2-controlled-difficulty/master/img/spawns/1_summaries.png)

![running cdspawndetails](https://raw.githubusercontent.com/notblackout/kf2-controlled-difficulty/master/img/spawns/2_details.png)

## Sample Configuration

The following `KFGame.ini` snippet contains a 10-wave configuration adapted from an average HOE Long game.  All of the squads used are present in HOE Long games.  The special squads have been selected to be average or slightly below average for their wave number.  Scrakes start at 5, FPs start at 7.  The big zeds are spread out a bit, but within the rules used by standard KF2.

The overall effect of this set of `SpawnCycleDefs` is to mimic a moderate-difficulty HOE Long game as closely as possible.  To mimic the way the base game only spawns a special squad on every other spawn list, the following definitions repeat each trash list twice on one line, including a special squad only in the first half.

```
[ControlledDifficulty.CD_Survival]
SpawnCycle=ini
SpawnCycleDefs=4CC,3CC_1AL_1GF,6SL,4CC_1BL,3AL_1SL,4CC,3CC_1AL_1GF,4CC_1BL,3AL_1SL
SpawnCycleDefs=3CC_1AL,3CC_1SL_1BL,2CR,2ST,3BL,1HU,1SL_2AL_1GF,2AL_2GF,3CC_1AL_1GF,4CC,4CR,3CC_1AL,3CC_1SL_1BL,2CR,2ST,1HU,1SL_2AL_1GF,2AL_2GF,3CC_1AL_1GF,4CC,4CR
SpawnCycleDefs=4CR,3AL_1BL,2SL_3CR_1GF,3HU,3CC_1GF_1SI,1SL_3GF,1HU,3CC_1AL,2CR,2CR_2GF_2ST_1SI,4ST,4GF,4CR,3AL_1BL,2SL_3CR_1GF,3CC_1GF_1SI,1SL_3GF,1HU,3CC_1AL,2CR,2CR_2GF_2ST_1SI,4ST,4GF
SpawnCycleDefs=3CC_1AL,3CC_1CR_2ST_1BL_1SI,1HU,4CR,3CC_1BL,2AL_2GF,3CC_1GF_1SI,9GF,2ST,1SL_3GF,3CC_1CR_2ST_1BL_1SI,6CR,4GF,2CR_2GF_2ST_1SI,3CC_1AL,3CC_1CR_2ST_1BL_1SI,1HU,4CR,3CC_1BL,2AL_2GF,3CC_1GF_1SI,2ST,1SL_3GF,3CC_1CR_2ST_1BL_1SI,6CR,4GF,2CR_2GF_2ST_1SI
SpawnCycleDefs=2CR,4ST,2CR_2GF_2ST_1SI,4CR,3CC_1CR_2ST_1BL_1SI,2ST,1SC_6ST,3CC_1BL,2AL_1GF_1HU,4GF,6CR,2AL_2GF,1SL_3GF,3CC_1GF_1SI,3AL_1SL,2CR,4ST,2CR_2GF_2ST_1SI,4CR,3CC_1CR_2ST_1BL_1SI,2ST,3CC_1BL,2AL_1GF_1HU,4GF,6CR,2AL_2GF,1SL_3GF,3CC_1GF_1SI,3AL_1SL
SpawnCycleDefs=2AL_1GF_1HU,4CR,3AL_1SL,2SL_2CR_2GF_2SI,1SC_4ST,3CC_1SL_1BL,2CR,2AL_1SC,2ST,1SL_2AL_1GF,4GF,6CR,2CR_2GF_2ST_1SI,1HU,1SL_3GF,2SL_3CR_1GF,3CC_1CR_2ST_1BL_1SI,4CC,4ST,3CC_1AL_1GF,2AL_1GF_1HU,4CR,3AL_1SL,2SL_2CR_2GF_2SI,3CC_1SL_1BL,2CR,2AL_1SC,2ST,1SL_2AL_1GF,4GF,6CR,2CR_2GF_2ST_1SI,1HU,1SL_3GF,2SL_3CR_1GF,3CC_1CR_2ST_1BL_1SI,4CC,4ST,3CC_1AL_1GF
SpawnCycleDefs=1SL_2AL_1GF,2AL_2GF,2SL_3CR_1GF,2SC_4ST,3CC_1CR_2ST_1BL_1SI,3CC_1AL_1GF,4ST,4GF,2CR_2ST_1BL_2SI,3CC_1AL,2SL_2CR_2GF_2SI,6CR,2SL_3GF_1SC,4CR,3CC_1BL,2HU,4CC,1SL_2AL_1GF,2AL_2GF,2SL_3CR_1GF,3CC_1CR_2ST_1BL_1SI,3CC_1AL_1GF,4ST,4GF,2CR_2ST_1BL_2SI,3CC_1AL,2SL_2CR_2GF_2SI,6CR,2SL_3GF_1SC,4CR,3CC_1BL,2HU,4CC
SpawnCycleDefs=4CC_1BL,2SL_3GF_1SC,2CR,2AL_1GF_1HU,2ST,1SL_2AL_1GF,2SL_2CR_2GF_2SI,3AL_1SL,4CR,2AL_2GF,1FP_1SC,2SL_3CR_1GF,3CC_1CR_2ST_1BL_1SI,1HU,4ST,2AL_1SC,4CC,4GF,2CR_2GF_2ST_1SI,6CR,4CC_1BL,2SL_3GF_1SC,2CR,2AL_1GF_1HU,2ST,1SL_2AL_1GF,2SL_2CR_2GF_2SI,3AL_1SL,4CR,2AL_2GF,2SL_3CR_1GF,3CC_1CR_2ST_1BL_1SI,1HU,4ST,2AL_1SC,4CC,4GF,2CR_2GF_2ST_1SI,6CR
SpawnCycleDefs=4ST,2HU,4CC_1BL,2CR,3AL_1SL,2AL_1SC,6CR,2SL_2CR_2GF_2SI,4GF,2ST,1SL_2AL_1GF,2FP_1SC,4CR,2AL_2GF,2SL_3GF_1SC,2SL_3CR_1GF,3CC_1CR_2ST_1BL_1SI,4CC,2CR_2GF_2ST_1SI,4ST,2HU,4CC_1BL,2CR,3AL_1SL,2AL_1SC,6CR,2SL_2CR_2GF_2SI,4GF,2ST,1SL_2AL_1GF,4CR,2AL_2GF,2SL_3CR_1GF,3CC_1CR_2ST_1BL_1SI,2SL_3GF_1SC,4CC,2CR_2GF_2ST_1SI
SpawnCycleDefs=1SL_2AL_1GF,4CR,2HU,3CC_1BL,2AL_1SC,2AL_2GF,2SL_3CR_1GF,2SL_2CR_2GF_2SI,3AL_1SL,2FP_2SC,1HU,4ST,4CC,2CR_2ST_1BL_2SI,2SL_3GF_1SC,6CR,3CC_1AL_1GF,3CC_1CR_2ST_1BL_1SI,4GF,1SL_2AL_1GF,4CR,2HU,3CC_1BL,2AL_1SC,2AL_2GF,2SL_3CR_1GF,2SL_2CR_2GF_2SI,3AL_1SL,1HU,4ST,2SL_3GF_1SC,4CC,2CR_2ST_1BL_2SI,6CR,3CC_1AL_1GF,3CC_1CR_2ST_1BL_1SI,4GF
```
