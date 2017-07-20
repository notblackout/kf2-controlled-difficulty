class CD_DynamicSetting_FleshpoundHPFakes extends CD_DynamicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.FleshpoundHPFakes;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.FleshpoundHPFakes = Ind;
}

protected function float ReadValue()
{
	return float(Outer.FleshpoundHPFakesInt);
}

protected function WriteValue( const out float Val )
{
	Outer.FleshpoundHPFakesInt = Round(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(Round(RawValue));
}

defaultproperties
{
	IniDefsArrayName="FleshpoundHPFakesDefs"
	OptionName="FleshpoundHPFakes"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=32

	ChatCommandNames=("!cdfleshpoundhpfakes","!cdfphpf")
	ChatWriteParamHintFragment="int"
}
