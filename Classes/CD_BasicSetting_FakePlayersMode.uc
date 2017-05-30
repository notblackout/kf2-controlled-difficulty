class CD_BasicSetting_FakePlayersMode extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.FakePlayersMode;
}

protected function WriteIndicator( const out string Val )
{
	Outer.FakePlayersMode = Val; 
	SetFakePlayersModeEnum();  // Update FakePlayersModeEnum
}

protected function string SanitizeIndicator( const string Raw )
{
	if ( !IsValidFakePlayersModeString( Raw ) )
	{
		return DefaultSettingIndicator;
	}

	return Raw;
}

defaultproperties
{
	OptionName="FakePlayersMode"
	DefaultSettingIndicator="add"

	ChatCommandNames=("!cdfakeplayersmode")
	ChatWriteParamHints=("add|replace")
}
