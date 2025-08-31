/**
 * This file is a part of media_kit (https://github.com/media-kit/media-kit).
 * <p>
 * Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 * All rights reserved.
 * Use of this source code is governed by MIT license that can be found in the LICENSE file.
 */
package com.alexmercerind.media_kit_video;

import androidx.annotation.NonNull;
import android.app.Activity;
import android.app.PictureInPictureParams;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Rational;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * MediaKitVideoPlugin
 */
public class MediaKitVideoPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private MethodChannel channel;
    private VideoOutputManager videoOutputManager;
    private Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.alexmercerind/media_kit_video");
        channel.setMethodCallHandler(this);

        videoOutputManager = new VideoOutputManager(flutterPluginBinding.getTextureRegistry());

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "VideoOutputManager.Create": {
                final long handle = Long.parseLong(call.argument("handle"));
                videoOutputManager.create(handle, (id, wid, width, height) -> channel.invokeMethod("VideoOutput.Resize", new HashMap<String, Object>() {{
                    put("handle", handle);
                    put("id", id);
                    put("wid", wid);
                    put("rect", new HashMap<String, Object>() {{
                        put("left", 0);
                        put("top", 0);
                        put("width", width);
                        put("height", height);
                    }});
                }}));
                result.success(null);
                break;
            }
            case "VideoOutputManager.SetSurfaceSize": {
                final long handle = Long.parseLong(call.argument("handle"));
                final int width = Integer.parseInt(call.argument("width"));
                final int height = Integer.parseInt(call.argument("height"));
                videoOutputManager.setSurfaceSize(handle, width, height);
                result.success(null);
                break;
            }
            case "VideoOutputManager.Dispose": {
                final long handle = Long.parseLong(call.argument("handle"));
                videoOutputManager.dispose(handle);
                result.success(null);
                break;
            }
            case "Utils.IsEmulator": {
                result.success(Utils.isEmulator());
                break;
            }
            case "enterPictureInPicture": {
                if (activity != null) {
                    result.success(enterPictureInPicture());
                } else {
                    result.success(false);
                }
                break;
            }
            case "exitPictureInPicture": {
                if (activity != null) {
                    result.success(exitPictureInPicture());
                } else {
                    result.success(false);
                }
                break;
            }
            case "isInPictureInPictureMode": {
                if (activity != null) {
                    result.success(isInPictureInPictureMode());
                } else {
                    result.success(false);
                }
                break;
            }
            case "isPictureInPictureSupported": {
                result.success(isPictureInPictureSupported());
                break;
            }
            default: {
                result.notImplemented();
                break;
            }
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        // Activity is being detached due to a configuration change
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }

    /**
     * Enter Picture in Picture mode
     */
    private boolean enterPictureInPicture() {
        if (!isPictureInPictureSupported() || activity == null) {
            return false;
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                PictureInPictureParams.Builder paramsBuilder = new PictureInPictureParams.Builder();
                
                // Set aspect ratio (16:9 is common for video)
                paramsBuilder.setAspectRatio(new Rational(16, 9));
                
                // Enter PiP mode
                return activity.enterPictureInPictureMode(paramsBuilder.build());
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                // For API 24-25, use the deprecated method
                return activity.enterPictureInPictureMode();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Exit Picture in Picture mode
     */
    private boolean exitPictureInPicture() {
        if (activity != null && isInPictureInPictureMode()) {
            try {
                // Move task to front to exit PiP
                activity.moveTaskToBack(false);
                return true;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return false;
    }

    /**
     * Check if currently in Picture in Picture mode
     */
    private boolean isInPictureInPictureMode() {
        if (activity == null) {
            return false;
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            return activity.isInPictureInPictureMode();
        }
        
        return false;
    }

    /**
     * Check if Picture in Picture is supported on this device
     */
    private boolean isPictureInPictureSupported() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            return false;
        }
        
        try {
            return activity != null && 
                   activity.getPackageManager().hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
