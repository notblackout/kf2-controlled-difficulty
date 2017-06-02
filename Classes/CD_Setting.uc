//=============================================================================
// CD_Setting
//=============================================================================
// Handles staging and applying changes to user-/admin-controlled CD
// configuration settings.  The authoritative copy of a configuration var lives
// on the CD_Survival class, and lots of code reads those vars directly.  This
// interface is a layer of logic top that mediates writes, including
// initialization.  It also provides support for chat commands to read and
// update the setting's value.
//=============================================================================

interface CD_Setting
	DependsOn(CD_ChatCommander);

/*
 * Returns the option name.  This is what the user would set on the `open`
 * command line and the name of the option they would edit in KFGame.ini.
 */
function string GetOptionName();

/*
 * Validates the Raw string as a legal value for this setting,
 * then copies it to a staging area.
 */
function bool StageIndicator( const out string Raw, out string StatusMsg, const optional bool ForceOverwrite = false );

/*
 * Writes any staged changes back to this option's var in CD_Survival.
 */
function string CommitStagedChanges( const int OverrideWaveNum, const optional bool ForceOverwrite = false );

/*
 * Given an unreal engine option string (i.e. the initial parameter to the
 * InitGame event), look for this setting in the option string.  If present,
 * try to initialize the setting to the option string's associated value.  If
 * not present, try to initialize to the default value.
 */
function InitFromOptions( const out string Options );

/*
 * Configures the out-param with a chat command that will echo the value of
 * this setting.
 */
function bool GetChatReadCommand( out StructChatCommand scc );

/*
 * Configures the out-param with a single-param chat command that will modify
 * this setting.
 */
function bool GetChatWriteCommand( out StructChatCommand scc );

/*
 * Returns a string print this option's name, an equals sign, the current
 * value, and then, if any changes are staged, a space, an open parenthesis,
 * the word "staged:" followed by space,  the staged value, and a close
 * parethesis.
 */
function string GetChatLine();
