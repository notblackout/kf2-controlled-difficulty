//=============================================================================
// CD_DS_Gorefast_Regular
// Sets the special spawnchance to zero on all difficulties (always 1 blade)
//=============================================================================
class CD_DS_Gorefast_Regular extends KFDifficulty_Gorefast
	abstract;

static function float GetSpecialGorefastChance( KFGameReplicationInfo KFGRI )
{
	return 0.f;
}
