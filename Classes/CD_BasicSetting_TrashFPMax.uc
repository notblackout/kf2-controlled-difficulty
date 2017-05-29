class CD_BasicSetting_TrashFPMax extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.TrashFPMax;
}

protected function WriteIndicator( const out string Val )
{
	Outer.TrashFPMax = Val; 
	Outer.TrashFPMaxInt = int( Val );
}

protected function string SanitizeIndicator( const string Raw )
{
	return string( Clamp( int(Raw), -1, 32 ) );
}

defaultproperties
{
	OptionName="TrashFPMax"
	DefaultSettingIndicator="-1"

	ChatCommandNames=("!cdtrashfpmax")
	ChatWriteParamHints=("int, -1 disables limit")
}
