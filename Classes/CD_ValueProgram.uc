//=============================================================================
// CD_ValueProgram
//=============================================================================
// Abstracts a function that takes wave progress and player count as
// parameters, returning a float.
//=============================================================================

interface CD_ValueProgram;

function float GetValue( const int WaveNum, const int MaxWaveNum, const int HumanPlayers, const int MaxHumanPlayers );
