# CD Console Commands

Controlled Difficulty defines several console commands.
The console can be opened by pressing the tilde key (~) on most keyboards.

In standalone mode (solo play), any console command may be executed.
This document makes a distinction between client-side and server-side
commands, but if you only care about solo play, then you can ignore the
distinction and run commands from either category.

In networked play, only some commands are available to the client.
The server has all commands available, but the client-oriented ones
tend to be irrelevant.  This distinction is awkward for some commands,
and it might go away in future revisions, insofar as that can be done
without opening any potential for replicated function resource abuse.

## Client-Side Console Commands

### CDAlphaGlitter [true|false]

Gets or sets the value of AlphaGlitter.  False disables the red visual
particle effects associated with an albino alpha clot's AOE rally ability.
True leaves those effects just as they are in the vanilla game (default).

### CDChatCharThreshold [int]

Gets or sets the value of ChatCharThreshold.  When CD prints a message
to global chat which exceeds this many characters, the
message will only be printed to the console.  In the chat box, the single
line "(See Console)" will be printed in lieu of the actual message.

### CDChatLineThreshold [int]

Gets or sets the value of ChatLineThreshold.  When CD prints a message
to global chat which exceeds this many lines (measured by the number of
newlines it contains, not the number of automatically-wrapped lines), the
message will only be printed to the console.  In the chat box, the single
line "(See Console)" will be printed in lieu of the actual message.

### CDClientLogging [true|false]

Gets or sets the CD client logging flag, which controls a few client-side
logging statements.  These are generally uninteresting except when debugging
CD's chat message and console message handling.

## Server-Side Console Commands

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
