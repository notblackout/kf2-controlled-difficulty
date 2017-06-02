//=============================================================================
// CD_StringUtils
//============================================================================
// Static helper methods for converting things to and from strings
//=============================================================================

class CD_StringUtils extends Object
	Abstract;

static function string GetShortWaveNameByIndex( const int WaveIndex )
{
	return GetShortWaveNameByNum( WaveIndex + 1 );
}

static function string GetShortWaveNameByNum( const int WaveNum )
{
	local string s;

	s = string( WaveNum );

	while ( 2 > Len(s) )
	{
		s = "0" $ s;
	}

	s = "W" $ s;

	return s;
}

static function string ZeroPadIntString( int NumberToFormat, const int TotalWidth )
{
	local string NumberAsString;
	local int ZerosToAdd, i;
	local bool IsNegative;

	if ( 0 > NumberToFormat )
	{
		IsNegative = true;
		NumberToFormat *= -1;
	}
	else
	{
		IsNegative = false;
	}

	NumberAsString = string( NumberToFormat );

	ZerosToAdd = TotalWidth - Len( NumberAsString );

	if ( IsNegative )
	{
		ZerosToAdd -= 1;
	}

	for ( i = 0; i < ZerosToAdd; i++ )
	{
		NumberAsString = "0" $ NumberAsString;
	}


	if ( IsNegative )
	{
		NumberAsString = "-" $ NumberAsString;
	}

	return NumberAsString;
}

static function bool IsFloat( const out string s )
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
		i++;

		// We allow one dot anywhere after the optional minus sign,
		// regardless of whether there are or are not preceeding or
		// following numerals
		if ( !DotSeen && UnicodePoint == 46 )
		{
			DotSeen = true;
			continue;
		}

		// Check for low ascii numerals [0-9]
		if ( !( 48 <= UnicodePoint && UnicodePoint <= 57 ) )
		{
			return false; // not a numeral
		}
		else
		{
			DigitSeen = true;
		}
	}

	return DigitSeen;
}

static function int HexStringToInt( string hexstr, out int value )
{
	local int i;
	local int multiplier;

	hexstr = Locs(hexstr);

	multiplier = 1;
	value = 0;

	for ( i = Len(hexstr) - 1 ; 0 <= i ; i-- )
	{
		switch (Mid(hexstr, i, 1))
		{
		case "0": break;
		case "1": value += multiplier; break;
		case "2": value += (multiplier * 2);  break;
		case "3": value += (multiplier * 3);  break;
		case "4": value += (multiplier * 4);  break;
		case "5": value += (multiplier * 5);  break;
		case "6": value += (multiplier * 6);  break;
		case "7": value += (multiplier * 7);  break;
		case "8": value += (multiplier * 8);  break;
		case "9": value += (multiplier * 9);  break;
		case "a": value += (multiplier * 10); break;
		case "b": value += (multiplier * 11); break;
		case "c": value += (multiplier * 12); break;
		case "d": value += (multiplier * 13); break;
		case "e": value += (multiplier * 14); break;
		case "f": value += (multiplier * 15); break;
		default: return -1;
		}

		multiplier *= 16; 
	}

	return value;
}
