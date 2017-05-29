class CD_BasicSetting_AlbinoCrawlers extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.AlbinoCrawlers;
}

protected function WriteIndicator( const out string Val )
{
	Outer.AlbinoCrawlers = Val; 
	Outer.AlbinoCrawlersBool = bool( Val );
}

protected function string SanitizeIndicator( const string Raw )
{
	return string( bool( Raw ) );
}

defaultproperties
{
	OptionName="AlbinoCrawlers"
	DefaultSettingIndicator="true"

	ChatCommandNames=("!cdalbinocrawlers","!cdac")
	ChatWriteParamHints=("true|false")
}
