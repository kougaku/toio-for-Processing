# toio for Processing

<img src="https://i.gyazo.com/50f30fd3cd9ba2f62c948ab3e844b377.png" width="713" alt="toio for processing">

Processingでtoioを使うためのコードです。toioとのBLE通信を行うにあたり、Scratch Linkを仲介しています。<br>
現状でライブラリ（JAR）化してませんので、同根されているCube.pdeをライブラリ代わりに使ってください。
<br>
<br>
## 動作に必要なもの
Scratch Link と Websockets for Processing のインストールが必要です。

### Scratch Link
v1.3.66以上をインストールしてください。Processingのスケッチを実行する際は、Scratch Linkを起動しておいてください。<br>
- Mac版： https://downloads.scratch.mit.edu/link/mac.zip <br>
- Windows版： https://downloads.scratch.mit.edu/link/windows.zip <br>

### Websockets for Processing
- [Websockets for Processing](https://github.com/alexandrainst/processing_websockets) <br>
Processing用のWebSocketライブラリです。現状のリリース版（V1.0）はSSL通信に対応していないため、動きません（※2021年1月7日現在、ProcessingのContribution Managerからインストールされるのもこのバージョンです）。現在masterに上がっているコードはSSL対応になっていますので、プロジェクトページの「Code」→「Download ZIP」からファイルをダウンロードし、手動でインストールしてください。
<br><br>

## サンプルコード
### single_cube_demo
1個のキューブを操作するデモです。画面では接続状態表示、位置・角度表示を行います。<br>
- 方向キーで前後移動・右回転・左回転
- gキーで目標位置（x=200, y=780）へ移動
- sキーでサウンド再生
<br>
<img src="https://i.gyazo.com/6ef321fdd2d2f517ccbd8882fbe14a42.png" alt="single_cube_demo" width="250"/><br>

### two_cubes_demo
2個のキューブを操作するデモです。画面ではキューブの位置・角度表示を行います。<br>
- 1キーで1つめのキューブを操作対象に、2キーで2つめのキューブを操作対象にする。
- 方向キーで前後移動・右回転・左回転
- gキーで目標位置（x=200, y=780）へ移動
- sキーでサウンド再生
<br>
<img src="https://i.gyazo.com/f8e7d28b0320bc9fb4927177849aa226.png" alt="two_cubes_demo" width="250"/><br>

### moveTo_by_click
マット上のどこにキューブがあるかを図示し、マウスクリックで目標位置を指定することができます。
- 方向キーで前後移動・右回転・左回転
- gキーで目標位置（x=200, y=780）へ移動
- 1,2,3,4,5,6,7,8,9,0,-キーでサウンド再生
<br>
<img src="https://i.gyazo.com/52eb2b06cb815e489e33778bb9793a54.gif" alt="moveTo_by_click" width="450"/><br>



## API
toioのすべての機能を網羅しているわけではありませんが、簡単なプロトタイピングに必要な機能を最低限実装しておきました。

```java
// インスタンス生成（自動的に接続を始めます）
Cube cube = new Cube(this);

// 接続先検索中フラグ
if ( cube.searching ) println("searching cube");

// 接続トライ中フラグ
if ( cube.try_connect ) println("trying to connect");

// 接続完了フラグ（※切断検知は実装されていません）
if ( cube.connected ) println("cube is connected");

// キューブの位置と角度
println( cube.x, cube.y, cube.angle );

// モータ制御（連続動作）
cube.move(left_speed, right_speed);

// 時間指定付きモータ制御
cube.move(left_speed, right_speed, time_x100ms);

// 目標指定付きモータ制御（角度指定なし）
cube.moveTo(x, y, max_speed);

// 目標指定付きモータ制御（角度指定なし、速度タイプ指定あり）
cube.moveTo(x, y, max_speed, move_type, speed_type);

// 目標指定付きモータ制御（角度指定あり）
cube.moveTo(x, y, max_speed, angle, move_type, speed_type, angle_type);

// サウンド再生
cube.playSound(sound_id, volume);
```



