//=============================================================================
// CD_ValueProgram_Bilinear
//=============================================================================
// Implements a product of two linear interpolations:
//
//  (a) human player count, lerp 0 to server's max players, inclusive
//
//  (b) wave number, lerp 0 to final non-boss wave, inclusive
//=============================================================================

class CD_ValueProgram_Bilinear
	extends Object
	implements (CD_ValueProgram);

/*

  bilinear:1_1.25P*1_1.5W;1.75max

 */

`include(CD_Log.uci)

var private CD_ConsolePrinter CDCP;

var float PlayerCoefficientMin;
var float PlayerCoefficientMax;

var float WaveCoefficientMin;
var float WaveCoefficientMax;

var float OverallMax;

function SetConsolePrinter( const CD_ConsolePrinter NewCDCP )
{
	CDCP = NewCDCP;
}

function bool ParseComposite( const out string Composite, const bool ShouldLog )
{
	local string Body;
	local array<string> Tokens;
	local float PCMin, PCMax, WCMin, WCMax, OMax;

	if ( Composite == "" )
	{
		`cdlog( "Bilinear: ignoring empty specification string", ShouldLog );
		return false;
	}

	if ( Left( Composite, 9 ) != "bilinear:" )
	{
		`cdlog( "Bilinear: Unrecognized prefix (expected \"bilinear\"): " $ Composite, ShouldLog );
		return false;
	}

	Body = Right( Composite, Len(Composite) - 9 );

	if ( Body == "" )
	{
		`cdlog( "Bilinear: ignoring empty body string", ShouldLog );
		return false;
	}

	ParseStringIntoArray( Body, Tokens, ";", true );

	if ( 0 == Tokens.Length )
	{
		`cdlog( "Bilinear: ignoring empty body string", ShouldLog );
		return false;
	}

	if ( 2 < Tokens.Length )
	{
		`cdlog( "Bilinear: too many (" $ Tokens.Length $ ") ;-separated tokens in body string: " $ Body, ShouldLog );
		return false;
	}

	if ( !ParseCoefficients( Tokens[0], PCMin, PCMax, WCMin, WCMax, ShouldLog ) )
	{
		return false;
	}

	if ( Tokens.Length == 2 )
	{
		if ( !ParseMax( Tokens[1], OMax, ShouldLog ) )
		{
			return false;
		}
	}
	else
	{
		OMax = -1.f;
	}

	PlayerCoefficientMin = PCMin;
	PlayerCoefficientMax = PCMax;
	WaveCoefficientMin = WCMin;
	WaveCoefficientMax = WCMax;
	OverallMax = OMax;

	`cdlog( "Bilinear: read P["$ PCMin $","$ PCMax $"] W["$ WCMin $","$ WCMax $"] OMax="$ OMax, ShouldLog );

	return true;
}

function bool ParseMax( const out string MS, out float Result, const bool ShouldLog )
{
	local string LMS;

	LMS = Locs(MS);

	if ( Len(LMS) > 3 && Right(LMS, 3) == "max" )
	{
		LMS = Left(LMS, Len(LMS) - 3);
	}

	if ( !class'CD_StringUtils'.static.IsFloat(LMS) )
	{
		`cdlog( "Bilinear: malformed maxvalue string: " $ LMS, ShouldLog );
		return false;
	}

	Result = float(LMS);
	return true;
}

function bool ParseCoefficients( const out string CS, out float PCMin, out float PCMax, out float WCMin, out float WCMax, const bool ShouldLog )
{
	local array<string> Tokens;

	ParseStringIntoArray( Locs(CS), Tokens, "*", true );

	if ( 2 != Tokens.Length || Tokens[0] == "" || Tokens[1] == "" )
	{
		`cdlog( "Bilinear: malformed coefficient string: " $ CS, ShouldLog );
		return false;
	}

	if ( Right(Tokens[0], 1) == "p" )
	{
		Tokens[0] = Left( Tokens[0], Len(Tokens[0]) - 1 );
	}

	if ( Right(Tokens[1], 1) == "w" )
	{
		Tokens[1] = Left( Tokens[1], Len(Tokens[1]) - 1 );
	}

	if ( Tokens[0] == "" || Tokens[1] == "" )
	{
		`cdlog( "Bilinear: malformed coefficient string: " $ CS, ShouldLog );
		return false;
	}

	if ( !ParseLerpRangeString( Tokens[0], PCMin, PCMax, ShouldLog ) )
	{
		`cdlog( "Bilinear: malformed player coefficient range: " $ Tokens[0], ShouldLog );
		return false;
	}

	if ( !ParseLerpRangeString( Tokens[1], WCMin, WCMax, ShouldLog ) )
	{
		`cdlog( "Bilinear: malformed wave coefficient range: " $ Tokens[1], ShouldLog );
		return false;
	}

	return true;
}

function bool ParseLerpRangeString( const out string S, out float Min, out float Max, const bool ShouldLog )
{
	local array<string> Tokens;

	ParseStringIntoArray( S, Tokens, "_", true );

	if ( 2 != Tokens.Length || Tokens[0] == "" || Tokens[1] == "" )
	{
		`cdlog( "Bilinear: malformed bounds string: " $ S, ShouldLog );
		return false;
	}

	if ( !class'CD_StringUtils'.static.IsFloat( Tokens[0] ) )
	{
		`cdlog( "Bilinear: lower bound is not a float: " $ Tokens[0], ShouldLog );
		return false;
	}

	if ( !class'CD_StringUtils'.static.IsFloat( Tokens[1] ) )
	{
		`cdlog( "Bilinear: upper bound is not a float: " $ Tokens[1], ShouldLog );
		return false;
	}

	Min = float(Tokens[0]);
	Max = float(Tokens[1]);
	return true;
}

function float GetValue( const int WaveNum, const int MaxWaveNum, const int HumanPlayers, const int MaxHumanPlayers )
{
	local float PlayerAlpha, WaveAlpha, HumanFactor, WaveFactor, Result;
	local int ClampedWaveIndex, ClampedHumanIndex, MaxWaveIndex, MaxHumanIndex;

	MaxHumanIndex = MaxHumanPlayers - 1;
	ClampedHumanIndex = Clamp( HumanPlayers - 1, 0, MaxHumanIndex );

	MaxWaveIndex = MaxWaveNum - 2; // subtract 1 for num-to-index conversion, subtract 1 to ignore bosswave
	ClampedWaveIndex = Clamp( WaveNum - 1, 0, MaxWaveIndex );

	`cdlog( "Bilinear: WaveNum="$ WaveNum $" MaxWaveNum="$ MaxWaveNum $" ClampedWaveindex="$ ClampedWaveIndex $" MaxWaveIndex="$ MaxWaveIndex );

	PlayerAlpha = float(ClampedHumanIndex) / float(MaxHumanIndex);
	WaveAlpha = float(ClampedWaveIndex) / float(MaxWaveIndex);
	WaveAlpha = FMin( 1.f, WaveAlpha ); // scaling stops on the penultimate (last non-boss) wave

	HumanFactor = Lerp( PlayerCoefficientMin, PlayerCoefficientMax, PlayerAlpha );
	WaveFactor = Lerp( WaveCoefficientMin, WaveCoefficientMax, WaveAlpha );

	`cdlog( "Bilinear: HumanFactor="$ HumanFactor $" WaveFactor="$ WaveFactor );
	Result = HumanFactor * WaveFactor;
	`cdlog( "Bilinear: uncapped unrounded result="$ Result );

	if ( OverallMax >= 0 )
	{
		Result = FMin( Result, OverallMax );
		`cdlog( "Bilinear: applied max "$ OverallMax $": capped result="$ Result );
	}

	`cdlog( "Bilinear: final result="$ Result );

	return Result;
}
