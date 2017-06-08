class CD_Pawn_ZedClot_Alpha extends KFPawn_ZedClot_Alpha;

simulated event PostBeginPlay()
{
	local CD_PlayerController CDPC;

	super.PostBeginPlay();

	CDPC = CD_PlayerController( GetALocalPlayerController() );

	if ( !CDPC.AlphaGlitterBool )
	{
		SpecialMoveHandler.SpecialMoveClasses[SM_Rally] = class'CD_AlphaRally_NoGlitter';
	}
}

defaultproperties
{
	ElitePawnClass=class'CD_Pawn_ZedClot_AlphaKing'
}
