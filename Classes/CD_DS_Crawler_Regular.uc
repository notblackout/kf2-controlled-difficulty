//=============================================================================
// CD_DS_Crawler_Regular
// Sets the special spawnchance to zero on all difficulties
//=============================================================================
class CD_DS_Crawler_Regular extends KFDifficulty_Crawler
	abstract;

static function float GetSpecialCrawlerChance( KFPawn_ZedCrawler CrawlerPawn , KFGameReplicationInfo KFGRI )
{
	return 0.f;
}
