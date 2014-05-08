package 
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.core.GestureWorks;
	import flash.desktop.*;
	import flash.desktop.NativeApplication;
	import flash.display.*;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.text.TextField;
	import flash.utils.Timer;
	import images.OESplash;
	
	[SWF(width = "1280", height = "720", backgroundColor = "0x000000", frameRate = "60")]
	
	/**
	 * The Open Exhibits Player
	 * @author Charles
	 */	 
	public class OpenExhibits extends Sprite
	{
		[Embed(source="../design/oe-splash.png")]
		public var SplashImage:Class;		
		
		private var isLoaded:Boolean = false;
		private var mainWindow:NativeWindow;
		private var splashTimer:Timer;
		
		private var splashWindow:NativeWindow;
		private var appSplash:OESplash;
		
		private var debug:Boolean = false;
		private var log:TextField;		
						
		private var gw:GestureWorks;
		private var key:String = "cl3ar";
		private var nativeMenu:NativeMenu
        private var fileMenu:NativeMenuItem; 
		private var file:File;
        private var recentdocuments:Array = new Array(new File("app-storage:/GreatGatsby.pdf"), new File("app-storage:/WarAndPeace.pdf"), new File("app-storage:/Iliad.pdf"));
					 
			 
		public function OpenExhibits() 
		{
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);			
			
			splashTimer = new Timer(5000, 1);
			splashTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			splashTimer.start();
			
			
			if (NativeWindow.supportsMenu){ 
                stage.nativeWindow.menu = new NativeMenu(); 
                stage.nativeWindow.menu.addEventListener(Event.SELECT, selectCommandMenu); 
                fileMenu = stage.nativeWindow.menu.addItem(new NativeMenuItem("File")); 
                fileMenu.submenu = createFileMenu();  
            } 
             
            if (NativeApplication.supportsMenu){ 
                NativeApplication.nativeApplication.menu.addEventListener(Event.SELECT, selectCommandMenu); 
                fileMenu = NativeApplication.nativeApplication.menu.addItem(new NativeMenuItem("File")); 
                fileMenu.submenu = createFileMenu(); 
            }
			
			
			mainWindow = this.stage.nativeWindow;
		 
			var splashWindowinitOptions:NativeWindowInitOptions= new NativeWindowInitOptions();
			splashWindowinitOptions.transparent = true;
			splashWindowinitOptions.systemChrome = NativeWindowSystemChrome.NONE;
			splashWindowinitOptions.type = NativeWindowType.UTILITY;
			splashWindowinitOptions.renderMode = NativeWindowRenderMode.AUTO;
		 
			splashWindow = new NativeWindow(splashWindowinitOptions);
			splashWindow.title = "Splash";
		 
			appSplash = new OESplash();
			splashWindow.stage.addChild(appSplash);
			splashWindow.stage.removeChild(appSplash);
		 
			splashWindow.stage.scaleMode = 'noScale';
			splashWindow.stage.align = 'topLeft';
			splashWindow.stage.addChild(appSplash);
			splashWindow.x = Screen.mainScreen.visibleBounds.width/2 - 425;
			splashWindow.y = Screen.mainScreen.visibleBounds.height/2 - 263.5;
			splashWindow.width = 850;
			splashWindow.height = 527;
			splashWindow.activate();
		 
			mainWindow.visible = false;	
			
			if (debug)
				createLog();			
		}	
		
	
		
		private function onTimerComplete(e:TimerEvent):void
		{
			isLoaded = true;
			removeSplash();
			
			//logEvent("isLoaded " +  isLoaded);
			//logEvent("invokedFileEvent " + invokedFileEvent);
			
			if (invokedFileEvent) {			
				CMLParser.rootDirectory = invokedFileEvent.currentDirectory.url.concat("/");
				
				if (debug) 
					logEvent("CMLParser.rootDirectory: " + CMLParser.rootDirectory);
				
				CMLParser.relativePaths = true;
				gw = new GestureWorks(invokedFileEvent.arguments[0], invokedFileEvent.arguments[1]);
				gw.key = key;
				addChild(gw);
			}
		}


		private function removeSplash():void 
		{
			mainWindow.x = Screen.mainScreen.visibleBounds.width/2 - mainWindow.width/2;
			mainWindow.y = Screen.mainScreen.visibleBounds.height/2 - mainWindow.height/2;
		 
			mainWindow.visible = true;
			mainWindow.activate();
		 
			splashWindow.stage.removeChild(appSplash);
			splashWindow.close();
			splashWindow = null;
		 
			splashTimer.stop();
			splashTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, removeSplash);
			splashTimer = null;
		}		
	
		
		
		public function createLog():void 
		{
			log = new TextField();  
            log.width = 1280; 
            log.height = 300; 
            log.background = true;
            addChild(log);			
		}
		
		public function browser():void 
		{
            file = new File();
            file.addEventListener(Event.SELECT, onFileSelect);
            file.browseForOpen("Select CML file");
        }

		public function onFileSelect(e:Event):void
		{
			var fileDir:String = file.url;			
			var rootPath:String = fileDir.replace(file.name, "");				
			CMLParser.rootDirectory = rootPath;
			CMLParser.relativePaths = true;			
			gw = new GestureWorks("library/gestures.gml", file.nativePath);
			addChild(gw);			
		}
		
		
		private var invokedFileEvent:InvokeEvent;
		public function onInvoke(e:InvokeEvent):void
		{
			if (!isLoaded)
				invokedFileEvent = e;
			else {	
				CMLParser.rootDirectory = e.currentDirectory.url.concat("/");
				
				if (debug) 
					logEvent("CMLParser.rootDirectory: " + CMLParser.rootDirectory);
				
				CMLParser.relativePaths = true;
				gw = new GestureWorks(e.arguments[0]);
				gw.key = key;
				addChild(gw);				
			}
				
		}		
		
		
        public function logEvent(entry:String):void  
        { 
            log.appendText(entry + "\n"); 
        } 

         public function createFileMenu():NativeMenu 
		 { 
            var fileMenu:NativeMenu = new NativeMenu(); 
            fileMenu.addEventListener(Event.SELECT, selectCommandMenu); 
             
            var newCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Open")); 
            newCommand.addEventListener(Event.SELECT, selectCommand); 
			
			
			/*
            var newCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Close")); 
            newCommand.addEventListener(Event.SELECT, selectCommand); 
			*/
			
			
            var newCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Exit")); 
            newCommand.addEventListener(Event.SELECT, selectCommand); 
			
			
			/*
			var openRecentMenu:NativeMenuItem =  
                    fileMenu.addItem(new NativeMenuItem("Open Recent"));  
            openRecentMenu.submenu = new NativeMenu(); 
            openRecentMenu.submenu.addEventListener(Event.DISPLAYING, 
                                            updateRecentdocumentMenu); 
            openRecentMenu.submenu.addEventListener(Event.SELECT, selectCommandMenu); 
			*/
			
			
            return fileMenu; 
        } 
         
		
        public function createEditMenu():NativeMenu { 
            var editMenu:NativeMenu = new NativeMenu(); 
            editMenu.addEventListener(Event.SELECT, selectCommandMenu); 
             
            var copyCommand:NativeMenuItem = editMenu.addItem(new NativeMenuItem("Copy")); 
            copyCommand.addEventListener(Event.SELECT, selectCommand); 
            copyCommand.keyEquivalent = "c"; 
            var pasteCommand:NativeMenuItem =  
                    editMenu.addItem(new NativeMenuItem("Paste")); 
            pasteCommand.addEventListener(Event.SELECT, selectCommand); 
            pasteCommand.keyEquivalent = "v"; 
            editMenu.addItem(new NativeMenuItem("", true)); 
            var preferencesCommand:NativeMenuItem =  
                    editMenu.addItem(new NativeMenuItem("Preferences")); 
            preferencesCommand.addEventListener(Event.SELECT, selectCommand); 
             
            return editMenu; 
        }
		
		
        private function updateRecentdocumentMenu(event:Event):void { 
          //  trace("Updating recent document menu."); 
            var docMenu:NativeMenu = NativeMenu(event.target); 
             
            for each (var item:NativeMenuItem in docMenu.items) { 
                docMenu.removeItem(item); 
            } 
         
        } 
        
		
        private function selectRecentdocument(event:Event):void { 
           // trace("Selected recent document: " + event.target.data.name); 
        } 
        
		
        private function selectCommand(event:Event):void 
		{ 
            if (debug) 
				trace("Selected command: " + event.target.label); 
			
			if (event.target.label == "Open") {
				this.browser();
			}	
			else if (event.target.label == "Close") {
				dispose();
			}
			else if (event.target.label == "Exit") {
				 NativeApplication.nativeApplication.exit();
			}			

        } 
 
		
		private function dispose():void
		{
			var arr:Array = CMLObjectList.instance.getValueArray();
			for (var j:int = 0; j < arr.length; j++){
				arr[j].dispose();
			}						
			
 			//for (var i:int = 0; i < gw.cmlDisplays.length; i++) {
				//if (gw.contains(gw.cmlDisplays[i]))
				//gw.removeChild(gw.cmlDisplays[i]);
			//}
			//
			//gw.cmlDisplays = null;
			removeChild(gw);
			gw = null;
			
			CMLParser.rootDirectory = "";
			CMLParser.relativePaths = true;		
		}
		
		
		
        private function selectCommandMenu(event:Event):void { 
            if (event.currentTarget.parent != null) { 
                var menuItem:NativeMenuItem = 
                        findItemForMenu(NativeMenu(event.currentTarget)); 
                if (menuItem != null) { 
                    trace("Select event for \"" +  
                            event.target.label +  
                            "\" command handled by menu: " +  
                            menuItem.label); 
                } 
            } else { 
                trace("Select event for \"" +  
                        event.target.label +  
                        "\" command handled by root menu."); 
            } 
        } 
         
        private function findItemForMenu(menu:NativeMenu):NativeMenuItem { 
            for each (var item:NativeMenuItem in menu.parent.items) { 
                if (item != null) { 
                    if (item.submenu == menu) { 
                        return item; 
                    } 
                } 
            } 
            return null; 
        } 
    } 		

}