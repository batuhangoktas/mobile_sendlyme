package com.batuhan.sendlyme;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.webkit.MimeTypeMap;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Random;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "external";
  private String sharedText;
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      if (checkSelfPermission(
              Manifest.permission.WRITE_EXTERNAL_STORAGE)
              != PackageManager.PERMISSION_GRANTED) {

        // Should we show an explanation?
        if (shouldShowRequestPermissionRationale(
                Manifest.permission.WRITE_EXTERNAL_STORAGE)) {

          // Show an explanation to the user *asynchronously* -- don't block
          // this thread waiting for the user's response! After the user
          // sees the explanation, try again to request the permission.

        } else {

          // No explanation needed, we can request the permission.

          requestPermissions(
                  new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},
                  0);

          // MY_PERMISSIONS_REQUEST_SEND_SMS is an
          // app-defined int constant. The callback method gets the
          // result of the request.
        }
      }
    }
    GeneratedPluginRegistrant.registerWith(this);
    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {

              }
            });

    GeneratedPluginRegistrant.registerWith(this);
    Intent intent = getIntent();
    String action = intent.getAction();
    String type = intent.getType();

    if (Intent.ACTION_SEND.equals(action) && type != null) {
      Log.e("Info","Content1"+type);
        handleSendText(intent); // Handle text being sent
    }

    new MethodChannel(getFlutterView(), "app.channel.shared.data").setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                Log.e("Info","sharedText11"+sharedText);
                if (call.method.contentEquals("getSharedText")) {
                  result.success(sharedText);
                  sharedText = null;
                }
              }
            });

    new MethodChannel(getFlutterView(), "com.batuhan.sendly.mediascan").setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                Log.e("Info","Media"+call.argument("filePath"));

                try {
                  MediaScannerConnection.scanFile(getApplicationContext(),
                          new String[] { call.argument("filePath") }, null,
                          new MediaScannerConnection.OnScanCompletedListener() {
                            public void onScanCompleted(String path, Uri uri) {
                              Log.i("ExternalStorage", "Scanned " + path + ":");
                              Log.i("ExternalStorage", "-> uri=" + uri);
                            }
                          });
                  result.success(1);
                }
                catch (Exception e)
                {
                  result.success(0);
                }

              }
            });
  }

  void handleSendText(Intent intent) {

    Uri uri =   intent.getParcelableExtra(android.content.Intent.EXTRA_STREAM);
    try {
      String[] filePathColumn = { MediaStore.Images.Media.DATA };
      Cursor cursor = getContentResolver().query(uri, filePathColumn, null, null, null);
      cursor.moveToFirst();
      int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
      String filePath = cursor.getString(columnIndex);
      cursor.close();
      sharedText = filePath;
    }
    catch (Exception ex)
    {
      MimeTypeMap mime = MimeTypeMap.getSingleton();
      String mimeTypeExtension = mime.getExtensionFromMimeType(getContentResolver().getType(uri));
      File file = new File(getCacheDir(), "File_"+(new Random().nextInt(900)+100)+"."+mimeTypeExtension);
      try {
        InputStream inputStream=getContentResolver().openInputStream(uri);
        OutputStream output = new FileOutputStream(file);
        try {
          byte[] buffer = new byte[4 * 1024];
          int read;
          while ((read = inputStream.read(buffer)) != -1) {
            output.write(buffer, 0, read);
          }
          output.flush();
        } finally {
          output.close();
          sharedText = file.getAbsolutePath();
        }
      } catch (FileNotFoundException e) {
        e.printStackTrace();
        sharedText = "ERROR";
      } catch (IOException e) {
        e.printStackTrace();
      } finally {
      }
    }




  //  Log.e("Info","getDataString"+intent.getData().getPath());
  }


  @Override
  public void onRequestPermissionsResult(int requestCode,
                                         String permissions[], int[] grantResults) {
    switch (requestCode) {
      case 0: {
        // If request is cancelled, the result arrays are empty.
        if (grantResults.length > 0
                && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

          // permission was granted, yay! Do the
          // contacts-related task you need to do.

        } else {

          // permission denied, boo! Disable the
          // functionality that depends on this permission.
        }
        return;
      }

      // other 'case' lines to check for other
      // permissions this app might request.
    }
  }
}