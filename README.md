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

まずはリポジトリを フォーク! github でポチるだけです。
次にリポジトリをクローン! 
そこから以下の流れ（草案）で共同開発できるかと！

大まかな作業の流れ（の、草案）

1. フォークした自分のリポジトリで作業する.
1. 作業したら `commit` して gitihub に `push` する.
1. 早い段階で WIP プルリクエストを作成する.
   github で自分のリポジトリからどんぐりさんのリポジトリに向かってプルリクエストを作成.
   やったこととかやりたいこととか書いて共有する.
   開発途中でもいいから プルリク作ってあーだこーだ言いながらみんなで開発するのが良いかと.
1. その機能が欲しいなら マージする. お試しとかでマージ不要であればそのまま プルリク を破棄しちゃう.
   お試しコードは自分のリポジトリで PR 作ってまとめて共有する程度でも良さげ.
1. これで複数人同時進行の開発ができる.

### 作業例

git は GUI でも OK.

```
# プロジェクトに移動
cd chop-shop/
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
# この段階で自分のリポジトリで PR ができているだろうから, マージ or 破棄
# お試しなら main にマージしない方が良いかも
#
# どんぐりさんの chop-shop にマージして欲しいなら
# github で どんぐりさんの リポジトリに向かって プルリクを作成
# 
# 追加開発
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
# どんぐりさんの リポジトリに向かっているプルリクが更新される
# マージ or 破棄 
```
