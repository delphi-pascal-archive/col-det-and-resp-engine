//*| -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//*| GAME ENGINE
//*| ---------------------------------------------------------------------------
//*| by Georgy Moshkin
//*|
//*| email : tmtlib@narod.ru
//*| WWW   : http://www.tmtlib.narod.ru/
//*|
//*| License: Public Domain
//*| =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

unit shill;

interface

uses
  Windows,
  Messages,
  OpenGL,
  blender,
  sysutils,
  cdnr1,
  gameobj,
  render,
  camera,
  _mmtime;


(*** Start NeHeGL.h ***)

{$ifndef GL_FRAMEWORK__INCLUDED}
{$define GL_FRAMEWORK__INCLUDED}

type
  PKeys = ^TKeys;
  TKeys = record                       // Structure For Keyboard Stuff
    keyDown: array[0..255] of Boolean; // Holds TRUE / FALSE For Each Key
  end;                                 // Keys

  PApplication = ^TApplication;
  TApplication = record                // Contains Information Vital To Applications
    hInstance: HINST;                  // Application Instance
    className:  PAnsiChar;             // Application ClassName
  end;                                 // Application

  PGL_WindowInit = ^TGL_WindowInit;
  TGL_WindowInit = record              // Window Creation Info
    application:  PApplication;        // Application Structure
    title:        PAnsiChar;           // Window Title
    width:        Integer;             // Width
    height:       Integer;             // Height
    bitsPerPixel: Integer;             // Bits Per Pixel
    isFullScreen: Boolean;             // FullScreen?
  end;                                 // GL_WindowInit

  PGL_Window = ^TGL_Window;
  TGL_Window = record                  // Contains Information Vital To A Window
    keys:          PKeys;              // Key Structure
    h_Wnd:         HWND;               // Window Handle
    h_DC:          HDC;                // Device Context
    h_RC:          HGLRC;              // Rendering Context
    init:          TGL_WindowInit;     // Window Init
    isVisible:     Boolean;            // Window Visible?
    lastTickCount: DWORD;              // Tick Counter
  end;                                 // GL_Window

procedure TerminateApplication(window: PGL_Window); // Terminate The Application
procedure ToggleFullscreen(window: PGL_Window); // Toggle Fullscreen / Windowed Mode

// These Are The Function You Must Provide
function Initialize(window: PGL_Window; keys: PKeys): Boolean; // Performs All Your Initialization
procedure Deinitialize;                // Performs All Your DeInitialization
procedure Update(milliseconds: DWORD); // Perform Motion Updates
procedure Draw;                        // Perform All Your Scene Drawing

{$endif}            // GL_FRAMEWORK__INCLUDED

(*** Finish NeHeGL.h ***)

(*** Not basecode, just required to run ***)
var dmDefault: DEVMODE;
function WinMain (hInstance, hPrevInstance: HINST; lpCmdLine: PAnsiChar; nCmdShow: Integer): Integer; stdcall;
(*** Ok back to basecode ***)

const
  WM_TOGGLEFULLSCREEN = WM_USER+1;     // Application Define Message For Toggling

var
  g_isProgramLooping: Boolean;         // Window Creation Loop, For FullScreen/Windowed Toggle																		// Between Fullscreen / Windowed Mode
  g_createFullScreen: Boolean;         // If TRUE, Then Create Fullscreen

(*** Start Example.cpp ***)

  g_window: PGL_Window;
  g_keys: PKeys;

(*** Finish Example.cpp ***)

implementation

(*** Start Example.cpp ***)

function Initialize(window: PGL_Window; keys: PKeys): Boolean; // Any GL Init Code & User Initialiazation Goes Here
begin
  g_window := window;
  g_keys := keys;

  glClearColor(0.3, 0.3, 0.3, 0.5);    // Black Background
  glClearDepth(1.0);                   // Depth Buffer Setup
  glDepthFunc(GL_LEQUAL);              // The Type Of Depth Testing (Less Or Equal)
  glEnable(GL_DEPTH_TEST);             // Enable Depth Testing
  glShadeModel(GL_SMOOTH);             // Select Smooth Shading
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST); // Set Perspective Calculations To Most Accurate

	Result := True;                      // Return TRUE (Initialization Successful)
end;

procedure Deinitialize;                // Any User DeInitialization Goes Here
begin
end;

procedure Update(milliseconds: DWORD); // Perform Motion Updates Here
begin
  if g_keys^.keyDown[VK_ESCAPE] then   // Is ESC Being Pressed?
    TerminateApplication(g_window);    // Terminate The Program

	if g_keys^.keyDown[VK_F1] then       // Is F1 Being Pressed?
    ToggleFullscreen(g_window);        // Toggle Fullscreen Mode

end;



var TestLevel:TGameObj;
    Monster:TGameObj;


var ShowLayers:boolean=true;

procedure Draw;
begin

 // Если длина массива с полигонами = 0, то нужно провести загрузку:
 if length(TestLevel.Poligoni.data)=0 then
  begin
    LoadModel('.\kafe\','model.txt',TestLevel.Poligoni); // загрузка модели

    SetMinMax(FindMinMax(1,0,@TestLevel.Poligoni)+10,
              FindMinMax(1,1,@TestLevel.Poligoni)+10);

     repeat
      glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
      glLoadIdentity();
      BeforeRender;
      RenderModel(@TestLevel.poligoni); // true - значит разрешили рисовать закорючку
     until AfterRender;
    SetPerspMode(640,480);

   MakeCollisionCircle(TestCircle,(KRUG_W-1));

   glEnable(GL_CULL_FACE);

   MMTimeAlloc;

  end;


 // Очистка экрана

 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
 glLoadIdentity();


 CameraElapsed:=mmtimeElapsed;

 if CameraElapsed>100 then CameraElapsed:=100;
 CollisionElapsed:=CameraElapsed;


 // ставим камеру в нужное место
 With Monster do
  SetThirdPersonCamera(x,
                       ySCREEN,
                       z,
                       phi);

// рендерим модель
 RenderModel(@TestLevel.poligoni); // true - значит разрешили рисовать закорючку


  if g_keys^.keyDown[VK_UP] then  // ВПЕРЁД
   begin
    Monster.x:=Monster.x+(0.022*CameraElapsed)*sin(Monster.phi*3.14/180);
    Monster.z:=Monster.z+(0.022*CameraElapsed)*cos(Monster.phi*3.14/180);
   end;

  if g_keys^.keyDown[VK_DOWN] then  // НАЗАД
   begin
    Monster.x:=Monster.x-(0.022*CameraElapsed)*sin(Monster.phi*3.14/180);
    Monster.z:=Monster.z-(0.022*CameraElapsed)*cos(Monster.phi*3.14/180);
   end;

  if g_keys^.keyDown[VK_LEFT] then  // ПОВОРОТ ВЛЕВО
   with Monster do
    phi:=phi+10*(0.022*CameraElapsed);

  if g_keys^.keyDown[VK_RIGHT] then  // ПОВОРОТ ВПРАВО
   with Monster do
    phi:=phi-10*(0.022*CameraElapsed);

  if g_keys^.keyDown[VK_SPACE] then  // ПОКАЗАТЬ ПОДСКАЗКУ ПО АЛГОРИТМУ
   begin
    ShowLayers:=not ShowLayers;
    sleep(250);
   end;


  // запускаем движок проверки столкновений
  DoCollisionEngine(TestCircle,
                    Monster.x,
                    Monster.y,
                    Monster.ySCREEN,
                    Monster.z);


  With Monster do
   RenderObject(x,y,ySCREEN,z,phi);

  if ShowLayers then
   ShowCollisionOpenGL(Monster.y);

 
 glFlush();
end;

(*** Finish Example.cpp ***)

procedure TerminateApplication(window: PGL_Window); // Terminate The Application
begin
  PostMessage(window^.h_Wnd, WM_QUIT, 0, 0);        // Send A WM_QUIT Message
  g_isProgramLooping := FALSE;                      // Stop Looping Of The Program
end;

procedure ToggleFullscreen (window: PGL_Window);    // Toggle Fullscreen/Windowed
begin
  PostMessage (window^.h_Wnd, WM_TOGGLEFULLSCREEN, 0, 0); // Send A WM_TOGGLEFULLSCREEN Message
end;

procedure ReshapeGL(width, height: Integer); // Reshape The Window When It's Moved Or Resized
begin
  glViewport(0, 0, width, height);           // Reset The Current Viewport
  glMatrixMode(GL_PROJECTION);               // Select The Projection Matrix
  glLoadIdentity();                          // Reset The Projection Matrix
  gluPerspective(45.0, width/height,         // Calculate The Aspect Ratio Of The Window
                 1.0, 1000.0);

  glMatrixMode(GL_MODELVIEW);                // Select The Modelview Matrix
  glLoadIdentity();                          // Reset The Modelview Matrix
end;

function ChangeScreenResolution (width, height, bitsPerPixel: Integer): Boolean; // Change The Screen Resolution
var
  dmScreenSettings: DEVMODE;                        // Device Mode
begin
  Result := False;                                  // Display Change Failed, Return False
  ZeroMemory (@dmScreenSettings, SizeOf(DEVMODE));  // Make Sure Memory Is Cleared
  dmScreenSettings.dmSize       := SizeOf(DEVMODE); // Size Of The Devmode Structure
  dmScreenSettings.dmPelsWidth  := width;           // Select Screen Width
  dmScreenSettings.dmPelsHeight := height;          // Select Screen Height
  dmScreenSettings.dmBitsPerPel := bitsPerPixel;    // Select Bits Per Pixel
  dmScreenSettings.dmFields     := DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT;
  if ChangeDisplaySettings(dmScreenSettings, CDS_FULLSCREEN) = DISP_CHANGE_SUCCESSFUL then
    Result := True;                                 // Display Change Was Successful, Return True
end;

function CreateWindowGL(window: PGL_Window): Boolean; // This Code Creates Our OpenGL Window
var
  windowStyle: DWORD;
  windowExtendedStyle: DWORD;
  pfd: PIXELFORMATDESCRIPTOR;
  windowRect: TRect;
  PixelFormat: Integer;                      // Will Hold The Selected Pixel Format
begin
  Result := False;
  windowStyle := WS_OVERLAPPEDWINDOW;        // Define Our Window Style
  windowExtendedStyle := WS_EX_APPWINDOW;    // Define The Window's Extended Style

  with pfd do begin                          // pfd Tells Windows How We Want Things To Be
    nSize           := SizeOf(PIXELFORMATDESCRIPTOR); // Size Of This Pixel Format Descriptor
    nVersion        := 1;                    // Version Number
    dwFlags         := PFD_DRAW_TO_WINDOW or // Format Must Support Window
                       PFD_SUPPORT_OPENGL or // Format Must Support OpenGL
                       PFD_DOUBLEBUFFER;     // Must Support Double Buffering
    iPixelType      := PFD_TYPE_RGBA;        // Request An RGBA Format
    cColorBits := window^.init.bitsPerPixel; // Select Our Color Depth
    cRedBits        := 0;                    // Color Bits Ignored
    cRedShift       := 0;
    cGreenBits      := 0;
    cGreenShift     := 0;
    cBlueBits       := 0;
    cBlueShift      := 0;
    cAlphaBits      := 0;                    // No Alpha Buffer
    cAlphaShift     := 0;                    // Shift Bit Ignored
    cAccumBits      := 0;                    // No Accumulation Buffer
    cAccumRedBits   := 0;                    // Accumulation Bits Ignored
    cAccumGreenBits := 0;
    cAccumBlueBits  := 0;
    cAccumAlphaBits := 0;
    cDepthBits      := 16;                   // 16Bit Z-Buffer (Depth Buffer)
    cStencilBits    := 0;                    // No Stencil Buffer
    cAuxBuffers     := 0;                    // No Auxiliary Buffer
    iLayerType      := PFD_MAIN_PLANE;       // Main Drawing Layer
    bReserved       := 0;                    // Reserved
    dwLayerMask     := 0;                    // Layer Masks Ignored
    dwVisibleMask   := 0;
    dwDamageMask    := 0;
  end;

  with windowRect do begin                   // Define Our Window Coordinates
    Left   := 0;
    Top    := 0;
    Right  := window^.init.width;
    Bottom := window^.init.height;
  end;

  if window^.init.isFullScreen then begin    // Fullscreen Requested, Try Changing Video Modes
    EnumDisplaySettings(nil,DWORD(-1),dmDefault); // Not basecode, get current Resolution
    if not ChangeScreenResolution (window^.init.width, window^.init.height, window^.init.bitsPerPixel) then begin
      MessageBox(HWND_DESKTOP, 'Mode Switch Failed.\nRunning In Windowed Mode.', 'Error', MB_OK or MB_ICONEXCLAMATION); // Fullscreen Mode Failed.  Run In Windowed Mode Instead
      window^.init.isFullScreen := False;    // Set isFullscreen To False (Windowed Mode)
    end
    else begin                               // Otherwise (If Fullscreen Mode Was Successful)
      ShowCursor(False);                     // Turn Off The Cursor
      windowStyle         := WS_POPUP;       // Set The WindowStyle To WS_POPUP (Popup Window)
      windowExtendedStyle := windowExtendedStyle or WS_EX_TOPMOST; // Set The Extended Window Style To WS_EX_TOPMOST
    end;                                     // (Top Window Covering Everything Else)
  end
  else                                       // If Fullscreen Was Not Selected
    AdjustWindowRectEx(windowRect, windowStyle, False, windowExtendedStyle); // Adjust Window, Account For Window Borders

  window^.h_Wnd := CreateWindowEx(           // Create The OpenGL Window
       windowExtendedStyle,                  // Extended Style
       window^.init.application^.className,  // Class Name
       window^.init.title,                   // Window Title
       windowStyle,                          // Window Style
       0, 0,                                 // Window X,Y Position
       windowRect.right - windowRect.left,   // Window Width
       windowRect.bottom - windowRect.top,   // Window Height
       HWND_DESKTOP,                         // Desktop Is Window's Parent
       0,                                    // No Menu
       window^.init.application^.hInstance,  // Pass The Window Instance
       window);

  if (window^.h_Wnd = 0) then                // Was Window Creation A Success?
    Exit;                                    // If Not Return False

  window^.h_DC := GetDC(window^.h_Wnd);      // Grab A Device Context For This Window
  if (window^.h_DC = 0) then begin           // Did We Get A Device Context?
                                             // Failed
    DestroyWindow(window^.h_Wnd);            // Destroy The Window
    window^.h_Wnd := 0;                      // Zero The Window Handle
    Exit;                                    // Return False
  end;

  PixelFormat := ChoosePixelFormat(window^.h_DC, @pfd); // Find A Compatible Pixel Format
  if (PixelFormat = 0) then begin            // Did We Find A Compatible Format?
                                             // Failed
    ReleaseDC(window^.h_Wnd, window^.h_DC);  // Release Our Device Context
    window^.h_DC := 0;                       // Zero The Device Context
    DestroyWindow(window^.h_Wnd);            // Destroy The Window
    window^.h_Wnd := 0;                      // Zero The Window Handle
    Exit;                                    // Return False
  end;

  if not SetPixelFormat(window^.h_DC, PixelFormat, @pfd) then begin // Try To Set The Pixel Format
                                             // Failed
    ReleaseDC(window^.h_Wnd, window^.h_DC);  // Release Our Device Context
    window^.h_DC := 0;                       // Zero The Device Context
    DestroyWindow(window^.h_Wnd);            // Destroy The Window
    window^.h_Wnd := 0;                      // Zero The Window Handle
    Exit;                                    // Return False
  end;

  window^.h_RC := wglCreateContext(window^.h_DC); // Try To Get A Rendering Context
  if (window^.h_RC = 0) then begin          // Did We Get A Rendering Context?
                                             // Failed
    ReleaseDC(window^.h_Wnd, window^.h_DC);  // Release Our Device Context
    window^.h_DC := 0;                       // Zero The Device Context
    DestroyWindow(window^.h_Wnd);            // Destroy The Window
    window^.h_Wnd := 0;                      // Zero The Window Handle
    Exit;                                    // Return False
  end;

  if not wglMakeCurrent(window^.h_DC, window^.h_RC) then begin // Make The Rendering Context Our Current Rendering Context
                                             // Failed
    wglDeleteContext (window^.h_RC);         // Delete The Rendering Context
    window^.h_RC := 0;                       // Zero The Rendering Context
    ReleaseDC(window^.h_Wnd, window^.h_DC);  // Release Our Device Context
    window^.h_DC := 0;                       // Zero The Device Context
    DestroyWindow(window^.h_Wnd);            // Destroy The Window
    window^.h_Wnd := 0;                      // Zero The Window Handle
    Exit;                                    // Return False
  end;

  ShowWindow(window^.h_Wnd, SW_NORMAL);      // Make The Window Visible
  window^.isVisible := True;                 // Set isVisible To True
  ReshapeGL(window^.init.width, window^.init.height); // Reshape Our GL Window
  ZeroMemory(window^.keys, SizeOf(TKeys));   // Clear All Keys
  window^.lastTickCount := GetTickCount();   // Get Tick Count

  Result := True;                            // Window Creating Was A Success
end; // Initialization Will Be Done In WM_CREATE

function DestroyWindowGL(window: PGL_Window): Boolean; // Destroy The OpenGL Window & Release Resources
begin
  if not (window^.h_Wnd = 0) then begin      // Does The Window Have A Handle?
    if not (window^.h_DC = 0) then begin     // Does The Window Have A Device Context?
      wglMakeCurrent(window^.h_DC, 0);       // Set The Current Active Rendering Context To Zero
      if not (window^.h_RC = 0)then begin    // Does The Window Have A Rendering Context?
        wglDeleteContext(window^.h_RC);      // Release The Rendering Context
        window^.h_RC := 0;                   // Zero The Rendering Context
      end;
      ReleaseDC(window^.h_Wnd, window^.h_DC); // Release The Device Context
      window^.h_DC := 0;                     // Zero The Device Context
    end;
    DestroyWindow(window^.h_Wnd);            // Destroy The Window
    window^.h_Wnd := 0;                      // Zero The Window Handle
  end;
  if (window^.init.isFullScreen) then begin  // Is Window In Fullscreen Mode
    ChangeDisplaySettings(dmDefault,0);      // Switch Back To Desktop Resolution
    ShowCursor(True);                        // Show The Cursor
  end;
  Result := True;                            // Return True
end;

function WindowProc (h_Wnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall; // Process Window Message Callbacks
var
  window: PGL_Window;
  creation: PCREATESTRUCT;
begin
  Result := 0;
  window := PGL_Window(GetWindowLong(h_Wnd, GWL_USERDATA)); // Get The Window Context
  case uMsg of                               // Evaluate Window Message
    WM_SYSCOMMAND: begin                     // Intercept System Commands
      case wParam of                         // Check System Calls
        SC_SCREENSAVE: begin end;            // Screensaver Trying To Start?
        SC_MONITORPOWER: begin end;          // Monitor Trying To Enter Powersave?
      else
        Result := DefWindowProc(h_Wnd, uMsg, wParam, lParam); // Pass Unhandled Messages To DefWindowProc
      end;
  	  Exit;
    end;
    WM_CREATE: begin                         // Window Creation
      creation := PCREATESTRUCT(lParam);     // Store Window Structure Pointer
      window := PGL_Window(creation^.lpCreateParams);
      SetWindowLong(h_Wnd, GWL_USERDATA, Integer(window));
  	Exit;
    end;
    WM_CLOSE: begin                          // Closing The Window
      TerminateApplication(window);          // Terminate The Application
      Exit;                                  // Return
    end;
    WM_SIZE: begin                           // Size Action Has Taken Place
      case wParam of                         // Evaluate Size Action
        SIZE_MINIMIZED:                      // Was Window Minimized?
          window^.isVisible := False;        // Set isVisible To False
        SIZE_MAXIMIZED: begin                // Was Window Maximized?
          window^.isVisible := True;         // Set isVisible To True
          ReshapeGL(LOWORD(lParam), HIWORD(lParam)); // Reshape Window - LoWord=Width, HiWord=Height
        end;
        SIZE_RESTORED: begin                 // Was Window Restored?
          window^.isVisible := True;         // Set isVisible To True
          ReshapeGL(LOWORD(lParam), HIWORD(lParam)); // Reshape Window - LoWord=Width, HiWord=Height
        end;
      else
        Result := DefWindowProc(h_Wnd, uMsg, wParam, lParam); // Pass Unhandled Messages To DefWindowProc
  	  end;
      Exit;
    end;
    WM_KEYDOWN: begin                        // Update Keyboard Buffers For Keys Pressed
      if ((wParam >= 0) and (wParam <= 255)) then // Is Key (wParam) In A Valid Range?
        window^.keys^.keyDown[wParam] := True; // Set The Selected Key (wParam) To True
      Exit;
    end;
    WM_KEYUP: begin                          // Update Keyboard Buffers For Keys Released
      if ((wParam >= 0) and (wParam <= 255)) then // Is Key (wParam) In A Valid Range?
        window^.keys^.keyDown[wParam] := False; // Set The Selected Key (wParam) To False
      Exit;
    end;
    WM_TOGGLEFULLSCREEN: begin               // Toggle FullScreen Mode On/Off
      g_createFullScreen := not g_createFullScreen;
      PostMessage (h_Wnd, WM_QUIT, 0, 0);
    end;
  else
    Result := DefWindowProc(h_Wnd, uMsg, wParam, lParam); // Pass Unhandled Messages To DefWindowProc
  end;
end;

function RegisterWindowClass(application: PApplication): Boolean; // Register A Window Class For This Application.
var
  windowClass: WNDCLASSEX;                   // Window Class
begin                                        // Register A Window Class
  Result := False;
  ZeroMemory(@windowClass, SizeOf(WNDCLASSEX));            // Make Sure Memory Is Cleared
  windowClass.cbSize        := SizeOf(WNDCLASSEX);         // Size Of The windowClass Structure
  windowClass.style         := CS_HREDRAW or               // Redraws The Window For Any Movement / Resizing
                               CS_VREDRAW or
                               CS_OWNDC;
  windowClass.lpfnWndProc   := @WindowProc;                // WindowProc Handles Messages
  windowClass.hInstance     := application^.hInstance;     // Set The Instance
  windowClass.hbrBackground := HBRUSH(COLOR_APPWORKSPACE); // Class Background Brush Color
  windowClass.hCursor       := LoadCursor(0, IDC_ARROW);   // Load The Arrow Pointer
  windowClass.lpszClassName := application^.className;     // Sets The Applications Classname
  if not (RegisterClassEx(windowClass) = 0) then           // Did Registering The Class Fail?
    Result := True
  else
    MessageBox (HWND_DESKTOP, 'RegisterClassEx Failed!', 'Error', MB_OK or MB_ICONEXCLAMATION);
end;

// Program Entry (WinMain)
function WinMain (hInstance, hPrevInstance: HINST; lpCmdLine: PAnsiChar; nCmdShow: Integer): Integer; stdcall;
var
  application: TApplication; // Application Structure
  window:      TGL_Window;   // Window Structure
  keys:        TKeys;        // Key Structure
  isMessagePumpActive: Boolean; // Message Pump Active?
  msg:         TMsg;         // Window Message Structure
  tickCount:   DWORD;        // Used For The Tick Counter
begin                        // Fill Out Application Data
  application.className := 'OpenGL';         // Application Class Name
  application.hInstance := hInstance;        // Application Instance
                                             // Fill Out Window
  ZeroMemory (@window, SizeOf(TGL_Window));  // Make Sure Memory Is Zeroed
  window.keys     := @keys;                  // Window Key Structure
  window.init.application  := @application;  // Window Application
  window.init.title   := 'CDNR1 v1.0 by Georgy Moshkin'; // Window Title
  window.init.width   := 640;                // Window Width
  window.init.height   := 480;               // Window Height
  window.init.bitsPerPixel := 16;            // Bits Per Pixel
  window.init.isFullScreen := True;          // Fullscreen? (Set To TRUE)

  ZeroMemory (@keys, SizeOf(TKeys));         // Zero keys Structure
// Ask The User If They Want To Start In FullScreen Mode?
  if (MessageBox(HWND_DESKTOP, 'Would You Like To Run In Fullscreen Mode?', 'Start FullScreen?', MB_YESNO or MB_ICONQUESTION) = IDNO) then
    window.init.isFullScreen := False;       // If Not, Run In Windowed Mode
// Register A Class For Our Window To Use
  if not RegisterWindowClass(@application) then begin // Did Registering A Class Fail?
                                             // Failure
    MessageBox (HWND_DESKTOP, 'Error Registering Window Class!', 'Error', MB_OK or MB_ICONEXCLAMATION);
    Result := -1;                            // Terminate Application
    Exit;
  end;

  g_isProgramLooping := True;                // Program Looping Is Set To TRUE
  g_createFullScreen := window.init.isFullScreen; // g_createFullScreen Is Set To User Default
  while g_isProgramLooping do begin          // Loop Until WM_QUIT Is Received
// Create A Window
    window.init.isFullScreen := g_createFullScreen; // Set Init Param Of Window Creation To Fullscreen?
    if CreateWindowGL(@window) then begin    // Was Window Creation Successful?
// At This PoWe: Integer Should Have A Window That Is Setup To Render OpenGL
      if not Initialize(@window, @keys) then begin // Call User Intialization
                                             // Failure
        TerminateApplication(@window);       // Close Window, This Will Handle The Shutdown
      end
      else begin                             // Otherwise (Start The Message Pump)
        isMessagePumpActive := True;         // Set isMessagePumpActive To TRUE
        while isMessagePumpActive do begin   // While The Message Pump Is Active
// Success Creating Window.  Check For Window Messages
          if PeekMessage(msg, window.h_Wnd, 0, 0, PM_REMOVE) then begin
// Check For WM_QUIT Message
            if not (msg.message = WM_QUIT) then begin // Is The Message A WM_QUIT Message?
		          TranslateMessage(msg);
              DispatchMessage(msg);          // If Not, Dispatch The Message
            end
            else begin                       // Otherwise (If Message Is WM_QUIT)
              isMessagePumpActive := FALSE;  // Terminate The Message Pump
            end;
          end
          else begin                         // If There Are No Messages
            if  not window.isVisible then begin // If Window Is Not Visible
              WaitMessage ();                // Application Is Minimized Wait For A Message
            end
            else begin                       // If Window Is Visible
// Process Application Loop
              tickCount := GetTickCount();   // Get The Tick Count
              Update(tickCount - window.lastTickCount); // Update The Counter
              window.lastTickCount := tickCount; // Set Last Count To Current Count
              Draw();                        // Draw Our Scene
              SwapBuffers(window.h_DC);      // Swap Buffers (Double Buffering)
            end;
          end;
        end;                                 // Loop While isMessagePumpActive == TRUE
      end;                                   // If (Initialize (...
// Application Is Finished
      Deinitialize ();                       // User Defined DeInitialization
      DestroyWindowGL(@window);              // Destroy The Active Window
    end
    else begin                               // If Window Creation Failed
// Error Creating Window
      MessageBox(HWND_DESKTOP, 'Error Creating OpenGL Window', 'Error', MB_OK or MB_ICONEXCLAMATION);
      g_isProgramLooping := FALSE;           // Terminate The Loop
    end;
  end;                                       // While (isProgramLooping)

  UnregisterClass (application.className, application.hInstance); // UnRegister Window Class
  Result := 0;
end;                                         // End Of WinMain()

end.
