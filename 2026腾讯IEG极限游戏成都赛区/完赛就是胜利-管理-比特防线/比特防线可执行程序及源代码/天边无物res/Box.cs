using Godot;
using System;

public partial class Box : Marker2D
{
	public static Godot.Collections.Array<Box> Have=new Godot.Collections.Array<Box>();
	[Export]
	public Vector2I Index { get; set; }
	
	public override void _EnterTree()
	{
		Have.Add(this);
		
	}

	public override void _ExitTree()
	{
		Have.Remove(this);
	}
	
	
	
	
}
