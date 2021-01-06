Cube cube;
PVector targetPos;
boolean keyDown = false;

void setup() {
  size(800, 700);

  // キューブのインスタンス作成
  cube = new Cube(this);

  // 起動時にウィンドウをアクティブにするための命令
  ((java.awt.Canvas)surface.getNative()).requestFocus();
}

void draw() {
  background(50);

  textSize(20);
  fill(255);
  text("move : UP, DOWN, LEFT, RIGHT", 30, 30 );
  text("go to destinatin : mouse click", 30, 55 ); 
  text("play sound : 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, - ", 30, 80 );

  fill(255, 255, 0);
  text("    x=" + cube.x + ", y="+cube.y + ", angle=" + cube.angle, 30, 120 );

  //-----------------------------------------------------------------------------
  int offset_x = 34;
  int offset_y = 35;
  int mat_width = 339 - 34;
  int mat_height = 250 - 35;

  translate( 30, 120 ); // 全体の表示位置決め
  scale(0.6);          // 表示サイズの調整

  // 現在の座標系でのマウスカーソルの座標値を取得
  targetPos = screenToLocal(mouseX, mouseY);

  stroke(255);
  strokeWeight(2);
  for ( int x=0; x<3; x++ ) {
    for (int y=0; y<4; y++) {
      pushMatrix();
      translate( x * mat_width + offset_x, y * mat_height + offset_y ); 
      fill(60);
      rect(0, 0, mat_width, mat_height );
      textSize(30);
      fill(255);
      text("#"+(x*4+y+1), 10, 35);
      popMatrix();
    }
  }

  // cube
  translate(cube.x, cube.y);
  rotate(radians(cube.angle));
  stroke(255, 255, 0);
  strokeWeight(3);
  noFill();
  rectMode(CENTER);
  rect( 0, 0, 20, 20 );
  rectMode(CORNER);
  line( 10, 0, 20, 0);
}

void keyPressed() {
  // キーリピートを防ぐ仕組み
  if ( keyDown ) return;
  keyDown = true;
  
  if ( keyCode == UP )   cube.move(25, 25);    // 移動。左右輪の移動速度を指定
  if ( keyCode == DOWN )  cube.move(-25, -25);
  if ( keyCode == LEFT )  cube.move(-25, 25);
  if ( keyCode == RIGHT ) cube.move(25, -25);
  if ( key == 'g' )       cube.moveTo(200, 780, 50);  // 目標位置へ移動 (x,y,移動速度)
  if ( key == 's' )       cube.playSound(1, 100);     // サウンド再生 (サウンドID, 音量)

  int volume = 255;
  if ( key == '1' ) cube.playSound(0, volume);
  if ( key == '2' ) cube.playSound(1, volume);
  if ( key == '3' ) cube.playSound(2, volume);
  if ( key == '4' ) cube.playSound(3, volume);
  if ( key == '5' ) cube.playSound(4, volume);
  if ( key == '6' ) cube.playSound(5, volume);
  if ( key == '7' ) cube.playSound(6, volume);
  if ( key == '8' ) cube.playSound(7, volume);
  if ( key == '9' ) cube.playSound(8, volume);
  if ( key == '0' ) cube.playSound(9, volume);
  if ( key == '-' ) cube.playSound(10, volume);
}

// キーを離したら停止
void keyReleased() {
  keyDown = false;
  cube.move(0, 0);  // 停止（移動速度ゼロ）
}

void mousePressed() {
  int max_speed = 50;
  cube.moveTo( (int)targetPos.x, (int)targetPos.y, max_speed );
}

// スクリーン座標を現在の座標系の座標値に変換
PVector screenToLocal(float x, float y) {
  PVector in = new PVector(x, y);
  PVector out = new PVector();
  PMatrix2D current_matrix = new PMatrix2D();
  getMatrix(current_matrix);  
  current_matrix.invert();
  current_matrix.mult(in, out);
  return out;
}
