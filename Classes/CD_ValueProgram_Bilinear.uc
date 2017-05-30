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

function bool ParseComposite( const out string Composite )
{
	local string Body;
	local array<string> Tokens;

	local float PCMin, PCMax, WCMin, WCMax, OMax;

	if ( Composite == "" )
	{
		`cdlog("BilinearParser: ignoring empty specification string");
		return false;
	}

	if ( Left( Composite, 9 ) != "bilinear:" )
	{
		`cdlog("BilinearParser: Unrecognized prefix (expected \"bilinear\"): " $ Composite);
		return false;
	}

	Body = Right( Composite, Len(Composite) - 9 );

	if ( Body == "" )
	{
		`cdlog("BilinearParser: ignoring empty body string");
		return false;
	}

	ParseStringIntoArray( Body, Tokens, ";", true );

	if ( 0 == Tokens.Length )
	{
		`cdlog("BilinearParser: ignoring empty body string");
		return false;
	}

	if ( 2 < Tokens.Length )
	{
		`cdlog("BilinearParser: too many (" $ Tokens.Length $ ") ;-separated tokens in body string: " $ Body);
		return false;
	}

	if ( !ParseCoefficients( Tokens[0], PCMin, PCMax, WCMin, WCMax ) )
	{
		return false;
	}

	if ( Tokens.Length == 2 )
	{
		if ( !ParseMax( Tokens[1], OMax ) )
		{
			return false;
		}
	}

	// We don't enforce CoefficientMin < CoefficientMax.  Lerp can handle inversion
	// of that inequality.  It's not clear that it's useful, but it is allowed.

	// I thought about rejecting negative values, but I'm ignoring that for now.

	PlayerCoefficientMin = PCMin;
	PlayerCoefficientMax = PCMax;
	WaveCoefficientMin = WCMin;
	WaveCoefficientMax = WCMax;
	OverallMax = OMax;

	`cdlog("BilinearParser: read P["$ PCMin $","$ PCMax $"] W["$ WCMin $","$ WCMax $"] OMax="$ OMax);

	return true;
}

function bool ParseMax( const out string MS, out float Result )
{
	local string LMS;

	LMS = Locs(MS);

	if ( Len(LMS) > 3 && Right(LMS, 3) == "max" )
	{
		LMS = Left(LMS, Len(LMS) - 3);
	}

	if ( !class'CD_StringUtils'.static.IsFloat(LMS) )
	{
		`cdlog("BilinearParser: malformed maxvalue string: " $ LMS);
		return false;
	}

	Result = float(LMS);
	return true;
}

function bool ParseCoefficients( const out string CS, out float PCMin, out float PCMax, out float WCMin, out float WCMax )
{
	local array<string> Tokens;

	ParseStringIntoArray( Locs(CS), Tokens, "*", true );

	if ( 2 != Tokens.Length || Tokens[0] == "" || Tokens[1] == "" )
	{
		`cdlog("BilinearParser: malformed coefficient string: " $ CS);
		return false;
	}

	if ( Right(Tokens[0], 1) == "P" )
	{
		Tokens[0] = Left( Tokens[0], Len(Tokens[0]) - 1 );
	}

	if ( Right(Tokens[1], 1) == "W" )
	{
		Tokens[1] = Left( Tokens[1], Len(Tokens[1]) - 1 );
	}

	if ( Tokens[0] == "" || Tokens[1] == "" )
	{
		`cdlog("BilinearParser: malformed coefficient string: " $ CS);
		return false;
	}

	if ( !ParseLerpRangeString( Tokens[0], PCMin, PCMax ) )
	{
		`cdlog("BilinearParser: malformed player coefficient range: " $ Tokens[0]);
		return false;
	}

	if ( !ParseLerpRangeString( Tokens[1], WCMin, WCMax ) )
	{
		`cdlog("BilinearParser: malformed wave coefficient range: " $ Tokens[1]);
		return false;
	}

	return true;
}

function bool ParseLerpRangeString( const out string S, out float Min, out float Max )
{
	local array<string> Tokens;

	ParseStringIntoArray( S, Tokens, "_", true );

	if ( 2 != Tokens.Length || Tokens[0] == "" || Tokens[1] == "" )
	{
		`cdlog("BilinearParser: malformed bounds string: " $ S);
		return false;
	}

	if ( !class'CD_StringUtils'.static.IsFloat( Tokens[0] ) )
	{
		`cdlog("BilinearParser: lower bound is not a float: " $ Tokens[0]);
		return false;
	}

	if ( !class'CD_StringUtils'.static.IsFloat( Tokens[1] ) )
	{
		`cdlog("BilinearParser: upper bound is not a float: " $ Tokens[1]);
		return false;
	}

	Min = float(Tokens[0]);
	Max = float(Tokens[1]);
	return true;
}

function float GetValue( const int WaveNum, const int MaxWaveNum, const int HumanPlayers, const int MaxHumanPlayers )
{
	local float PlayerAlpha, WaveAlpha, Result, HumanFactor, WaveFactor;
	local int ClampedWaveIndex, ClampedHumanIndex, MaxWaveIndex, MaxHumanIndex;

	MaxHumanIndex = MaxHumanPlayers - 1;
	ClampedHumanIndex = Clamp( HumanPlayers - 1, 0, MaxHumanIndex );

	MaxWaveIndex = MaxWaveNum - 2; // subtract 1 for num-to-index conversion, subtract 1 to ignore bosswave
	ClampedWaveIndex = Clamp( WaveNum - 1, 0, MaxWaveIndex );

	`cdlog("Bilinear: WaveNum="$ WaveNum $" MaxWaveNum="$ MaxWaveNum $" ClampedWaveindex="$ ClampedWaveIndex $" MaxWaveIndex="$ MaxWaveIndex);

	PlayerAlpha = float(ClampedHumanIndex) / float(MaxHumanIndex);
	WaveAlpha = float(ClampedWaveIndex) / float(MaxWaveIndex);

	HumanFactor = Lerp( PlayerCoefficientMin, PlayerCoefficientMax, PlayerAlpha );
	WaveFactor = Lerp( WaveCoefficientMin, WaveCoefficientMax, WaveAlpha );

	`cdlog("Bilinear: HumanFactor="$ HumanFactor $" WaveFactor="$ WaveFactor);
	Result = HumanFactor * WaveFactor;
	`cdlog("Bilinear: uncapped result="$ Result);

	if ( OverallMax >= 0 )
	{
		Result = Min( Result, OverallMax );
		`cdlog("Bilinear: applied max "$ OverallMax $": capped result="$ Result);
	}

	return Result;
}
