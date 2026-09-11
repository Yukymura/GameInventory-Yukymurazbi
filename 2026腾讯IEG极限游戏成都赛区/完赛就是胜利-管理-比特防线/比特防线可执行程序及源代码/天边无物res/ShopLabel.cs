using Godot;
using System;

public partial class ShopLabel : Node2D
{
	[Export] public int Level { get; set; } = 0;
	public override void _PhysicsProcess(double delta)
	{
		base._PhysicsProcess(delta);
		Level = (GetParent() as Draged).Level;
		GlobalRotation = 0;
		(GetChild(0) as Label).Text = $"{Level + 1}";
	}
}
