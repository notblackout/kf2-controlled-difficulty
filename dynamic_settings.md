# Dynamic Settings Reference

CD has some configuration options capable of automatically adjusting to changes in human player count or wave progression.
These are called "dynamic settings".

This is useful on CD dedicated servers.  The admin can use this feature to make CD automatically tailor its difficulty
settings to the number of players present and how far they are in the current game (wave-wise).

### Supported Options

The following CD options support dynamism:

* `BossFP`
* `CohortSize`
* `FakePlayers`
* `FleshpoundFP`
* `MaxMonsters`
* `ScrakeFP`
* `SpawnMod`
* `SpawnPoll`
* `TrashFP`
* `ZTSpawnSlowdown`

Dynamic settings is an optional feature that must be deliberately configured on an option-by-option basis.
It's never required.  So, if you prefer that your settings never change without manual intervention, just
don't use the special dynamic setting value syntaxes described in this document ("ini" and "bilinear:...").

### Dynamic Setting Modes

Dynamic settings currently support two modes.  In the source code, these are called "value programs", but that's
just an implementation detail right now.

* `ini`
* `bilinear:<function specifier>`

#### `ini` Dynamic Setting Configuration

The special value "ini" makes a dynamic setting look in the config file for a table of values to use.


CD appends the string "Defs" to the option name, then looks for one or more lines with that
name in the config.  Here's an illustrative example that assumes short game length:

```
MaxMonsters=ini
MaxMonstersDefs=16,18,20,22,24,26
MaxMonstersDefs=18,20,22,24,26,28
MaxMonstersDefs=19,21,23,25,29,32
MaxMonstersDefs=19,21,24,27,31,36
```

The `Defs` lines effectively form a matrix.  Rows represent wave progress.  The first row is for the
first wave, the second row is for the second wave, etc.  Columns represent player count.  The first
column is for one player, the second column is for two players, etc.

The matrix may be ragged.  Whenever the current wavenumber or player count exceeds the row or column
dimension, CD uses the bottommost or rightmost cell, respectively.  For example, say the configuration
above is used in a long game with 6 people.  MaxMonsters would progress from 26 on wave 1, to 28 on
wave 2, to 32 on wave 3, to 36 on waves 4 through the rest of the game.

Technically, this system even applies to boss waves, although most settings are not meaningful in
boss waves.  This system applies to boss waves mainly so that one `BossFP` line is sufficient to
control Boss HP no matter the gamelength, and to keep the system with potential future options that
might influence both boss and non-boss waves.

The `-Defs` configuration suffix convention may seem a bit odd.  It was chosen for its resemblance to
the `SpawnCycleDefs` which came first (more info on that in [spawn.md](spawn.md)).  The conceptual
model is similar but not identical.

### Bilinear Dynamic Setting Configuration

The special value "bilinear:<function specifier >" makes a dynamic setting compute its value according to
the function you specified.

The function spec is an extremely restricted syntax.  CD does not have a general formula parser.

**Function specification syntax:**  *A*\_*B*[P]\**X*\_*Y*[W][;*Z*max]

Parameters *A*, *B*, *X*, *Y*, and *Z* may assume any floating point number value.  Floats should be
written using only numerals, up to one decimal point, and up to one leading minus sign.  Do not use
exponent notation or append an "f".

The parts written in square brackets are optional.  The "P" and "W" characters are shorthands for
player and wave, signifying what the preceding part of the specifier scales.  The position of these
characters cannot be swapped.  The letter P must always come first (or be omitted, in which case
it is assumed) and the letter W must always come second (or be omitted, in which case it is assumed).

This syntax resolves to the following internal result:

```
   Min( Lerp(A, B, PlayerAlpha) * Lerp(X, Y, WaveAlpha), Z )
```

`Lerp` is Unreal's builtin linear interpolation function.  Its return value varies linearly from the
first argument to the second as the third argument varies from 0 to 1.

`PlayerAlpha` and `WaveAlpha` are computed by subtracting one from the actual player count or wave number,
then dividing by `(MaxPlayers - 1)` or the `(total number of waves - 1)`.  The "total number of
waves" excludes the boss wave.  For example, in a long game, the "total number of waves" is 10,
and `(total number of waves - 1) = 9`.  On wave one of this long game, `WaveAlpha=0`.  On the second
wave of this game, `WaveAlpha=.1111`.  On the third wave, `WaveAlpha=.2222`.  And so on to wave 10,
where `WaveAlpha=1.0`.  This the following boss wave also has `WaveAlpha=1.0`.

If the optional maximum *Z* was omitted, then the `Min` function above is not executed.  The product
of linear interpolations is used directly.

This function works on floating point numbers internally, but casts to integers where the option
requires (e.g. MaxMonsters, FakePlayers, etc.). As long as absolute values remain less than 2^24
(just over 16 million) this will not cause precision errors.  Larger values may cause IEEE 754
single-precision errors when converting to integers.

##### Bilinear Dynamic Setting Examples

```
   MaxMonsters=bilinear:16_32*1_1.5;44max
```

Scales MaxMonsters from 16 to 32 with player count on wave 1.
As waves progress, the MM value from wave 1 creeps upward.
For example, assuming a full server, MaxMonsters grows from 32
to 44 (it would be slightly higher by the end, but is limited
by the max clause).

```
   SpawnPoll=bilinear:1_0.75P*1.5_0.75W
```

This gradually decreases SpawnPoll as the player count and 
wave index increase.  In a solo short game, we would get:

* Wave 1: SP = 1.5
* Wave 2: SP = 1.25
* Wave 3: SP = 1.0
* Wave 4: SP = 0.75
* Boss Wave: SP = 0.75
