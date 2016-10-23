class CD_WaveSummary extends Object;

var int Crawlers;
var int Cysts;
var int Alphas;
var int Slashers;
var int Stalkers;
var int Gorefasts;

var int Bloats;
var int Husks;
var int Sirens;

var int Fleshpounds;
var int Scrakes;

function Increment( EAIType type, int count )
{
	switch (type)
	{
		case AT_Crawler:      Crawlers    += count; break;
		case AT_Clot:         Cysts       += count; break;
		case AT_AlphaClot:    Alphas      += count; break;
		case AT_SlasherClot:  Slashers    += count; break;
		case AT_Stalker:      Stalkers    += count; break;
		case AT_GoreFast:     Gorefasts   += count; break;
		case AT_Bloat:        Bloats      += count; break;
		case AT_Husk:         Husks       += count; break;
		case AT_Siren:        Sirens      += count; break;
		case AT_Scrake:       Scrakes     += count; break;
		case AT_FleshPound:   FleshPounds += count; break;
	};
}

function Clear()
{
	Crawlers = 0;
	Cysts = 0;
	Alphas = 0;
	Slashers = 0;
	Stalkers = 0;
	Gorefasts = 0;

	Bloats = 0;
	Husks = 0;
	Sirens = 0;

	Scrakes = 0;
	Fleshpounds = 0;
}

function string GetString()
{
	local string s;

	s =	"Crawl="$ZeroPadIntString(Crawlers, 4)$
		" Cyst="$ZeroPadIntString(Cysts, 4)$
		" Alpha="$ZeroPadIntString(Alphas, 4)$
		" Slash="$ZeroPadIntString(Slashers, 4)$
		" Stalk="$ZeroPadIntString(Stalkers, 4)$
		" Gore="$ZeroPadIntString(Gorefasts, 4)$
		" Bloat="$ZeroPadIntString(Bloats, 3)$
		" Husk="$ZeroPadIntString(Husks, 3)$
		" Siren="$ZeroPadIntString(Sirens, 3)$
		" SC="$ZeroPadIntString(Scrakes, 2)$
		" FP="$ZeroPadIntString(Fleshpounds, 2)$
		" // TOTALS:"$
		" Trash="$ZeroPadIntString(GetTrash(), 4)$
		" Medium="$ZeroPadIntString(GetMedium(), 3)$
		" Big="$ZeroPadIntString(GetBig(), 3)$
		" ALL="$ZeroPadIntString(GetTotal(), 4);

	`log(s);

	return s;
}

function AddParamToSelf( CD_WaveSummary addend )
{
	Crawlers += addend.Crawlers;
	Cysts += addend.Cysts;
	Alphas += addend.Alphas;
	Slashers += addend.Slashers;
	Stalkers += addend.Stalkers;
	Gorefasts += addend.Gorefasts;

	Bloats += addend.Bloats;
	Husks += addend.Husks;
	Sirens += addend.Sirens;

	Scrakes += addend.Scrakes;
	Fleshpounds += addend.Fleshpounds;
}

function int GetTrash()
{
	return Crawlers + Cysts + Alphas + Slashers + Stalkers + Gorefasts;
}

function int GetMedium()
{
	return Bloats + Husks + Sirens;
}

function int GetBig()
{
	return Scrakes + Fleshpounds;
}

function int GetTotal()
{
	return GetTrash() + GetMedium() + GetBig();
}

private static function string ZeroPadIntString( int numberToFormat, int totalWidth )
{
	local string numberAsString;

	numberAsString = string( numberToFormat );

	while ( Len(numberAsString) < totalWidth )
	{
		numberAsString = "0" $ numberAsString;
	}
	
	return numberAsString;
}
