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

procedure LoadModel(path,fname:string;var Poligoni:TPoligons); // ��������� ��� �������� ����� � �������
                                        // �������� ������������
                                        // �� ���������� PATH
                                        // fname - ��� ����� � �������


function FindMinMax(coord,minmax:integer;Poligoni:PPoligons):single;
// ��������� FindMinMax:
//                    [0/1/2] [0/1]
//                    [x/y/z] [min/max]
// ��������, FindMinMax(2,0) - ����� ����������� ���������� �� Z

implementation

////////////////////////////////////////////////////////////////////////////////
procedure LoadModel(path,fname:string;var Poligoni:TPoligons); // ��������� ��� �������� ����� � �������
var i,j:integer;      // ���������� ��� ������
    f:text;           // ������������� ���������� ����
    s:string;         // ��������� ���������� ��� �������� ������
    loaded:boolean;   // ��������� �� ��� ��� ��������
    loadedID:GLUINT;  // ���� ��������� - ������� � ID
begin

   DecimalSeparator:='.'; // ����������� ��� ������� ����� - �����

   assign(f,path+fname);  // ������������ � ����
   reset(f);              // ������� ����

    repeat
     readln(f,s); // ��������� ������
     s:=trim(s);  // �������� ������ ������� �� �����

     if s='face' then // ������� ����� FACE - ������ �������
      begin
       setlength(Poligoni.data,length(Poligoni.data)+1); // ����������� ����� �������
       j:=length(Poligoni.data);                    // � �������� ����� ����� �������

       Poligoni.data[j-1].hasUV:=false;             // �������������� �������,
                                               // ��� �������� ���
       readln(f,s);
       Poligoni.data[j-1].BMPname:=trim(s);         // ��� ��������

       if Poligoni.data[j-1].BMPname<>'NOTEXTURE' then // �������� ����
         Poligoni.data[j-1].hasUV:=true;

       readln(f,s);
       Poligoni.data[j-1].vertnum:=StrToInt(trim(s));  // ���������� ������ ��������

       for i:=0 to Poligoni.data[j-1].vertnum-1 do     // ��������� ������� ��������
        begin
         readln(f,s);
         s:=trim(s);
         Poligoni.data[j-1].vert[i].x:=-StrToFloat(StringWordGet(s,' ',1));
         Poligoni.data[j-1].vert[i].z:=StrToFloat(StringWordGet(s,' ',2)); {Z!!}
         Poligoni.data[j-1].vert[i].y:=StrToFloat(StringWordGet(s,' ',3)); {Y!!}
        end;

       for i:=0 to Poligoni.data[j-1].vertnum-1 do     // ��������� ������� ��������
        begin
         readln(f,s);
         s:=trim(s);
         Poligoni.data[j-1].norm[i].x:=-StrToFloat(StringWordGet(s,' ',1));
         Poligoni.data[j-1].norm[i].z:=StrToFloat(StringWordGet(s,' ',2)); {Z!!}
         Poligoni.data[j-1].norm[i].y:=StrToFloat(StringWordGet(s,' ',3)); {Y!!}
        end;

       if Poligoni.data[j-1].hasUV then
        for i:=0 to Poligoni.data[j-1].vertnum-1 do     // ��������� ���������� ����������
         begin
          readln(f,s);
          s:=trim(s);
          Poligoni.data[j-1].texcoord[i].u:=StrToFloat(StringWordGet(s,' ',1));
          Poligoni.data[j-1].texcoord[i].v:=StrToFloat(StringWordGet(s,' ',2));
         end;

      end;


    until eof(f); // ����������� ���������� �����

    // ������ �������� �������� � ������ ����, ��� � ������
    // ��������� ����� ���� ���������� ��������.

    for i:=0 to length(Poligoni.data)-1 do // ��� ���� ���������
     begin

      loaded:=false; // ��� ��� ��������� �������� ������������� �������

      for j:=0 to i-1 do // ��������� ��������, ������� ��� ��������� ���� �������� �������
       if Poligoni.data[j].BMPname=Poligoni.data[i].BMPname then // ���� ����� ���������, �� ��������� ������ �� �����
        begin
         loaded:=true; // �������, ��� �������� ��� ���������
         Poligoni.data[i].gltex:=Poligoni.data[j].gltex; //���������� ID ����������� ����� ��������
         break; //���������� ���� for (������� �� �����)
        end;

      if not loaded then // ���� ��-���� �� ���������, �� ��������:
       begin
        if Poligoni.data[i].BMPname<>'NOTEXTURE' then
         LoadTexture(path+Poligoni.data[i].BMPname, Poligoni.data[i].gltex)
       end;



     end;

   close(f);  // ��������� ����

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
