//=============================================================================
// CD_SpawnCycle_PresetBase
//=============================================================================
// An abstract base class intended for CD_SpawnCycle_Preset implementations
// Implementations do not have to use this; it's just a convenience that takes
// care of boilerplate that would tend to be repeated across separate impls.
//=============================================================================

class CD_SpawnCycle_PresetBase extends Object abstract;

// I initially tried implementing this base class with three
// array<string> variables: ShortDefs, NormalDefs, and LongDefs.
//
// Subclasses could specify values for one or more variables
// in their defaultproperties block.  All of the function logic
// to satisfy the CD_SpawnCycle_Preset interface requirements
// was defined here.  That worked, but it has a problem.
//
// defaultproperties syntax is highly constrained (far more so
// than the rest of unrealscript), placing strict conditions on
// whitespaces and newlines.  SpawnCycle preset arrays tend to
// be very long, and to make them even remotely readable, they
// should really be spread out over multiple lines.  This isn't
// really possible in a defaultproperties block.  That's why I
// abandoned that approach.

function string GetName()
{
	local string result;

	result = string( self.class );

	result = Repl( result, "CD_SpawnCycle_Preset_", "", true );

	return result;
}

function CopyDefs( out array<string> sink, const out array<string> source )
{
	local int i;

	sink.length = 0;
	sink.Insert(0, source.length);

	for ( i = 0; i < source.length; i++ )
	{
		sink[i] = source[i];
	}
}
