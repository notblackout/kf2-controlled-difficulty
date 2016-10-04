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
