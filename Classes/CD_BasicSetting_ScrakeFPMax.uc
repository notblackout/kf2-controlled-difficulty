class CD_BasicSetting_ScrakeFPMax extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.ScrakeFPMax;
}

protected function WriteIndicator( const out string Val )
{
	Outer.ScrakeFPMax = Val; 
	Outer.ScrakeFPMaxInt = int( Val );
}

protected function string Sanitize( const string Raw )
{
	return string( Clamp( int(Raw), -1, 32 ) );
}

defaultproperties
{
	OptionName="ScrakeFPMax"
	DefaultSettingIndicator="-1"

	ChatCommandNames=("!cdscrakefpmax")
	ChatWriteParamHints=("int, -1 disables limit")
}
