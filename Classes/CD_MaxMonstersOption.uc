class CD_MaxMonstersOption extends CD_RegulatedOption
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.MaxMonsters;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.MaxMonsters = Ind;
}

protected function int ReadValue()
{
	return Outer.MaxMonstersInt;
}

protected function WriteValue( const out int Val )
{
	Outer.MaxMonstersInt = Val;
}

defaultproperties
{
	IniDefsArrayName="MaxMonstersDefs"
	OptionName="MaxMonsters"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=10000
}
