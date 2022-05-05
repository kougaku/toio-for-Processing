import java.util.Base64;
import websockets.*;

public class Cube {
  // アルファベットが小文字であることに注意。
  final String SERVICE_UUID    = "10b20100-5b3b-4571-9508-cf3efcd7bbae";
  final String READ_CHAR_UUID  = "10b20101-5b3b-4571-9508-cf3efcd7bbae";
  final String MOTOR_CHAR_UUID = "10b20102-5b3b-4571-9508-cf3efcd7bbae";
  final String SOUND_CHAR_UUID = "10b20104-5b3b-4571-9508-cf3efcd7bbae";

  final byte NONE = 0x00;
  final byte CONTROL_CONTINUOUS = 0x01;         // モータ制御（連続動作）
  final byte CONTROL_TIME_SPECIFIED = 0x02;     // 時間指定付きモータ制御
  final byte CONTROL_POSITION_SPECIFIED = 0x03; // 目標指定付きモータ制御

  final byte MOVE_WITH_ROTATION = 0x00;          // 回転しながら移動
  final byte MOVE_WITH_ROTATION_NO_BACK = 0x01;  // 回転しながら移動（後退なし）
  final byte MOVE_AFTER_ROTATION = 0x02;         // 回転してから移動

  final byte SPEED_CONSTANT = 0x00;    // 速度一定
  final byte SPEED_ACCELERATED = 0x01; // 目標地点まで徐々に加速
  final byte SPEED_DECELERAED = 0x02;  // 目標地点まで徐々に減速
  final byte SPEED_ACC_AND_DEC = 0x03; // 中間地点まで徐々に加速し、そこから目標地点まで減速

  final byte DEST_ANGLE_ABS = 0x00;         // 絶対角度  回転量が少ない方向
  final byte DEST_ANGLE_ABS_POS = 0x01;     // 絶対角度  正方向
  final byte DEST_ANGLE_ABS_NEG = 0x02;     // 絶対角度  負方向
  final byte DEST_ANGLE_REL_POS = 0x03;     // 相対角度  正方向
  final byte DEST_ANGLE_REL_NEG = 0x04;     // 相対角度  負方向
  final byte DEST_ANGLE_NO_ROTATION = 0x05; // 角度指定なし  回転しない
  final byte DEST_ANGLE_SAME_AS_START = 0x06;  // 書き込み操作時と同じ（動作開始時と同じ角度）  回転量が少ない方向

  final byte MOTOR_ID_LEFT = 0x01;
  final byte MOTOR_ID_RIGHT = 0x02;
  final byte MOTOR_DIR_FRONT = 0x01;
  final byte MOTOR_DIR_BACK = 0x02;

  final byte PLAY_SOUND = 0x02;
  final byte SOUND_ID_ENTER = 0x00;
  final byte SOUND_ID_SELECTED = 0x01;
  final byte SOUND_ID_CANCEL = 0x02;
  final byte SOUND_ID_CURSOR = 0x03;
  final byte SOUND_ID_MATIN  = 0x04;
  final byte SOUND_ID_MATOUT = 0x05;
  final byte SOUND_ID_GET1 = 0x06;
  final byte SOUND_ID_GET2 = 0x07;
  final byte SOUND_ID_GET3 = 0x08;
  final byte SOUND_ID_EFFECT1 = 0x09;
  final byte SOUND_ID_EFFECT2 = 0x0A;

  PApplet parent;
  Proxy proxy;
  WebsocketClient ws;
  long peripheralId = 0;
  int x, y, angle, std_id, std_angle;

  boolean searching = false;
  boolean try_connect = false;
  boolean connected = false;

  // コンストラクタ
  public Cube(PApplet parent) {
    this.parent = parent;
    this.proxy = new Proxy();
    // this.ws = new WebsocketClient(proxy, "wss://device-manager.scratch.mit.edu:20110/scratch/ble");
    this.ws = new WebsocketClient(proxy, "ws://127.0.0.1:20111/scratch/ble"); // for Scratch Link v1.4    
    parent.registerMethod("dispose", this);

    // discover後自動的に接続シーケンスに入るしくみ。
    discover();
  }

  void connect() {
  }

  public class Proxy extends PApplet {
    public Proxy() {
    }
    void webSocketEvent(String msg) {
      // println(msg);
      JSONObject recv = parseJSONObject(msg);

      // 成功のレスポンス
      if ( recv.hasKey("result") && recv.isNull("result") ) {
        if ( try_connect ) {
          try_connect = false;
          connected = true;
        }
      }
      
      // 接続失敗したときの処理が必要。
      
      

      // method check ------------------------------------------------------------------------------------------
      String method = recv.getString("method");
      if ( method == null ) return;

      if ( method.equals("didDiscoverPeripheral")) {
        searching = false;
        if ( !connected ) {
          peripheralId = (recv.getJSONObject("params")).getLong("peripheralId");
          connectProcess();
          startNotifications(READ_CHAR_UUID);
        }
      }

      if ( method.equals("characteristicDidChange") ) {
        if ( recv.getJSONObject("params").getString("characteristicId").equals(READ_CHAR_UUID) ) {
          String data = recv.getJSONObject("params").getString("message");
          byte[] bytedata = decodeBase64(data);
          if ( bytedata.length == 13 ) {
            x = (bytedata[2] << 8 ) | (bytedata[1] & 0xFF);
            y = (bytedata[4] << 8 ) | (bytedata[3] & 0xFF);
            angle = (bytedata[6] << 8 ) | (bytedata[5] & 0xFF);
          }
        }
      }
    }
  }


  // 終了時の処理
  public void dispose() {
    this.ws.dispose();
  }

  void getVersion() {
    JSONObject json = new JSONObject();
    json.setString("jsonrpc", "2.0");
    json.setInt("id", 1);
    json.setString("method", "getVersion");
    ws.sendMessage(json.toString());
  }

  void discover() {
    searching = true;
    
    JSONObject json = new JSONObject();
    json.setString("jsonrpc", "2.0");
    json.setInt("id", 1);
    json.setString("method", "discover");
    json.setJSONObject("params", parseJSONObject("{\"filters\":[{\"services\":[\"" + SERVICE_UUID + "\"]}]}"));

    ws.sendMessage(json.toString());
  }

  void connectProcess() {
    try_connect = true;
    // print("-");

    JSONObject json = new JSONObject();
    json.setString("jsonrpc", "2.0");
    json.setInt("id", 1);
    json.setString("method", "connect");
    json.setJSONObject("params", (new JSONObject()).setLong("peripheralId", peripheralId));

    ws.sendMessage(json.toString());
  }

  void write(String charId, byte[] data) {
    if ( !connected ) return;
    
    JSONObject params = new JSONObject();
    params.setString("serviceId", SERVICE_UUID );
    params.setString("characteristicId", charId);
    params.setString("message", encodeBase64(data));
    params.setString("encoding", "base64");
    params.setBoolean("withResponse", false);

    JSONObject json = new JSONObject();
    json.setString("jsonrpc", "2.0");
    json.setInt("id", 1);
    json.setString("method", "write");
    json.setJSONObject("params", params);

    ws.sendMessage(json.toString());
  }

  void startNotifications(String charId) {
    JSONObject params = new JSONObject();
    params.setString("serviceId", SERVICE_UUID );
    params.setString("characteristicId", charId);

    JSONObject json = new JSONObject();
    json.setString("jsonrpc", "2.0");
    json.setInt("id", 1);
    json.setString("method", "startNotifications");
    json.setJSONObject("params", params);

    ws.sendMessage(json.toString());
  }

  String encodeBase64(byte[] data) {
    return Base64.getEncoder().encodeToString(data);
  }

  byte[] decodeBase64(String str) {
    return Base64.getDecoder().decode(str);
  }

  // 下位バイト（２バイトのうち下位１バイト分を取得）
  byte lowByte(int value) {
    return (byte)(value & 0xFF);
  }

  // 上位バイト（２バイトのうち上位１バイト分を取得）
  byte highByte(int value) {
    return (byte)((value >> 8) & 0xFF);
  }

  // モータ制御（連続動作）
  void move(int left_speed, int right_speed ) {
    byte[] data = new byte[7];  
    data[0] = CONTROL_CONTINUOUS;
    data[1] = MOTOR_ID_LEFT;
    data[2] = ( left_speed >=0 ) ? MOTOR_DIR_FRONT : MOTOR_DIR_BACK;
    data[3] = (byte)constrain(abs(left_speed), 0, 255);
    data[4] = MOTOR_ID_RIGHT;
    data[5] = ( right_speed >=0 ) ? MOTOR_DIR_FRONT : MOTOR_DIR_BACK;
    data[6] = (byte)constrain(abs(right_speed), 0, 255);

    write( MOTOR_CHAR_UUID, data );
  }

  // 時間指定付きモータ制御
  void move(int left_speed, int right_speed, int time_x100ms) {
    byte[] data = new byte[8];  
    data[0] = CONTROL_TIME_SPECIFIED;
    data[1] = MOTOR_ID_LEFT;
    data[2] = ( left_speed >=0 ) ? MOTOR_DIR_FRONT : MOTOR_DIR_BACK;
    data[3] = (byte)constrain(abs(left_speed), 0, 255);
    data[4] = MOTOR_ID_RIGHT;
    data[5] = ( right_speed >=0 ) ? MOTOR_DIR_FRONT : MOTOR_DIR_BACK;
    data[6] = (byte)constrain(abs(right_speed), 0, 255);
    data[7] = (byte)constrain(time_x100ms, 0, 255);

    write( MOTOR_CHAR_UUID, data );
  }

  void moveTo(int x, int y, int max_speed) {
    moveTo( x, y, max_speed, 0, MOVE_WITH_ROTATION_NO_BACK, SPEED_CONSTANT, DEST_ANGLE_NO_ROTATION );
  }

  // 目標指定付きモータ制御（角度指定なし）
  void moveTo(int x, int y, int max_speed, byte move_type, byte speed_type) {
    moveTo( x, y, max_speed, 0, move_type, speed_type, DEST_ANGLE_NO_ROTATION );
  }

  // 目標指定付きモータ制御（角度指定あり）
  void moveTo(int x, int y, int max_speed, int angle, byte move_type, byte speed_type, byte angle_type ) {
    int timeout = 5; // 秒
    int control_id_value = 0; // 制御識別値

    byte[] data = new byte[13];
    data[0] = CONTROL_POSITION_SPECIFIED;
    data[1] = (byte)control_id_value;
    data[2] = (byte)timeout;
    data[3] = (byte)move_type;
    data[4] = (byte)max_speed;
    data[5] = (byte)speed_type;
    data[6] = NONE;
    data[7] = lowByte(x);
    data[8] = highByte(x);
    data[9] = lowByte(y);
    data[10] = highByte(y); 
    data[11] = lowByte(angle);
    data[12] = (byte)(highByte(angle) + (angle_type << 5));

    write( MOTOR_CHAR_UUID, data );
  }

  // 音を鳴らす
  void playSound(int sound_id, int volume) {
    byte[] data = new byte[3]; 
    data[0] = PLAY_SOUND;
    data[1] = (byte)constrain(sound_id, 0, 10);
    data[2] = (byte)constrain(volume, 0, 255);

    write( SOUND_CHAR_UUID, data );
  }
}
