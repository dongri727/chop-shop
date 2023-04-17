# Introduction

This project was initiated by the planners who were deeply impressed by "The History of Everything," Flutter's earliest application, and started this project to read and study its code. Anyone who shares the same interest is welcome to join, whether it's adding a single line of code or writing a few words of opinion. Full-fledged participation is also welcome.

Although "The History of Everything" is a beautiful application of animation, the target of this project is the creation of a chronological timeline that represents the passage of time in a very smooth motion. From the beginning of the universe (BIG BANG) to "now," from a general overview that allows you to get the time distance right to zooming in and seeing the details, it is intriguing to see what features of Flutter this consists of. Words cannot do it justice, so please take a look at the actual application.

## Project Goals

We have three steps in mind for this project:

Carefully study the code in which this smooth movement is established without using any particular package.
Rewrite the code as it was written in Flutter1 to support Flutter3 for further understanding.
Aim to package this wonderful feature so that many people can take advantage of it.

## Package Functions

We are considering the following three functions for the package:

An extendable and retractable time axis
Display of scale characters linked to the time axis
Display of items linked to the time axis

## issues

We will write about specific issues in the issue as they arise, so please choose the ones that interest you. We look forward to your participation.


これはThe History of EverythingというFlutter最初期のアプリに感動した企画者が、そのコードを読み込み勉強するために始めたプロジェクトです。興味を同じくする方がいらっしゃれば、どなたでも参加して、１行だけでもcodeを付け加えるとか、意見を一言書き込むとか、もちろん本格参入も大歓迎です。

The History of Everythingは、animationの美しいアプリですが、今回のターゲットはanimationではなく、非常になめらかな動きで時の流れを表現する年表の時間軸の作成です。宇宙の始まりbig bangから「今」まで、時間的距離を正しく把握できる総覧から、ズームインして細部を見ることまで、これがFlutterのどのような機能で構成されているのか、興味は尽きません。言葉では表現しきれないので、ぜひ実物のアプリをご覧ください。

次の３つのステップを考えています。
1 このなめらかな動きが、とくにPackageも使わず成立しているcodeをじっくりと読みこむ。
2 Flutter1で書かれたままのcodeをFlutter3対応に書き換えることで、さらに理解を深める。
3 この素晴らしい機能を、多くの人が活用できるよう、バッケージ化を目指す。

パッケージの機能としては以下の３つを考えています。
1 　伸縮自在の時間軸
2　時間軸に連動する目盛り文字の表示
3　時間軸に連動する項目の表示

具体的な課題については随時issueにあげていきますので、興味のあるものをお選びください。
ご参加お待ちしています。


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
