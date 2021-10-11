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

// -=( уровень / персонаж / объект )=-
type TGameObj=record
               x,y,ySCREEN,z:single;    // координаты (в плоскости пола)
               phi:single;    // угол поворота
               poligoni:TPoligons;
              end;


            

implementation

end.
