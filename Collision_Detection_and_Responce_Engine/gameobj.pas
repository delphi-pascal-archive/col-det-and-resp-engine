//*| -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//*| GAME OBJECTS UNIT
//*| ---------------------------------------------------------------------------
//*| by Georgy Moshkin
//*|
//*| email : tmtlib@narod.ru
//*| WWW   : http://www.tmtlib.narod.ru/
//*|
//*| License: Public Domain
//*| =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
unit gameobj;

interface

uses render;

// -=( ������� / �������� / ������ )=-
type TGameObj=record
               x,y,ySCREEN,z:single;    // ���������� (� ��������� ����)
               phi:single;    // ���� ��������
               poligoni:TPoligons;
              end;


            

implementation

end.
