//=============================================================================
// CD_WaveSummary
//=============================================================================
// Stores zed counts by type.  This supports the CDSpawnSummaries command that
// prints how many of each zed would spawn on each wave of a SpawnCycle.
//=============================================================================

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
var int FleshpoundMinis;
var int Scrakes;

function Increment( EAIType type, int count )
{
	switch (type)
	{
		case AT_Crawler:         Crawlers        += count; break;
		case AT_Clot:            Cysts           += count; break;
		case AT_AlphaClot:       Alphas          += count; break;
		case AT_SlasherClot:     Slashers        += count; break;
		case AT_Stalker:         Stalkers        += count; break;
		case AT_GoreFast:        Gorefasts       += count; break;
		case AT_Bloat:           Bloats          += count; break;
		case AT_Husk:            Husks           += count; break;
		case AT_Siren:           Sirens          += count; break;
		case AT_Scrake:          Scrakes         += count; break;
		case AT_FleshpoundMini:  FleshpoundMinis += count; break;
		case AT_FleshPound:      FleshPounds     += count; break;
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
	FleshpoundMinis = 0;
	Fleshpounds = 0;
}

function string GetString()
{
	local string s;

	s =	"Crawl="$class'CD_StringUtils'.static.ZeroPadIntString(Crawlers, 4)$
		" Cyst="$class'CD_StringUtils'.static.ZeroPadIntString(Cysts, 4)$
		" Alpha="$class'CD_StringUtils'.static.ZeroPadIntString(Alphas, 4)$
		" Slash="$class'CD_StringUtils'.static.ZeroPadIntString(Slashers, 4)$
		" Stalk="$class'CD_StringUtils'.static.ZeroPadIntString(Stalkers, 4)$
		" Gore="$class'CD_StringUtils'.static.ZeroPadIntString(Gorefasts, 4)$
		" Bloat="$class'CD_StringUtils'.static.ZeroPadIntString(Bloats, 3)$
		" Husk="$class'CD_StringUtils'.static.ZeroPadIntString(Husks, 3)$
		" Siren="$class'CD_StringUtils'.static.ZeroPadIntString(Sirens, 3)$
		" SC="$class'CD_StringUtils'.static.ZeroPadIntString(Scrakes, 2)$
		" MF="$class'CD_StringUtils'.static.ZeroPadIntString(FleshpoundMinis, 2)$
		" FP="$class'CD_StringUtils'.static.ZeroPadIntString(Fleshpounds, 2)$
		" // TOTALS:"$
		" Trash="$class'CD_StringUtils'.static.ZeroPadIntString(GetTrash(), 4)$
		" Medium="$class'CD_StringUtils'.static.ZeroPadIntString(GetMedium(), 3)$
		" Big="$class'CD_StringUtils'.static.ZeroPadIntString(GetBig(), 3)$
		" ALL="$class'CD_StringUtils'.static.ZeroPadIntString(GetTotal(), 4);

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
	FleshpoundMinis += addend.FleshpoundMinis;
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
	return Scrakes + Fleshpounds + FleshpoundMinis;
}

function int GetTotal()
{
	return GetTrash() + GetMedium() + GetBig();
}
