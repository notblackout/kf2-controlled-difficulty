class CD_WaveSummary extends Object;

var int Trash;

var int Bloats;
var int Husks;
var int Sirens;

var int Fleshpounds;
var int Scrakes;

var int Total;

function Increment( EAIType type, int count )
{
	Total += count;

	if ( type == AT_FleshPound )
	{
		Fleshpounds += count;
	}
	else if ( type == AT_Scrake )
	{
		Scrakes += count;
	}
	else if ( type == AT_Siren )
	{
		Sirens += count;
	}
	else if ( type == AT_Husk )
	{
		Husks += count;
	}
	else if ( type == AT_Bloat )
	{
		Bloats += count;
	}
	else
	{
		Trash += count;
	}
}

function Clear()
{
	Trash = 0;

	Bloats = 0;
	Husks = 0;
	Sirens = 0;

	Scrakes = 0;
	Fleshpounds = 0;

	Total = 0;

}

function string GetString()
{
	local string s;

	s =
		"Trash="$class'CD_Survival'.static.ZeroPadIntString(Trash, 4)$
		" Bloats="$class'CD_Survival'.static.ZeroPadIntString(Bloats, 3)$
		" Husks="$class'CD_Survival'.static.ZeroPadIntString(Husks, 3)$
		" Sirens="$class'CD_Survival'.static.ZeroPadIntString(Sirens, 3)$
		" Scrakes="$class'CD_Survival'.static.ZeroPadIntString(Scrakes, 2)$
		" Fleshpounds="$class'CD_Survival'.static.ZeroPadIntString(Fleshpounds, 2)$
		" TOTAL="$class'CD_Survival'.static.ZeroPadIntString(Total, 4);

	`log(s);

	return s;
}

function AddParamToSelf( CD_WaveSummary addend )
{
	Trash += addend.Trash;

	Bloats += addend.Bloats;
	Husks += addend.Husks;
	Sirens += addend.Sirens;

	Scrakes += addend.Scrakes;
	Fleshpounds += addend.Fleshpounds;

	Total += addend.Total;
}
