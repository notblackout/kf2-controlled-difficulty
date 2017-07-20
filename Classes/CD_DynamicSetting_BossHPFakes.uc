class CD_DynamicSetting_BossHPFakes extends CD_DynamicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.BossHPFakes;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.BossHPFakes = Ind;
}

protected function float ReadValue()
{
	return float(Outer.BossHPFakesInt);
}

protected function WriteValue( const out float Val )
{
	Outer.BossHPFakesInt = Round(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(Round(RawValue));
}

defaultproperties
{
	IniDefsArrayName="BossHPFakesDefs"
	OptionName="BossHPFakes"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=32

	ChatCommandNames=("!cdbosshpfakes","!cdbhpf")
	ChatWriteParamHintFragment="int"
}
