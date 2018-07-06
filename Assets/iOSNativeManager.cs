using NTCore;
using Rg;
using System;
using System.Runtime.InteropServices;
using UnityEngine;

/// <summary>
/// iOS 빌드용 네이티브 매니저
/// </summary>
public class iOSNativeManager : MonoBehaviour
{	
	#region Unity Call

	void Awake()
	{		
		Log.Write("{0} Awake()", this.gameObject.name);
	}

	void Start()
	{        
        Log.Write("{0} Start()", this.gameObject.name);
	}

    #endregion
    //==========================================================================================
    #region Local Notification

    public void InitNotification()
    {
        UnityEngine.iOS.NotificationServices.RegisterForNotifications(
            UnityEngine.iOS.NotificationType.Alert |
            UnityEngine.iOS.NotificationType.Badge |
            UnityEngine.iOS.NotificationType.Sound);
    }

    public void SetNotification(string title, string body, double second)
    {
        UnityEngine.iOS.LocalNotification noti = new UnityEngine.iOS.LocalNotification();
        noti.alertAction = title;
        noti.alertBody = body;
        noti.soundName = UnityEngine.iOS.LocalNotification.defaultSoundName;
        noti.applicationIconBadgeNumber = 1;
        noti.fireDate = System.DateTime.Now.AddSeconds(second);
        UnityEngine.iOS.NotificationServices.ScheduleLocalNotification(noti);
    }

    public void CancelAllNotification()
    {        
        UnityEngine.iOS.NotificationServices.ClearLocalNotifications();
        UnityEngine.iOS.NotificationServices.CancelAllLocalNotifications();
    }    

    #endregion
    //==========================================================================================
    #region Camera

    /// <summary>
    /// 현재 화면을 캡쳐하여 스크린샷으로 만든다.
    /// iOS에서는 info.plist에 NSPhotoLibraryUsageDescription 항목을 추가해야 CameraRoll에 접근가능하다.
    /// Unity Application.CaptureScreenshot()을 통해 저장된 스크린샷 이미지는 Document에 저장되며,
    /// extern 메소드를 통해서 iPhone의 CameraRoll으로 복사 저장된다.
    /// </summary>
    public void CaptureScreenShot()
	{
#if !UNITY_EDITOR && UNITY_IOS
		string today = DateTime.Now.ToString("yyMMddHHmmss");
		string saveFilename = string.Format("Screenshot_{0}.png", today);

		try
		{
			Application.CaptureScreenshot(saveFilename);
			CaptureToCameraRoll(saveFilename);
			Log.Write("Save Capture PNG image to Camera Roll");
		}
		catch (Exception ex)
		{
			Log.WriteError(ex.Message);
		}
#endif
    }

    public void SaveTextureToCameraRoll(Texture2D texture, string name = "ScreenShot")
	{
#if UNITY_IOS && !UNITY_EDITOR
        if(texture != null) {
            byte[] val = texture.EncodeToPNG();
            string bytesString = System.Convert.ToBase64String (val);
            SaveToCameraRoll(bytesString);
        } 
#endif
    }

    #endregion
    //==========================================================================================
    #region Utils

    public static string GetCFBundleVersion()
	{
		return Marshal.PtrToStringAnsi(getCFBundleVersion());
	}

    private System.Collections.Generic.Queue<System.Action<string>> _networkStateQueue = null;
    public void CheckNetworkState(System.Action<string> callback)
    {        
        if (_networkStateQueue == null)
            _networkStateQueue = new System.Collections.Generic.Queue<Action<string>>();

        _networkStateQueue.Enqueue(callback);

        CheckStartReachability();
    }

    public void CopyToClipboardText(string t)
    {        
        CopyToClipboard(t);
    }
        
    public static string GetAppGuardUUID()
    {
        return Marshal.PtrToStringAnsi(getAppGuardUUID());
    }
    
    public static string GetDeepLinkURL()
    {
        return Marshal.PtrToStringAnsi(getDeeplinkURL());
    }
    
    public static string GetDocumentDirectoryPath(string targetPath)
    {
        return Marshal.PtrToStringAnsi(getDocumentDirectoryPath(targetPath));
    }
        
    #endregion
    //==========================================================================================
    #region Objective-C Extern

    // iOS Native Code를 사용하기 위한 Unity iOS Plugin Methods

    [DllImport("__Internal")]
	public static extern void CaptureToCameraRoll(string fileName);

	[DllImport("__Internal")]
	public static extern void SaveToCameraRoll(string media);
	
	[DllImport("__Internal")]
	public static extern void CheckStartReachability();

	[DllImport("__Internal")]
	private static extern System.IntPtr getCFBundleVersion();

    [DllImport("__Internal")]
    public static extern void CopyToClipboard(string t);

    [DllImport("__Internal")]
    public static extern string PasteFromClipboard();

    [DllImport("__Internal")]
    public static extern bool receiveUserID(string userid);

    [DllImport("__Internal")]
    public static extern System.IntPtr getAppGuardUUID();

    [DllImport("__Internal")]
    public static extern System.IntPtr getDeeplinkURL();
    
    [DllImport("__Internal")]
    public static extern int getDeviceGroup();
    
    [DllImport("__Internal")]
    public static extern System.IntPtr getDocumentDirectoryPath(string path);

    [DllImport("__Internal")]
    public static extern bool getIsIphone();

    #endregion
    //==========================================================================================
    #region Native Callback

    // iOS Native Code에서 Unity로 값을 전달하기 위해 UnitySendMessage()로 보내는 콜백

    private void OnReachabilityChanged(string val)
	{
        // NotReachable, WiFi, WWAN
        
        string result = "Disconnected";

        if (val.Equals("NotReachable"))
        {
            result = "Disconnected";
        }
        else if (val.Equals("WiFi"))
        {
            result = "Wifi";
        }
        else
        {
            result = "Data";
        }

        if (_networkStateQueue != null && _networkStateQueue.Count > 0)
        {
            System.Action<string> _checkNetworkCallback = _networkStateQueue.Dequeue();

            if (_checkNetworkCallback != null)
            {
                _checkNetworkCallback(result);

                if (previousState != result)
                    Log.Write("OnReachabilityChanged : {0}", val);

                previousState = result;
                _checkNetworkCallback = null;
            }
            else
            {
                Rg.Log.WriteError("CheckNetworkCallback is NULL");
            }
        }
        else
        {
            Rg.Log.WriteError("CheckNetworkCallback Queue is NULL");
        }

    }

    //private void OnDeepLinkCallback(string val)
    //{
    //    Log.Write("Received Deeplink : {0}", val);
    //}

	#endregion
}