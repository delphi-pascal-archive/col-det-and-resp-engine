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

(***********************************************
*                                              *
*    Jeff Molofee's Revised OpenGL Basecode    *
*  Huge Thanks To Maxwell Sayles & Peter Puck  *
*            http://nehe.gamedev.net           *
*                                              *
***********************************************)


program syndrome;

uses
  Windows,
  shill in 'shill.pas',
  blender in 'blender.pas',
  cdnr1 in 'cdnr1.pas',
  vectors in 'vectors.pas',
  camera in 'camera.pas',
  render in 'render.pas',
  gameobj in 'gameobj.pas';

begin
  WinMain(hInstance, hPrevInst, CmdLine, CmdShow);
end.
