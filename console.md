# CD Console Commands

Controlled Difficulty defines several console commands.
The console can be opened by pressing the tilde key (~) on most keyboards.

These console commands can currently only be executed in either solo
play or on a dedicated server using the `admin` command.

### CDChatHelp

This prints a list of every registered chat command and a brief line
explaining what it does and what parameters it takes.  There's a very
strong argument for making this option client-side rather than server-side,
and it might change from server-side to client-side in the future.

### CDSpawnDetails

When a [`SpawnCycle`](spawn.md) is loaded, this prints one line per wave,
where each line shows exactly which squads would spawn.  The squads are
comma-separated.  The format is the same as the SpawnCycleDefs ini-file
format.  This command does nothing when using `SpawnCycle=unmodded`.

### CDSpawnSummaries

When a [`SpawnCycle`](spawn.md) is loaded, this prints one line per wave,
where each line shows how many of each zed type would spawn in that wave.
There is an additiona line at the bottom showing whole-game projected
totals.  This command does nothing when using `SpawnCycle=unmodded`.
