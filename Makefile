.PHONY: \
	run icon

# flutterを実行
run:
	flutter run --release

# アプリにアイコンを設定する
# ※生成される画像の大きさが誤っている場合があります
icon:
	flutter pub run flutter_launcher_icons