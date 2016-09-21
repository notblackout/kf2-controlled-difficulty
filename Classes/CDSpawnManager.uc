//=============================================================================
// CDSpawnManager
//
// This is the common parent class for CD's various game-length-specific
// SpawnManager subclasses.  Having one subclass per game-length is a
// convention inherited from the base game.
// This lets us override GetMaxMonsters() once for all of the
// game-length-specific subclasses.
//=============================================================================
class CDSpawnManager extends KFAISpawnManager
	within CD_Survival;

// This function is invoked by the spawning system in the base game.
// Its return value is the maximum number of simultaneously live zeds
// allowed on the map at one time.
function int GetMaxMonsters()
{
	local int mm;

	// We must be careful when accessing CD_Survival's MaxMonsters variable,
	// because we inherited a MaxMonsters field from KFAISpawnManager.  We generally
	// want to ignore the KFAISpawnManager variable and consider only Outer.MaxMonsters,
	// which is the user-specified CD_Survival setting.

	mm = Outer.MaxMonsters;

	if (0 < mm)
	{
		`log("GetMaxMonsters(): Returning custom value "$mm, bLogControlledDifficulty);
	}
	else
	{
		mm = super.GetMaxMonsters();
		`log("GetMaxMonsters(): Returning default value "$mm, bLogControlledDifficulty);
	}

	return mm;
}

// This function is invoked by the spawning system in the base game.
// It is obnoxiously difficult to modify the spawn chances for albino/regular
// crawlers without introducing a new pawn class.  I would have much rather
// they made this spawn chance table part of DifficultyInfo instead of hardcoding
// it into defaultproperties and then reading it by static method invocation.
//
// The point of this method is to replace the standard crawler pawn class (with
// hardcoded albino chances) with a CD pawn class that never spawns albinos, if
// and only if the user set AlbinoCrawlers=False.
function GetSpawnListFromSquad(byte SquadIdx, out array< KFAISpawnSquad > SquadsList, out array< class<KFPawn_Monster> >  AISpawnList)
{
	local int i;
	local int crawlersForcedRegular;

	super.GetSpawnListFromSquad(SquadIdx, SquadsList, AISpawnList);

	if ( !AlbinoCrawlers )
	{
		crawlersForcedRegular = 0;

		`log("AlbinoCrawlers="$AlbinoCrawlers$": scanning AISpawnList of length "$AISpawnList.Length$" at squadidx "$SquadIdx);
		// Replace all standard crawler classes with forced-regular crawers
		for ( i = 0; i < AISpawnList.Length; i++ )
		{
			if ( AISpawnList[i] == AIClassList[AT_Crawler] )
			{
				AISpawnList[i] = class'ControlledDifficulty.CDPawn_ZedCrawler';
				`log("Forcing crawler at AISpawnList["$i$"] to spawn as a regular crawler");
				crawlersForcedRegular += 1;
			}
		}

		`log("Total crawlers forced regular in this AISpawnList: "$crawlersForcedRegular);
	}
	else
	{
		`log("AlbinoCrawlers="$AlbinoCrawlers$": allowing albino crawlers to spawn normally");
	}
}
