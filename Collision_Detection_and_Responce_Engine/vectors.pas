//*| -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//*| VECTORS
//*| Procedures And Functions For Working With 2D/3D Vectors
//*| ---------------------------------------------------------------------------
unit vectors;

interface

// -=( Vector | ������ )=
type TVector=record
              x,y,z : single;
             end;

// -=( Texture Coordinates | ���������� ���������� )=
type TUVCoord=record
               u,v : single;
              end;

// -=( 2d-vector | ��� ����������� ������� )=-
type TVector2D=record
                x,y:single; // coordinates | ����������
               end;

implementation

end.
