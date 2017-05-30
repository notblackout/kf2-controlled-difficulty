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
