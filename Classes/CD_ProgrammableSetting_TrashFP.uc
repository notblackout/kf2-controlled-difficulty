class CD_ProgrammableSetting_TrashFP extends CD_ProgrammableSetting
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
	Outer.TrashFPInt = int(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(int(RawValue));
}

defaultproperties
{
	IniDefsArrayName="TrashFPDefs"
	OptionName="TrashFP"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=32
}
