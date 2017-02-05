All options are order-insensitive with respect to one another.

## CD Options

#### AlbinoAlphas
* false forces all alpha clots to be ordinary alphas
* true allows albino alpha clots to spawn (does not force all regular alpha clots to become albinos)

#### AlbinoCrawlers
* false forces all crawlers to be ordinary crawlers
* true allows albino crawlers to spawn (does not force all regular crawlers to become albinos)

#### AlbinoGorefasts
* false forces all gorefasts to be ordinary gorefasts
* true allows albino gorefasts to spawn (does not force all regular gorefasts to become albinos)

#### Boss
* hans or volter: forces Hans Volter to spawn on the boss wave
* patriarch or patty: forces the Patriarch to spawn on the boss wave
* unmodded: random boss is selected on boss wave just like in standard KF2

#### FakePlayers
* 0 to 32, inclusive

#### MaxMonsters
* any positive value is taken literally
* 0 or negative means use the unmodded game's default
* note: standard KF2 solo uses 16, standard KF2 multiplayer server uses 32

#### SpawnCycle
* Try `CDSpawnPresets` to see valid options
* For full docs on this option, see https://github.com/notblackout/kf2-controlled-difficulty/blob/master/spawn.md

#### SpawnMod
* Multiplies the time spent waiting between zed spawns
* Smaller values are harder (less time between spawns)
* Bigger values are easier (more time between spawns)
* Recommended value range: (HOE GC's hardest setting) 0.75 ... 1.0 (HOE GC's easiest setting)
* Hard minimum: 0 (spawns one squad each second, extremely difficult)
* Hard maximum: 1

#### TraderTime
* any value in seconds
* 0 means use the default (0 does not disable trader time)

#### WeaponTimeout
* Controls how long
* Set to any nonnegative integer (seconds), or "max" to set this to the largest value representable within a integer
* -1 means use TWI's default weapon timeout, which was 5 minutes at this was last updated

## Standard KF2 Options

#### GameLength
* 0 = Short
* 1 = Medium
* 2 = Long

#### Difficulty
* 0 = Normal
* 1 = Hard
* 2 = Suicidal
* 3 = HOE


