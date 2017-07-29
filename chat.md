# Chat Commands

CD supports certain global chat incantations that will make it display or modify aspects of its configuration on the fly.

These commands all start with the string **"!cd"**.

#### How Chat Commands Work

Chat commands may be issued at any time CD is loaded: in the warmup session before a game starts, during a wave, during trader time, or after a game has ended.

Every chat command belongs to exactly one of two categories: `CDAUTH_READ` or `CDAUTH_WRITE`.  An example of a `CDAUTH_READ` command is **"!cdmaxmonsters"**, which prints the current MaxMonsters setting.  An example of a `CDAUTH_WRITE` command is **"!cdmaxmonsters 36"**, which sets MaxMonsters to 36.

`CDAUTH_WRITE` commands apply immediately when issued outside a wave (i.e. in pregame warmup, trader time, or after a game has ended).  However, when a `CDAUTH_WRITE` command is issued mid-wave, it delays application via a mechanism called "staging".  This means the command writes your modification to temporary storage without applying it to the live game configuration.  It immediately responds with a string like "Staged: MaxMonsters=36".  As soon as the wave ends -- either due to the trader opening, the team winning, or the team dying -- your changes are applied, and CD displays a reminder notification displaying the option name and the new value that it has just copied from temporary storage to the live game configuration.

`CDAUTH_READ` commands always respond immediately.  `CDAUTH_READ` commands are aware of the staging mechanism.  If a `CDAUTH_READ` command is issued mid-wave after relevant configuration writes have been staged, it will report both the actual and staged values.

#### Configuring Chat Command Access on Servers

In server mode, the INI option `DefaultAuthLevel` controls what anonymous users may do by default using chat commands.

If `DefaultAuthLevel` is set to `CDAUTH_WRITE`, then any user may run any command.  This is intended for private servers where all users are trusted.

If `DefaultAuthLevel` is set to `CDAUTH_READ` (the default), then anonymous users may only run commands that read the configuration.  They cannot run chat commands that modify the configuration.
However, a user whose SteamID is listed in any of one or more optional `AuthorizedUsers` lines may run any command, including those that modify the configuration.

Here's a config snippet illustrating how `DefaultAuthLevel=CDAUTH_READ` works with `AuthorizedUsers`.  This snippet authorizes two users to run any chat command.  Anyone besides the two listed users can run chat commands that read the configuration, but not those that would modify it.

```
[ControlledDifficulty.CD_Survival]
DefaultAuthLevel=CDAUTH_READ
AuthorizedUsers=(SteamID="STEAM_0:0:3691909",Comment="blackout")
AuthorizedUsers=(SteamID="STEAM_0:0:11101",Comment="gabe newell")
```

The AuthorizedUsers line may appear as many times as needed. Each line specifies one SteamID (which can be found with a tool like http://steamidfinder.com/) and an arbitrary comment. The comment field can be any text you want. It's just there to make the list somewhat maintainable.

#### Chat Commands are Always Accessible in Solo

Playing CD solo automatically and unconditionally enables all chat commands, both `CDAUTH_READ` and `CDAUTH_WRITE`.  There's no need to edit your KFGame.ini to configure `DefaultAuthLevel` or `AuthorizedUsers` if you just want to use chat commands in solo mode.

## Option Chat Command Reference

### !cdalbinoalphas 

*Description:* Get AlbinoAlphas

*Auth level:* [CDAUTH_READ]

### !cdalbinoalphas <true|false>

*Description:* Set AlbinoAlphas

*Auth level:* [CDAUTH_WRITE]

### !cdalbinocrawlers 

*Description:* Get AlbinoCrawlers

*Auth level:* [CDAUTH_READ]

### !cdalbinocrawlers <true|false>

*Description:* Set AlbinoCrawlers

*Auth level:* [CDAUTH_WRITE]

### !cdalbinogorefasts 

*Description:* Get AlbinoGorefasts

*Auth level:* [CDAUTH_READ]

### !cdalbinogorefasts <true|false>

*Description:* Set AlbinoGorefasts

*Auth level:* [CDAUTH_WRITE]

### !cdboss 

*Description:* Get Boss

*Auth level:* [CDAUTH_READ]

### !cdboss <volter|patriarch|random>

*Description:* Set Boss

*Auth level:* [CDAUTH_WRITE]

### !cdbosshpfakes 

*Alternate name(s):* !cdbhpf

*Description:* Get BossHPFakes

*Auth level:* [CDAUTH_READ]

### !cdbosshpfakes <ini|bilinear;<func>|int>

*Alternate name(s):* !cdbhpf

*Description:* Set BossHPFakes

*Auth level:* [CDAUTH_WRITE]

### !cdcohortsize 

*Alternate name(s):* !cdcs

*Description:* Get CohortSize

*Auth level:* [CDAUTH_READ]

### !cdcohortsize <ini|bilinear;<func>|int, 0 disables cohort mode>

*Alternate name(s):* !cdcs

*Description:* Set CohortSize

*Auth level:* [CDAUTH_WRITE]

### !cdfakesmode 

*Alternate name(s):* !cdfm

*Description:* Get FakesMode

*Auth level:* [CDAUTH_READ]

### !cdfakesmode <add_with_humans|ignore_humans>

*Alternate name(s):* !cdfm

*Description:* Set FakesMode

*Auth level:* [CDAUTH_WRITE]

### !cdfleshpoundhpfakes 

*Alternate name(s):* !cdfphpf

*Description:* Get FleshpoundHPFakes

*Auth level:* [CDAUTH_READ]

### !cdfleshpoundhpfakes <ini|bilinear;<func>|int>

*Alternate name(s):* !cdfphpf

*Description:* Set FleshpoundHPFakes

*Auth level:* [CDAUTH_WRITE]

### !cdfleshpoundragespawns 

*Description:* Get FleshpoundRageSpawns

*Auth level:* [CDAUTH_READ]

### !cdfleshpoundragespawns <true|false>

*Description:* Set FleshpoundRageSpawns

*Auth level:* [CDAUTH_WRITE]

### !cdinfo 

*Description:* Display CD config summary

*Auth level:* [CDAUTH_READ]

### !cdinfo <full|abbrev>

*Description:* Display full CD config

*Auth level:* [CDAUTH_READ]

### !cdmaxmonsters 

*Alternate name(s):* !cdmm

*Description:* Get MaxMonsters

*Auth level:* [CDAUTH_READ]

### !cdmaxmonsters <ini|bilinear;<func>|int, 0 to use unmodded default>

*Alternate name(s):* !cdmm

*Description:* Set MaxMonsters

*Auth level:* [CDAUTH_WRITE]

### !cdpausetrader 

*Alternate name(s):* !cdpt

*Description:* Pause TraderTime countdown

*Auth level:* [CDAUTH_WRITE]

### !cdscrakehpfakes 

*Alternate name(s):* !cdschpf

*Description:* Get ScrakeHPFakes

*Auth level:* [CDAUTH_READ]

### !cdscrakehpfakes <ini|bilinear;<func>|int>

*Alternate name(s):* !cdschpf

*Description:* Set ScrakeHPFakes

*Auth level:* [CDAUTH_WRITE]

### !cdspawncycle 

*Description:* Get SpawnCycle

*Auth level:* [CDAUTH_READ]

### !cdspawncycle <ini|name_of_spawn_cycle|unmodded>

*Description:* Set SpawnCycle

*Auth level:* [CDAUTH_WRITE]

### !cdspawnmod 

*Alternate name(s):* !cdsm

*Description:* Get SpawnMod

*Auth level:* [CDAUTH_READ]

### !cdspawnmod <ini|bilinear;<func>|float, default is 1.0>

*Alternate name(s):* !cdsm

*Description:* Set SpawnMod

*Auth level:* [CDAUTH_WRITE]

### !cdspawnpoll 

*Alternate name(s):* !cdsp

*Description:* Get SpawnPoll

*Auth level:* [CDAUTH_READ]

### !cdspawnpoll <ini|bilinear;<func>|float, default is 1.0>

*Alternate name(s):* !cdsp

*Description:* Set SpawnPoll

*Auth level:* [CDAUTH_WRITE]

### !cdtradertime 

*Description:* Get TraderTime

*Auth level:* [CDAUTH_READ]

### !cdtrashhpfakes 

*Alternate name(s):* !cdthpf

*Description:* Get TrashHPFakes

*Auth level:* [CDAUTH_READ]

### !cdtrashhpfakes <ini|bilinear;<func>|int>

*Alternate name(s):* !cdthpf

*Description:* Set TrashHPFakes

*Auth level:* [CDAUTH_WRITE]

### !cdunpausetrader 

*Alternate name(s):* !cdupt

*Description:* Unpause TraderTime countdown

*Auth level:* [CDAUTH_WRITE]

### !cdversion 

*Description:* Display mod version

*Auth level:* [CDAUTH_READ]

### !cdwavesizefakes 

*Alternate name(s):* !cdwsf

*Description:* Get WaveSizeFakes

*Auth level:* [CDAUTH_READ]

### !cdwavesizefakes <ini|bilinear;<func>|int>

*Alternate name(s):* !cdwsf

*Description:* Set WaveSizeFakes

*Auth level:* [CDAUTH_WRITE]

### !cdweapontimeout 

*Description:* Get WeaponTimeout

*Auth level:* [CDAUTH_READ]

### !cdweapontimeout <int seconds, "max", or "unmodded"/-1>

*Description:* Set WeaponTimeout

*Auth level:* [CDAUTH_WRITE]

### !cdwho 

*Description:* Display names of connected players

*Auth level:* [CDAUTH_READ]

### !cdzedsteleportcloser 

*Alternate name(s):* !cdztc

*Description:* Get ZedsTeleportCloser

*Auth level:* [CDAUTH_READ]

### !cdzedsteleportcloser <true|false>

*Alternate name(s):* !cdztc

*Description:* Set ZedsTeleportCloser

*Auth level:* [CDAUTH_WRITE]

### !cdztspawnmode 

*Description:* Get ZTSpawnMode

*Auth level:* [CDAUTH_READ]

### !cdztspawnmode <clockwork|unmodded>

*Description:* Set ZTSpawnMode

*Auth level:* [CDAUTH_WRITE]

### !cdztspawnslowdown 

*Description:* Get ZTSpawnSlowdown

*Auth level:* [CDAUTH_READ]

### !cdztspawnslowdown <ini|bilinear;<func>|float, default is 1.0>

*Description:* Set ZTSpawnSlowdown

*Auth level:* [CDAUTH_WRITE]
