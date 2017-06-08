class CD_DynamicSetting_FakePlayers extends CD_DynamicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.FakePlayers;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.FakePlayers = Ind;
}

protected function float ReadValue()
{
	return float(Outer.FakePlayersInt);
}

protected function WriteValue( const out float Val )
{
	Outer.FakePlayersInt = Round(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(Round(RawValue));
}

defaultproperties
{
	IniDefsArrayName="FakePlayersDefs"
	OptionName="FakePlayers"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=160

	ChatCommandNames=("!cdfakeplayers","!cdfp")
	ChatWriteParamHintFragment="int"
}
