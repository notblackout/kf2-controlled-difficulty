# `SpawnCycle` Draft Docs

## Overview

Controlled Difficulty includes the `SpawnCycle` system.  This is optional.  When enabled, it bypasses standard KF2's random zed spawns and instead spawns a user-specified list of zed squads in predictable order.  _TODO: I want eventually include popular spawn lists in CD itself, selectable by a simple in-game option, with no manual list-editing required.  I will mention it here when implemented._

With this system, it is possible to define waves of zeds with practically any difficulty level. Crucially, it is stable and repeatable.  Runs made with this system in place are easier to compare, because players using the same config will see the same zeds in the same spawn order on every attempt.

This removes a significant aspect of luck when comparing challenge runs.

## Background

A squad is a predefined group of zeds that the game attempts to spawn simultaneously.  Examples of squads that the standard game can spawn:

* 4 cysts
* 2 slashers, 3 gorefasts, and a scrake
* 3 fleshpounds

Standard KF2\* comes with predefined squad definitions, called "archetypes", created by  Tripwire.  For each combination of difficulty+gamelength+wavenumber, the game also has a list of squad archetypes allowed to spawn in that wave.  For a full list of these archetypes, consult [Simple Cat's KF2 spreadsheet](https://docs.google.com/spreadsheets/d/1GDpg2mN1l_86U_RaDug0glFx8cZCuErwxZLiBKl9SyY) or open the KF2 SDK and browse Packages->Gameplay->GP_Spawning_ARCH

When a wave starts, the game creates an initially-empty list.  The game adds all of the wave's "normal squads" as described in Simple Cat's spreadsheet to the list.  The game then randomly selects one "special squad" as described in Simple Cat's spreadsheet and adds it to the list.  The game then randomly shuffles the entire list.

The game then iterates through the shuffled list, spawning zeds as it goes.

If the game reaches the end of the list before the wave ends, then it discards the old list and repeats the entire list-building process, but with one exception: on the 2nd, 4th, 6th, ... lists, the game only uses regular squads.  This creates a natural rhythm: the beginning of a wave tends to be more hectic because the spawn list includes a special squad, but that is followed by a less hectic spawn list with no special squad, then there is another spawn list with a special squad that makes the game more hectic, etc.

Note that the name "normal squad" is somewhat misleading.  In later waves on higher difficulties, a "normal squad" may include up to one scrake. For example, "normal squads" on Wave 10 HOE guarantee at least two scrakes per pass through the spawn list, even with no special squad.

This system removes player control over difficulty.  It has two key problems:

* Special squads are selected totally randomly, but they vary widely in comparative difficulty.

  For instance, Wave 10 HOE special squads vary from 2 SC + 4 Stalkers (probably the easiest) to 2 FP + 3 Scrakes or 3 FP (probably the hardest).
* Shuffling the squad list creates unpredictably distributed big zeds.  They could all spawn at the same time, or they could be evenly-spaced among trash spawns with rest time in between.
  
  Consider the beginning of Wave 10 HOE.  The normal squads guarantee two scrakes in one squad each.  For the sake of discussion, say that the game randomly chooses the 2 FP + 2 SC special squad at the start of the wave.  The game then shuffles the list.  This could result in 6 SC + 2 FP spawning nearly consecutively (if all of those squads happen to randomly shuffle next to each other), or it could result in the squads being spread out over the wave, so that two scrakes march out one at a time with a short break, and then the 2 FP + 2 SC squad emerges alone later.  This variation can actually be even more severe than described, since it is possible that the big zed squads from one list might immediately precede big zed squads from the next list, depending on how the shuffles went.

\* current as of v1043

## Benefits of CD's `SpawnCycle` System

CD lets the user define, for each wave, exactly what squads spawn and in what order.  If the user-provided list is shorter than the wave, then it repeats in order until the wave ends.  This offers both fine control and reproducibility.

**Fine control:** Specify as many or as few squads as you want. Compose squads with whatever combination of zeds you want. CD spawns zeds as listed without shuffling.  This system supports all squads used in the base game, but also permits squads unseen in the base game (e.g. 4 FP), should you wish to use such squads.

**Reproducibility:** This system removes random ordering from the spawn list.  The only remaining random aspect is spawnpoint selection.  On solo maps like Hillside or Midnightpark, spawnpoint selection is nearly irrelevant, and only zed spawn order and rate really matters.  This is where deterministic spawns really help.  Once you've set the spawn list and rate, every run presents effectively identical difficulty.  The game doesn't randomly get harder or easier from one attempt to the next depending on random list generation and shuffling, like in the standard game.  This takes a major luck aspect out of challenges.



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
