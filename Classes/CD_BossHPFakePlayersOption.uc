class CD_BossHPFakePlayersOption extends CD_RegulatedOption
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.BossHPFakePlayers;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.BossHPFakePlayers = Ind;
}

protected function float ReadValue()
{
	return float(Outer.BossHPFakePlayersInt);
}

protected function WriteValue( const out float Val )
{
	Outer.BossHPFakePlayersInt = int(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(int(RawValue));
}

defaultproperties
{
	IniDefsArrayName="BossHPFakePlayersDefs"
	OptionName="BossHPFakePlayers"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=32
}
