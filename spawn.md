# `SpawnCycle` Docs

## Overview

Controlled Difficulty includes the `SpawnCycle` system.  This is optional.  When enabled, it bypasses standard KF2's random zed spawns and instead spawns a user-specified list of zed squads in predictable order.  There are two ways to activate this feature.

* `SpawnCycle=<name_of_preset>` activates one of CD's builtin, standard, handcrafted spawnlists.  The command `CDSpawnPresets` lists all available preset names and the game lengths supported by each preset.  This is easy to use, though the presets are not customizable.  Note that CD must already be loaded before `CDSpawnPresets` will work.
* `SpawnCycle=ini` tells CD to look in KFGame.ini for a spawnlist.  This provides maximum control.  You can control every zed that spawns, in what squads, and in what order, on every wave.  This is highly customizable, though it requires editing KFGame.ini manually.

To turn it off, set `SpawnCycle=unmodded`.  It is off by default.

Because the `SpawnCycle` system spawns zeds in a fixed order, it avoids a significant aspect of luck when comparing challenge runs.  The only aspect of spawning it does not control is spawnpoint selection.


## Background: Details about KF2's Spawn System

A squad is a predefined group of zeds that the game attempts to spawn simultaneously.  Examples of squads that the standard game can spawn:

* 4 cysts
* 2 slashers, 3 gorefasts, and a scrake
* 3 fleshpounds

Standard KF2 comes with predefined squad definitions, called "archetypes", created by  Tripwire.  A list of archetypes is associated with each combination of difficulty+gamelength+wavenumber.  For a full list of these archetypes, consult [Simple Cat's KF2 spreadsheet](https://docs.google.com/spreadsheets/d/1GDpg2mN1l_86U_RaDug0glFx8cZCuErwxZLiBKl9SyY) or open the KF2 SDK and browse Packages->Gameplay->GP_Spawning_ARCH

When a wave starts, the game creates an initially-empty squadlist.  The game iterates through all "normal squad" archetypes, adding each one to the its list.  The game then randomly selects one "special squad" archetype and adds it to the squadlist.  The game then randomly shuffles the entire squadlist.

The game then spawns each squad in the squadlist.

If the game reaches the end of the squadlist before the wave ends, then it discards the used-up squadlist and repeats entire squadlist-building process from the start.  However, there is one complication.  On the 2nd, 4th, 6th, ... squadlists, the game only uses "normal squad" archetypes.  It does not spawn a "special squad" archetype on these even-numbered squadlists.  This behavior creates a natural hard-easy-hard-easy-... rhythm.  The beginning of a wave tends to be more hectic because the spawn list includes a special squad, but that is followed by a less hectic spawn list with no special squad, then there is another spawn list with a special squad that makes the game more hectic, etc.

Note that "normal squad" is somewhat misleading.  In later waves on higher difficulties, a "normal squad" may include up to one scrake. For example, there are two separate "normal squad" archetypes on Wave 10 HOE that have one scrake each.  This means even the squadlists without a "special squad" archetype will still have two scrakes, and squadlists with a "special squad" archytpes have two extra scrakes mixed in.

This system removes player control over difficulty.  It has two key problems:

* Special squads are selected totally randomly, but they vary widely in comparative difficulty.

  For instance, Wave 10 HOE special squads vary from 2 SC + 4 Stalkers (probably the easiest) to 2 FP + 3 Scrakes or 3 FP (probably the hardest).
* Shuffling the squad list creates unpredictably distributed big zeds.  They could all spawn at the same time, or they could be evenly-spaced among trash spawns with rest time in between.
  
  Consider the beginning of Wave 10 HOE.  The normal squads guarantee two scrakes in one squad each.  For the sake of discussion, say that the game randomly chooses the 2 FP + 2 SC special squad at the start of the wave.  The game then shuffles the list.  This could result in 6 SC + 2 FP spawning nearly consecutively (if all of those squads happen to randomly shuffle next to each other), or it could result in the squads being spread out over the wave, so that two scrakes march out one at a time with a short break, and then the 2 FP + 2 SC squad emerges alone later.  This variation can actually be even more severe than described, since it is possible that the big zed squads from one list might immediately precede big zed squads from the next list, depending on how the shuffles went.

## Benefits of CD's `SpawnCycle` System

CD lets the user define, for each wave, exactly what squads spawn and in what order.  This offers both fine control and reproducibility.

**Fine control:** Specify as many or as few squads as you want. Compose squads with whatever combination of zeds you want. CD spawns zeds as listed without shuffling.  This system supports all squads used in the base game, but also permits squads unseen in the base game (e.g. 4 FP), should you wish to use such squads.

**Reproducibility:** This system removes random spawn list shuffling.  The only random aspect is spawnpoint selection.  On solo maps like Hillside or Midnightpark, spawnpoint selection is nearly irrelevant, and only zed spawn order and rate really matters.  This is where deterministic spawns really help.  Once you've set the spawn list and rate, every run presents effectively identical difficulty.  The game doesn't randomly get harder or easier from one attempt to the next depending on random list generation and shuffling, like in the standard game.  This takes a major luck aspect out of challenges.

## Getting Started: Commands and Options

To control this feature, set `SpawnCycle=<some_value>` on your `open` command when starting CD.  `SpawnCycle` takes the following values:

* ini: Spawn zeds according to the `SpawnCycleDefs` settings in `KFGame.ini`.  The syntax for `SpawnCycleDefs` is described in a later section of this document.
* anything else: Interpreted as the name of `SpawnCycle` preset.  Must be listed in `CDSpawnPresets` and must support the selected game length.
* unmodded: Use standard KF2's randomized spawn system.  This effectively disables spawn cycles.

For example, this command would load `KF-Hillside-B4` with the `SpawnCycle` preset named `basic_moderate`:

```
open KF-Hillside-B4?game=ControlledDifficulty.CD_Survival?SpawnCycle=basic_moderate
```

Some commands are available to display information about spawn cycles.

`CDSpawnPresets` lists available `SpawnCycle` preset names, accession dates, and authors.

`CDSpawnSummaries [optional_cycle_name [optional_player_count]]` projects the estimated number of zeds per wave, breaking fleshpounds, scrakes, sirens, husks, bloats, and trash into separate counts.  It considers the currently loaded `SpawnCycle` if no parameters are specified.  If the `optional_cycle_name` parameter is present, then it interprets it as a `SpawnCycle` value and projects for that one instead of whatever is loaded.  By default, it projects zed counts for one player plus the `FakePlayers` setting.  However, if running on a server or if you just want to see pro-forma numbers for a different player count, you can specify the `optional_player_count` parameter, which must be a positive integer.  This overrides the guessed 1 + fakes value when specified.  This command does not consider the boss wave.  It only considers regular waves.

`CDSpawnDetails [optional_cycle_name]` lists the exact spawn squads scheduled for each wave.  Summaries just counts the number of cysts, gorefasts, crawlers, etc per wave; this command, on the other hand, describes exactly what squads spawn on each wave, and in what order.  It is more verbose than the summaries.

![loading the mod](https://raw.githubusercontent.com/notblackout/kf2-controlled-difficulty/master/img/spawns/0_load.png)

![listing known presets](https://raw.githubusercontent.com/notblackout/kf2-controlled-difficulty/master/img/spawns/1_presets.png)

![running cdspawnsummaries](https://raw.githubusercontent.com/notblackout/kf2-controlled-difficulty/master/img/spawns/2_summaries.png)

![running cdspawndetails](https://raw.githubusercontent.com/notblackout/kf2-controlled-difficulty/master/img/spawns/3_details.png)

## INI Configuration Syntax

When `SpawnCycle=ini` is specified on CD's `open` command, CD looks for `SpawnCycleDefs` lines in KFGame.ini's `[ControlledDifficulty.CD_Survival]` section.  `SpawnCycleDefs` can only appear in `KFGame.ini` under this section.  There is no way to specify `SpawnCycleDefs` in the `open` command.  This makes `SpawnCycle=ini` currently the only aspect of CD that requires manual config editing to use.

The first `SpawnCycleDefs` that appears in `KFGame.ini` controls Wave 1, the second controls Wave 2, etc.  The number of `SpawnCycleDefs` must match the game length or an error message will be printed at game startup and CD will revert to unmodded spawn behavior.

A single `SpawnCycleDefs` line for a wave is a comma-separated list of squads.  Squads are comprised of one or more underscore-separated elements, where each element is a number and a zed type.  This allows for heterogeneous squads.

The squads on each `SpawnCycleDefs` are spawned in the order listed.  If only part of a squad can be spawned (because of `MaxMonsters`), then zeds are spawned left-to-right within the squad.  For example, assume we have a game in progress and already at the `MaxMonsters` cap, so that new nothing can spawn.  One zed dies.  The next squad to spawn is 2Stalker_1Cyst.  CD will spawn one stalker.  Another zed dies.  CD spawns the second stalker.  Another zed dies.  CD will then spawn the cyst.

If CD reaches the end of a `SpawnCycleDefs` list before the end of the wave, then CD goes back to the beginning of the `SpawnCycleDefs` line and repeats it.  This is why they're called cycles.  They repeat as necessary to supply the number of zeds required for the selected difficulty, wave number, and player count.

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
* fle
* flesh
* fleshp
* FleshPound

Whereas all of the following strings are *invalid* (don't do this):

* flp
* FPound
* POUND

### Albino/Special Zed Variants

At the time this document was last updated, there are two albino or special zed variants:

* AL(PHA)\*, CA\*, ClotA\* (Albino Alpha Clot)
* CR(AWLER)\* (Albino Crawler)

The asterisk suffix makes these zeds albino/special.  For example, "Crawler\*" would spawn a gas grawler and "AL\*" would spawn an albino alpha clot.  Appending a * character to a zed that has no albino variant generates an error message and causes the SpawnCycle to be rejected.

CD's `AlbinoCrawlers` and `AlbinoAlphas` options only have an effect when `SpawnCycle=unmodded`.  If `SpawnCycle` is set to any other value (i.e. ini or a preset), then the cycle defs determine whether and when albino zeds spawn, regardless of the `AlbinoCrawlers` and `AlbinoAlphas` options.

## Sample Configuration

The following `KFGame.ini` snippet reflects the `basic_moderate` preset.  This could be useful if you want to start tweaking an existing preset rather than starting from scratch.

```
[ControlledDifficulty.CD_Survival]
SpawnCycle=ini
SpawnCycleDefs=4CY,3CY_1AL_1GF,6SL,4CY_1BL,3AL_1SL,4CY,3CY_1AL_1GF,4CY_1BL,3AL_1SL
SpawnCycleDefs=3CY_1AL,3CY_1SL_1BL,2CR,2ST,4CY_1BL_2GF,1HU,1SL_2AL_1GF,2AL_2GF,3CY_1AL_1GF,4CY,4CR,3CY_1AL,3CY_1SL_1BL,2CR,2ST,1HU,1SL_2AL_1GF,2AL_2GF,3CY_1AL_1GF,4CY,4CR
SpawnCycleDefs=4CR,3AL_1BL,2SL_3CR_1GF,8ST,3CY_1GF_1SI,1SL_3GF,1HU,3CY_1AL,2CR,2CR_2GF_2ST_1SI,4ST,4GF_1BL,4CR,4CY_1SI,3AL_2BL,2SL_3CR_1GF,3CY_1GF_1SI,1SL_3GF,1HU,3CY_1AL,2CR,2CR_2GF_2ST_1SI,4ST,4GF
SpawnCycleDefs=3CY_1AL,3CY_1CR_2ST_1BL_1SI,1HU_4CR,3CY,2AL_2GF,3CY_1GF_1SI,9GF,2ST,1SL_3GF,3CY_2CR_2ST_1SI,6CR,4GF,2CR_2GF_2ST,1BL_4CY_1AL,3CY_1CR_2ST_1BL_1SI,4CR,3CY_2BL,2AL_2GF,1HU,3CY_1GF_1SI,2ST,1SL_3GF,3CY_1CR_2ST_1BL_1SI,6CR,2CY_1SL_1HU,4GF,2CR_2GF_2ST_1SI
SpawnCycleDefs=2CR,2CR_2GF_2ST_1SI,4CR,3CY_1CR_2ST_1BL_1SI,1SC_6ST,2ST,3CY_1BL,4GF,6CR,4ST,2AL_2GF,2AL_1GF_1HU,1SL_3GF,3CY_1GF_1SI,3AL_1SL,2CR,4ST,2CR_2GF_2ST_1SI,4CR,3CY_1CR_2ST_1BL_1SI,1SC,2ST,3CY_1BL,4GF,2AL_1GF_1HU,6CR,2AL_2GF,1SL_3GF,3CY_1GF_1SI,3AL_1SL
SpawnCycleDefs=2AL_1GF_1HU,4CR,3AL_1SL,2SL_2CR_2GF_2SI,2AL_1SC,3CY_1SL_1BL,2CR,2ST,1SL_2AL_1GF,4GF,6CR,2CR_2GF_2ST_1SI,1HU,1SL_3GF,2SL_3CR_1GF,3CY_1CR_2ST_1BL_1SI,1SC_4ST,4CY,4ST,3CY_1AL_1GF,2AL_1GF_1HU,4CR,3AL_1SL,2SL_2CR_2GF_2SI,3CY_1SL_1BL,2CR,2AL_1SC,2ST,1SL_2AL_1GF,4GF,6CR,2CR_2GF_2ST_1SI,1SC_3GF,1SL_3GF,2SL_3CR_1GF,1HU,3CY_1CR_2ST_1BL_1SI,4CY,4ST,3CY_1AL_1GF
SpawnCycleDefs=1SL_2AL_1GF,2AL_2GF,1FP_1SC,2SL_3CR_1GF,3CY_1CR_2ST_1BL,3CY_1AL_1GF,4ST,4GF,1HU,2CR_2ST_1CY_1SI,4CY_1AL,2SL_2CR_2GF_2SI,6CR,2SL_3GF_1SC,1HU_4CR,3CY_1BL,4CY,1HU_1AL_2SL,1SL_2AL_1GF,2AL_2GF,2SL_3CR_1GF,3CY_1CR_2ST_1CY_1SI,2SL_2GF_2SC,3CY_1AL_1GF,4ST,4GF,2CR_2ST_1BL_2SI,3CY_1AL,2SL_2CR_2GF_2SI,6CR,4CR,3CY_1BL,4CY
SpawnCycleDefs=2SL_3GF_1SC,4CY_1BL,2CR,2AL_1GF_1HU,2ST,1SL_2AL_1GF,2SL_2CR_2GF,2SI,3AL_1SL,4CR,2AL_2GF,1FP_1SC,2SL_3CR_1GF,3CY_1CR_2ST_1BL_1SI,4ST,4CY,4GF,1HU,2CR_2GF_2ST_1SI,2AL_1SC,6CR,4CY_1BL,2CR,2AL_1GF_1HU,2ST,1SL_2AL_1GF,2SL_2CR_2GF,2SI,3AL_1SL,4CR,2AL_2GF,2SL_3CR_1GF,2SL_3GF_1SC,3CY_1CR_2ST_1BL_1SI,2AL_1SC,1BL_4ST,4CY,4GF,2CR_2GF_2ST_1SI,6CR
SpawnCycleDefs=1HU_4ST,2AL_1SC,4CY_1BL,2CR,3AL_1SL,6CR,2SL_2CR_2GF_2SI,4GF,2FP_1SC,2ST,1SL_2AL_1GF,4CR,2AL_2GF,2SL_3CR_1GF,3CY_1CR_2ST,2BL_1SI,2CR_2GF_2ST_1SI,4CY,2SL_3GF_1SC,4ST,4CY_1BL,2CR,1HU,3CY_2GF,3AL_1SL,6CR,2SL_2CR_2GF_2SI,4GF,2ST,1SL_2AL_1GF,4CR,2SL_3CR_1GF,2AL_2GF,2AL_1SC,3CY_1CR_2ST_1BL_1SI,2SL_3GF_1SC,4CY,2CR_2GF_2ST_1SI,1HU,3CY_1CR_2ST,1BL_1SI,4CY,3GF_1SL
SpawnCycleDefs=1SL_2AL_1GF,4CR,2FP_2SC,3CY_1SL,2AL_2CY,2AL_2GF,4CY,2SL_3CR_1GF,2SL_2CR_2GF_1SI,3AL_1SL,4ST,2SL_3GF_1SC,6CR,1HU,2CR_2ST,1BL_2SI,3CY_1AL_1GF,3CY_1CR_2ST_1BL_1SI,4GF,1SL_2AL_1GF,4CR,3CY_2BL,2AL_1SC,1HU_3CY,2AL_2GF,2SL_3CR_1GF,2SL_2CR_2GF,2SI,2SL_3GF_1SC,3AL_1SL,4CY_1AL,4ST,1CR_2ST_1BL_1SI,6CR,3CY_1AL_1GF,4CY_1CR_2ST_1BL,4GF
```
