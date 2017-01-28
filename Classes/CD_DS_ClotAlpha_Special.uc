//=============================================================================
// CD_DS_ClotAlpha_Special
// Sets the special spawnchance to one on all difficulties
//=============================================================================
class CD_DS_ClotAlpha_Special extends KFDifficulty_ClotAlpha
	abstract;

static function float GetSpecialAlphaChance( KFGameReplicationInfo KFGRI )
{
	return 1.f;
}
