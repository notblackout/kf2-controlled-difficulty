//=============================================================================
// CD_DS_Fleshpound_Special
// Sets the special spawnchance to one
//=============================================================================

class CD_DS_Fleshpound_Special extends KFDifficulty_Fleshpound
	abstract;

static function float GetSpecialFleshpoundChance( KFGameReplicationInfo KFGRI )
{
	return 1.f;
}
