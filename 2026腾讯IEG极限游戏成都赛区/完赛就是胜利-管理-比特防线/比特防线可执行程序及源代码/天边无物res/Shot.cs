using Godot;
using System;

public partial class Shot : Node2D
{
	[Signal]
	public delegate void ToTowerEventHandler(int row,string type,string magic);
	public void EmitShot(int i, int j, int id)
	{
		GD.Print($"index: {i} {j} emit shot {id}");
		if (id == 10)
		{
			TryUseMoney(-50);
			return;
		}

		id--;
		int q = id / 3;
		int r = id % 3;
		string type = new string[] { "机枪子弹", "榴弹炮弹", "激光枪能量弹" }[r];
		string magic = new string[] { "无", "燃烧", "冰冻" }[q];
		EmitSignal(SignalName.ToTower, i,type,magic);
	}
	public bool TryUseMoney(int Cost)
	{
		var global = GetNode("/root/GlobalNode") as GodotObject ;
		int less = (int)global.Get("electricity") - Cost;
		if (less>=0)
		{
			global.Set("electricity",less);
			GD.Print($"try  money -= {Cost}");
			return true;
		}
		
		return false;
	}
}
