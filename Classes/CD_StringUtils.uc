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
