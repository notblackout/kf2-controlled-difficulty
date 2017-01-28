//=============================================================================
// CD_DS_ClotAlpha_Regular
// Sets the special spawnchance to zero on all difficulties
//=============================================================================
class CD_DS_ClotAlpha_Regular extends KFDifficulty_ClotAlpha
	abstract;

static function float GetSpecialAlphaChance( KFGameReplicationInfo KFGRI )
{
	return 0.f;
}
