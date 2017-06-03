# Chat Commands

CD supports certain global chat incantations that will make it display or modify aspects of its configuration on the fly.

These commands all start with the string **"!cd"**.

#### How Chat Commands Work

Chat commands may be issued at any time: in the warmup session before a game starts, during a wave, during trader time, or after a game has ended.

Chat commands that do not modify the configuration always respond immediately.

Chat commands that would modify the configuration take effect immediately when issued outside a wave.  However, when executed inside a wave, modifying commands do something called "staging".  This means the command writes your modification to temporary storage without applying it right away.  When a command issued mid-wave stages your change, it will immediately respond with a string like "Staged: FakePlayers=5".  As soon as the wave ends -- either due to the trader opening, the team winning, or the team dying -- your changes are applied, and CD displays a reminder notification displaying the option name and new value.

#### Configuring Chat Command Access on Servers

In server mode, the INI option `DefaultAuthLevel` controls what anonymous users may do by default using chat commands.

If `DefaultAuthLevel` is set to `CDAUTH_WRITE`, then any user may run any command.  This is intended for private servers where all users are trusted.

If `DefaultAuthLevel` is set to `CDAUTH_READ` (the default), then anonymous users may only run commands that read the configuration.  They cannot run chat commands that modify the configuration.
However, a user whose SteamID is listed in any of one or more optional `AuthorizedUsers` lines may run any command, including those that modify the configuration.

Here's a config snippet illustrating how `DefaultAuthLevel=CDAUTH_READ` works with `AuthorizedUsers`.  This snippet authorizes two users to run any chat command; anyone else can only run chat commands that just read the configuration.

```
[ControlledDifficulty.CD_Survival]
DefaultAuthLevel=CDAUTH_READ
AuthorizedUsers=(SteamID="STEAM_0:0:3691909",Comment="blackout")
AuthorizedUsers=(SteamID="STEAM_0:0:11101",Comment="gabe newell")
```

The AuthorizedUsers line may appear as many times as needed. Each line specifies one SteamID (which can be found with a tool like http://steamidfinder.com/) and an arbitrary comment. The comment field can be any text you want. It's just there to make the list somewhat maintainable.

#### Chat Commands are Always Accessible in Solo

Playing CD solo automatically and unconditionally enables all chat commands.  There's no need to edit your KFGame.ini to configure `DefaultAuthLevel` or `AuthorizedUsers` if you just want to use chat commands in solo mode on your own machine.

## Option Chat Command Reference

### !cdalbinoalphas 

*Alternate name(s):* !cdaa

*Description:* Get AlbinoAlphas

*Auth level:* [CDAUTH_READ]

### !cdalbinoalphas <true|false> 

*Alternate name(s):* !cdaa

*Description:* Set AlbinoAlphas

*Auth level:* [CDAUTH_WRITE]

### !cdalbinocrawlers 

*Alternate name(s):* !cdac

*Description:* Get AlbinoCrawlers

*Auth level:* [CDAUTH_READ]

### !cdalbinocrawlers <true|false> 

*Alternate name(s):* !cdac

*Description:* Set AlbinoCrawlers

*Auth level:* [CDAUTH_WRITE]

### !cdalbinogorefasts 

*Alternate name(s):* !cdag

*Description:* Get AlbinoGorefasts

*Auth level:* [CDAUTH_READ]

### !cdalbinogorefasts <true|false> 

*Alternate name(s):* !cdag

*Description:* Set AlbinoGorefasts

*Auth level:* [CDAUTH_WRITE]

### !cdalphaglitter 

*Description:* Get AlphaGlitter

*Auth level:* [CDAUTH_READ]

### !cdalphaglitter <true|false> 

*Description:* Set AlphaGlitter

*Auth level:* [CDAUTH_WRITE]

### !cdboss 

*Description:* Get Boss

*Auth level:* [CDAUTH_READ]

### !cdboss <volter|patriarch|random> 

*Description:* Set Boss

*Auth level:* [CDAUTH_WRITE]

### !cdbossfp 

*Description:* Get BossFP

*Auth level:* [CDAUTH_READ]

### !cdbossfp <ini|int> 

*Description:* Set BossFP

*Auth level:* [CDAUTH_WRITE]

### !cdcohortsize 

*Alternate name(s):* !cdcs

*Description:* Get CohortSize

*Auth level:* [CDAUTH_READ]

### !cdcohortsize <ini|int, 0 disables cohort mode> 

*Alternate name(s):* !cdcs

*Description:* Set CohortSize

*Auth level:* [CDAUTH_WRITE]

### !cdfakeplayers 

*Alternate name(s):* !cdfp

*Description:* Get FakePlayers

*Auth level:* [CDAUTH_READ]

### !cdfakeplayers <ini|int> 

*Alternate name(s):* !cdfp

*Description:* Set FakePlayers

*Auth level:* [CDAUTH_WRITE]

### !cdfakeplayersmode 

*Description:* Get FakePlayersMode

*Auth level:* [CDAUTH_READ]

### !cdfakeplayersmode <add|replace> 

*Description:* Set FakePlayersMode

*Auth level:* [CDAUTH_WRITE]

### !cdfleshpoundfp 

*Description:* Get FleshpoundFP

*Auth level:* [CDAUTH_READ]

### !cdfleshpoundfp <ini|int> 

*Description:* Set FleshpoundFP

*Auth level:* [CDAUTH_WRITE]

### !cdmaxmonsters 

*Alternate name(s):* !cdmm

*Description:* Get MaxMonsters

*Auth level:* [CDAUTH_READ]

### !cdmaxmonsters <ini|int, 0 to use unmodded default> 

*Alternate name(s):* !cdmm

*Description:* Set MaxMonsters

*Auth level:* [CDAUTH_WRITE]

### !cdscrakefp 

*Description:* Get ScrakeFP

*Auth level:* [CDAUTH_READ]

### !cdscrakefp <ini|int> 

*Description:* Set ScrakeFP

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

### !cdspawnmod <ini|float, default is 1.0> 

*Alternate name(s):* !cdsm

*Description:* Set SpawnMod

*Auth level:* [CDAUTH_WRITE]

### !cdspawnpoll 

*Alternate name(s):* !cdsp

*Description:* Get SpawnPoll

*Auth level:* [CDAUTH_READ]

### !cdspawnpoll <ini|float, default is 1.0> 

*Alternate name(s):* !cdsp

*Description:* Set SpawnPoll

*Auth level:* [CDAUTH_WRITE]

### !cdtradertime 

*Alternate name(s):* !cdtt

*Description:* Get TraderTime

*Auth level:* [CDAUTH_READ]

### !cdtrashfp 

*Description:* Get TrashFP

*Auth level:* [CDAUTH_READ]

### !cdtrashfp <ini|int> 

*Description:* Set TrashFP

*Auth level:* [CDAUTH_WRITE]

### !cdweapontimeout 

*Alternate name(s):* !cdwt

*Description:* Get WeaponTimeout

*Auth level:* [CDAUTH_READ]

### !cdweapontimeout <int seconds, "max", or "unmodded"/-1> 

*Alternate name(s):* !cdwt

*Description:* Set WeaponTimeout

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

### !cdztspawnslowdown <ini|float, default is 1.0> 

*Description:* Set ZTSpawnSlowdown

*Auth level:* [CDAUTH_WRITE]

### !cdzedsteleportcloser 

*Alternate name(s):* !cdztc

*Description:* Get ZedsTeleportCloser

*Auth level:* [CDAUTH_READ]

### !cdzedsteleportcloser <true|false> 

*Alternate name(s):* !cdztc

*Description:* Set ZedsTeleportCloser

*Auth level:* [CDAUTH_WRITE]

## Miscellaneous Chat Command Reference

### !cdhelp 

*Description:* Information about CD's chat commands

*Auth level:* [CDAUTH_READ]

### !cdpausetrader 

*Alternate name(s):* **!cdpt**

*Description:* Pause TraderTime countdown

*Auth level:* [CDAUTH_WRITE]

### !cdunpausetrader 

*Alternate name(s):* !cdupt

*Description:* Unpause TraderTime countdown

*Auth level:* [CDAUTH_WRITE]

### !cdinfo 

*Description:* Display CD config summary

*Auth level:* [CDAUTH_READ]

### !cdinfo <full|abbrev> 

*Description:* Display full CD config

*Auth level:* [CDAUTH_READ]

### !cdversion 

*Description:* Display mod version

*Auth level:* [CDAUTH_READ]

### !cdwho 

*Description:* Display names of connected players

*Auth level:* [CDAUTH_READ]
