class CD_AISpawnSquad extends KFAISpawnSquad
	dependson(KFSpawnVolume);

var array<AISquadElement> CustomMonsterList;

function AddSquadElement( AISquadElement e )
{
	CustomMonsterList.AddItem(e);
}

defaultproperties
{
	MonsterList = ();
}
