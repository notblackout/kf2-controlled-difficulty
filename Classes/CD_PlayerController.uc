class CD_PlayerController extends KFPlayerController;

`include(CD_Log.uci)

var config int ChatCharThreshold;
var config int ChatLineThreshold;
var config string AlphaGlitter;
var bool AlphaGlitterBool;

var CD_ConsolePrinter Client_CDCP;
var bool ClientLogging;

var const string CDEchoMessageColor;

/* CD introduces custom alpha and crawler zed classes to
   control albinism.  KF2's zed kill count (displayed at
   the after-action report screen) is based on exact class
   name matches.  This function override treats CD's
   subclasses like their parent classes for the purposes
   of zed kill tracking.
*/
function AddZedKill( class<KFPawn_Monster> MonsterClass, byte Difficulty, class<DamageType> DT )
{
	MonsterClass = class'CD_ZedNameUtils'.static.CheckMonsterClassRemap( MonsterClass, "CD_PlayerController.AddZedKill", ClientLogging );

	super.AddZedKill( MonsterClass, Difficulty, DT );
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	Client_CDCP = new class'CD_ConsolePrinter';

	if ( 0 >= ChatLineThreshold )
	{
		ChatLineThreshold = 7;
	}

	if ( 0 >= ChatCharThreshold )
	{
		ChatCharThreshold = 340;
	}

	if ( "" == AlphaGlitter )
	{
		AlphaGlitterBool = true;
		AlphaGlitter = string( AlphaGlitterBool );
	}
}

reliable client event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime  )
{
	local bool b;
	local int MessageChars, MessageLines;
	local array<string> Tokens;

	// Messages from CD bypass the usual chat display code
	if ( PRI == None && S != "" && Type == 'CDEcho' )
	{
		// Log a copy of this message to the client's console;
		// this happens regardless of what menu state the client is in (lobby, postgame, action)
		LocalPlayer(Player).ViewportClient.ViewportConsole.OutputText("[ControlledDifficulty Server Message]\n  " $ Repl(S, "\n", "\n  "));

		MessageChars = Len(s);

		// Count newlines by splitting string on \n... this seems awful, but I don't see a less-awful way
		ParseStringIntoArray( S, Tokens, "\n", false );
		MessageLines = Tokens.Length;

		if ( MessageLines > ChatLineThreshold )
		{
			S = "[See Console]";
			`cdlog( "chatdebug: Squelching chat message with lines=" $ MessageLines, ClientLogging );
		} 
		else
		{
			`cdlog( "chatdebug: Displaying chat message with lines=" $ MessageLines, ClientLogging );
		}

		if ( MessageChars > ChatCharThreshold )
		{
			S = "[See Console]";
			`cdlog( "chatdebug: Squelching chat message with charlength=" $ MessageChars, ClientLogging );
		} 
		else
		{
			`cdlog( "chatdebug: Displaying chat message with charlength=" $ MessageChars, ClientLogging );
		}

		// Attempt to append it to the PartyWidget or PostGameMenu (if active)
		if (MyGFxManager != none)
		{
			`cdlog( "chatdebug: PartyWidget instance is " $ MyGFxManager.PartyWidget, ClientLogging );

			if ( None != MyGFxManager.PartyWidget )
			{
				b = MyGFxManager.PartyWidget.ReceiveMessage( S, CDEchoMessageColor );
				`cdlog( "chatdebug: PartyWidget.ReceiveMessage returned " $ b, ClientLogging );
			}

			`cdlog( "chatdebug: PostGameMenu is " $ MyGFxManager.PostGameMenu, ClientLogging );

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

exec function CDChatCharThreshold( optional int i = -2147483648 )
{
	if ( i == -2147483648 )
	{
		Client_CDCP.Print("ChatCharThreshold="$ChatCharThreshold);
	}
	else
	{
		ChatCharThreshold = Clamp(i, 40, 2147483647);
		SaveConfig();
		Client_CDCP.Print("Set ChatCharThreshold="$ChatCharThreshold);
	}
}

exec function CDClientLogging( optional string b = "" )
{
	if ( b == "" )
	{
		Client_CDCP.Print("ClientLogging="$ClientLogging);
	}
	else
	{
		ClientLogging = bool(b);
		SaveConfig();
		Client_CDCP.Print("Set ClientLogging="$ClientLogging);
	}
}

exec function CDChatLineThreshold( optional int i = -2147483648 )
{
	if ( i == -2147483648 )
	{
		Client_CDCP.Print("ChatLineThreshold="$ChatLineThreshold);
	}
	else
	{
		ChatLineThreshold = Clamp(i, 1, 2147483647);
		SaveConfig();
		Client_CDCP.Print("Set ChatLineThreshold="$ChatLineThreshold);
	}
}

exec function CDAlphaGlitter( optional string b = "" )
{
	if ( b == "" )
	{
		Client_CDCP.Print("AlphaGlitter="$AlphaGlitter);
	}
	else
	{
		AlphaGlitterBool = bool( b );
		AlphaGlitter = string( AlphaGlitterBool );
		SaveConfig();
		Client_CDCP.Print("Set AlphaGlitter="$AlphaGlitter);
	}
}

defaultproperties
{
	MatchStatsClass=class'ControlledDifficulty.CD_EphemeralMatchStats'
	CDEchoMessageColor="00DCCE"
}
