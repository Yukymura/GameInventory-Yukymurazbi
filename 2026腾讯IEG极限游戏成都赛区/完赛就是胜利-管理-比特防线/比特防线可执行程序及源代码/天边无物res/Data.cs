using Godot;
using System;
using System.IO;
using Godot.Collections;
using Array = System.Array;

public partial class Data : Node
{
	[Export] public Array<PackedScene> Scenes = new Array<PackedScene>();

	[Export] public string DirPath { get; set; } = "res://Drageds";

	public override void _Ready()
	{
		base._Ready();
		// LoadScenesFromDirectory(DirPath);
	}

	public void LoadScenesFromDirectory(string dirPath )
	{
		var dir = DirAccess.Open(dirPath);
		
		// Godot 4 不需要参数
		dir.ListDirBegin();
		
		
		for (string fileName = dir.GetNext();fileName != "";fileName = dir.GetNext())
		{
			// 跳过目录和隐藏文件
			if (dir.CurrentIsDir() || fileName.StartsWith("."))
			{
				continue;
			}

			GD.Print($"{dirPath}/{fileName}");
			// 过滤 .tscn 文件（注意导出后可能是 .scn，建议同时检查）
			if (fileName.EndsWith(".remap"))
				fileName = fileName.Replace(".remap", "");
			
			if (fileName.EndsWith(".tscn"))
			{
				
				string fullPath = $"{dirPath}/{fileName}";
				
				// 加载为 PackedScene
				var scene = ResourceLoader.Load<PackedScene>(fullPath);
				Scenes.Add(scene);
			}
		}
		
		dir.ListDirEnd();
		GD.Print($"总计加载 {Scenes.Count} 个场景");
	}
}
