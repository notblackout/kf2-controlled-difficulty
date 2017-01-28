//=============================================================================
// CD_DS_Gorefast_Special
// Sets the special spawnchance to one on all difficulties (always 2 blades)
//=============================================================================
class CD_DS_Gorefast_Special extends KFDifficulty_Gorefast
	abstract;

static function float GetSpecialGorefastChance( KFGameReplicationInfo KFGRI )
{
	return 1.f;
}
