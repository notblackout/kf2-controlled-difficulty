class CD_BasicSetting_ZTSpawnMode extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.ZTSpawnMode;
}

protected function WriteIndicator( const out string Val )
{
	Outer.ZTSpawnMode = Val; 
	SetZTSpawnModeEnum();  // Update ZTSpawnModeEnum
}

protected function string SanitizeIndicator( const string Raw )
{
	if ( !IsValidZTSpawnModeString( Raw ) )
	{
		return DefaultSettingIndicator;
	}

	return Raw;
}

defaultproperties
{
	OptionName="ZTSpawnMode"
	DefaultSettingIndicator="clockwork"

	ChatCommandNames=("!cdboss")
	ChatWriteParamHints=("clockwork|unmodded")
}
