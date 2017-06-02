class CD_DynamicSetting_MaxMonsters extends CD_DynamicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.MaxMonsters;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.MaxMonsters = Ind;
}

protected function float ReadValue()
{
	return float(Outer.MaxMonstersInt);
}

protected function WriteValue( const out float Val )
{
	Outer.MaxMonstersInt = int(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(int(RawValue));
}

defaultproperties
{
	IniDefsArrayName="MaxMonstersDefs"
	OptionName="MaxMonsters"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=10000

	ChatCommandNames=("!cdmaxmonsters","!cdmm")
	ChatWriteParamHintFragment="int, 0 to use unmodded default"
}
