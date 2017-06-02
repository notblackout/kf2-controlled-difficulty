class CD_BasicSetting_FakePlayersMode extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.FakePlayersMode;
}

protected function WriteIndicator( const out string Val )
{
	Outer.FakePlayersMode = Val; 

	if ( Outer.FakePlayersMode == "add" )
	{
		FakePlayersModeEnum = FPM_ADD;
	}
	else
	{
		FakePlayersModeEnum = FPM_REPLACE;
	}
}

protected function string SanitizeIndicator( const string Raw )
{
	if ( !IsValidFakePlayersModeString( Raw ) )
	{
		return DefaultSettingIndicator;
	}

	return Raw;
}

private static function bool IsValidFakePlayersModeString( const out string fpm )
{
	return "add" == fpm || "replace" == fpm;
}

defaultproperties
{
	OptionName="FakePlayersMode"
	DefaultSettingIndicator="add"

	ChatCommandNames=("!cdfakeplayersmode")
	ChatWriteParamHints=("add|replace")
}
