class CD_AISpawnSquad extends KFAISpawnSquad
	dependson(KFSpawnVolume);

/** Type and amount of AI and spawn behavior */
struct CD_AISquadElement
{
	var	EAIType			Type;
	var	byte			Num;

	structdefaultproperties
	{
		Num=1
	}
};


var array<AISquadElement> CustomMonsterList;

function CopyAISquadElements( out array<AISquadElement> sink )
{
	sink = CustomMonsterList;
}

function AddSquadElement( AISquadElement e )
{
	CustomMonsterList.AddItem(e);
}

defaultproperties
{
	MonsterList = ();
}
