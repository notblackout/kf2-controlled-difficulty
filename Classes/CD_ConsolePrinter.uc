class CD_ConsolePrinter extends Object;

var GameViewportClient CachedGVC;

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


