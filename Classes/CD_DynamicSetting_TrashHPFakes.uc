class CD_DynamicSetting_TrashHPFakes extends CD_DynamicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.TrashHPFakes;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.TrashHPFakes = Ind;
}

protected function float ReadValue()
{
	return float(Outer.TrashHPFakesInt);
}

protected function WriteValue( const out float Val )
{
	Outer.TrashHPFakesInt = Round(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(Round(RawValue));
}

defaultproperties
{
	IniDefsArrayName="TrashHPFakesDefs"
	OptionName="TrashHPFakes"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=32

	ChatCommandNames=("!cdtrashhpfakes","!cdthpf")
	ChatWriteParamHintFragment="int"
}
