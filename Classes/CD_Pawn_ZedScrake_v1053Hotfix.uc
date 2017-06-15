//=============================================================================
// CD_Pawn_ZedScrake_v1053Hotfix
//
// Temporary hack to workaround TWI scrake-rage bug in v1053
//=============================================================================
class CD_Pawn_ZedScrake_v1053Hotfix extends KFPawn_ZedScrake;

// Scrakes internally track both their body and head health percentage.
// If either falls under a difficulty-specific threshold (90%), then
// the scrake rages.  v1053 changed the way the maximum head
// health was calculated and stored, apparently accidentally multiplying
// it by GetAIHealthModifier twice instead of just once.  This is not
// the same as squaring the max head health: it's squaring a smaller,
// separate factor which is then multiplied with the head health.
//
// At runtime, the first multiplication happens in KFPawn_Monster,
// when HitZones[HZI_HEAD].MaxGoreHealth is initialized.
// (HitZones[HZI_HEAD].MaxGoreHealth is the basis of the head health %
// denominator in v1053).  Here's that function.  The parameter 
// HealthMod is passed from KFGameInfo, which sets it to
// GetAIHealthModifier for the current difficulty and playercount.
// 
// /** Initialize GoreHealth (Server only) */
// function ApplySpecialZoneHealthMod(float HealthMod)
// {
//     //Update head
//     HitZones[HZI_HEAD].GoreHealth = default.HitZones[HZI_HEAD].GoreHealth * HealthMod;
//     HitZones[HZI_HEAD].MaxGoreHealth = HitZones[HZI_HEAD].GoreHealth;
// }
//
// The second multiplication happens on a stack variable inside
// KFPawn_Monster's GetHeadHealthPercent().  This is invoked from
// scrake's TakeDamage() method and compared to the threshold.
//
// Before v1053, this made sense, because
// this calculation used a class default instead of the MaxGoreHealth
// variable.  v1053 made it a bug.
//
// /** Returns the percentage of head health remaining on this zed */
// function float GetHeadHealthPercent()
// {
//     local KFGameInfo KFGI;
//     local float HeadHealth, HeadHealthMax;
//     local float HealthMod, HeadHealthMod;
// 
//     HeadHealth = float(HitZones[HZI_Head].GoreHealth);
//     HeadHealthMax = float(HitZones[HZI_Head].MaxGoreHealth);
// 
//     KFGI = KFGameInfo(WorldInfo.Game);
//     if ( KFGI != none )
//     {
//         KFGI.DifficultyInfo.GetAIHealthModifier(self, KFGI.GameDifficulty, KFGI.GetLivingPlayerCount(), HealthMod, HeadHealthMod);
//         HeadHealthMax *= HeadHealthMod;
//     }
// 
//     return HeadHealth / HeadHealthMax;
// }
//
// Theoretically, because this bug involves code in KFPawn_Monster,
// it could affect all subclasses.  However, only the Scrake appears
// to actually depend on both the affected variable --
// HitZones[HZI_HEAD].MaxGoreHealth -- and the affected function --
// GetHeadHealthPercent() in a material way.  The head gore chunking
// system also seems to use GetHeadHealthPercent(), but I think that's
// it right now.

/** Returns the percentage of head health remaining on this zed */
function float GetHeadHealthPercent()
{
	local float HeadHealth, HeadHealthMax;

	HeadHealth = float(HitZones[HZI_Head].GoreHealth);
	HeadHealthMax = float(HitZones[HZI_Head].MaxGoreHealth);

	return HeadHealth / HeadHealthMax;
}
