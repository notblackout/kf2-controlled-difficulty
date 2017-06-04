# Option Reference

CD can be configured three ways.

* Parameters to the `open` command in the client or server console
* Editing KFGame.ini on the client or PCServer-KFGame.ini on the server
* Chat commands (only a subset of settings can be modified this way)

*Configuring CD via `open`*

Whenever you invoke `open <map>?game=ControlledDifficulty.CD_Survival`,
you may append additional "?"-separated key-value pairs of CD setting
names and their values.

For example, to set CohortSize to 6 and SpawnPoll to 0.75 on Outpost:

`open KF-Outpost?game=ControlledDifficulty.CD_Survival?SpawnPoll=0.75?CohortSize=6` 

*Configuring CD through INI files*

Controlled Difficulty automatically saves its settings every time they
are modified.

On the client or in standalone solo mode, this file is usually

```
<My Documents>\My Games\KillingFloor2\KFGame\KFGame\Config\KFGame.ini
```

The exact path is subject to change from one Windows version to the next.

On the server, this file is usually

```
<Server Root>\KFGame\Config\PCServer-KFGame.ini
```

If these files are not writable, then CD cannot and will not write any
of its settings to them.

*Configuring CD through Chat Commands*

Most CD configuration settings may be viewed and changed at runtime by
typing a special string into the game's public chat.  For example,
to show the current value of MaxMonsters, type `!cdmaxmonsters` in chat.
To set it to 24, type `!cdmaxmonsters 24` in chat.

CD can automatically generate a list of every chat commands name,
accepted parameters (if any), and a short description of what it does.
Type `CDChatHelp` in the console (not in the chat window!) to see this
information.

CD's chat commands are controlled by an authentication and authorization
system when CD is running on a dedicated server.  These options are 
listed in this file under the
[Chat Command Authorization](#chat-command-authorization) subsection.

For details about available Chat Commands and how they work, see 
[chat.md](chat.md).

### Spawn Intensity Settings

#### CohortSize

The maximum number of zeds that CD's SpawnManager may spawn simultaneously
(i.e. on one invocation of the SpawnManager's update function).

If this is set to 0, then the cohort spawn logic is inactive, and the game
instead spawns one squad per invocation of the update function.  That
behavior (i.e.  when set to 0) is how unmodded KF2 works: the spawn manager
creates one squad per attempt, no matter how much headroom might exist under
the MaxMonsters limit, or how many eligible spawnvolumes might be available
to accomodate more squads.

#### MaxMonsters

The maximum monsters allowed on the map at one time.  In the vanilla game,
this is 16 when in NM_StandAlone and GetLivingPlayerCount() == 1.   The
vanilla game's default is 32 in any other case (such as when playing alone
on a dedicated server).

If this is set to a nonpositive value, then the vanilla behavior prevails.

If this is set to a positive value, then it is the number of maximum
monsters allowed on the map at one time.

#### SpawnMod

The forced spawn modifier, expressed as a float between 0 and 1.

1.0 is KFGameConductor's player-friendliest state.  0.75 is
KFGameConductor's player-hostile state.

Below 0.75 is spawn intensity unseen in the vanilla game.

Setting zero means the SpawnManager will try to spawn zeds every single time
it is awoken (SpawnPoll controls how often it is awoken).  It will
only fail to spawn zeds if either the MaxMonsters limit is reached, if the
entire wave's worth of zeds has already spawned, or if the map's spawn
volumes are so congested that new zeds physically cannot be spawned without
failing a collision check (zeds inside other zeds).

Setting zero nullifies any spawn interval multiplier built into the map.
It also nullifies the sine-wave delay system TWI built into vanilla KF2,
and any early wave or difficulty-related delays.  When this is zero, the
only timing variables that matter are SpawnMod, and, to a limited extent
during zed time, ZTSpawnSlowdown.

This does not affect SpawnPoll.  SP controls how often the
SpawnManager wakes up.  This setting influences whether the SpawnManager
does or does not attempt to spawn zeds when it wakes up (along with some
other factors, like early wave modifiers, the presence of a leftover spawn
squad, the map's baked in spawn interval modifier, and a sinewave mod that
TWI probably thought would lend some kind of natural "rhythm" to the wave).
Specifically, this goes into calculation of TimeUntilNextSpawn, which is a
bit like SpawnManager marking its calendar with the soonest possible next
spawntime.

#### SpawnPoll

The timer interval, in seconds, for CD's SpawnManager's update function.
The update function first checks several state variables to determine
whether to attempt to spawn more zeds.  If it determines that it should
spawn zeds, the function then starts placing squads on spawner and/or
spawnvolume entities.  In the unmodded game, this is hardcoded to one
second.

#### ZTSpawnMode

Controls how the spawn manager does (or doesn't) react to zed time.

"unmodded" makes it run as it does in the vanilla game.  This means that the
spawn manager wakeup timer is destroyed every time zed time starts or is
extended.  This can result in extremely long spawn lulls after zed time if
SpawnPoll is long (e.g. 20 seconds).

"clockwork" prevents the spawn manager wakeup timer from being destroyed
every time zed time starts.  "clockwork" also applies ZTSpawnSlowdown to the
spawn manager timer's dilation factor.  

#### ZTSpawnSlowdown

If ZTSpawnSlowdown is 1.0, then the timer is not dilated, which means that
the spawn manager continues to wakeup every SpawnPoll (in real
seconds).  This means zed time does not slow down or speed up spawns in real
terms at all.

When ZTSpawnSlowdown is greater than 1, the spawn manager wakeup timer is
dilated to make it run that many times slower.

For example, say ZTSpawnSlowdown is set to 2.0, SpawnPoll is set to
5.0, and SpawnMode is set to 0.  The spawn manager wakes up, spawns some
zeds, and Zed Time starts one millisecond later.  Zed Time lasts 4 seconds.
The spawn manager's next wakeup will occur about 9 seconds after its last:
the spawn manager perceived 4 real seconds of zed time as only 2 seconds due
to ZTSpawnSlowdown, and then 3 more seconds elapsed during normal time, for
a total of 5 seconds.

### Zed Type and Spawn-Ordering Control

#### AlbinoCrawlers

Controls whether albino crawlers can spawn.

See AlbinoAlphas for details about exactly how this works.

#### AlbinoAlphas

Controls whether albino alphas can spawn.

true allows albino alphas to spawn normally. The meaning of "normally"
depends on the SpawnCycle.  If SpawnCycle=unmodded, the albino alphas spawn
by pure chance, the way TWI does it in vanilla KF2.  If SpawnCycle is not
unmodded, then albino alphas will spawn according to the SpawnCycle.  If the
configured SpawnCycle has no albino alphas, then none will spawn even if
this option is set to true.

false prevents albino alphas from spawning at all.  Even if the SpawnCycle
mandates albino alphas, they will not spawn when this is false.

#### AlbinoGorefasts

Controls whether albino gorefasts can spawn.

See AlbinoAlphas for details about exactly how this works.

#### Boss

Optionally controls which boss spawns, if and when the boss wave arrives.

"hans" or "volter": forces the hans boss to spawn if/when the boss wave
comes

"pat", "patty", "patriarch": forces the patriarch boss to spawn if/when the
boss wave comes

"random" or "unmodded": choose a random boss when the time comes (unmodded
game behavior)

#### SpawnCycle

Says whether to use a SpawnCycle (and if so, which one).

"ini": read info about squads from config and use it to set spawn squads

"unmodded": unmodded game behavior

All other values are reserved for current and future preset names.  Type
CDSpawnPresets to see available preset names.


### FakePlayers Settings


#### FakePlayers

Increase zed count (but not hp) as though this many additional players were
present.  The game normally increases dosh rewards for each zed at
numplayers >= 3, and faking players this way does the same.  You can always
refrain from buying if you want an extra challenge, but if the mod denied
you that bonus dosh, it could end up being gamebreaking for some runs.  In
short, FakePlayers increases both your budget and the zed count in each
wave.

The name "FakePlayers" is something of a historical artifact at this point.
This option might better be called "ExtraWaveSize" where the units are
phantom players.

#### FakePlayersMode

Controls how the values of the FakePlayers, BossFP, FleshpoundFP,
ScrakeFP, and TrashFP settings interact with the human player count.

If set to "add", then the values of various fake options are added to the
human player count value.  For example, playing solo with FakePlayers=1,
each wave will be sized as though two real humans were playing.

If set to "replace", then only the value of a specific fake option is
considered in its context, and the human player count value is ignored.  For
example, playing solo with FakePlayers=2, each wave will be sized as though
two real humans were playing.  If this is set to "replace" and any fake
option is set to zero, then that option is treated as though it had been set
to one instead.  

#### BossFP

The FakePlayers modifier applied when scaling boss head and body health.

This is affected by FakePlayersMode.

#### FleshpoundFP

The FakePlayers modifier applied when scaling fleshpound head and body
health.

This is affected by FakePlayersMode.

#### ScrakeFP

The FakePlayers modifier applied when scaling scrake head and body health.

This is affected by FakePlayersMode.

#### TrashFP

The FakePlayers modifier applied when scaling trash zed head and body
health.  The trash HP scaling algorithm is a bit screwy compared to the
other zed HP scaling algorithms, and this parameter only generally matters
when the net count exceeds 6.

"Trash" in this context means any zed that is not a boss, a scrake, or a
fleshpound.

This is affected by FakePlayersMode.


### Chat Command Authorization


#### AuthorizedUsers

Defines users always allowed to run any chat command.  This is an array
option.  It can appear on as many lines as you wish.  This is only consulted
when the game is running in server mode.  If the game is running in
standalone mode ("solo"), then the player is always authorized to run any
command, regardless of AuthorizedUsers.

Each AuthorizedUsers line specifies a steamid (in STEAMID2 format) and a
comment.  The comment can be whatever you like.  It's there just to make the
list more manageable.  You might want to put the player's nickname in there
and the date added, for example, but you can put anything in the comment
field that you want.  CD does not read the comment.

These two values are organized in a struct with the following form:

```
  (SteamID="STEAM_0:0:1234567",Comment="Mr Elusive Jan 31 2017")
```

There are many ways to find out a steamid.  Here's one tool that takes the
name or URL of a steam account, then gives the ID for that account:

```
  http://steamidfinder.com (not my website or affiliated with CD)
```

On steamidfinder.com, you want to copy the field called "SteamID" into
AuthorizedUsers.

Here's a sample INI snippet would authorize CD's author and Gabe Newell.

```
  [ControlledDifficulty.CD_Survival]
  DefaultAuthLevel=CDAUTH_READ
  AuthorizedUsers=(SteamID="STEAM_0:0:3691909",Comment="blackout")
  AuthorizedUsers=(SteamID="STEAM_0:0:11101",Comment="gabe newell")
```

#### DefaultAuthLevel

Controls the chat command authorization given to users who are connected to
a server and whose SteamID is not in the AuthorizedUsers array.  For the
rest of this section, we will call these users "anonymous users".

"CDAUTH_READ" means that anonymous users can run any CD chat command that
does not modify the configuration.  This lets players inspect the current
configuration but not change it.

"CDAUTH_WRITE" means that anonymous users can run any CD chat command.
CDAUTH_WRITE effectively makes AuthorizedUsers superfluous, since there is
no effective difference in chat command authority between AuthorizedUsers
and anonymous users with CDAUTH_WRITE.


### Miscellaneous Settings


#### AlphaGlitter

Controls the bright red particle effects that appear around zeds when an
albino alpha clot rallies them (and himself).

true to play the particle effects normally.  This makes alpha rallies look
the same as in the vanilla game.

false to disable the particle effects.  An albino alpha clot performing a
rally will still play his little stomp animation, and a small distortion
bubble will still appear around his body for a fraction of a second, but
there will be no bright red particles.  This sometimes aids visibility.

This option is strictly cosmetic.  It does not affect any of the behavior
aspects of rallies (like damage multiplier, cooldown, movespeed multiplier,
etc.).  So, even when this is set to false, rallies still happen as usual,
it's just that it's easier to see them.

This might become a client-side option one day if I can figure out how to do
that nondisruptively.

#### TraderTime

The trader time, in seconds.  if this is zero or negative, its value is
totally ignored, and the difficulty's standard trader time is used instead.

#### WeaponTimeout

Time, in seconds, that dropped weapons remain on the ground before
disappearing.  This must be either a valid integer in string form, or the
string "max".

If set to a negative value, then the game's builtin default value is not
modified.  At the time I wrote this comment, the game's default was 300
seconds (5 minutes), but that could change; setting this to -1 will use
whatever TWI chose as the default, even if they change the default in future
patches.  If set to a positive value, it overrides the TWI default.  All
dropped weapons will remain on the ground for as many seconds as this
variable's value, regardless of whether the weapon was dropped by a dying
player or a live player who pressed his dropweapon key.

If set to zero, CD behaves as though it had been set to 1.

If set to "max", the value 2^31 - 1 is used.

#### ZedsTeleportCloser

Controls whether zeds are allowed to teleport around the map in an effort to
move them closer to human players.  This teleporting is unconditionally
enabled in the vanilla game.

true allows zeds to teleport in exactly the same way they do in the
vanilla game.

false prevents zeds from teleporting closer to players.  A zed can still
teleport if it becomes convinced that it is stuck.  Furthermore, this option
does not affect the way incoming zed squads or cohorts choose spawnpoints,
which means that brand new zeds can still spawn around corners, surrounding
doorways, etc as the team kites.  These "in-your-face" spawns can look quite
a bit like zeds teleporting.  CD has no way to alter that "in-your-face"
spawn behavior (yet).

#### bLogControlledDifficulty

true enables additional CD-specific logging output at runtime.  This option
is one of the earliest added to CD, before a naming convention was established,
and its unusual name is retained today for backwards-compatibility.
