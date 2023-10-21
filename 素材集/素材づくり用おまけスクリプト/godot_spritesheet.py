# sprite_sheet.py
# 複数の画像の最大サイズ＋マージンを計算して、等間隔スプライトシートを作成する python
# 画像は、pngsフォルダに入れておく。
# pythonのインストールは、こちらから：https://www.python.org/downloads/
# 必要なモジュールはこのコマンドで入れる： pip install pillow
# 使い方：python sprite_sheet.py

from PIL import Image
import os, glob

image_dir = "./pngs/*.png" # 画像ファイルのパス
image_files = glob.glob(image_dir)
image_files.sort()

DIV_W = 4 # 画像の並び
MARGIN = 1 * 2 # 画像のマージン
OUT = "omochi.png" # 出力スプライトシートのファイル名

# 画像を読み込み、最大サイズを取得
max_width = 0
max_height = 0
images = []
for file in image_files:
    image = Image.open(file)
    images.append(image)
    width, height = image.size
    if width > max_width:
        max_width = width
    if height > max_height:
        max_height = height
# 画像の最大サイズにマージンWを追加
max_width += MARGIN * DIV_W

# スプライトシートのサイズを計算
num_images = len(images)
num_rows = (num_images + (DIV_W-1)) // DIV_W

# 画像の最大サイズにマージンHを追加
max_height += MARGIN * num_rows

sheet_width = max_width * DIV_W
sheet_height = max_height * num_rows

# スプライトシートを作成
sheet = Image.new("RGBA", (sheet_width, sheet_height), (0, 0, 0, 0))
x = 0
y = 0
for i, image in enumerate(images):
    # 画像を中央に貼り付け
    width, height = image.size
    sheet.paste(image, (x + (max_width - width) // 2, y + (max_height - height) // 2))
    x += max_width
    if (i + 1) % DIV_W == 0:
        x = 0
        y += max_height

# スプライトシートを保存
sheet.save(OUT)
