//=============================================================================
// CD_DynamicSetting
//=============================================================================
// Represents a setting whose value depends on wave number and player count
// (and the user's/admin's configuration).  Compare with CD_BasicSetting, which
// only changes on manual intervention.
//=============================================================================

class CD_DynamicSetting extends Object
	within CD_Survival
	implements (CD_Setting)
	Abstract;

`include(CD_Log.uci)

/*
    A regulated option has three pieces of important state:

    - "indicator", a string.  This essentially says whether
      and how to regulate the option value at runtime.  The
      parser looks for some known values related to regulation,
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
	local CD_ValueProgram_Bilinear BilinearRegulator;

	if ( Raw != "" && Raw == StagedIndicator && !ForceOverwrite )
	{
		StatusMsg = OptionName $" is already "$ Raw;
		return false;
	}

	// If we fail to parse, use the default value
	StatusMsg = "";
	StagedValue = DefaultSettingValue;
	StagedRegulator = None;
	StagedIndicator = PrettyValue( StagedValue );

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
			StatusMsg = "Parse error in "$ IniDefsArrayName $"; defaulting to "$ StagedIndicator;
		}
	}
	else if ( Left(Raw, 9) ~= "bilinear;" )
	{
		BilinearRegulator = new class'CD_ValueProgram_Bilinear';
		BilinearRegulator.SetConsolePrinter( GameInfo_CDCP );
		if ( BilinearRegulator.ParseComposite( Raw, Outer.bLogControlledDifficulty ) )
		{
			StagedIndicator = Raw;
			StagedRegulator = BilinearRegulator;
		}
		else
		{
			StatusMsg = "Invalid function spec: "$ Raw $"; defaulting to "$ StagedIndicator;
		}
	}
	else
	{
		StagedValue = FClamp( float( Raw ), MinSettingValue, MaxSettingValue );
		StagedIndicator = PrettyValue( StagedValue );
		StagedRegulator = None;
		`cdlog("Converted raw string "$ Raw $" to staged float value "$ StagedValue $
		       " (indicator: "$ StagedIndicator $")", bLogControlledDifficulty);
		if ( StagedIndicator == ReadIndicator() )
		{
			StatusMsg = OptionName $" is already "$ StagedIndicator;
		}
	}

	if ( StatusMsg == "" )
	{
		StatusMsg = "Staged: "$ OptionName $"="$ StagedIndicator $
			"\nEffective after current wave"; 
		return true;
	}
	
	return false;
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
	return GetChatLineInternal( false );
}

function string GetBriefChatLine()
{
	return GetChatLineInternal( true );
}

private final function string GetChatLineInternal( bool BriefFormat )
{
	local string Result;
	local string CurIndicator;
	local float TempValue, TempWaveNum;
	local name GameStateName;
	local int NumPlayersPlusDebug;

	NumPlayersPlusDebug = Outer.NumPlayers + Outer.DebugExtraProgramPlayers;

	Result = OptionName $"=";

	CurIndicator = ReadIndicator();

	// midwave
	// MaxMonsters=20@W02 [ini] (staged: 24)

	// TT
	// MaxMonsters=20@W02, 18@W01 [ini]
	// MaxMonsters=20@W02, 18@W01 [bilinear;x_yP*s_tW,777max]

	if ( ActualRegulator != None )
	{
		GameStateName = Outer.GetStateName();

		`cdlog("StateName: "$ GameStateName, bLogControlledDifficulty);

		// Now append a little string in square brackets showing the regulated values
		if ( GameStateName == 'PendingMatch' )
		{
			// Before the match starts, show the value that would be used on wave 1
			TempValue = ClampedGetValue( 1, Outer.WaveMax, NumPlayersPlusDebug, Outer.MaxPlayers );	
			Result $= PrettyValue( TempValue ) $"@W01";
		}
		else if ( GameStateName == 'TraderOpen' )
		{
			// During trader, show the current/last wave value and next wave values
			TempValue = ClampedGetValue( WaveNum + 1, Outer.WaveMax, NumPlayersPlusDebug, Outer.MaxPlayers );	
			Result $= PrettyValue( TempValue ) $"@"$ class'CD_StringUtils'.static.GetShortWaveNameByNum( WaveNum + 1 ) $",";
			TempValue = ClampedGetValue( WaveNum, Outer.WaveMax, NumPlayersPlusDebug, Outer.MaxPlayers );	
			Result $= PrettyValue( TempValue ) $"@"$ class'CD_StringUtils'.static.GetShortWaveNameByNum( WaveNum );
		}
		else
		{
			// During or after the game, show the current/last wave value
			TempWaveNum = 1 > WaveNum ? 1 : WaveNum;
			TempValue = ClampedGetValue( TempWaveNum, Outer.WaveMax, NumPlayersPlusDebug, Outer.MaxPlayers );
			Result $= PrettyValue( TempValue ) $"@"$ class'CD_StringUtils'.static.GetShortWaveNameByNum( TempWaveNum );
		}
	}
	else
	{
		Result $= CurIndicator;
	}

	// Append information about the dynamic setting regulator/program in square brackets, if applicable
	if ( Left(CurIndicator, 9) ~= "bilinear;" )
	{
		Result $= " [" $ ( BriefFormat ? "bilinear" : CurIndicator ) $ "]";
	}
	else if ( CurIndicator ~= "ini" )
	{
		Result $= " [ini]";
	}

	// Append the staged value, if any
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
	local string PrettyOldValue, PrettyNewValue;
	local int NumPlayersPlusDebug;
	local string StatusMsg;

	NumPlayersPlusDebug = Outer.NumPlayers + Outer.DebugExtraProgramPlayers;

	`cdlog("Tending "$ OptionName, bLogControlledDifficulty);

	StatusMsg = "";

	if ( None != ActualRegulator )
	{
		OldValue = ReadValue();
		NewValue = ClampedGetValue( OverrideWaveNum, Outer.WaveMax, NumPlayersPlusDebug, Outer.MaxPlayers );
		WriteValue( NewValue );
		PrettyOldValue = PrettyValue( OldValue );
		PrettyNewValue = PrettyValue( NewValue );
		if ( PrettyOldValue != PrettyNewValue )
		{
			StatusMsg = OptionName $"="$ PrettyNewValue $" (old: "$ PrettyOldValue $ ")";
			`cdlog( "Regulated "$ StatusMsg, bLogControlledDifficulty ); 
		}
		else
		{
			StatusMsg = OptionName $"="$ PrettyNewValue $" (no change)";
			`cdlog( "Regulated "$ StatusMsg, bLogControlledDifficulty );
		}
	}
	else
	{
		`cdlog( "No regulator configured for "$ OptionName, bLogControlledDifficulty );
	}

	return StatusMsg;
}

final private function float ClampedGetValue( const int OverrideWaveNum, const int MaxWaveNum, const int HumanPlayers, const int MaxHumanPlayers )
{
	local float ResultValue;

	ResultValue = ActualRegulator.GetValue( OverrideWaveNum, MaxWaveNum, HumanPlayers, MaxHumanPlayers );

	`cdlog("DynamicSetting: ClampedGetValue, before clamping: "$ResultValue, bLogControlledDifficulty);

	ResultValue = FClamp( ResultValue, MinSettingValue, MaxSettingValue );

	`cdlog("DynamicSetting: ClampedGetValue, after clamping: "$ResultValue, bLogControlledDifficulty);

	return ResultValue;
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
	scc.CDSetting = self;
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

	hint = "ini|bilinear;<func>|" $ ChatWriteParamHintFragment;
	hints.length = 1;
	hints[0] = hint;

	scc.Names = ChatCommandNames;
	scc.ParamHints = hints;
	scc.NullaryImpl = None;
	scc.ParamsImpl = ChatWriteCommand;
	scc.CDSetting = self;
	scc.Description = desc;
	scc.AuthLevel = CDAUTH_WRITE;
	scc.ModifiesConfig = true;

	return true;
}
