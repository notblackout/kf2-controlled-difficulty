class CD_ProgrammableSetting extends Object
	within CD_Survival
	implements (CD_Setting)
	Abstract;

`include(CD_Log.uci)

/*
    A regulated option has three pieces of important state:

    - "indicator", a string.  This essentially says whether
      and how to regulate the option value at runtime.  The
      parser looks for some known values related to regulation
      (just "ini" for now, but maybe "bilinear:..." later),
      then falls back on trying to convert the string using a
      float(...) cast in every other case.

    - "value", a float.  This is either set directly by the
      user, or if the user specified automatic option regulation,
      by the regulator at each wave start.

    - "regulator", a CD_ValueProgram.

    The indicator must always be non-empty and valid.  The
    regulator will be None when regulation is disabled and
    non-None when regulation is enabled.
*/

var CD_ValueProgram ActualRegulator;

var string StagedIndicator;
var float StagedValue;
var CD_ValueProgram StagedRegulator;

var array<string> IniDefsArray;

var const string IniDefsArrayName;
// Default must be set within [min,max]; the default is *not* bounds-checked
var const string OptionName;
var const float DefaultSettingValue;
// Minima and maxima may be chosen mostly arbitrarily, but keep them within
// the integer precision range on IEEE 754 floats.  We don't do any arithmetic,
// so we aren't subject to cumulative error, but getting near the 2^24 boundary
// is just asking for roundoff that suprises the user.
var const float MinSettingValue;
var const float MaxSettingValue;

var const array<string> ChatCommandNames;
var const string ChatReadDescription;
var const string ChatWriteDescription;
var const string ChatWriteParamHintFragment;

function bool StageIndicator( const out string Raw, out string StatusMsg, const optional bool ForceOverwrite = false )
{
	// takes unsanitized string "Raw", attempts to interpret it as
	// a value directive, and assigns to staging state variables

	local CD_ValueProgram_IniDefs IniDefsRegulator;

	if ( Raw != "" && Raw == StagedIndicator && !ForceOverwrite )
	{
		StatusMsg = OptionName $" is already "$ Raw;
		return true;
	}

	StagedIndicator = "";
	StagedRegulator = None;
	StagedValue = DefaultSettingValue;

	if ( Raw == "ini" )
	{
		IniDefsRegulator = new class'CD_ValueProgram_IniDefs';
		IniDefsRegulator.SetConsolePrinter( GameInfo_CDCP );
		if ( IniDefsRegulator.ParseDefs( IniDefsArray, IniDefsArrayName ) )
		{
			StagedIndicator = Raw;
			StagedRegulator = IniDefsRegulator;
		}
		else
		{
			StagedValue = DefaultSettingValue;
			StagedIndicator = PrettyValue( StagedValue );
			StatusMsg = "Unable to parse "$ OptionName $" definitions; defaulting to "$ StagedIndicator;
			`cdlog(StatusMsg, bLogControlledDifficulty);
			return false;
		}
	}
	else
	{
		StagedValue = Clamp( float( Raw ), MinSettingValue, MaxSettingValue );
		StagedIndicator = PrettyValue( StagedValue );
		`cdlog("Converted raw string "$ Raw $" to staged float value "$ StagedValue 
			$" (indicator: "$ StagedIndicator $")", bLogControlledDifficulty);
	}

	StatusMsg = "Staged: "$ OptionName $"="$ StagedIndicator $
		"\nEffective after current wave"; 

	return true;
}

protected function string ReadIndicator()
{
	// TODO throw a fatal error
}

protected function WriteIndicator( const out string Ind )
{
	// TODO throw a fatal error
}

protected function float ReadValue()
{
	// TODO throw a fatal error
}

protected function WriteValue( const out float Val )
{
	// TODO throw a fatal error
}

protected function string PrettyValue( const float RawValue )
{
	return string(RawValue);
}

function bool HasStagedChanges()
{
	return ReadIndicator() != StagedIndicator;
}

function string GetChatLine()
{
	local string Result;
	local string CurIndicator;
	local float TempValue, TempWaveNum;
	local name GameStateName;
	local int NumPlayersPlusDebug;

	NumPlayersPlusDebug = Outer.NumPlayers + Outer.DebugExtraProgramPlayers;

	Result = OptionName $"=";

	CurIndicator = ReadIndicator();

	Result $= CurIndicator;

	if ( ActualRegulator != None )
	{
		GameStateName = Outer.GetStateName();

		`cdlog("StateName: "$ GameStateName, bLogControlledDifficulty);

		Result $= " [";

		// Now append a little string in square brackets showing the regulated values
		if ( GameStateName == 'PendingMatch' )
		{
			// Before the match starts, show the value that would be used on wave 1
			TempValue = ActualRegulator.GetValue( 1, Outer.WaveMax, NumPlayersPlusDebug, Outer.MaxPlayers );	
			Result $= PrettyValue( TempValue ) $"@W01";
		}
		else if ( GameStateName == 'TraderOpen' )
		{
			// During trader, show the current/last wave value and next wave values
			TempValue = ActualRegulator.GetValue( WaveNum + 1, Outer.WaveMax, NumPlayersPlusDebug, Outer.MaxPlayers );	
			Result $= PrettyValue( TempValue ) $"@"$ class'CD_StringUtils'.static.GetShortWaveNameByNum( WaveNum + 1 ) $",";
			TempValue = ActualRegulator.GetValue( WaveNum, Outer.WaveMax, NumPlayersPlusDebug, Outer.MaxPlayers );	
			Result $= PrettyValue( TempValue ) $"@"$ class'CD_StringUtils'.static.GetShortWaveNameByNum( WaveNum );
		}
		else
		{
			// During or after the game, show the current/last wave value
			TempWaveNum = 1 > WaveNum ? 1 : WaveNum;
			TempValue = ActualRegulator.GetValue( TempWaveNum, Outer.WaveMax, NumPlayersPlusDebug, Outer.MaxPlayers );
			Result $= PrettyValue( TempValue ) $"@"$ class'CD_StringUtils'.static.GetShortWaveNameByNum( TempWaveNum );
		}
		Result $= "]";
	}

	if ( HasStagedChanges() )
	{
		Result $= " (staged: " $ StagedIndicator $ ")";
	}

	return Result;
}

function string ChatWriteCommand( const out array<string> params )
{
	local string StatusMsg;

	StageIndicator( params[0], StatusMsg );

	return StatusMsg;
}

function InitFromOptions( const out string Options )
{
	local string UserInd, StatusMsg;

	// Get the user-supplied indicator from either game options or config file
	// If the indicator is bogus, the staging method will stage the default
	if ( HasOption( Options, OptionName ) )
	{
		UserInd = ParseOption( Options, OptionName );
	}
	else
	{
		UserInd = ReadIndicator();

		if ( UserInd == "" )
		{
			UserInd = string( DefaultSettingValue );
			`cdlog(OptionName $ ": blank config entry detected, initializing default=" $ UserInd,
				Outer.bLogControlledDifficulty);
		}
	}

	StageIndicator( UserInd, StatusMsg, true );

	// Force-commit to state vars in CD_Survival (overwrites values if necessary)
	CommitStagedChanges( 0 < WaveNum ? WaveNum : 1, true );

	GameInfo_CDCP.Print( GetChatLine() );
}

function string CommitStagedChanges( const int OverrideWaveNum, const optional bool ForceOverwrite = false )
{
	local string OldIndicator;

	OldIndicator = ReadIndicator();

	if ( StagedIndicator == OldIndicator && !ForceOverwrite )
	{
		return "";
	}

	WriteIndicator( StagedIndicator );

	ActualRegulator = StagedRegulator;

	if ( ActualRegulator != None )
	{
		RegulateValue( OverrideWaveNum );
	}
	else
	{
		WriteValue( StagedValue );
	}

	return OptionName $"="$ StagedIndicator $" (old: "$ OldIndicator $")";
}

function string RegulateValue( const int OverrideWaveNum )
{
	local float OldValue, NewValue;
	local int NumPlayersPlusDebug;
	local string StatusMsg;

	NumPlayersPlusDebug = Outer.NumPlayers + Outer.DebugExtraProgramPlayers;

	`cdlog("Tending "$ OptionName, bLogControlledDifficulty);

	StatusMsg = "";

	if ( None != ActualRegulator )
	{
		OldValue = ReadValue();
		NewValue = ActualRegulator.GetValue( OverrideWaveNum, Outer.WaveMax, NumPlayersPlusDebug, Outer.MaxPlayers );
		WriteValue( NewValue );
		if ( OldValue != NewValue )
		{
			StatusMsg = OptionName $"="$ PrettyValue( NewValue ) $" (old: "$ PrettyValue( OldValue ) $ ")";
			`cdlog( "Regulated "$ StatusMsg ); 
		}
		else
		{
			StatusMsg = OptionName $"="$ PrettyValue( NewValue ) $" (no change)";
			`cdlog( "Regulated "$ StatusMsg );
		}
	}
	else
	{
		`cdlog( "No regulator configured for "$ OptionName );
	}

	return StatusMsg;
}

function string GetOptionName()
{
	return OptionName;
}

function bool GetChatReadCommand( out StructChatCommand scc )
{
	local array<string> empty;
	local string desc;

	if ( ChatReadDescription != "" )
	{
		desc = ChatReadDescription;
	}
	else
	{
		desc = "Get " $ OptionName;
	}

	empty.length = 0;

	scc.Names = ChatCommandNames;
	scc.ParamHints = empty;
	scc.NullaryImpl = GetChatLine;
	scc.ParamsImpl = None;
	scc.Description = desc;
	scc.AuthLevel = CDAUTH_READ;
	scc.ModifiesConfig = false;

	return true;
}

function bool GetChatWriteCommand( out StructChatCommand scc )
{
	local string desc, hint;
	local array<string> hints;

	if ( ChatWriteDescription != "" )
	{
		desc = ChatWriteDescription;
	}
	else
	{
		desc = "Set " $ OptionName;
	}

	hint = "ini|" $ ChatWriteParamHintFragment;
	hints.length = 1;
	hints[0] = hint;

	scc.Names = ChatCommandNames;
	scc.ParamHints = hints;
	scc.NullaryImpl = None;
	scc.ParamsImpl = ChatWriteCommand;
	scc.Description = desc;
	scc.AuthLevel = CDAUTH_WRITE;
	scc.ModifiesConfig = true;

	return true;
}
