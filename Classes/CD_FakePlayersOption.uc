class CD_FakePlayersOption extends CD_RegulatedOption
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.FakePlayers;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.FakePlayers = Ind;
}

protected function int ReadValue()
{
	return Outer.FakePlayersInt;
}

protected function WriteValue( const out int Val )
{
	Outer.FakePlayersInt = Val;
}

defaultproperties
{
	IniDefsArrayName="FakePlayersDefs"
	OptionName="FakePlayers"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=32
}
