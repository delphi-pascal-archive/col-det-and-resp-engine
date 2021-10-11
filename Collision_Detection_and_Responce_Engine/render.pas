unit render;

interface

uses OpenGL,
     bmp,   
     Vectors;

// -=( ������� )=
type TPoligon=record
               BMPname   : string;   // ��� ����� � ���������
               vertnum   : integer;  // ���������� ������ (3 �� 4)
               vert      : array[0..3] of TVector; // ������ � ���������
               norm      : array[0..3] of TVector; // ������ � ���������
               texcoord  : array[0..3] of TUVCoord; // ������ � �����������
                                                    // ������������
               gltex     : GLUINT;   // OpenGL-������� ������������� ��������
               hasUV     : boolean;  // ������� ������� ��������
              end;

// -=( ������ � ���������� )=
type TPoligons=record
                data:array of TPoligon;
//                mode1_list:GLenum;
               end;

type PPoligons=^TPoligons;

(*
var RenderMode:integer; // 0 - glBegin/glEnd
                        // 1 - display lists
                        // 2 - vertex arrays
*)


procedure RenderObject(x,y,ySCREEN,z,phi:Single);
procedure RenderModel(poligoni:PPoligons);


implementation

procedure RenderObject(x,y,ySCREEN,z,phi:Single);
var i:integer;
begin

           glDisable(GL_TEXTURE_2D); // �������� ��������
           glBegin(GL_LINE_LOOP); // �������� �������� ������������ � ��������� ���������
           for i:=0 to 5 do
            begin
             glVertex3f(x+3*cos(60*i*3.14/180),
                        ySCREEN,
                        z+3*sin(60*i*3.14/180));
            end;
           glEnd;


           glBegin(GL_LINES); // �������� �������� ������ ����������� � ������ ������ ���������
             glVertex3f(x,
                        ySCREEN,
                        z);
             glVertex3f(x+3*sin(phi*3.14/180),
                        ySCREEN,
                        z+3*cos(phi*3.14/180));

             glVertex3f(x,
                        ySCREEN,
                        z);
             glVertex3f(x,
                        ySCREEN+10,
                        z);
           glEnd;

end;

////////////////////////////////////////////////////////////////////////////////
procedure RenderModel(poligoni:PPoligons);
var i,j:integer;
begin

//�������� ��� ��������
 for i:=0 to length(poligoni^.data)-1 do
  begin

   if poligoni^.data[i].hasUV then  //���� ������ �������������
    begin
     glEnable(GL_TEXTURE_2D); // ������� ��������
     glBindTexture(GL_TEXTURE_2D,poligoni^.data[i].gltex); // ����������� ������ ��������
     glDisable(GL_LIGHTING); // �������� ����
    end
     else  // ���� ������ �� �������������
    begin
     glDisable(GL_TEXTURE_2D); // �������� ��������
     glEnable(GL_LIGHTING);    // ������� ����
     glEnable(GL_LIGHT0);
    end;


   glBegin(GL_POLYGON); // �������� �������� �������
    for j:=0 to poligoni^.data[i].vertnum-1 do
     begin
      // �� ��� ������: ���������� ����������, ������� � ���� �������
      glTexCoord2f(poligoni^.data[i].texcoord[j].u,
                   poligoni^.data[i].texcoord[j].v);

      glNormal3f(poligoni^.data[i].norm[j].x,
                 poligoni^.data[i].norm[j].y,
                 poligoni^.data[i].norm[j].z);

      glVertex3f(poligoni^.data[i].vert[j].x,
                 poligoni^.data[i].vert[j].y,
                 poligoni^.data[i].vert[j].z);
     end;
   glEnd;

  end;

end;


end.
