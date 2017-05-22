class CD_SettingRegulator_IniDefs
	extends Object
	implements (CD_SettingRegulator);

`include(CD_Log.uci)

struct StructFloatArray
{
	var array<float> fs;
};

struct StructRegParserState
{
	// all indexes are zero-based
	var int WaveIndex;
	var int PlayerIndex; // index 0 == one player (solo)

	var bool ParseError;

	structdefaultproperties
	{
		ParseError=false
	}
};


var StructRegParserState ParserState;

var array<StructFloatArray> Defs;

var private CD_ConsolePrinter CDCP;

function SetConsolePrinter( const CD_ConsolePrinter NewCDCP )
{
	CDCP = NewCDCP;
}

function bool ParseDefs( const out array<string> NewDefs, const string DefsName )
{
	local int i, j;
	local array<string> Tokens;

	Defs.Length = NewDefs.Length;

	ClearParserState();

	if ( 0 == NewDefs.Length )
	{
		CDCP.Print("WARNING "$ DefsName $" parse error:\n" $
	               "   >> Message: No entries found in the configuration");

		return false;
	}

	for ( i = 0; i < NewDefs.Length; i++ )
	{
		ParseStringIntoArray( NewDefs[i], Tokens, ",", false );

		Defs[i].fs.Length = Tokens.Length;

		if ( 0 == Tokens.Length )
		{
			PrintWaveParseError( DefsName, "empty string found" );
			// keep going, try to print as many errors as we can find
		}

		for ( j = 0; j < Tokens.Length; j++ )
		{
			if ( IsFloat(Tokens[j]) )
			{
				Defs[i].fs[j] = float( Tokens[j] );
			}
			else
			{
				PrintPlayerParseError( DefsName, "not a float: " $ Tokens[j] );
				// keep going, try to print as many errors as we can find
			}
		}
	}

	return !HasParseError();
}

function bool HasParseError()
{
	return ParserState.ParseError;
}

private function ClearParserState()
{
	ParserState.WaveIndex = 0;
	ParserState.PlayerIndex = 0;
	ParserState.ParseError = false;
}

private function bool PrintWaveParseError( const string DefsName, const string message )
{
	ParserState.ParseError = true;

	CDCP.Print("WARNING "$ DefsName $" parse error:\n" $
	               "      WaveNumber: " $ string(ParserState.WaveIndex + 1) $ "(one-based)\n" $
	               "   >> Message: "$ message);
	return false;
}

private function bool PrintPlayerParseError( const string DefsName, const string message )
{
	ParserState.ParseError = true;

	CDCP.Print("WARNING "$ DefsName $" parse error: (all indices start counting from 1)\n" $
	               "      WaveNumber: " $ string(ParserState.WaveIndex + 1) $ "\n" $
                       "      PlayerNumber: " $ string(ParserState.PlayerIndex + 1) $ "\n" $
	               "   >> Message: "$ message);

	return false;
}

private static function bool IsFloat( const out string s )
{
	local int i, StrLen, UnicodePoint;
	local bool DotSeen, DigitSeen;

	DotSeen = false;
	DigitSeen = false;
	StrLen = Len( s );

	if ( s == "" )
	{
		return false;
	}

	i = ( Left(s, 1) == "-" ) ? 1 : 0;

	while ( i < StrLen )
	{
		// Get unicode codepoint (as int) for char at index i
		UnicodePoint = Asc( Mid( s, i, 1 ) );

		// We allow one dot anywhere after the optional minus sign,
		// regardless of whether there are or are not preceeding or
		// following numerals
		if ( !DotSeen && UnicodePoint == 42 )
		{
			DotSeen = true;
		}

		// Check for low ascii numerals [0-9]
		if ( !( 48 <= UnicodePoint && UnicodePoint <= 57 ) )
		{
			break; // not a numeral
		}
		else
		{
			DigitSeen = true;
		}

		i++;
	}

	return DigitSeen;
}


function float GetValue( const int WaveNum, const int MaxWaveNum, const int HumanPlayers, const int MaxHumanPlayers )
{
	local int ClampedWaveIndex;
	local int ClampedHumanIndex;

	ClampedWaveIndex = Clamp( WaveNum - 1, 0, Defs.Length - 1 );

	ClampedHumanIndex = Clamp( HumanPlayers - 1, 0, Defs[ClampedWaveIndex].fs.Length - 1 );

	`cdlog("Returning "$ Defs[ClampedWaveIndex].fs[ClampedHumanIndex] $
	       " (ClampedWaveIndex="$ ClampedWaveIndex $" ClampedHumanIndex="$ ClampedHumanIndex $
	       " WaveNum="$ WaveNum $ " HumanPlayers=" $ HumanPlayers $ ")");

	return Defs[ClampedWaveIndex].fs[ClampedHumanIndex];
}
