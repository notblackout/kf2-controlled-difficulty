class CD_BasicSetting_WeaponTimeout extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.WeaponTimeout;
}

protected function WriteIndicator( const out string Val )
{
	Outer.WeaponTimeout = Val; 
	Outer.WeaponTimeoutInt = int( Val );
}

protected function string SanitizeIndicator( const string Raw )
{
	if ( Locs(Raw) == "max" )
	{
		return string( 2147483647 );
	}

	if ( Locs(Raw) == "unmodded" )
	{
		return string( -1 );
	}

	return string( Clamp( int(Raw), -1, 2147483647 ) );
}

defaultproperties
{
	OptionName="WeaponTimeout"
	DefaultSettingIndicator="-1"

	ChatCommandNames=("!cdweapontimeout")
	ChatWriteParamHints=("int seconds, \"max\", or \"unmodded\"/-1")
}

