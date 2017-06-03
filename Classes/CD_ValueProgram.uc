//=============================================================================
// CD_ValueProgram
//=============================================================================
// Abstracts a function that takes wave progress and player count as
// parameters, returning a float.
//=============================================================================

interface CD_ValueProgram;

/*
 * Evaluate this program at the specified wave and playercount.
 *
 * WaveNum must be one-based.  So, for the initial wave in a game,
 * this value should be one, not zero.  The basis interpretation
 * extends to MaxWaveNum.
 *
 * MaxWaveNum includes the boss wave.  For example, in the initial
 * wave of a long game, the WaveNum parameter would be 0 and the
 * MaxWaveNum parameter would be 10.
 *
 * HumanPlayers must exclude fakes.  MaxHumanPlayers should
 * generally be the active player limit on the server exclusive
 * of observers, if observers are allowed.
 */
function float GetValue( const int WaveNum, const int MaxWaveNum, const int HumanPlayers, const int MaxHumanPlayers );
