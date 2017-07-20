class CD_DynamicSetting_WaveSizeFakes extends CD_DynamicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.WaveSizeFakes;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.WaveSizeFakes = Ind;
}

protected function float ReadValue()
{
	return float(Outer.WaveSizeFakesInt);
}

protected function WriteValue( const out float Val )
{
	Outer.WaveSizeFakesInt = Round(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(Round(RawValue));
}

defaultproperties
{
	IniDefsArrayName="WaveSizeFakesDefs"
	OptionName="WaveSizeFakes"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=160

	ChatCommandNames=("!cdwavesizefakes","!cdwsf")
	ChatWriteParamHintFragment="int"
}
