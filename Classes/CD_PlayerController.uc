class CD_PlayerController extends KFPlayerController;

`include(CD_Log.uci)

var const string CDEchoMessageColor;

var CD_Survival CDGameInfo;

/* CD introduces custom alpha and crawler zed classes to
   control albinism.  KF2's zed kill count (displayed at
   the after-action report screen) is based on exact class
   name matches.  This function override treats CD's
   subclasses like their parent classes for the purposes
   of zed kill tracking.
*/
function AddZedKill( class<KFPawn_Monster> MonsterClass, byte Difficulty, class<DamageType> DT )
{
	MonsterClass = class'CD_ZedNameUtils'.static.CheckMonsterClassRemap( MonsterClass, "CD_PlayerController.AddZedKill", CDGameInfo.bLogControlledDifficulty );

	super.AddZedKill( MonsterClass, Difficulty, DT );
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	if ( WorldInfo != None )
	{
		CDGameInfo = CD_Survival( WorldInfo.Game );
	}
}

reliable client event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime  )
{
	local bool b;
	local int LengthThreshold, MessageLength;

	if ( 0 < CDGameInfo.ChatMessageThreshold )
	{
		LengthThreshold = CDGameInfo.ChatMessageThreshold;
	}
	else
	{
		LengthThreshold = 260;
	}

	// Messages from CD bypass the usual chat display code
	if ( PRI == None && S != "" && Type == 'CDEcho' )
	{
		// Log a copy of this message to the client's console;
		// this happens regardless of what menu state the client is in (lobby, postgame, action)
		LocalPlayer(Player).ViewportClient.ViewportConsole.OutputText("[ControlledDifficulty Server Message]\n  " $ Repl(S, "\n", "\n  "));

		MessageLength = Len(s);

		if ( MessageLength > LengthThreshold )
		{
			S = "[See Console]";
			`cdlog( "chatdebug: Squelching chat message with length=" $ MessageLength, CDGameInfo.bLogControlledDifficulty );
		} 
		else
		{
			`cdlog( "chatdebug: Displaying chat message with length=" $ MessageLength, CDGameInfo.bLogControlledDifficulty );
		}

		// Attempt to append it to the PartyWidget or PostGameMenu (if active)
    	if (MyGFxManager != none)
    	{
			`cdlog( "chatdebug: PartyWidget instance is " $ MyGFxManager.PartyWidget, CDGameInfo.bLogControlledDifficulty);

    		if ( None != MyGFxManager.PartyWidget )
    		{
				b = MyGFxManager.PartyWidget.ReceiveMessage( S, CDEchoMessageColor );
				`cdlog( "chatdebug: PartyWidget.ReceiveMessage returned " $ b, CDGameInfo.bLogControlledDifficulty );
    		}

			`cdlog( "chatdebug: PostGameMenu is " $ MyGFxManager.PostGameMenu, CDGameInfo.bLogControlledDifficulty );

    		if( None != MyGFxManager.PostGameMenu )
    		{
    			MyGFxManager.PostGameMenu.ReceiveMessage( S, CDEchoMessageColor );
    		}
		}

		// Attempt to append it to GFxHUD.HudChatBox (this is at the lower-left 
		// of the player's screen after the game starts)
	    if( None != MyGFxHUD && None != MyGFxHUD.HudChatBox )
		{
			MyGFxHUD.HudChatBox.AddChatMessage(S, CDEchoMessageColor);
		}
	}
	else
	{
		// Everything else is processed as usual
		super.TeamMessage( PRI, S, Type, MsgLifeTime );
	}
}

defaultproperties
{
	MatchStatsClass=class'ControlledDifficulty.CD_EphemeralMatchStats'
	CDEchoMessageColor="00DCCE"
}
