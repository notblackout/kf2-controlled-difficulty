class CD_BasicSetting_FleshpoundFPMax extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.FleshpoundFPMax;
}

protected function WriteIndicator( const out string Val )
{
	Outer.FleshpoundFPMax = Val; 
	Outer.FleshpoundFPMaxInt = int( Val );
}

protected function string Sanitize( const string Raw )
{
	return string( Clamp( int(Raw), -1, 32 ) );
}

defaultproperties
{
	OptionName="FleshpoundFPMax"
	DefaultSettingIndicator="-1"

	ChatCommandNames=("!cdfleshpoundfpmax")
	ChatWriteParamHints=("int, -1 disables limit")
}
