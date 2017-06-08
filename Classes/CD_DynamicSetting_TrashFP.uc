class CD_DynamicSetting_TrashFP extends CD_DynamicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.TrashFP;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.TrashFP = Ind;
}

protected function float ReadValue()
{
	return float(Outer.TrashFPInt);
}

protected function WriteValue( const out float Val )
{
	Outer.TrashFPInt = Round(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(Round(RawValue));
}

defaultproperties
{
	IniDefsArrayName="TrashFPDefs"
	OptionName="TrashFP"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=32

	ChatCommandNames=("!cdtrashfp")
	ChatWriteParamHintFragment="int"
}
