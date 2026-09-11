using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Godot.Collections;


public partial class Draged : Area2D
{
	private bool _isDragging = false;
	private Vector2 _dragStartOffset;
	private Camera2D _camera;

	[Export] public int Multi { get; set; } = 1;
	public int Cost { get; set; }= 0;
	[Export] public int OriginCost { get; set; }= 0;

	public void UpdateCost()
	{
		Cost = OriginCost;
	}
	[Export] public string Tip { get; set; } = "this is a Draged";
	
	[Export] public float MaxDiff { get; set; }

	public Vector2I Index { get; set; } = new ();
	
	// 种类，数量
	[Export] public Array<Array<Vector2I>> Inputs { get; set; } = new ();
	
	[Export] public Array<Array<Vector2I>> Outputs { get; set; }= new ();

	[Export] public float IntervalTime { get; set; } = 1;
	[Export] public int Id { get; set; } = 0;
	[Export] public int Level { get; set; } = 0;
	[Export] public int MaxLevel { get; set; } = 0;

	public bool IsInInterval { get; set; } = false;
	
	public Godot.Collections.Dictionary<int,int> HaveInput { get; set; }= new ();
	public Queue<int> HaveOutput { get; set; } = new Queue<int>();

	[Export] public bool IsEmit { get; set; } = false;
	public Queue<int> HaveEmit { get; set; } = new Queue<int>();
	
	[Export]
	public int RotNum { get; set; }

	public int LastAsk { get; set; } = 0;

	public (int,int,int) GetLastAsk()
	{
		return (Index.X, Index.Y, (RotNum + LastAsk++) % 4);
	}

	[Export] public Godot.Collections.Array<Vector2I> FromTo { get; set; } = new Array<Vector2I>();

	[Export]private int FromToNum { get; set; } = 0; 
	public List<(int,int,int,int)> GetFromTo()
	{
		if(FromTo.Count!=0) FromToNum = (FromToNum + 1) % FromTo.Count;
		return FromTo.Skip(FromToNum).Take(1)
			.Select(v => ((v.X + RotNum) % 4, (v.Y + RotNum) % 4,Index.X,Index.Y))
			.ToList();
	}

	public void GetInput(int type)
	{
		if(!HaveInput.ContainsKey(type)) HaveInput.Add(type,0);
		HaveInput[type]++;
	}

	public void Make()
	{
		foreach (var (Input, Output) in Inputs.Zip(Outputs).Take((Level + 1)*Multi).Reverse())
		{
			if (IsInInterval==false && Output.Count!=0 &&
				Input.All(x =>  HaveInput.ContainsKey(x.X) && x.Y <= HaveInput[x.X]))
			{
				GD.Print($"{Index} Make {Output}");
				Input.ToList().ForEach(x=>HaveInput[x.X]-=x.Y);
			
				Output.SelectMany(x=>Enumerable.Repeat(x.X,x.Y)).ToList()
					.ForEach((IsEmit ? HaveEmit : HaveOutput).Enqueue);

				IsInInterval = true;
				GetNode<Timer>("IntervalTimer").Start();
				break;
			}
		}
		
	}

	public void FinishInterval()
	{
		IsInInterval = false;
	}
	public override void _Ready()
	{
		GetChild<Panel>(4).TooltipText = Tip; 
		_camera = GetViewport().GetCamera2D();
		GetNode<Timer>("IntervalTimer").WaitTime=IntervalTime;
		GetNode<Timer>("IntervalTimer").Timeout+=FinishInterval;
	}

	public override void _Input(InputEvent @event)
	{
		// 阶段 1：按下检测
		if (@event is InputEventMouseButton mouseBtn && mouseBtn.ButtonIndex == MouseButton.Left)
		{
			if (mouseBtn.Pressed)
			{
				// 检查是否点击在本对象上（使用物理查询或碰撞检测）
				if (IsMouseOver())
				{
					Sound("pick");
					_isDragging = true;
					_dragStartOffset = GlobalPosition - GetGlobalMousePosition();
					
					OnDragStart(); // 自定义回调
					GetViewport().SetInputAsHandled();
				}
			}
			else // 松开
			{
				if (_isDragging)
				{
					_isDragging = false;
					OnDragEnd(); // 自定义回调
					GetViewport().SetInputAsHandled();
				}
			}
		}
		
		// 阶段 2：移动检测（仅在拖拽状态下）
		if (_isDragging && @event is InputEventMouseMotion)
		{
			// 跟随鼠标移动
			GlobalPosition = GetGlobalMousePosition() + _dragStartOffset;
		}
		
		if (_isDragging && @event is InputEventKey keyEvent && keyEvent.Pressed && !keyEvent.Echo)
		{
			switch (keyEvent.Keycode)
			{
				case Key.R:
					RotNum++;
					RotNum %= 4;
					Rotation = (float)(RotNum * Math.PI/2);
					break;
			}
		}
	}
	
	private bool IsMouseOver()
	{
		// 使用碰撞体（需要 Area2D 或 PhysicsBody）
		var spaceState = GetWorld2D().DirectSpaceState;
		var query = new PhysicsPointQueryParameters2D
		{
			Position = GetGlobalMousePosition(),
			CollideWithAreas = true,
			CollideWithBodies = true
		};
		var result = spaceState.IntersectPoint(query);
		
		foreach (var item in result)
		{
			if (item["collider"].As<Node>() == this)
				return true;
		}
		return false;
		
	}
	
	// 可重写的回调方法
	protected virtual void OnDragStart() 
	{
		Scale = new Vector2(1.1f, 1.1f); // 放大反馈
		Modulate = new Color(1.2f, 1.2f, 1.2f);
	}


	public override void _Process(double delta)
	{
		base._Process(delta);
		GetChildren().OfType<AnimatedSprite2D>().ToList().ForEach(
			x=>x.Animation=
				HaveInput.Values.Any(x=>x!=0)?"activate":"default");
	}

	float dis(Node2D x) => (x.GlobalPosition - this.GlobalPosition).Length();

	public void TryChangeParent(Box may)
	{
		var have = may.FindChildren("*", "Area2D", true, false)
			.OfType<Draged>().ToArray();
		if (have.Length != 0)
		{
			if (have[0]!=this && have[0].Id == Id && have[0].Level==Level && Level!=MaxLevel && CheckCost())
			{
				have[0].Level++;
				QueueFree();
				GD.Print($"{Id} {Level} become {Id} {Level+1}");
				Sound("upgrade");
			}
			return;
		}
		Sound("put");

		if (!CheckCost()) return;
		Reparent(may);
		Cost = 0;
		Index = may.Index;
	}

	private bool CheckCost()
	{
		return TryUseMoney(Cost);
	}

	void Sound(string s)
	{
		var player = GetNode<Node>("/root/SignalBus");
		player.EmitSignal(new StringName("play_sfx"), s);
	}
	protected virtual void OnDragEnd() 
	{
		Scale = Vector2.One; // 恢复
		Modulate = Colors.White;
		
		// 检查是否放置在有效区域
		if (Box.Have.Count != 0)
		{
			var may=Box.Have.MinBy(dis);
			if (dis(may) <= MaxDiff )
			{
				TryChangeParent(may);
			}
		}

		Position = Vector2.Zero;

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
