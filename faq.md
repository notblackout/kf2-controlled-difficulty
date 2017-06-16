# Frequently Asked Questions

### How does CD relate to Skell's Faked Suite and Project One mods?

I made this mod after P1 went unmaintained, but before Skell returned to make his [Faked Suite](https://steamcommunity.com/sharedfiles/filedetails/?id=768190709).
There is significant feature overlap, though some things are unique on each side. Both mods are good.

### Does CD modify my vanilla KF2?

No.  CD does not alter any files in your KF2 installation.  CD does not affect solo games that you start through the ordinary KF2 graphical user interface, and CD does not affect vanilla multiplayer games that you join.

CD's code is contained entirely in one file, `ControlledDifficulty.u`.  This file is downloaded into `<My Documents>\My Games\KillingFloor2\KFGame\Cache` when you subscribe to CD on the workshop or join a CD-enabled dedicated server.  However, even when this file is present, it is normally inactive and its contents are not loaded.  CD can only be loaded deliberately, by either starting a solo game using the `open <mapname>?Game=ControlledDifficulty.CD_Survival` console command (as described in [getting_started.md](getting_started.md)), or by joining a dedicated server running CD.  CD is automatically unloaded when you leave a CD-enabled game.

CD will save some of its settings to pair of separate subsections in your KFGame.ini file.  These sections are:

* `[ControlledDifficulty.CD_Survival]`
* `[ControlledDifficulty.CD_PlayerController]`

By saving its settings to only these sections, CD avoids touching settings that affect the vanilla game.

### Where can I get KF-Hillside?

This is Skell's map. Skell posted this map to both the Tripwire forums and to the Steam Workshop.

Tripwire Forums link: http://forums.tripwireinteractive.com/forum/killing-floor-2/killing-floor-2-modifications/level-design-ac/beta-map-releases-aa/114043-kf-hillside

Steam Workshop link: https://steamcommunity.com/sharedfiles/filedetails/?id=769353502

CD works with any map, not just Hillside. But Hillside is good for a lot of solo challenges.

### Is CD on Tripwire's whitelist?

No. Want CD whitelisted?  Only Tripwire has the power to add CD to their whitelist; politely ask: https://forums.tripwireinteractive.com/forum/killing-floor-2/killing-floor-2-modifications/general-modding-discussion-ad/120340-whitelisting-mods-and-mutators

### Can I level up my perks in CD?

No. Tripwire decided to prevent perk progression when the server is running any non-whitelisted modifications.
CD is not on TWI's whitelist.
While playing CD, your perks will not persistently gain or lose XP.

### Why doesn't this work with the "FP Legs + Backpack Weapons" mutator?

CD doesn't work with https://steamcommunity.com/sharedfiles/filedetails/?id=679113913. At a minimum, that mutator appears to break CD's chat commands. For all I know, it breaks other things too; I haven't checked.

That mutator's description says that it 'is not compatible with mods that replace the pawn or controller such as ServerExt,' and CD does indeed subclass the player controller. I can only speculate as to what's going on here, because that mutator's source is, as best I can tell, closed. CD is open source.
