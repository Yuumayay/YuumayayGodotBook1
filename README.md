## ゆるっとはじめるGodot Engineゲームプログラミング①～④ サポートサイト
<img alt="1章" src="https://github.com/Yuumayay/YuumayayGodotBook1/assets/3530659/b9804073-3a47-4e64-9179-479f3696c5c7" width="20%">
<!--<img alt="2章" src="https://github.com/Yuumayay/YuumayayGodotBook1/assets/3530659/abce6201-baeb-4d02-a831-e8cb27e84511" width="15%">
<img alt="3章" src="https://github.com/Yuumayay/YuumayayGodotBook1/assets/3530659/60480f7d-2f7b-4255-9e93-dc96ff9f749b" width="15%">-->
<img alt="4章" src="https://github.com/Yuumayay/YuumayayGodotBook1/assets/3530659/1b753bda-b9e9-4ede-9c77-e183d2cab88f" width="20%">

### 説明

ここは『ゆるっとはじめるGodot Engineゲームプログラミング入門編①～③』『④オンラインゲーム編』のサポートサイトです。

緑の「Code」ボタンをクリックしたのちに「Download ZIP」をクリックしてZIPファイルをダウンロードして展開してください。

素材集フォルダの中に各ゲームの素材がまとめてあるフォルダが入っています。

その他のフォルダには、各ゲームのサンプルプロジェクトが入っています。

サンプルプロジェクトフォルダ内のproject.godotファイルをGodot Engineからインポートすると、Godot Engine上で開けます。

### Godotterの集い

著者Yuumayayが運営する、Godot Engineでまったり開発するDiscordサーバー「Godotterの集い」の招待URLです。

https://discord.gg/dpCNYKNJXV

### プラットフォーマーRTA

プラットフォーマーはGodot Engineを使えば〇〇秒で作れちゃう！？

2DプラットフォーマーRTAの動画URLです。

https://www.youtube.com/shorts/D02C0EogwWA


## 誤植・修正情報

### 2Dアクション編 ノックバック処理の修正
- 128ページ

関数の呼び出し順番を以下に修正してください。

誤）
```GDScript
func _on_enemy_hitbox_body_entered(body):
    if body.name == "Character":
        UI.damage(20)
        body.knockback()
```

正）
```GDScript
func _on_enemy_hitbox_body_entered(body):
    if body.name == "Character":
        body.knockback()
        UI.damage(20)
```

- 134ページ

knockback関数を以下に修正してください。

誤）
```GDScript
func knockback():
	can_move = false
	if sprite.flip_h == true:
		velocity = Vector2(100, -300)
	else:
		velocity = Vector2(-100, -300)

	await get_tree().create_timer(0.5).timeout
	can_move = true
```

正）
```GDScript
func knockback():
	can_move = false
	velocity = Vector2(-100, -300)

	await get_tree().create_timer(0.5).timeout
	can_move = true
```

その後、152ページまで進めた後にknockback関数を以下に修正してください。
```GDScript
func knockback():
	can_move = false
	if sprite.flip_h == true:
		velocity = Vector2(100, -300)
	else:
		velocity = Vector2(-100, -300)

	await get_tree().create_timer(0.5).timeout
	can_move = true
```

### 2Dアクション編 インデントが消えている
- 182ページ 20行目

インデントが消えている誤植がありました。一つ前の行と同じインデントに修正してください。

誤）
```GDScript
		await get_tree().create_timer(3).timeout
get_tree().change_scene_to_file("res://stage1.tscn")
```

正）
```GDScript
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://stage1.tscn")
```

### 素材集の不足
- 2024/07/29 2Dアクションの素材集にcoin.png、ground.pngが欠けていたため修正
- 2025/01/05 2Dアクションの素材集にtakarabako.pngが欠けていたため修正
