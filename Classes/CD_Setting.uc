interface CD_Setting
	DependsOn(CD_ChatCommander);

function string GetOptionName();

function InitFromOptions( const out string Options );

function string CommitStagedChanges( const int OverrideWaveNum, const optional bool ForceOverwrite = false );

function bool GetChatReadCommand( out StructChatCommand scc );

function bool GetChatWriteCommand( out StructChatCommand scc );

function string GetChatLine();
