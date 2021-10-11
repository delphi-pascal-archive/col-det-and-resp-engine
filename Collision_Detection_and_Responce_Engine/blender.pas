//*| -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//*| BLENDER-TO-DELPHI MODEL LOADER v1.1
//*| ---------------------------------------------------------------------------
//*| by Georgy Moshkin
//*|
//*| email : tmtlib@narod.ru
//*| WWW   : http://www.tmtlib.narod.ru/
//*|
//*| License: Public Domain
//*| =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
unit blender;

interface

uses OpenGL,
     SysUtils,
     _strman,
     windows,
     vectors,
     bmp,
     render;

procedure LoadModel(path,fname:string;var Poligoni:TPoligons); // процедура для загрузки файла с моделью
                                        // загрузка производится
                                        // из директории PATH
                                        // fname - имя файла с моделью


function FindMinMax(coord,minmax:integer;Poligoni:PPoligons):single;
// синтаксис FindMinMax:
//                    [0/1/2] [0/1]
//                    [x/y/z] [min/max]
// например, FindMinMax(2,0) - найти минимальную координату по Z

implementation

////////////////////////////////////////////////////////////////////////////////
procedure LoadModel(path,fname:string;var Poligoni:TPoligons); // процедура для загрузки файла с моделью
var i,j:integer;      // переменные для циклов
    f:text;           // идентификатор текстового файл
    s:string;         // временная переменная для хранения текста
    loaded:boolean;   // загружена ли уже эта текстура
    loadedID:GLUINT;  // если загружена - запишем её ID
begin

   DecimalSeparator:='.'; // разделитель для дробных чисел - точка

   assign(f,path+fname);  // подключаемся к фалй
   reset(f);              // ресетим файл

    repeat
     readln(f,s); // считываем строку
     s:=trim(s);  // обрубаем лишние пробелы по краям

     if s='face' then // засекли слово FACE - значит полигон
      begin
       setlength(Poligoni.data,length(Poligoni.data)+1); // увеличиваем длину массива
       j:=length(Poligoni.data);                    // и получаем новую длину массива

       Poligoni.data[j-1].hasUV:=false;             // предварительно считаем,
                                               // что текстуры нет
       readln(f,s);
       Poligoni.data[j-1].BMPname:=trim(s);         // имя текстуры

       if Poligoni.data[j-1].BMPname<>'NOTEXTURE' then // текстура есть
         Poligoni.data[j-1].hasUV:=true;

       readln(f,s);
       Poligoni.data[j-1].vertnum:=StrToInt(trim(s));  // количество вершин полигона

       for i:=0 to Poligoni.data[j-1].vertnum-1 do     // считываем вершины полигона
        begin
         readln(f,s);
         s:=trim(s);
         Poligoni.data[j-1].vert[i].x:=-StrToFloat(StringWordGet(s,' ',1));
         Poligoni.data[j-1].vert[i].z:=StrToFloat(StringWordGet(s,' ',2)); {Z!!}
         Poligoni.data[j-1].vert[i].y:=StrToFloat(StringWordGet(s,' ',3)); {Y!!}
        end;

       for i:=0 to Poligoni.data[j-1].vertnum-1 do     // считываем нормали полигона
        begin
         readln(f,s);
         s:=trim(s);
         Poligoni.data[j-1].norm[i].x:=-StrToFloat(StringWordGet(s,' ',1));
         Poligoni.data[j-1].norm[i].z:=StrToFloat(StringWordGet(s,' ',2)); {Z!!}
         Poligoni.data[j-1].norm[i].y:=StrToFloat(StringWordGet(s,' ',3)); {Y!!}
        end;

       if Poligoni.data[j-1].hasUV then
        for i:=0 to Poligoni.data[j-1].vertnum-1 do     // считываем текстурные координаты
         begin
          readln(f,s);
          s:=trim(s);
          Poligoni.data[j-1].texcoord[i].u:=StrToFloat(StringWordGet(s,' ',1));
          Poligoni.data[j-1].texcoord[i].v:=StrToFloat(StringWordGet(s,' ',2));
         end;

      end;


    until eof(f); // Закончилось считывание файла

    // Теперь загрузим текстуры с учётом того, что у разных
    // полигонов могут быть одинаковые текстуры.

    for i:=0 to length(Poligoni.data)-1 do // для всех полигонов
     begin

      loaded:=false; // это для алгоритма проверки дублирующихся текстур

      for j:=0 to i-1 do // посмотрим полигоны, которые уже проходили этап загрузки текстур
       if Poligoni.data[j].BMPname=Poligoni.data[i].BMPname then // если имена совпадают, то загружать заново не нужно
        begin
         loaded:=true; // говорим, что текстура уже загружена
         Poligoni.data[i].gltex:=Poligoni.data[j].gltex; //записываем ID загруженной ранее текстуры
         break; //прекращаем цикл for (выходим из цикла)
        end;

      if not loaded then // если всё-таки не загружена, то загрузим:
       begin
        if Poligoni.data[i].BMPname<>'NOTEXTURE' then
         LoadTexture(path+Poligoni.data[i].BMPname, Poligoni.data[i].gltex)
       end;



     end;

   close(f);  // закрываем файл

end;

function FindMinMax(coord,minmax:integer;Poligoni:PPoligons):single;
var i:integer;
rst:single;
begin
 case coord of
  0:rst:=Poligoni^.data[0].vert[0].x;
  1:rst:=Poligoni^.data[0].vert[0].y;
  2:rst:=Poligoni^.data[0].vert[0].z;
 end;

 case coord of
  0:for i:=0 to length(Poligoni^.data)-1 do
     begin
      if minmax=0 then
       if Poligoni^.data[i].vert[0].x<rst then rst:=Poligoni^.data[i].vert[0].x;
      if minmax=1 then
       if Poligoni^.data[i].vert[0].x>rst then rst:=Poligoni^.data[i].vert[0].x;
     end;
  1:for i:=0 to length(Poligoni^.data)-1 do
     begin
      if minmax=0 then
       if Poligoni^.data[i].vert[0].y<rst then rst:=Poligoni^.data[i].vert[0].y;
      if minmax=1 then
       if Poligoni^.data[i].vert[0].y>rst then rst:=Poligoni^.data[i].vert[0].y;
     end;
  2:for i:=0 to length(Poligoni^.data)-1 do
     begin
      if minmax=0 then
       if Poligoni^.data[i].vert[0].z<rst then rst:=Poligoni^.data[i].vert[0].z;
      if minmax=1 then
       if Poligoni^.data[i].vert[0].z>rst then rst:=Poligoni^.data[i].vert[0].z;
     end;
  end;

 result:=rst;
end;




end.
