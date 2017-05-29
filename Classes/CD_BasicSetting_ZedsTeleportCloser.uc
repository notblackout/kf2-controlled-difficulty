class CD_BasicSetting_ZedsTeleportCloser extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.ZedsTeleportCloser;
}

protected function WriteIndicator( const out string Val )
{
	Outer.ZedsTeleportCloser = Val; 
	Outer.ZedsTeleportCloserBool = bool( Val );
}

protected function string Sanitize( const string Raw )
{
	return string( bool( Raw ) );
}

defaultproperties
{
	OptionName="ZedsTeleportCloser"
	DefaultSettingIndicator="false"

	ChatCommandNames=("!cdzedsteleportcloser","!cdztc")
	ChatWriteParamHints=("true|false")
}
