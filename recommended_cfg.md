# Advice on CD Configuration Tuning

CD has accumulated many configuration settings over its development.
Some of these settings partially or fully supersede older ones,
even though the old ones are retained for backwards-compatibility and to support reproducible challenges.

This page highlights the most important CD options and which options to change when increasing or decreasing difficulty,
whether solo or in a group.

### Guidance on Spawn Configuration

This section assumes you're either using one of the following
SpawnCycles.  Any of these is a good choice for getting started.
Here they are listed in very loosely ascending difficulty order.

* SpawnCycle=basic_moderate
* SpawnCycle=unmodded
* SpawnCycle=basic_heavy
* SpawnCycle=nam_pro_v3

The following configuration snippets omit options that have
safe defaults.  That is, if the best starting value is the
the automatic default, then it's not listed.

Here's a good starting point configuration.  This configuration
attempts to approximate the intensity and rate of spawning in
HOE in the unmodded game.  This configuration is listed in the
form of a KFGame.ini snippet that could be copy-pasted, but you
could also configure these settings through parameters to the
`open` command used to start CD, or through chat commands.

This config is not exactly the same as vanilla HOE; this config
is probably somewhat more difficult.  Such a comparison is
somewhat subjective, and there are a lot of variables left undefined
here (for instance, there's a big difference between SpawnCycle
basic_moderate and nam_pro_v3).  So think of the difficulty
comparison as very loose and approximate.

```
[ControlledDifficulty.CD_Survival]
; You can use any SpawnCycle, but these tips were written
; with SpawnCycle=unmodded, SpawnCycle=nam_pro_v3,
; SpawnCycle=basic_moderate, or SpawnCycle=basic_heavy in mind
SpawnCycle=nam_pro_v3 ; change if desired
; Leave SpawnMod=0 and tune the other settings below
SpawnMod=0 ; Leave this alone
;
; HOE STARTING-POINT SAMPLE SETTINGS
;
; Play with the following settings.  The values below approximate
; vanilla HOE.  Adjust as you play and see how it feels.
;
; SpawnPoll controls how often the game spawns new zeds (seconds)
; smaller=more intensity, bigger=less intensity
SpawnPoll=1.25
; CohortSize controls how many zeds spawn every SpawnPoll seconds
; smaller=less intensity, bigger=more intensity
CohortSize=4
; MaxMonsters is the hardcap on live zeds.  Once MaxMonsters zeds
; are alive, no more can spawn until at least one dies.
MaxMonsters=32 ; 32 is TWI's standard multiplayer cap
; ...or...
MaxMonsters=16 ; 16 is TWI's standard solo cap
```

Assuming the map's spawn areas are big enough to keep zeds flowing,
under this configuration, zeds enter the map at a rate of approximately:

```
(CohortSize / SpawnPoll) zeds/sec = 4/1.25 = 3.2 zeds/sec
```

CD retains TWI's hardcoded 4 to 5 second delay between when the wave starts
and when the zeds begin spawning.  So there's always a slight lull in
those first five seconds or so.  But then the spawnrate equation above
starts reflecting reality.  This lull is reported in the automatic
post-wave recap stats.  It is called "pre" time in that recap.

That equation is an upper bound.  Once the MaxMonsters cap is reached,
spawning is suspended until some zeds die.  Also, on extremely cramped
maps with extremely liberal CD settings, it's possible to spawn zeds
so quickly that every spawnpoint on the map becomes congested with zeds,
and no more zeds can physically spawn until some move out of at least
one of the spawn areas.

Here's a configuration that's substantiall more intense than
vanilla HOE, but still plausibly beatable with a 6-man team.

```
[ControlledDifficulty.CD_Survival]
; You can use any SpawnCycle, but these tips were written
; with SpawnCycle=unmodded, SpawnCycle=nam_pro_v3,
; SpawnCycle=basic_moderate, or SpawnCycle=basic_heavy in mind
SpawnCycle=nam_pro_v3 ; change if desired
; Leave SpawnMod=0 and tune the other settings below
SpawnMod=0 ; Leave this alone
;
; HIGH-INTENSITY 6-MAN SAMPLE SETTINGS
;
; Play with the following settings.  The values below approximate
; vanilla HOE.  Adjust as you play and see how it feels.
;
; SpawnPoll controls how often the game spawns new zeds (seconds)
; smaller=more intensity, bigger=less intensity
SpawnPoll=1.0 ; spawn new zeds as equally often as in the unmodded game
; CohortSize controls how many zeds spawn every SpawnPoll seconds
; smaller=less intensity, bigger=more intensity
CohortSize=10 ; roughly 2x the size of unmodded game's squads
; MaxMonsters is the hardcap on live zeds.  Once MaxMonsters zeds
; are alive, no more can spawn until at least one dies.
MaxMonsters=64 ; 2x TWI's default multiplayer cap of 32
```

Here's a comically extreme hypothetical configuration.  This
would be incredibly difficult for a 6-man team, perhaps impossible.
This config would try to spawn 20 zeds every half-second.
It would keep spawning until 96 zeds were alive.  This is capable
of filling a large map (e.g. Outpost) with 96 zeds in 2.5 seconds.
This is just a theoretical exercise -- **not recommended** for
ordinary 6-man team play.

```
[ControlledDifficulty.CD_Survival]
; You can use any SpawnCycle, but these tips were written
; with SpawnCycle=unmodded, SpawnCycle=nam_pro_v3,
; SpawnCycle=basic_moderate, or SpawnCycle=basic_heavy in mind
SpawnCycle=nam_pro_v3 ; change if desired
; Leave SpawnMod=0 and tune the other settings below
SpawnMod=0 ; Leave this alone
;
; ABSURD INTENSITY -- JUST FOR DEMONSTRATION, DO NOT DO THIS
;
; Play with the following settings.  The values below approximate
; vanilla HOE.  Adjust as you play and see how it feels.
;
; SpawnPoll controls how often the game spawns new zeds (seconds)
; smaller=more intensity, bigger=less intensity
SpawnPoll=0.500 ; spawn new zeds twice as often as unmodded game
; CohortSize controls how many zeds spawn every SpawnPoll seconds
; smaller=less intensity, bigger=more intensity
CohortSize=20 ; roughly 5x the size of unmodded game's squads
; MaxMonsters is the hardcap on live zeds.  Once MaxMonsters zeds
; are alive, no more can spawn until at least one dies.
MaxMonsters=96 ; 3x TWI's default multiplayer cap of 32, hard to kite
```
Now let's move towards the easier end of the difficulty spectrum.
Here's a rather relaxed solo-oriented configuration.
Assuming the SpawnCycle isn't something crazy (like all fleshpounds),
a competent solo player can probably handle this without kiting (e.g.
on hillside).  It's comparable to vanilla HOE, and probably even a
bit easier than that.

```
[ControlledDifficulty.CD_Survival]
; Use whatever SpawnCycle suits you
SpawnCycle=basic_moderate ; change if desired
; Leave SpawnMod=0 and tune the other settings below
SpawnMod=0 ; Leave this alone
;
; RELAXED SOLO SAMPLE SETTINGS
;
; Play with the following settings.  The values below approximate
; vanilla HOE.  Adjust as you play and see how it feels.
;
; SpawnPoll controls how often the game spawns new zeds (seconds)
; smaller=more intensity, bigger=less intensity
SpawnPoll=2.0
; CohortSize controls how many zeds spawn every SpawnPoll seconds
; smaller=less intensity, bigger=more intensity
CohortSize=4
; MaxMonsters is the hardcap on live zeds.  Once MaxMonsters zeds
; are alive, no more can spawn until some die.
MaxMonsters=16
```

### Tuning Wave Size with `FakePlayers`

FakePlayers only affects the number of zeds in a wave.
Basically, when it is time for the game to calculate the
size of a wave, it pretends these FakePlayers were present.

This setting is mostly a matter of taste, but it has a
substantial impact on difficulty, particularly in solo.

Wave size scales nonlinearly for net player (fake + real)
count less than or equal to 6.  Simple Cat's spreadsheet has
a table of values showing the exact multipliers for each
value in 1..6.  They are handpicked values that don't
conform to a specific function.

At values of 7 and greater, wave size begins to scale
linearly with net player count.

Larger waves tend to revert the player or team's kill rate
to mean for a variety of reasons: fatigue, grenades,
weapon swaps, long reloads, etc.  Both large and small
waves can be difficult dependin on the settings, but all
else equal, a longer wave tends to be harder than an a
smaller one.

Whether FakePlayers is added to the actual player count or
whether it replaces the actual player counnt is controlled
by FakePlayersMode.  For configurations between and including
solo and 6-man, the default value `add` is usually
preferable.  The other mode -- `replace` -- is aimed mainly
at modded servers with huge MaxPlayers and at scaling zed
health.

### Scaling Zed Health

BossFP, FleshpoundFP, ScrakeFP, and TrashFP affect zed body
and head health.  They do *not* affect the number of these
types of zeds that spawn -- that's affected only by `SpawnCycle`.
These options just affect HP.

This is a matter of taste.  The discussion about spawn intensity
at the top of this document assumed all of these parameters
were set to 0 (that is, zed health scales only with real human
players, just like in the unmodded game).

The FleshpoundFP and ScrakeFP options are particularly useful
to solo players who want to practice decapitation techniques on
zeds with 6-player head and body health.  However, increasing
these options is going to make waves that contain SC/FP more
dangerous (all else equal), so other settings may have to be
made easier to keep the configuration neutral.

### Convenience, Cosmetics, and Annoyances

Recommended:

```
[ControlledDifficulty.CD_Survival]
WeaponTimeout=max ; weapons dropped on the ground won't disappear
ZedsTeleportCloser=false ; zeds don't teleport closer to players
```

`WeaponTimeout` controls how long weapons can sit on the ground
before they disappear.  It takes a value in seconds, or the special
value `max`.

`ZedsTeleportCloser` is the most controversial one in this section.
It controls whether zeds can teleport around the map in an attempt
to get closer to human players.  In vanilla KF2, zeds can teleport
to get closer to human players, and this option's default matches
that behavior (i.e. it defaults to true).  False prevents zeds from
teleporting to try to get closer to human players.

However, even when this is false,
it does not remove the impression of zeds hiding around corners and
behind doors, since the spawnpoint selection algorithm for brand new
zeds sometimes places those zeds where others might have teleported.

This option has no effect on whether zeds can teleport when they
think they've become stuck.  That's always allowed.

`TraderTime` is configurable in CD.  In solo on a small challenge
map, 15 tends to be more than enough, and there's always `!cdpt`
to pause trader time if more is needed.  The HOE default of 60 is
probably good for teamplay though.

### Albino/Special Zed Control

Don't like a certain albino zed?  You can disable it, even if it is
part of a SpawnCycle.  Any instances of that albino zed that would
have spawned will be replaced by its non-albino equivalent.
Related options:

* AlbinoAlphas
* AlbinoCrawlers
* AlbinoGorefasts (double-blade)
