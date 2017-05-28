class CD_ZedHPFakePlayersOption extends CD_RegulatedOption
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.ZedHPFakePlayers;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.ZedHPFakePlayers = Ind;
}

protected function float ReadValue()
{
	return float(Outer.ZedHPFakePlayersInt);
}

protected function WriteValue( const out float Val )
{
	Outer.ZedHPFakePlayersInt = int(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(int(RawValue));
}

defaultproperties
{
	IniDefsArrayName="ZedHPFakePlayersDefs"
	OptionName="ZedHPFakePlayers"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=32
}
