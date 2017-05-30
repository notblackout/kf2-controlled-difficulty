class CD_StringUtils extends Object;

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
			return false; // not a numeral
		}
		else
		{
			DigitSeen = true;
		}

		i++;
	}

	return DigitSeen;
}

