# chop_shop

FU TeamDev 12

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 共同開発

まずはリポジトリをクローン! 

```
git clone git@github.com:dongri727/chop-shop.git
```

大まかな作業の流れ（の、草案）

1. `feature/xxx` (xxx は やりたいことを簡潔に) を切って作業する.
1. 作業したら `commit` して gitihub に `push` する.
1. push すると プルリクエスト を作成できるので そこに やったこととか書いて共有する.
1. 開発途中でもいいから プルリク作って, あーだこーだ言いながらみんなで開発.
1. その機能が欲しいなら マージする. お試しとかでマージ不要であればそのまま プルリク を破棄しちゃう.
1. これを複数人で同時進行で開発できる.

```
# `feature/xxx` (xxx は やりたいことを簡潔に) を切って作業する
git checkout -b feature/xxx
#
# ... 作業
#
# ステージング
git add .
# コミットする
git commit -m "GestureDetector のお試し page を作成"
# 開発途中でも push して プルリク作って共有する
git push origin feature/xxx
#
# ... github に行って プルリク作る
# 
# プルリクで色々検討
#
# 追加差分
git add .
git commit -m "GestureDetector で pinch してみる"
# ...
git add .
git commit -m "fix: 引数 hoge の初期値が null が原因のレイアウト不具合を解消"
# 再度 push
git push origin feature/xxx
# 
# github で マージ or 破棄
```