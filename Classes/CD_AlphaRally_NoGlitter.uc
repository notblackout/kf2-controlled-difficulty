//=============================================================================
// CD_AlphaRally_NoGlitter
//=============================================================================
// Extends the albino alpha clot's AOE rally skill to disable its red particle
// effects.  The rest of the aspects of the rally ability are unchanged.
//=============================================================================

class CD_AlphaRally_NoGlitter extends KFSM_AlphaRally;

function RallyZeds()
{
	local KFPawn_Monster KFPM;

	// Rally nearby zeds
	foreach KFPOwner.WorldInfo.GRI.VisibleCollidingActors( class'KFPawn_Monster', KFPM, RallyRadius, KFPOwner.Location )
	{
		// Skip our own pawn if self-rally is disabled
		if( !bRallySelf && KFPM == KFPOwner )
		{
			continue;
		}
		
		if( KFPM.IsHeadless() || !KFPM.IsAliveAndWell() )
		{
			continue;
		}
		
		// Activate buffs and effects
		KFPM.Rally( KFPOwner,
		            RallyEffect,
		            RallyEffectBoneName,
		            RallyEffectOffset,
		            AltRallyEffect,
		            AltRallyEffectBoneNames,
		            AltRallyEffectOffset,
		            true /* skip visual effects */ );
	}
}
