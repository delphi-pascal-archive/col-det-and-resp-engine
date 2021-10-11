//*| -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//*| OPENGL CAMERA
//*| ---------------------------------------------------------------------------
//*| by Georgy Moshkin
//*|
//*| email : tmtlib@narod.ru
//*| WWW   : http://www.tmtlib.narod.ru/
//*|
//*| License: Public Domain
//*| =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

unit camera;

interface

uses OpenGL;

// -=( ���, ����������� ��������� ������ )=-
type TCamera=record
              eye_x,eye_y,eye_z:single; // x,y,z
             end;

// -=( ����������, ��� �������� ���������� ������ )=-
var Camera1:TCamera;

var CameraElapsed:single;

procedure SetThirdPersonCamera(x,y,z,phi:single); // ��������� ������ � ������ �����
                                                                       // ��������� ������������� ������
                                                                       // � ��������� "��� �� �������� ����"


implementation

////////////////////////////////////////////////////////////////////////////////
procedure SetThirdPersonCamera(x,y,z,phi:single); // ��������� ������ � ������ �����
var need_x,need_y,need_z:single;
begin

 need_x:=x-25*sin(phi*3.14/180); // ��� ��� �� ����� ��������
 need_y:=y+10;
 need_z:=z-25*cos(phi*3.14/180);

 with Camera1 do // ����� ���� ��� ���� � �������� ���, ����� �������� ��������
  begin
   eye_x:=eye_x+(need_x-eye_x)*(0.002*CameraElapsed);
   eye_y:=eye_y+(need_y-eye_y)*(0.002*CameraElapsed);
   eye_z:=eye_z+(need_z-eye_z)*(0.002*CameraElapsed);
  end;

 gluLookAt(Camera1.eye_x,Camera1.eye_y,Camera1.eye_z, // ����� �������� � OpenGL
           x, need_y-3 ,z,
           0,1,0);

end;


end.
