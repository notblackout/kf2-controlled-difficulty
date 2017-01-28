//=============================================================================
// CD_DS_Crawler_Special
// Sets the special spawnchance to one on all difficulties
//=============================================================================
class CD_DS_Crawler_Special extends KFDifficulty_Crawler
	abstract;

static function float GetSpecialCrawlerChance( KFGameReplicationInfo KFGRI )
{
	return 1.f;
}
