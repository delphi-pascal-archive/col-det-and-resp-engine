unit render;

interface

uses OpenGL,
     bmp,   
     Vectors;

// -=( Полигон )=
type TPoligon=record
               BMPname   : string;   // имя файла с текстурой
               vertnum   : integer;  // количество вершин (3 ил 4)
               vert      : array[0..3] of TVector; // массив с вершинами
               norm      : array[0..3] of TVector; // массив с нормалями
               texcoord  : array[0..3] of TUVCoord; // массив с текстурными
                                                    // координатами
               gltex     : GLUINT;   // OpenGL-евсткий идентификатор текстуры
               hasUV     : boolean;  // признак наличия текстуры
              end;

// -=( Массив с полигонами )=
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

           glDisable(GL_TEXTURE_2D); // вырубаем текстуры
           glBegin(GL_LINE_LOOP); // начинаем рисовать шестигранник в основании закорючки
           for i:=0 to 5 do
            begin
             glVertex3f(x+3*cos(60*i*3.14/180),
                        ySCREEN,
                        z+3*sin(60*i*3.14/180));
            end;
           glEnd;


           glBegin(GL_LINES); // начинаем рисовать вектор направления и вектор высоты закорючки
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

//Отрисуем все полигоны
 for i:=0 to length(poligoni^.data)-1 do
  begin

   if poligoni^.data[i].hasUV then  //Если объект текстурирован
    begin
     glEnable(GL_TEXTURE_2D); // врубаем текстуры
     glBindTexture(GL_TEXTURE_2D,poligoni^.data[i].gltex); // подсовываем нужную текстуру
     glDisable(GL_LIGHTING); // вырубаем свет
    end
     else  // Если объект не текстурирован
    begin
     glDisable(GL_TEXTURE_2D); // вырубаем тектсуры
     glEnable(GL_LIGHTING);    // врубаем свет
     glEnable(GL_LIGHT0);
    end;


   glBegin(GL_POLYGON); // НАЧИНАЕМ рисовать полигон
    for j:=0 to poligoni^.data[i].vertnum-1 do
     begin
      // всё как обычно: текстурные координаты, нормаль и сама вершина
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
