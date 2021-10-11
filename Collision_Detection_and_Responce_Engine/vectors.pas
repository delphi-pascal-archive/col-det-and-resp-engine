//*| -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//*| VECTORS
//*| Procedures And Functions For Working With 2D/3D Vectors
//*| ---------------------------------------------------------------------------
unit vectors;

interface

// -=( Vector | Вектор )=
type TVector=record
              x,y,z : single;
             end;

// -=( Texture Coordinates | Текстурные координаты )=
type TUVCoord=record
               u,v : single;
              end;

// -=( 2d-vector | тип двухмерного вектора )=-
type TVector2D=record
                x,y:single; // coordinates | координаты
               end;

implementation

end.
