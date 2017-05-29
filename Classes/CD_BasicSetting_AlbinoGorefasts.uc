class CD_BasicSetting_AlbinoGorefasts extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.AlbinoGorefasts;
}

protected function WriteIndicator( const out string Val )
{
	Outer.AlbinoGorefasts = Val; 
	Outer.AlbinoGorefastsBool = bool( Val );
}

protected function string SanitizeIndicator( const string Raw )
{
	return string( bool( Raw ) );
}

defaultproperties
{
	OptionName="AlbinoGorefasts"
	DefaultSettingIndicator="true"

	ChatCommandNames=("!cdalbinogorefasts","!cdag")
	ChatWriteParamHints=("true|false")
}
