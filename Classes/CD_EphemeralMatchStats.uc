class CD_EphemeralMatchStats extends EphemeralMatchStats;

function RecordZedKill(Class<Pawn> PawnClass, class<DamageType> DT)
{
	if ( PawnClass == class'CDPawn_ZedCrawler' )
	{
		PawnClass = class'KFPawn_ZedCrawler';
		`log("Recording AAR stats kill for a CD crawler as though it were a standard crawler", bShowMatchStatsLogging);
	}

	`log("Recording zed kill for PawnClass="$PawnClass, bShowMatchStatsLogging);

	super.RecordZedKill( PawnClass, DT );
}
