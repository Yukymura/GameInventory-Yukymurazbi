using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Godot.Collections;
using Array = Godot.Collections.Array;
using Range = Godot.Range;

public partial class PlaceBuild : Node2D
{
	[Signal]
	public delegate void GetEmitEventHandler(int row,int colume,int type);
	
	[Export]
	public PackedScene BoxScene { get; set; }
	
	[Export]
	public int RowNum { get; set; }
	
	[Export]
	public int ColumnNum { get; set; }
	
	[Export]
	public float Space { get; set; }
	
	//0: pkg 1:build 2:reward 3:shop 4:del 5:flashShop
	[Export] public int IsMain { get; set; }
	
	
	[Export] public int Id { get; set; }
	[Export] public int Level { get; set; }
	
	public override void _Ready()
	{
		if (IsMain == 0 || IsMain==1 || IsMain ==3 || IsMain==5) Create();
		if (IsMain == 2)
		{
			var global = GetNode<Node>("/root/SignalBus") ;
			global.Connect("wave_cleared", new Callable(this,
				nameof(Create)));
		}
	}

	[Export] public string DataPath { get; set; } = "/root/Main/Data";

	[Export] public Array<Vector2I> ShopIndex { get; set; } = new();
	[Export] public Array<PackedScene> ShopObject { get; set; } = new();
	[Export] public Array<bool> ShopCanBuy { get; set; } = new();
	[Export] public PackedScene ShopLabel { get; set; } = new();
	[Export] public Vector2 ShopLabelOffset { get; set; }

	public List<Box> HaveBox = new();

	[Export] public int RefreshMoney { get; set; }
	public void Refresh()
	{
		if (TryUseMoney(RefreshMoney))
		{
			Create();
		}
	}
	public void Create()
	{
		Delete();
		HaveBox = new();
		for (int i = 0; i < RowNum; i++)
		{
			for (int j = 0; j < ColumnNum; j++)
			{
				Box box = BoxScene.Instantiate() as Box;
				AddChild(box);
				HaveBox.Add(box);
				box.Index = new Vector2I(i, j);
				box.Position = (new Vector2(j, i) * Space) + new Vector2(Space/2,Space/2);
				
				if (IsMain == 2)
				{
					Data data= GetNode(DataPath) as Data;
					var idx = GD.Randi() % data.Scenes.Count;
					Node created = data.Scenes[(int)idx].Instantiate();
					box.AddChild(created);
				}

				if (IsMain == 3 )
				{
					int idx = ShopIndex.IndexOf(new Vector2I(i, j));
					if (idx != -1 && ShopCanBuy[idx])
					{
						Draged created = ShopObject[idx].Instantiate() as Draged;
						box.AddChild(created);
						created.UpdateCost();
						
						Node2D label = ShopLabel.Instantiate() as Node2D;
						AddChild(label);
						label.GetChild<Label>(0, true).Text=$"{created.Cost}";
						label.Position = box.Position +ShopLabelOffset;		
					}
					else
					{
						box.QueueFree();
					}
				}
				if (IsMain == 1 || IsMain == 0 )
				{
					int idx = ShopIndex.IndexOf(new Vector2I(i, j));
					if (idx != -1)
					{
						Draged created = ShopObject[idx].Instantiate() as Draged;
						box.AddChild(created);
						created.Index = box.Index;
						
					}
				}
				
				if (IsMain == 5)
				{
					int idx = (int)(GD.Randi() % ShopObject.Count);
					GD.Print(idx);
					Draged created = ShopObject[idx].Instantiate() as Draged;
					box.AddChild(created);
					created.UpdateCost();
						
					Node2D label = ShopLabel.Instantiate() as Node2D;
					AddChild(label);
					label.GetChild<Label>(0, true).Text=$"{created.Cost}";
					label.Position = box.Position +ShopLabelOffset;		
					
				}
			}
		}
	}

	public void AddStaff()
	{
		for (int i = 0; i < RowNum; i++)
		{
			for (int j = 0; j < ColumnNum; j++)
			{
				var box = HaveBox[i * ColumnNum + j];
				// if (IsMain == 3)
				{
					int idx = ShopIndex.IndexOf(new Vector2I(i, j));
					if (idx != -1 && ShopCanBuy[idx] && box.GetChildCount()==1)
					{
						Draged created = ShopObject[idx].Instantiate() as Draged;
						created.UpdateCost();
						box.AddChild(created);
						
					}
				}
			}
		}
	}

	public void Delete()
	{
		FindChildren("*", "Node",true,false)
			.OfType<Box>().ToList().ForEach(x=>x.QueueFree());
		if (IsMain == 3 || IsMain==5)
		{
			FindChildren("*", "Node",true,false)
				.OfType<Node2D>().ToList().ForEach(x=>x.QueueFree());
		}
	}

	IEnumerable<T> Generate<T>(Func<T> fn)
	{
		while(true)
			yield return fn();
	}

	public override void _PhysicsProcess(double delta)
	{
		base._PhysicsProcess(delta);
		if (IsMain == 1)
		{
			Run();
		}

		if (IsMain == 3)
		{
			AddStaff();
		}
		if (IsMain == 4)
		{
			Create();
		}
	}

	public void Run()
	{
		var di = new int[] { -1, 0, 1, 0 };
		var dj = new int[] { 0,1,0,-1 };
		(int, int) convert((int,int,int) tp)
		{
			var (i, j, k) = tp;
			return (i * 2 + 1 + di[k], j * 2 + 1 + dj[k]);
		}
		int[] iconvert(int x)
		{
			if (x % 2 == 1)
			{
				return new int[]{(x) / 2};
			}
			else
			{
				return new int[]{(x-1)/2,(x+1) / 2};
			}
		}

		
		var sprites = FindChildren("*", "Area2D",true,false)
			.OfType<Draged>().ToArray();
		sprites.ToList().ForEach(x=>x.Make());
		sprites.ToList().ForEach(x =>
		{
			if (x.HaveEmit.Count != 0)
			{	
				GD.Print("is emit");
				EmitSignal(SignalName.GetEmit, x.Index.X, x.Index.Y, x.HaveEmit.Dequeue());
			}
		});
		
		var es=sprites
			.SelectMany(x => x.GetFromTo()).ToList();

		var e=Generate(()=>new List<(int,int)>())
			.Chunk(ColumnNum*2+1).Take(RowNum*2+1).ToArray();
		foreach (var (x, y, i, j) in es)
		{
			var (ci, cj) = convert((i, j, x));
			e[ci][cj].Add(convert((i, j, y)));
		}

		var vis=Generate(()=>0).Chunk(4).Chunk(ColumnNum).Take(RowNum).ToArray();

		(int, int) dfs(int i,int j)
		{
			if (e[i][j].Count == 0)
			{
				return (i,j);
			}
			else
			{
				return dfs(e[i][j][0].Item1, e[i][j][0].Item2);
			}
		}
		sprites.Where(x=>x.HaveOutput.Count!=0)
			.ToList().ForEach(draged =>
			{
				var x = draged.GetLastAsk();
				var (ci, cj) = convert(x);
				var (fi, fj) = dfs(ci, cj);
				if ((fi, fj) != (ci, cj))
				{
					foreach (var i in iconvert(fi))
					{
						foreach (var j in iconvert(fj))
						{
							if (i >= 0 && i < RowNum && j >= 0 && j < ColumnNum)
							{
								var (si, sj, _) = x;
								sprites.Where(x=>x.Index==new Vector2I(i,j) && x.Inputs.Count!=0)
									.ToList().ForEach(x=>
									{
										if (draged.HaveOutput.Count != 0)
										{
											var trans=draged.HaveOutput.Dequeue();
											x.GetInput(trans);
											GD.Print($"from {draged.Index} to {x.Index} : {trans}");
										}
										else
										{
											GD.Print($"fail from {draged.Index} to {x.Index} : ");
										}
										
									});
							}
						}
					}
					
				}
			});
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
