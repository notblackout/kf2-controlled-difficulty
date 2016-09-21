//=============================================================================
// CDDifficultySettings_Crawler
//=============================================================================
class CDDifficultySettings_Crawler extends KFDifficulty_Crawler
	abstract;

static function float GetSpecialCrawlerChance( KFPawn_ZedCrawler CrawlerPawn , KFGameReplicationInfo KFGRI )
{
	return 0.f;
}
