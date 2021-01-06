# toio for Processing

<img src="https://i.gyazo.com/50f30fd3cd9ba2f62c948ab3e844b377.png" width="570" height="177" alt="toio for processing">

Processingでtoioを使うためのコードです。toioとのBLE通信を行うにあたり、Scratch Linkを仲介しています。
現状でライブラリ（JAR）化してませんので、同根されているCube.pdeをライブラリ代わりに使ってください。
<br>
<br>
## 動作に必要なもの
Scratch Link と Websockets for Processing のインストールが必要です。

### (1) Scratch Link
v1.3.66以上をインストールしてください。<br>
- Mac版： https://downloads.scratch.mit.edu/link/mac.zip <br>
- Windows版： https://downloads.scratch.mit.edu/link/windows.zip <br>

### (2) Websockets for Processing
- [Websockets for Processing](https://github.com/alexandrainst/processing_websockets) <br>
現状のリリース版（V1.0）はSSL通信に対応していないため、動きません。現在masterに上がっているコードはSSL対応になっていますので、プロジェクトページの「Code」→「Download ZIP」からファイルをダウンロードし、手動でインストールしてください。


## サンプルコード
### single_cube_demo
1個のキューブを操作するデモです。

### two_cubes_demo
2個のキューブを操作するデモです。

### moveTo_by_click
マット上のどこにキューブがあるかを図示し、マウスクリックで目標位置を指定することができます。

