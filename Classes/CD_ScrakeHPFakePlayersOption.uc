class CD_ScrakeHPFakePlayersOption extends CD_RegulatedOption
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.ScrakeHPFakePlayers;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.ScrakeHPFakePlayers = Ind;
}

protected function float ReadValue()
{
	return float(Outer.ScrakeHPFakePlayersInt);
}

protected function WriteValue( const out float Val )
{
	Outer.ScrakeHPFakePlayersInt = int(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(int(RawValue));
}

defaultproperties
{
	IniDefsArrayName="ScrakeHPFakePlayersDefs"
	OptionName="ScrakeHPFakePlayers"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=32
}
