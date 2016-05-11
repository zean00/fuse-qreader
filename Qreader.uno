using Uno;
using Uno.Collections;
using Fuse.Scripting;
using Fuse.Reactive;
using Fuse;
using Uno.Compiler.ExportTargetInterop;
using Uno.Threading;

public class Qreader : NativeModule {
	public Qreader () {
		// Add Load function to load image as a texture
		AddMember(new NativePromise<string, string>("scan", (FutureFactory<string>)Scan,null));
	}

	static Future<string> Scan(object[] args)
	{
		//var path = Uno.IO.Path.Combine(Uno.IO.Directory.GetUserDirectory(Uno.IO.UserDirectory.Data), "temp.jpg");
			return QreaderImpl.Scan();
	}

}

/*
[ForeignInclude(Language.Java,
                "android.app.Activity",
                "android.content.Intent",
                "android.net.Uri",
                "android.os.Bundle",
                "android.provider.MediaStore",
                "java.io.InputStream",
                "java.io.FileOutputStream",
                "java.io.File")]
																*/
[ForeignInclude(Language.ObjC, "QreaderTask.h", "QRCodeReaderViewController.h","QRCodeReader.h")]
public class QreaderImpl
{
	static int BAD_ID = 1234;

	static bool InProgress {
		get; set;
	}

	static Promise<string> FutureResult {
		get; set;
	}
	/*
	static extern(Android) Java.Object _intentListener;
	*/
	public static Future<string> Scan() {
		if (InProgress) {
			return null;
		}
		InProgress = true;
		if defined(Android) {
			 if (_intentListener == null)
				_intentListener = Init();
		}
		ScannerImpl();
		FutureResult = new Promise<string>();
		return FutureResult;
	}
	/*
	[Foreign(Language.Java)]
	static extern(Android) Java.Object Init()
	@{
	    com.fuse.Activity.ResultListener l = new com.fuse.Activity.ResultListener() {
	        @Override public boolean onResult(int requestCode, int resultCode, android.content.Intent data) {
	            return @{OnRecieved(int,int,Java.Object):Call(requestCode, resultCode, data)};
	        }
	    };
	    com.fuse.Activity.subscribeToResults(l);
	    return l;
	@}

	[Foreign(Language.Java)]
	static extern(Android) bool OnRecieved(int requestCode, int resultCode, Java.Object data)
	@{
		debug_log("Got resultCode " + resultCode);
		debug_log("(Okay is: " + Activity.RESULT_OK);

	    if (requestCode == @{BAD_ID}) {
	    	if (resultCode == Activity.RESULT_OK) {
	    		Intent i = (Intent)data;

	    		Activity a = com.fuse.Activity.getRootActivity();

	    		// File outFile = new File(@{Path});
	    		// http://stackoverflow.com/questions/10854211/android-store-inputstream-in-file
	    		try {
	    			FileOutputStream output = new FileOutputStream(@{Path:Get()});
	    			InputStream input = a.getContentResolver().openInputStream(i.getData());

	    			byte[] buffer = new byte[4 * 1024]; // or other buffer size
	    			int read;

	    			while ((read = input.read(buffer)) != -1) {
	    			    output.write(buffer, 0, read);
	    			}
	    			output.flush();
	    			output.close();
	    			input.close();
	    		    debug_log("And it's ours!, and done");
	    		    @{Picked():Call()};
	    		} catch (Exception e) {
	    		    e.printStackTrace(); // handle exception, define IOException and others
	    		    @{Cancelled():Call()};

	    		}
	    	}
	    	else {
	    		@{Cancelled():Call()};
	    	}

	    }

	    return (requestCode == @{BAD_ID});
	@}
*/
	static extern(!Mobile) void ScannerImpl () {
		throw new Fuse.Scripting.Error("Unsupported platform");
	}
	/*
	[Foreign(Language.Java)]
	static extern(Android) void GetPictureImpl ()
	@{
		Activity a = com.fuse.Activity.getRootActivity();
		// Intent intent = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
		Intent intent = new Intent();
		intent.setType("image/*");
		intent.setAction(Intent.ACTION_GET_CONTENT);
		a.startActivityForResult(intent, @{BAD_ID});

		// http://stackoverflow.com/questions/5309190/android-pick-images-from-gallery
	@}
	*/
	[Require("Entity","QreaderImpl.Cancelled()")]
	[Require("Entity","QreaderImpl.Picked(string)")]
	[Foreign(Language.ObjC)]
	static extern(iOS) void ScannerImpl ()
	@{
			QreaderTask *task = [[QreaderTask alloc] init];

			static QRCodeReaderViewController *vc = nil;
			static dispatch_once_t onceToken;

			UIViewController *uivc = [UIApplication sharedApplication].keyWindow.rootViewController;
			[task setUivc:uivc];

			dispatch_once(&onceToken, ^{
					QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
					vc                   = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader];
					vc.modalPresentationStyle = UIModalPresentationFormSheet;
			});

			vc.delegate = task;

			[uivc
				presentViewController:vc
				animated:YES
				completion:nil];
	@}

	public static void Cancelled () {
		InProgress = false;
		FutureResult.Reject(new Exception("User cancelled the qr scanner"));
	}

	public static void Picked (string result) {
		InProgress = false;
		FutureResult.Resolve(result);
	}

}
