//=============================================================================
// CD_ValueProgram_IniDefs
//=============================================================================
// Reads values from a possibly ragged matrix represented by an array<string>.
// Waves on rows, human player count on columns.
// The bottommost and/or rightmost value is used wherever the input parameters
// exceed the dimension of the matrix.
//=============================================================================

class CD_ValueProgram_IniDefs
	extends Object
	implements (CD_ValueProgram);

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
			if ( class'CD_StringUtils'.static.IsFloat(Tokens[j]) )
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

/*
 * This implementation completely ignores MaxWaveNum and MaxHumanPlayers.
 */
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
