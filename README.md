### 説明

ここは『ゆるっとはじめるGodot Engineゲームプログラミング』のサポートサイトです。

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

### 誤植情報

1. 2Dアクション編の134ページ

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


