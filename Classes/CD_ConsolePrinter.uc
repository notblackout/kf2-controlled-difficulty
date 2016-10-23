//=============================================================================
// CD_ConsolePrinter
//=============================================================================
// Prints to the ViewportConsole.
// Uses a lazily-initialized GameViewport/ViewportConsole reference internally.
//=============================================================================

class CD_ConsolePrinter extends Object;

var GameViewportClient CachedGVC;

// This class is so simple that you could argue it shouldn't exist.
// It could be replaced with purely static functions/defaultproperties.
// However, I think this is still useful because it would facilitate
// adding a user-facing option to CD_Survival later that customizes
// console printing.  That would be trickier with a static approach here.

function Print( string message, optional bool autoPrefix = true )
{
	CachedGVC = class'GameEngine'.static.GetEngine().GameViewport;

	if ( autoPrefix )
	{
		CachedGVC.ViewportConsole.OutputTextLine("[ControlledDifficulty] "$message);
	}
	else
	{
		CachedGVC.ViewportConsole.OutputTextLine(message);
	}
}
