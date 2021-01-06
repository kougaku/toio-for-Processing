Cube cube;
boolean keyDown = false;

void setup() {
  size(400, 300);
  
  // キューブのインスタンス作成
  cube = new Cube(this);

  // 起動時にウィンドウをアクティブにするための命令
  ((java.awt.Canvas)surface.getNative()).requestFocus();
}

void draw() {
  background(50);
  fill(255);
  textSize(30);

  // 接続状態表示
  if ( cube.connected ) text("connected", 20, 50);
  else if ( cube.searching ) text("searching...", 20, 50);
  else if ( cube.try_connect) text("tring to connect...", 20, 50);

  // 位置・角度表示
  text("x=" + cube.x, 20, 100 );
  text("y=" + cube.y, 20, 150 );
  text("angle=" + cube.angle, 20, 200 );
}

void keyPressed() {
  // キーリピートを防ぐ仕組み
  if ( keyDown ) return;
  keyDown = true;

  // これらの操作コマンドは大量に送り付けると受信データに遅延が発生するので注意。
  // なので、キーリピートによって連続送信されないようにしています。
  if ( keyCode == UP )    cube.move(25, 25);    // 移動。左右輪の移動速度を指定
  if ( keyCode == DOWN )  cube.move(-25, -25);
  if ( keyCode == LEFT )  cube.move(-25, 25);
  if ( keyCode == RIGHT ) cube.move(25, -25);
  if ( key == 'g' )       cube.moveTo(200, 780, 50);  // 目標位置へ移動 (x,y,移動速度)
  if ( key == 's' )       cube.playSound(1, 100);     // サウンド再生 (サウンドID, 音量)
}

// キーを離したら停止
void keyReleased() {
  keyDown = false;
  cube.move(0, 0);  // 停止（移動速度ゼロ）
}
