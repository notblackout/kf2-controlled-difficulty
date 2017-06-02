class CD_BasicSetting_ZTSpawnMode extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.ZTSpawnMode;
}

protected function WriteIndicator( const out string Val )
{
	Outer.ZTSpawnMode = Val; 

	if ( Outer.ZTSpawnMode == "unmodded" )
	{
		ZTSpawnModeEnum = ZTSM_UNMODDED;
	}
	else
	{
		ZTSpawnModeEnum = ZTSM_CLOCKWORK;
	}
}

protected function string SanitizeIndicator( const string Raw )
{
	if ( !IsValidZTSpawnModeString( Raw ) )
	{
		return DefaultSettingIndicator;
	}

	return Raw;
}

private static function bool IsValidZTSpawnModeString( const out string ztsm )
{
	return "unmodded" == ztsm || "clockwork" == ztsm;
}

defaultproperties
{
	OptionName="ZTSpawnMode"
	DefaultSettingIndicator="clockwork"

	ChatCommandNames=("!cdztspawnmode")
	ChatWriteParamHints=("clockwork|unmodded")
}
