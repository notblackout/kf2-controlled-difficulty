//=============================================================================
// CD_BasicSetting
//=============================================================================
// Represents a setting that only changes on manual intervention.  Compare with
// CD_DynamicSetting, which can respond to wave number and player count.
//=============================================================================

class CD_BasicSetting extends Object
	within CD_Survival
	implements (CD_Setting)
	Abstract;

`include(CD_Log.uci)

var string StagedIndicator;

var const string OptionName;
var const string DefaultSettingIndicator;

var const array<string> ChatCommandNames;
var const string ChatReadDescription;
var const string ChatWriteDescription;
var const array<string> ChatWriteParamHints;

function bool StageIndicator( const out string Raw, out string StatusMsg, const optional bool ForceOverwrite = false )
{
	local string Candidate;

	Candidate = Locs( Raw );
	Candidate = SanitizeIndicator( Candidate );

	if ( Candidate != "" && Candidate == StagedIndicator && !ForceOverwrite )
	{
		StatusMsg = OptionName $" is already "$ Candidate;
		return false;
	}

	StagedIndicator = Candidate;

	`cdlog("Converted raw string "$ Raw $" to staged value "$ StagedIndicator,
		bLogControlledDifficulty);
	
	StatusMsg = "Staged: "$ OptionName $"="$ StagedIndicator $
		"\nEffective after current wave"; 
	
	return true;
}

protected function string ReadIndicator()
{
	// TODO throw a fatal error
}

protected function WriteIndicator( const out string Val )
{
	// TODO throw a fatal error
}

protected function string SanitizeIndicator( const string Raw )
{
	// TODO throw a fatal error
}

function bool HasStagedChanges()
{
	return ReadIndicator() != StagedIndicator;
}

function string GetChatLine()
{
	local string Result, CurIndicator;

	Result = OptionName $"=";

	CurIndicator = ReadIndicator();

	Result $= CurIndicator;

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

	if ( HasOption( Options, OptionName ) )
	{
		UserInd = ParseOption( Options, OptionName );
	}
	else
	{
		UserInd = ReadIndicator();

		if ( UserInd == "" )
		{
			UserInd = DefaultSettingIndicator;
			`cdlog(OptionName $ ": blank config entry detected, initializing default=" $ UserInd,
				Outer.bLogControlledDifficulty);
		}
	}

	StageIndicator( UserInd, StatusMsg, true );

	// Force-commit to state vars in CD_Survival (overwrites values if necessary)
	CommitStagedChangesBasic( true );

	GameInfo_CDCP.Print( GetChatLine() );
}

// Implemented for interface compliance; wave number is ignored on basic settings
function string CommitStagedChanges( const int OverrideWaveNum, const optional bool ForceOverwrite = false )
{
	return CommitStagedChangesBasic( ForceOverwrite );
}

function string CommitStagedChangesBasic( const optional bool ForceOverwrite = false )
{
	local string OldIndicator;

	OldIndicator = ReadIndicator();

	if ( StagedIndicator == OldIndicator && !ForceOverwrite )
	{
		return "";
	}

	WriteIndicator( StagedIndicator );

	return OptionName $"="$ StagedIndicator $" (old: "$ OldIndicator $")";
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
	local string desc;

	if ( ChatWriteDescription != "" )
	{
		desc = ChatWriteDescription;
	}
	else
	{
		desc = "Set " $ OptionName;
	}

	scc.Names = ChatCommandNames;
	scc.ParamHints = ChatWriteParamHints;
	scc.NullaryImpl = None;
	scc.ParamsImpl = ChatWriteCommand;
	scc.CDSetting = self;
	scc.Description = desc;
	scc.AuthLevel = CDAUTH_WRITE;
	scc.ModifiesConfig = true;

	return true;
}
