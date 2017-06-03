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

```
[ControlledDifficulty.CD_Survival]
; You can use any SpawnCycle, but these tips were written
; with SpawnCycle=unmodded, SpawnCycle=nam_pro_v3,
; SpawnCycle=basic_moderate, or SpawnCycle=basic_heavy in mind
SpawnCycle=nam_pro_v3 ; change if desired
; Leave SpawnMod=0 and tune the other settings below
SpawnMod=0 ; Leave this alone
;
; SAMPLE SETTINGS: HOE STARTING POINT
;
; Play with the following settings.  The values below approximate
; vanilla HOE.  Adjust as you play and see how it feels.
;
; SpawnPoll controls how often the game spawns new zeds (seconds)
; smaller=more intensity, bigger=less intensity
SpawnPoll=1.0
; CohortSize controls how many zeds spawn every SpawnPoll seconds
; smaller=less intensity, bigger=more intensity
CohortSize=4
; MaxMonsters is the hardcap on live zeds.  Once MaxMonsters zeds
; are alive, no more can spawn until some die.
MaxMonsters=32 ; 32 is TWI's standard multiplayer cap
; ...or...
MaxMonsters=16 ; 16 is TWI's standard solo cap
```

Assuming the map's spawn areas are big enough to keep zeds flowing,
under this configuration, zeds enter the map at a rate of approximately:

```
(CohortSize * SpawnPoll) zeds/sec = 5 zeds/sec
```

CD retains TWI's hardcoded 5 second delay between when the wave starts
and when the zeds begin spawning.  So there's always a slight lull in
those first five seconds or so.  But then the spawnrate equation above
starts reflecting reality.

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
; HIGH INTENSITY -- DIFFICULT 6-MAN CONFIG
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
; are alive, no more can spawn until some die.
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
; are alive, no more can spawn until some die.
MaxMonsters=96 ; 3x TWI's default multiplayer cap of 32, hard to kite
```
Now let's move towards the easier end of the difficulty spectrum.
Here's a more relaxed solo-oriented configuration.
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
SpawnPoll=1.0
; CohortSize controls how many zeds spawn every SpawnPoll seconds
; smaller=less intensity, bigger=more intensity
CohortSize=4
; MaxMonsters is the hardcap on live zeds.  Once MaxMonsters zeds
; are alive, no more can spawn until some die.
MaxMonsters=16
```
