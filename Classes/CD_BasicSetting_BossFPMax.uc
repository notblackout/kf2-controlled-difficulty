class CD_BasicSetting_BossFPMax extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.BossFPMax;
}

protected function WriteIndicator( const out string Val )
{
	Outer.BossFPMax = Val; 
	Outer.BossFPMaxInt = int( Val );
}

protected function string SanitizeIndicator( const string Raw )
{
	return string( Clamp( int(Raw), -1, 32 ) );
}

defaultproperties
{
	OptionName="BossFPMax"
	DefaultSettingIndicator="-1"

	ChatCommandNames=("!cdbossfpmax")
	ChatWriteParamHints=("int, -1 disables limit")
}
