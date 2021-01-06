
ArrayList<Cube> cubes = new ArrayList<Cube>();
Cube cube_sel = null;
boolean keyDown = false;

void setup() {
  size(400, 400);  
  int N = 2; // 接続するキューブの個数

  // キューブの接続は１つずつ行う。
  // 同時に行うと同じものに接続してしまうことがあるので、
  // 作成したインスタンスが connected になるまで待つ。  
  while ( cubes.size() < N ) {
    Cube c = new Cube(this);
    print( "cube " + cubes.size() + " is trying to connect.");
    while ( !c.connected ) {
      print(".");
      delay(100);
    }
    println("\ncube " + cubes.size() + " is connected!");
    cubes.add(c);
  }

  // 0番目のキューブを操作対象にする
  cube_sel = cubes.get(0);

  // 起動時にウィンドウをアクティブにするための命令
  ((java.awt.Canvas)surface.getNative()).requestFocus();
}

void draw() {
  background(50);
  fill(255);
  textSize(25);

  // 各キューブの位置・角度の表示
  for (int i=0; i<cubes.size(); i++) {
    Cube cube = cubes.get(i);
    text("cube " + i, 20, 40 );
    text("x=" + cube.x, 40, 80 );
    text("y=" + cube.y, 40, 120 );
    text("angle=" + cube.angle, 40, 160 );
    translate(0, 200);
  }
}

void keyPressed() {
  // キーリピートを防ぐ仕組み
  if ( keyDown ) return;
  keyDown = true;

  // 操作するキューブの選択
  if ( key == '1' ) cube_sel = cubes.get(0);
  if ( key == '2' ) cube_sel = cubes.get(1);
  
  if ( keyCode == UP )    cube_sel.move(25, 25);    // 移動。左右輪の移動速度を指定
  if ( keyCode == DOWN )  cube_sel.move(-25, -25);
  if ( keyCode == LEFT )  cube_sel.move(-25, 25);
  if ( keyCode == RIGHT ) cube_sel.move(25, -25);
  if ( key == 'g' )       cube_sel.moveTo(200, 780, 50);  // 目標位置へ移動 (x,y,移動速度)
  if ( key == 's' )       cube_sel.playSound(1, 100);     // サウンド再生 (サウンドID, 音量)
}

// キーを離したら停止
void keyReleased() {
  keyDown = false;
  cube_sel.move(0, 0);  // 停止（移動速度ゼロ）
}
