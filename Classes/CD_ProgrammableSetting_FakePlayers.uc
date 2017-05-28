class CD_ProgrammableSetting_FakePlayers extends CD_ProgrammableSetting
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
	Outer.FakePlayersInt = int(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(int(RawValue));
}

defaultproperties
{
	IniDefsArrayName="FakePlayersDefs"
	OptionName="FakePlayers"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=32
}
