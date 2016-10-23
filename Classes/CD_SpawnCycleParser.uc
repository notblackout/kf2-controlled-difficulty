class CD_SpawnCycleParser extends Object;

struct StructParserState
{
	// all indexes are zero-based
	var int WaveIndex;
	var int SquadIndex;
	var int ElemIndex;

	var bool ParseError;

	structdefaultproperties
	{
		ParseError=false
	}
};


var private CD_ConsolePrinter CDCP;

var private StructParserState ParserState;

const MinZedsInElement = 1;
const MaxZedsInElement = 10;

const MinZedsInSquad = 1;
const MaxZedsInSquad = 10;

function SetConsolePrinter( const CD_ConsolePrinter NewCDCP )
{
	CDCP = NewCDCP;
}

function bool HasParseError()
{
	return ParserState.ParseError;
}

private function bool PrintWaveParseError( const string message )
{
	ParserState.ParseError = true;

	CDCP.Print("WARNING Wave definition parse error:\n" $
	               "      WaveNumber: " $ string(ParserState.WaveIndex + 1) $ "(one-based)\n" $
	               "   >> Message: "$ message);
	return false;
}

private function bool PrintSquadParseError( const string message )
{
	ParserState.ParseError = true;

	CDCP.Print("WARNING Squad definition parse error: (all indices start counting from 1)\n" $
	               "      WaveNumber: " $ string(ParserState.WaveIndex + 1) $ "\n" $
                       "      SquadNumber: " $ string(ParserState.SquadIndex + 1) $ "\n" $
	               "   >> Message: "$ message);
	return false;
}

private function bool PrintElemParseError( const string message )
{
	ParserState.ParseError = true;

	CDCP.Print("WARNING Squad element definition parse error: (all indices start counting from 1)\n" $
	               "      WaveNumber: " $ string(ParserState.WaveIndex + 1) $ "\n" $
                       "      SquadNumber: " $ string(ParserState.SquadIndex + 1) $ "\n" $
                       "      ElementNumber: " $ string(ParserState.ElemIndex + 1) $ "\n" $
	               "   >> Message: "$ message);
	return false;
}

private function ClearParserState()
{
	ParserState.WaveIndex = 0;
	ParserState.SquadIndex = 0;
	ParserState.ElemIndex = 0;
	ParserState.ParseError = false;
}

function bool ParseFullSpawnCycle( const array<string> fullRawSchedule, const out array< class< KFPawn_Monster > > AIClassList, out array<CD_AIWaveInfo> WaveInfos )
{
	ClearParserState();

	for ( ParserState.WaveIndex = 0; ParserState.WaveIndex < fullRawSchedule.length; ParserState.WaveIndex++ )
	{
		`log("Attempting to parse wave "$(ParserState.WaveIndex + 1)$"...");
		WaveInfos.AddItem( ParseSpawnCycleDef( fullRawSchedule[ParserState.WaveIndex], AIClassList ) );
		
		// If the wave was empty, log a fatal parse error, but keep processing later waves to
		// try to log as much information/errors as possible
		if ( WaveInfos[WaveInfos.length - 1].CustomSquads.length < 1 )
		{
			PrintWaveParseError("No valid squads found in this wave");
		}
	}

	return !HasParseError();
}

private function CD_AIWaveInfo ParseSpawnCycleDef( const string rawSchedule, const out array< class< KFPawn_Monster > > AIClassList )
{
	local array<string> SquadDefs;
	local array<string> ElemDefs;
	local CD_AIWaveInfo CurWaveInfo;
	local CD_AISpawnSquad CurSquad;
	local AISquadElement CurElement;
	local ESquadType LargestVolumeInSquad;
	local ESquadType CurElementVolume;
	local int CurSquadSize;

	CurWaveInfo = new class'ControlledDifficulty.CD_AIWaveInfo';

	// Split on , and drop empty elements
	SquadDefs = SplitString( rawSchedule, ",", true );

	// Iterate through the squads
	for ( ParserState.SquadIndex = 0; ParserState.SquadIndex < SquadDefs.length; ParserState.SquadIndex++ )
	{
		CurSquad = new class'ControlledDifficulty.CD_AISpawnSquad';
		CurSquadSize = 0;

		LargestVolumeInSquad = EST_Crawler;

		// Squads may in general be heterogeneous, e.g.
		// 2Cyst_3Crawler_2Gorefast_2Siren
		//
		// But specific squads may be homogeneous, e.g. 
		// 6Crawler
		//
		// In the following code, we split on _ and loop through
		// each element, populating a CD_AISpawnSquad as we go.
		ElemDefs = SplitString( SquadDefs[ParserState.SquadIndex], "_", true );

		for ( ParserState.ElemIndex = 0; ParserState.ElemIndex < ElemDefs.length; ParserState.ElemIndex++ )
		{
			if ( !ParseSquadElement( ElemDefs[ParserState.ElemIndex], CurElement ) )
			{
				continue; // Parse error in that element
			}

			`log("[squad#"$ ParserState.SquadIndex $",elem#"$ ParserState.ElemIndex $"] "$CurElement.Num$"x"$CurElement.Type);

			CurSquad.AddSquadElement( CurElement );
			CurSquadSize += CurElement.Num;

			// Update LargestVolumeInSquad
			CurElementVolume = AIClassList[CurElement.Type].default.MinSpawnSquadSizeType;

			// ESquadType is biggest first (boss) to smallest last (crawler)
			// blame tripwire
			if ( CurElementVolume < LargestVolumeInSquad )
			{
				LargestVolumeInSquad = CurElementVolume;
			}
		}

		// Check overall zed count of the squad (summing across all elements)
		if ( CurSquadSize < MinZedsInSquad )
		{
			PrintSquadParseError("Squad size "$ CurSquadSize $" is too small.  "$
			    "Must be between "$ MinZedsInSquad $" to "$ MaxZedsInSquad $" (inclusive).");
			continue;
		}
		if ( CurSquadSize > MaxZedsInSquad )
		{
			PrintSquadParseError("Squad size "$ CurSquadSize $" is too large.  "$
			    "Must be between "$ MinZedsInSquad $" to "$ MaxZedsInSquad $" (inclusive).");
			continue;
		}

		// I think the squad volume type doesn't even matter in most cases,
		// judging from KFAISpawnManager and the shambholic state of this
		// property on the official TWI squad archetypes
		CurSquad.MinVolumeType = LargestVolumeInSquad;
		`log("[squad#"$ ParserState.SquadIndex $"] Set spawn volume type: "$CurSquad.MinVolumeType);

		CurWaveInfo.CustomSquads.AddItem(CurSquad);
	}

	return CurWaveInfo;
}

private function bool ParseSquadElement( const out String ElemDef, out AISquadElement SquadElement )
{
	local int ElemStrLen, UnicodePoint, ElemCount, i;
	local string ElemType;
	local EAIType ElemEAIType;
	local bool IsSpecial;

	IsSpecial = false;
	ElemStrLen = Len( ElemDef );

	if ( 0 == ElemStrLen )
	{
		return PrintElemParseError("Spawn elements must not be empty.");
	}

	// Locate the first index into ElemDef where the count
	// of zeds in the element ends and the type of zed should begin
	for ( i = 0; i < ElemStrLen; i++ )
	{
		// Get unicode codepoint (as int) for char at index i
		UnicodePoint = Asc( Mid( ElemDef, i, 1 ) );

		// Check for low ascii numerals [0-9]
		if ( !( 48 <= UnicodePoint && UnicodePoint <= 57 ) )
		{
			break; // not a numeral
		}
	}

	// The index must not be at the very beginning or end of the string.
	// If that's true, then we can assume it was malformed.
	if ( i <= 0 || i >= ElemStrLen )
	{
		return PrintElemParseError("Spawn element \""$ ElemDef $"\" could not be parsed.");
	}

	// Check whether the element string ends with a *.  The
	// asterisk suffix denotes special/albino zeds.  It is only
	// valid on crawlers and alphas (when this comment was written,
	// at least).  We will have to check that constraint later so
	// that we correctly reject requests for nonexistent specials,
	// e.g. albino scrake.
	if ( "*" == Right( ElemDef, 1 ) )
	{
		IsSpecial = true;

		// Check that the zed name is not empty
		if ( i >= ElemStrLen - 1)
		{
			return PrintElemParseError("Spawn element \""$ ElemDef $"\" could not be parsed.");
		}
	}

	// Cut string into two parts.
	//
	// Left is the count as a stringified int.  We know it is a
	// parseable int because of the preceding unicode check loop.
	//
	// Right is possibly the name of a zed as a string, but it is
	// totally unverified at this stage.  We exclude the * suffix
	// (if it was detected above).
	ElemCount = int( Mid( ElemDef, 0, i ) );
	ElemType  = Mid( ElemDef, i, ElemStrLen - i - ( IsSpecial ? 1 : 0 ) );

	// Check value range for ElemCount
	if ( ElemCount < MinZedsInElement )
	{
		return PrintElemParseError("Element count "$ ElemCount $" is not positive.  "$
		           "Must be between "$ MinZedsInElement $" to "$ MaxZedsInElement $" (inclusive).");
	}
	if ( ElemCount > MaxZedsInElement )
	{
		return PrintElemParseError("Element count "$ ElemCount $" is too large.  "$
		           "Must be between "$ MinZedsInElement $" to "$ MaxZedsInElement $" (inclusive).");
	}

	// Convert user-provided zed type name into a zed type enum
	ElemEAIType = class'CD_ZedNameUtils'.static.GetZedType( ElemType );

	// Was it a valid zed type name?
	if ( 255 == ElemEAIType )
	{
		return PrintElemParseError("\""$ ElemType $"\" does not appear to be a zed name."$
		              "  Must be a zed name or abbreviation like cyst, fp, etc.");
	}

	// If the ElemDef requested a special zed, then we need to
	// check that the zed described by ElemType actually has a
	// special/albino variant.
	if ( IsSpecial && !( ElemEAIType == AT_AlphaClot || ElemEAIType == AT_Crawler ) )
	{
		return PrintElemParseError("\""$ ElemType $"\" does not have a special variant."$
		      "  Remove the trailing asterisk from \""$ ElemDef $"\" to spawn a non-special equivalent.");
	}

	SquadElement.Type = ElemEAIType;
	SquadElement.Num = ElemCount;
	
	// Apply custom class overrides that control albinism
	if ( ElemEAIType == AT_AlphaClot )
	{
		SquadElement.CustomClass = IsSpecial ?
			class'CD_Pawn_ZedClot_Alpha_Special' :
			class'CD_Pawn_ZedClot_Alpha_Regular' ;
	}
	else if ( ElemEAIType == AT_Crawler )
	{
		SquadElement.CustomClass = IsSpecial ?
			class'CD_Pawn_ZedCrawler_Special' :
			class'CD_Pawn_ZedCrawler_Regular' ;
	}
	else
	{
		SquadElement.CustomClass = None;
	}

	return true;
}
