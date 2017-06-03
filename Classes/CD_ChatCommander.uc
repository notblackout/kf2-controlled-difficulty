//=============================================================================
// CD_ChatCommander
//=============================================================================
// Manages the ChatCommand datastructures; matches incoming !cd... command
// chat strings and dispatches to the appropriate function.
//=============================================================================

class CD_ChatCommander extends Object
	within CD_Survival
	DependsOn(CD_Survival);

`include(CD_BuildInfo.uci)
`include(CD_Log.uci)

struct StructChatCommand
{
	var array<string> Names; 
	var array<string> ParamHints; 
	var delegate<ChatCommandNullaryImpl> NullaryImpl;
	var delegate<ChatCommandParamsImpl> ParamsImpl;
	var CD_Setting CDSetting;
	var string Description;
	var ECDAuthLevel AuthLevel;
	var bool ModifiesConfig;
};

var array<StructChatCommand> ChatCommands;

delegate string ChatCommandNullaryImpl();
delegate string ChatCommandParamsImpl( const out array<string> params );

function PrintCDChatHelp()
{
	local string HelpString;
	local int CCIndex, NameIndex, ParamIndex;

	GameInfo_CDCP.Print("Controlled Difficulty Chat Commands", false);
	GameInfo_CDCP.Print("----------------------------------------------------", false);
	GameInfo_CDCP.Print("CD knows the following chat commands.  Type any command in global chat.", false);
	GameInfo_CDCP.Print("Commands typed in team chat are ignored.  Commands marked CDAUTH_READ ", false);
	GameInfo_CDCP.Print("are usable by anyone.  Dedicated server admins may optionally restrict ", false);
	GameInfo_CDCP.Print("access to commands marked CDAUTH_WRITE.", false);

	for ( CCIndex = 0; CCIndex < ChatCommands.Length; CCIndex++ )
	{
		HelpString = "  " $ ChatCommands[CCIndex].Names[0];

		for ( ParamIndex = 0; ParamIndex < ChatCommands[CCIndex].ParamHints.Length; ParamIndex++ )
		{
			HelpString $= " <" $ ChatCommands[CCIndex].ParamHints[ParamIndex] $ ">";
		}

		if ( 1 < ChatCommands[CCIndex].Names.Length )
		{
			HelpString $= " (alternate name(s): ";

			for ( NameIndex = 1; NameIndex < ChatCommands[CCIndex].Names.Length; NameIndex++ )
			{
				if ( 1 < NameIndex )
				{
					HelpString $= ", ";
				}
				HelpString $= ChatCommands[CCIndex].Names[NameIndex];
			}

			HelpString $= ")";
		}

		HelpString $= " [" $ ChatCommands[CCIndex].AuthLevel $ "]";

		GameInfo_CDCP.Print(HelpString, false);
		GameInfo_CDCP.Print("    " $ ChatCommands[CCIndex].Description, false);
	}
}

function RunCDChatCommandIfAuthorized( Actor Sender, string CommandString )
{
	local ECDAuthLevel AuthLevel;
	local string ResponseMessage;
	local array<string> CommandTokens;
	local name GameStateName;
	local StructChatCommand Cmd;
	local CD_Setting CDSetting;
	local string TempString;

	local delegate<ChatCommandNullaryImpl> CNDeleg;
	local delegate<ChatCommandParamsImpl> CPDeleg;

	// First, see if this chat message looks even remotely like a CD command
	if ( 3 > Len( CommandString ) || !( Left( CommandString, 3 ) ~= "!cd" ) )
	{
		return;
	}

	AuthLevel = GetAuthorizationLevelForUser( Sender );

	// Chat commands are case-insensitive.  Lowercase the command now
	// so that we can do safely do string comparisons with lowercase
	// operands below.
	CommandString = Locs( CommandString );

	// Split the chat command on spaces, dropping empty parts.
	ParseStringIntoArray( CommandString, CommandTokens, " ", true );

	ResponseMessage = "";

	`cdlog("CommandTokens.Length: "$ CommandTokens.Length);

	if ( MatchChatCommand( CommandTokens[0], Cmd, AuthLevel, CommandTokens.Length - 1 ) )
	{
		`cdlog("Invoking chat command via table match");
		CNDeleg = Cmd.NullaryImpl;
		CPDeleg = Cmd.ParamsImpl;
		if ( Cmd.ParamHints.Length == 0 )
		{
			`cdlog("Invoking nullary chat command: "$ CommandString, bLogControlledDifficulty);
			ResponseMessage = CNDeleg();
		}
		else
		{
			`cdlog("Invoking chat command with parameters: "$ CommandString, bLogControlledDifficulty);
			CommandTokens.Remove( 0, 1 );
			ResponseMessage = CPDeleg( CommandTokens );
		}

		if ( Cmd.ModifiesConfig )
		{
			// Check whether we're allowed to modify settings right now.
			// If so, change settings immediately and let ApplyStagedSettings()
			// format an appropriate notification message.
			GameStateName = Outer.GetStateName();
			if ( GameStateName == 'PendingMatch' || GameStateName == 'MatchEnded' || GameStateName == 'TraderOpen' )
			{
				CDSetting = CD_Setting( Cmd.CDSetting );
				if ( None != CDSetting )
				{
					TempString = CDSetting.CommitStagedChanges( WaveNum + 1 );
					if ( TempString != "" )
					{
						ResponseMessage = TempString;
						Outer.SaveConfig();
					}
				}
			}
		}
	}
	else
	{
		`cdlog("Discarding unknown or unauthorized command: "$ CommandString, bLogControlledDifficulty);
	}

	// An authorized command match was found; the command may or may not
	// have succeeded, but something was executed and a chat reply should
	// be sent to all connected clients
	if ( "" != ResponseMessage )
	{
		BroadcastCDEcho( ResponseMessage );
		return;
	}
}

function SetupChatCommands()
{
	local array<string> n;
	local array<string> h;
	local StructChatCommand scc;
	local int i;

	ChatCommands.Length = 0;

	// Setup pause commands
	n.Length = 2;
	h.Length = 0;
	n[0] = "!cdpausetrader";
	n[1] = "!cdpt";
	scc.Names = n;
	scc.ParamHints = h;
	scc.NullaryImpl = PauseTraderTime;
	scc.ParamsImpl = None;
	scc.CDSetting = None;
	scc.Description = "Pause TraderTime countdown";
	scc.AuthLevel = CDAUTH_WRITE;
	scc.ModifiesConfig = false;
	ChatCommands.AddItem( scc );

	n.Length = 2;
	h.Length = 0;
	n[0] = "!cdunpausetrader";
	n[1] = "!cdupt";
	scc.Names = n;
	scc.ParamHints = h;
	scc.NullaryImpl = UnpauseTraderTime;
	scc.ParamsImpl = None;
	scc.CDSetting = None;
	scc.Description = "Unpause TraderTime countdown";
	scc.AuthLevel = CDAUTH_WRITE;
	scc.ModifiesConfig = false;
	ChatCommands.AddItem( scc );

	// Setup info commands
	n.Length = 1;
	h.Length = 0;
	n[0] = "!cdinfo";
	scc.Names = n;
	scc.ParamHints = h;
	scc.NullaryImpl = GetCDInfoChatStringDefault;
	scc.ParamsImpl = None;
	scc.CDSetting = None;
	scc.Description = "Display CD config summary";
	scc.AuthLevel = CDAUTH_READ;
	scc.ModifiesConfig = false;
	ChatCommands.AddItem( scc );

	n.Length = 1;
	h.Length = 1;
	n[0] = "!cdinfo";
	h[0] = "full|abbrev";
	scc.Names = n;
	scc.ParamHints = h;
	scc.NullaryImpl = None;
	scc.ParamsImpl = GetCDInfoChatStringCommand;
	scc.CDSetting = None;
	scc.Description = "Display full CD config";
	scc.AuthLevel = CDAUTH_READ;
	scc.ModifiesConfig = false;
	ChatCommands.AddItem( scc );

	// Setup who command
	n.Length = 1;
	h.Length = 0;
	n[0] = "!cdwho";
	scc.Names = n;
	scc.ParamHints = h;
	scc.NullaryImpl = GetCDWhoChatString;
	scc.ParamsImpl = None;
	scc.CDSetting = None;
	scc.Description = "Display names of connected players";
	scc.AuthLevel = CDAUTH_READ;
	scc.ModifiesConfig = false;
	ChatCommands.AddItem( scc );


	for ( i = 0; i < AllSettings.Length; i++ )
	{
		if ( AllSettings[i].GetChatReadCommand( scc ) )
		{
			ChatCommands.AddItem( scc );
		}

		if ( AllSettings[i].GetChatWriteCommand( scc ) )
		{
			ChatCommands.AddItem( scc );
		}
	}

	SetupSimpleReadCommand( scc, "!cdhelp", "Information about CD's chat commands", GetCDChatHelpReferralString );
	SetupSimpleReadCommand( scc, "!cdversion", "Display mod version", GetCDVersionChatString );
}

private function bool MatchChatCommand( const string CmdName, out StructChatCommand Cmd, const ECDAuthLevel AuthLevel, const int ParamCount )
{
	local int CCIndex;
	local int NameIndex;

	for ( CCIndex = 0; CCIndex < ChatCommands.length; CCIndex++ )
	{
		if ( AuthLevel < ChatCommands[CCIndex].AuthLevel )
		{
			continue;
		}

		if ( ParamCount != ChatCommands[CCIndex].ParamHints.Length )
		{
			continue;
		}

		for ( NameIndex = 0; NameIndex < ChatCommands[CCIndex].Names.Length; NameIndex++ )
		{
			if ( ChatCommands[CCIndex].Names[NameIndex] == CmdName )
			{
				Cmd = ChatCommands[CCIndex];
				return true;
				`cdlog("MatchChatCommand["$ CCIndex $"]: found Name="$ CmdName $" ParamCount="$ ParamCount $" AuthLevel="$ AuthLevel, bLogControlledDifficulty);
			}
		}
	}

	return false;
}

private function SetupSimpleReadCommand( out StructChatCommand scc, const string CmdName, const string Desc, const delegate<ChatCommandNullaryImpl> Impl )
{
	local array<string> n;
	local array<string> empty;

	empty.length = 0;
	n.Length = 1;
	n[0] = CmdName;

	scc.Names = n;
	scc.ParamHints = empty;
	scc.NullaryImpl = Impl;
	scc.ParamsImpl = None;
	scc.CDSetting = None;
	scc.Description = Desc;
	scc.AuthLevel = CDAUTH_READ;
	scc.ModifiesConfig = false;

	ChatCommands.AddItem( scc );
}

// Info and Help

private function string GetCDChatHelpReferralString() {
	return "Type CDChatHelp in console for chat command info";
}

private function string GetCDInfoChatStringDefault()
{
	return GetCDInfoChatString( "brief" );
}

private function string GetCDInfoChatStringCommand( const out array<string> params)
{
	return GetCDInfoChatString( params[0] );
}

function string GetCDInfoChatString( const string Verbosity )
{
	local int i;
	local string s, t, Result;

	if ( Verbosity == "full" )
	{
		Result = "";

		for ( i = 0; i < AllSettings.Length; i++ )
		{
			if ( 0 < i )
			{
				Result $= "\n";
			}
			Result $= AllSettings[i].GetChatLine();
		}
	}
	else
	{
		Result = "";

		s = MaxMonstersSetting.GetChatLine();
		t = FakePlayersSetting.GetChatLine();

		DumbLineWrapper( s, t, Result );

		s = MinSpawnIntervalSetting.GetChatLine();
		t = SpawnModSetting.GetChatLine();

		DumbLineWrapper( s, t, Result );

		Result $= CohortSizeSetting.GetChatLine() $ "\n" $
		          SpawnCycleSetting.GetChatLine();
	}

	return Result;
}

private final function DumbLineWrapper( const out string s, const out string t, out string AppendTo )
{
	if ( 38 >= Len(s) + Len(t) )
	{
		AppendTo $= s $ " " $ t $ "\n";
	}
	else
	{
		AppendTo $= s $ "\n" $ t $ "\n";
	}
}

private function string GetCDVersionChatString()
{
	return "Commit=" $ `CD_COMMIT_HASH $ "\nDate=" $ `CD_AUTHOR_TIMESTAMP;
}


private function string GetCDWhoChatString()
{
	local KFPlayerController KFPC;
	local string Result, Code;
	local int TotalCount, SpectatorCount;
	local name GameStateName;

	Result = "";
	GameStateName = Outer.GetStateName();

        foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		Code = "";

		if ( !KFPC.bIsPlayer || KFPC.bDemoOwner )
		{
			continue;
		}

		if ( !KFPC.PlayerReplicationInfo.bOnlySpectator )
		{
			SpectatorCount++;
			Code = "S";
		}

		if ( GameStateName == 'PendingMatch' )
		{
			Code = KFPC.PlayerReplicationInfo.bReadyToPlay ? "R" : "_";
		}
		else if ( GameStateName == 'PlayingWave' )
		{
			Code = KFPC.Pawn.IsAliveAndWell() ? "L" : "D";
		}
		
		if ( 0 < TotalCount )
		{
			Result $= "\n";
		}

		if ( Code != "" )
		{
			Result $= "["$ Code $"] ";
		}

		Result $= KFPC.PlayerReplicationInfo.PlayerName;

		TotalCount++;
        }

	if ( Result != "" )
	{
		Result $= "\n";
	}

	Result $= TotalCount $ " total";

	if ( 0 < SpectatorCount )
	{
		Result $= ", " $ SpectatorCount $ " spectator(s)";
	}

	return Result;
}
