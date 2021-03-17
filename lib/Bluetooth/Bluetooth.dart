
package com.example.android.BluetoothByTerasicRFS;


import com.example.android.BluetoothByTerasicRFS.R;

import android.annotation.SuppressLint;
import android.app.ActionBar;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.view.inputmethod.EditorInfo;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

/**
 * This is the main Activity that displays the current chat session.
 */
public class Bluetooth extends Activity {
  // Debugging
  private static final String TAG = "Bluetooth";
  private static final boolean D = true;

  // Message types sent from the BluetoothService Handler
  public static final int MESSAGE_STATE_CHANGE = 1;
  public static final int MESSAGE_READ = 2;
  public static final int MESSAGE_WRITE = 3;
  public static final int MESSAGE_DEVICE_NAME = 4;
  public static final int MESSAGE_TOAST = 5;

  // Key names received from the BluetoothService Handler
  public static final String DEVICE_NAME = "device_name";
  public static final String TOAST = "toast";

  // Intent request codes
  private static final int REQUEST_CONNECT_DEVICE_SECURE = 1;
  private static final int REQUEST_CONNECT_DEVICE_INSECURE = 2;
  private static final int REQUEST_ENABLE_BT = 3;

  // Layout Views
  private ListView mConversationView;
  private EditText mOutEditText;
  private Button mSendButton;

  // Name of the connected device
  private String mConnectedDeviceName = null;
  // Array adapter for the conversation thread
  private ArrayAdapter<String> mConversationArrayAdapter;
  // String buffer for outgoing messages
  private StringBuffer mOutStringBuffer;
  // Local Bluetooth adapter
  private BluetoothAdapter mBluetoothAdapter = null;
  // Member object for the chat services
  private BluetoothService mChatService = null;
  //button0
  private ImageView ButtonLed0;
  private ImageView ButtonLed1;
  private ImageView ButtonLed2;
  private ImageView ButtonLed3;
  private ImageView ButtonALL;
  private ImageView ButtonLogo;
  boolean LED0_state = false;
  boolean LED1_state = false;
  boolean LED2_state = false;
  boolean LED3_state = false;
  boolean LED_state = false;
  private boolean Allswitch = false;

  private void sleep(int length) {
    for(int i=0; i<length; i++) {
      ;
    }
  }

  private void IsLed0ButtonClick()
  {
    ButtonLed0.setOnClickListener(new OnClickListener(){
    public void onClick(View v) {
    if(LED0_state==false){
    LED0_state = true;
    sendMessage("ABCDEFG");
    sleep(1000000000);
    sendMessage("ABCDEFG");
    ButtonLed0.setImageDrawable(getResources().getDrawable(R.drawable.led0_on));
    }else{
    LED0_state = false;
    sendMessage("ABCDEFG");
    ButtonLed0.setImageDrawable(getResources().getDrawable(R.drawable.led0_off));
    }
    }
    /*
          	 public void onClick(View v) {
          		    if(LED0_state==false){
	          		    LED0_state = true;
	          			sendMessage("0");
	          			ButtonLed0.setImageDrawable(getResources().getDrawable(R.drawable.led0_on));
          		    }else{
	          		    LED0_state = false;
	              		sendMessage("4");
	              		ButtonLed0.setImageDrawable(getResources().getDrawable(R.drawable.led0_off));
          		    }
          	 }
          	 */
    });
  }
  private void IsLed1ButtonClick()
  {
    ButtonLed1.setOnClickListener(new OnClickListener(){
    public void onClick(View v) {
    if(LED1_state==false){
    LED1_state = true;
    sendMessage("1");
    ButtonLed1.setImageDrawable(getResources().getDrawable(R.drawable.led1_on));
    }else{
    LED1_state = false;
    sendMessage("5");
    ButtonLed1.setImageDrawable(getResources().getDrawable(R.drawable.led1_off));
    }
    }
    });
  }
  private void IsLed2ButtonClick()
  {
    ButtonLed2.setOnClickListener(new OnClickListener(){
    public void onClick(View v)  {
    if(LED2_state==false){
    LED2_state = true;
    sendMessage("2");
    ButtonLed2.setImageDrawable(getResources().getDrawable(R.drawable.led2_on));
    }else{
    LED2_state = false;
    sendMessage("6");
    ButtonLed2.setImageDrawable(getResources().getDrawable(R.drawable.led2_off));
    }
    }
    });
  }
  private void IsLed3ButtonClick()
  {
    ButtonLed3.setOnClickListener(new OnClickListener(){
    public void onClick(View v) {
    if(LED3_state==false){
    LED3_state = true;
    sendMessage("3");
    ButtonLed3.setImageDrawable(getResources().getDrawable(R.drawable.led3_on));
    }else{
    LED3_state = false;
    sendMessage("7");
    ButtonLed3.setImageDrawable(getResources().getDrawable(R.drawable.led3_off));
    }
    }
    });
  }
  private void IsLedallButtonClick()
  {
    ButtonALL.setOnClickListener(new OnClickListener(){
    public void onClick(View v) {
    if(Allswitch == false){
    Allswitch = true;
    LED0_state = true;
    LED1_state = true;
    LED2_state = true;
    LED3_state = true;
    sendMessage("8");
    ButtonLed0.setImageDrawable(getResources().getDrawable(R.drawable.led0_on));
    ButtonLed1.setImageDrawable(getResources().getDrawable(R.drawable.led1_on));
    ButtonLed2.setImageDrawable(getResources().getDrawable(R.drawable.led2_on));
    ButtonLed3.setImageDrawable(getResources().getDrawable(R.drawable.led3_on));
    ButtonALL.setImageDrawable(getResources().getDrawable(R.drawable.led_on));


    }
    else{
    Allswitch = false;
    LED0_state = false;
    LED1_state = false;
    LED2_state = false;
    LED3_state = false;
    sendMessage("9");
    ButtonLed0.setImageDrawable(getResources().getDrawable(R.drawable.led0_off));
    ButtonLed1.setImageDrawable(getResources().getDrawable(R.drawable.led1_off));
    ButtonLed2.setImageDrawable(getResources().getDrawable(R.drawable.led2_off));
    ButtonLed3.setImageDrawable(getResources().getDrawable(R.drawable.led3_off));
    ButtonALL.setImageDrawable(getResources().getDrawable(R.drawable.led_off));	 }          	 }

    });
  }
  private void IsLogoButtonClick()
  {
    ButtonLogo.setOnClickListener(new OnClickListener(){
    public void onClick(View v) {
    Intent websiteIntent = new Intent(Intent.ACTION_VIEW);
    Uri uri = Uri.parse("http://www.terasic.com.tw/en/");
    websiteIntent.setData(uri);
    startActivity(websiteIntent);
    }

    });
  }
  @SuppressLint("NewApi")
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    if(D) Log.e(TAG, "+++ ON CREATE +++");
    // Set up the window layout
    getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    setContentView(R.layout.main);


    // Get local Bluetooth adapter
    mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

    ButtonLed0 = (ImageView)findViewById(R.id.imageViewLed0);
    IsLed0ButtonClick();
    ButtonLed1 = (ImageView)findViewById(R.id.imageViewLed1);
    IsLed1ButtonClick();
    ButtonLed2 = (ImageView)findViewById(R.id.imageViewLed2);
    IsLed2ButtonClick();
    ButtonLed3 = (ImageView)findViewById(R.id.imageViewLed3);
    IsLed3ButtonClick();
    ButtonALL = (ImageView)findViewById(R.id.imageViewLedall);
    IsLedallButtonClick();
    ButtonLogo = (ImageView)findViewById(R.id.imageViewLogo);
    IsLogoButtonClick();
    // If the adapter is null, then Bluetooth is not supported
    if (mBluetoothAdapter == null) {
      Toast.makeText(this, "Bluetooth is not available", Toast.LENGTH_LONG).show();
      finish();
      return;
    }
  }

  @SuppressLint("NewApi")
  @Override
  public void onStart() {
    super.onStart();
    if(D) Log.e(TAG, "++ ON START ++");

    // If BT is not on, request that it be enabled.
    // setupChat() will then be called during onActivityResult
    if (!mBluetoothAdapter.isEnabled()) {
      Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
      startActivityForResult(enableIntent, REQUEST_ENABLE_BT);
      // Otherwise, setup the chat session
    } else {
      if (mChatService == null) setupChat();
    }
  }

  @Override
  public synchronized void onResume() {
    super.onResume();
    if(D) Log.e(TAG, "+ ON RESUME +");

    // Performing this check in onResume() covers the case in which BT was
    // not enabled during onStart(), so we were paused to enable it...
    // onResume() will be called when ACTION_REQUEST_ENABLE activity returns.
    if (mChatService != null) {
      // Only if the state is STATE_NONE, do we know that we haven't started already
      if (mChatService.getState() == BluetoothService.STATE_NONE) {
        // Start the Bluetooth chat services
        mChatService.start();
      }
    }
  }

  @SuppressLint("NewApi")
  private void setupChat() {
    Log.d(TAG, "setupChat()");

    // Initialize the array adapter for the conversation thread
    mConversationArrayAdapter = new ArrayAdapter<String>(this, R.layout.message);
    mConversationView = (ListView) findViewById(R.id.in);
    mConversationView.setAdapter(mConversationArrayAdapter);

    // Initialize the BluetoothChatService to perform bluetooth connections
    mChatService = new BluetoothService(this, mHandler);

    // Initialize the buffer for outgoing messages
    mOutStringBuffer = new StringBuffer("");
  }

  @Override
  public synchronized void onPause() {
    super.onPause();
    if(D) Log.e(TAG, "- ON PAUSE -");
  }

  @Override
  public void onStop() {
    super.onStop();
    if(D) Log.e(TAG, "-- ON STOP --");
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
    // Stop the Bluetooth chat services
    if (mChatService != null) mChatService.stop();
    if(D) Log.e(TAG, "--- ON DESTROY ---");
  }

  @SuppressLint("NewApi")
  private void ensureDiscoverable() {
    if(D) Log.d(TAG, "ensure discoverable");
    if (mBluetoothAdapter.getScanMode() !=
        BluetoothAdapter.SCAN_MODE_CONNECTABLE_DISCOVERABLE) {
      Intent discoverableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE);
      discoverableIntent.putExtra(BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION, 300);
      startActivity(discoverableIntent);
    }
  }

  /**
   * Sends a message.
   * @param message  A string of text to send.
   */
  private void sendMessage(String message) {
    // Check that we're actually connected before trying anything
    if (mChatService.getState() != BluetoothService.STATE_CONNECTED) {
      Toast.makeText(this, R.string.not_connected, Toast.LENGTH_SHORT).show();
      return;
    }

    // Check that there's actually something to send
    if (message.length() > 0) {
      // Get the message bytes and tell the BluetoothChatService to write
      message = ";" + message + ";";
      byte[] send = message.getBytes();
      mChatService.write(send);

      // Reset out string buffer to zero and clear the edit text field
      mOutStringBuffer.setLength(0);
    }
  }

  // The action listener for the EditText widget, to listen for the return key
  @SuppressLint("NewApi")
  private TextView.OnEditorActionListener mWriteListener =
  new TextView.OnEditorActionListener() {
  public boolean onEditorAction(TextView view, int actionId, KeyEvent event) {
    // If the action is a key-up event on the return key, send the message
    if (actionId == EditorInfo.IME_NULL && event.getAction() == KeyEvent.ACTION_UP) {
      String message = view.getText().toString();
      sendMessage(message);
    }
    if(D) Log.i(TAG, "END onEditorAction");
    return true;
  }
};

@SuppressLint("NewApi")
private final void setStatus(int resId) {
final ActionBar actionBar = getActionBar();
if(actionBar!= null)
actionBar.setSubtitle(resId);
}

@SuppressLint("NewApi")
private final void setStatus(CharSequence subTitle) {
final ActionBar actionBar = getActionBar();
if(actionBar!= null)
actionBar.setSubtitle(subTitle);
}


// The Handler that gets information back from the BluetoothChatService
private final Handler mHandler = new Handler() {
@Override
public void handleMessage(Message msg) {
  switch (msg.what) {
    case MESSAGE_STATE_CHANGE:
      if(D) Log.i(TAG, "MESSAGE_STATE_CHANGE: " + msg.arg1);
      switch (msg.arg1) {
        case BluetoothService.STATE_CONNECTED:
          setStatus(getString(R.string.title_connected_to, mConnectedDeviceName));
          mConversationArrayAdapter.clear();
          break;
        case BluetoothService.STATE_CONNECTING:
          setStatus(R.string.title_connecting);
          break;
        case BluetoothService.STATE_LISTEN:
        case BluetoothService.STATE_NONE:
          setStatus(R.string.title_not_connected);
          break;
      }
      break;
    case MESSAGE_WRITE:
      byte[] writeBuf = (byte[]) msg.obj;
      // construct a string from the buffer
      String writeMessage = new String(writeBuf);
      mConversationArrayAdapter.add("Me:  " + writeMessage);
      break;
    case MESSAGE_READ:
      String readBuf =  (String) msg.obj;
      // construct a string from the valid bytes in the buffer
      mConversationArrayAdapter.add(mConnectedDeviceName+":  " + readBuf);
      //byte[] readBuf = (byte[]) msg.obj;
      // construct a string from the valid bytes in the buffer
      //String readMessage = new String(readBuf, 0, msg.arg1);
      //mConversationArrayAdapter.add(mConnectedDeviceName+":  " + readMessage);
      break;
    case MESSAGE_DEVICE_NAME:
    // save the connected device's name
      mConnectedDeviceName = msg.getData().getString(DEVICE_NAME);
      Toast.makeText(getApplicationContext(), "Connected to "
          + mConnectedDeviceName, Toast.LENGTH_SHORT).show();
      break;
    case MESSAGE_TOAST:
      Toast.makeText(getApplicationContext(), msg.getData().getString(TOAST),
          Toast.LENGTH_SHORT).show();
      break;
  }
}
};

public void onActivityResult(int requestCode, int resultCode, Intent data) {
  if(D) Log.d(TAG, "onActivityResult " + resultCode);
  switch (requestCode) {
    case REQUEST_CONNECT_DEVICE_SECURE:
    // When DeviceListActivity returns with a device to connect
      if (resultCode == Activity.RESULT_OK) {
        connectDevice(data, true);
      }
      break;

    case REQUEST_ENABLE_BT:
    // When the request to enable Bluetooth returns
      if (resultCode == Activity.RESULT_OK) {
        // Bluetooth is now enabled, so set up a chat session
        setupChat();
      } else {
        // User did not enable Bluetooth or an error occurred
        Log.d(TAG, "BT not enabled");
        Toast.makeText(this, R.string.bt_not_enabled_leaving, Toast.LENGTH_SHORT).show();
        finish();
      }
  }
}

@SuppressLint("NewApi")
private void connectDevice(Intent data, boolean secure) {
  // Get the device MAC address
  String address = data.getExtras()
      .getString(DeviceListActivity.EXTRA_DEVICE_ADDRESS);
  // Get the BluetoothDevice object
  BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(address);
  // Attempt to connect to the device
  mChatService.connect(device, secure);
}

@Override
public boolean onCreateOptionsMenu(Menu menu) {
  MenuInflater inflater = getMenuInflater();
  inflater.inflate(R.menu.option_menu, menu);
  return true;
}

@Override
public boolean onOptionsItemSelected(MenuItem item) {
  Intent serverIntent = null;
  switch (item.getItemId()) {
    case R.id.secure_connect_scan:
    // Launch the DeviceListActivity to see devices and do scan
      serverIntent = new Intent(this, DeviceListActivity.class);
      startActivityForResult(serverIntent, REQUEST_CONNECT_DEVICE_SECURE);
      return true;
    case R.id.discoverable:
    // Ensure this device is discoverable by others
      ensureDiscoverable();
      return true;
  }
  return false;
}

}
