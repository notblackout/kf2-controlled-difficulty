//=============================================================================
// CD_DS_Fleshpound_Regular
// Sets the special spawnchance to zero
//=============================================================================

class CD_DS_Fleshpound_Regular extends KFDifficulty_Fleshpound
	abstract;

static function float GetSpecialFleshpoundChance( KFGameReplicationInfo KFGRI )
{
	return 0.f;
}
