class CD_FleshpoundHPFakePlayersOption extends CD_RegulatedOption
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.FleshpoundHPFakePlayers;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.FleshpoundHPFakePlayers = Ind;
}

protected function float ReadValue()
{
	return float(Outer.FleshpoundHPFakePlayersInt);
}

protected function WriteValue( const out float Val )
{
	Outer.FleshpoundHPFakePlayersInt = int(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(int(RawValue));
}

defaultproperties
{
	IniDefsArrayName="FleshpoundHPFakePlayersDefs"
	OptionName="FleshpoundHPFakePlayers"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=32
}
