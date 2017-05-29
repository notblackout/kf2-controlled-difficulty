class CD_BasicSetting_Boss extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.Boss;
}

protected function WriteIndicator( const out string Val )
{
	Outer.Boss = Val; 
}

protected function string SanitizeIndicator( const string Raw )
{
	if ( !IsValidBossString( Raw ) )
	{
		return DefaultSettingIndicator;
	}

	return Raw;
}

defaultproperties
{
	OptionName="Boss"
	DefaultSettingIndicator="random"

	ChatCommandNames=("!cdboss")
	ChatWriteParamHints=("volter|hans|random")
}
