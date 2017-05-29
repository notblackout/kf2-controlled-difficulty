class CD_BasicSetting_TraderTime extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.TraderTime;
}

protected function WriteIndicator( const out string Val )
{
	Outer.TraderTime = Val; 
	Outer.TraderTimeInt = int( Val );
}

protected function string Sanitize( const string Raw )
{
	if ( Locs(Raw) == "max" )
	{
		return string( 2147483647 );
	}

	if ( Locs(Raw) == "unmodded" )
	{
		return string( 0 );
	}

	return string( Clamp( int(Raw), 0, 2147483647 ) );
}

function bool GetChatWriteCommand( out StructChatCommand scc )
{
	return false; // no write command for TT
}

defaultproperties
{
	OptionName="TraderTime"
	DefaultSettingIndicator="0"

	ChatCommandNames=("!cdtradertime","!cdtt")
}

