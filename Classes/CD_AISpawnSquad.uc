//=============================================================================
// CD_AISpawnSquad
//=============================================================================
// This exists because KFAISpawnSquad's MonsterList is constant, and CD needs a
// squad object with a mutable monster list to support runtime parsing of
// user-provided SpawnCycles.
//=============================================================================

class CD_AISpawnSquad extends KFAISpawnSquad
	dependson(KFSpawnVolume);

var array<AISquadElement> CustomMonsterList;

function CopyAISquadElements( out array<AISquadElement> sink )
{
	sink = CustomMonsterList;
}

function AddSquadElement( const out AISquadElement e )
{
	CustomMonsterList.AddItem(e);
}

defaultproperties
{
	MonsterList = (); // MonsterList is const; use CustomMonsterList instead
}
