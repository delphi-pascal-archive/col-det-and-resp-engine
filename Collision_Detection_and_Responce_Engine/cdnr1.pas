//*| -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//*| CDNR-1 v1.0
//*| Collision Detection aNd Responce (for 3D levels, mult-floor)
//*| Based on Z-BUFFER data analysis
//*| ---------------------------------------------------------------------------
//*| by Georgy Moshkin
//*|
//*| email : tmtlib@narod.ru
//*| WWW   : http://www.tmtlib.narod.ru/
//*|
//*| License: Public Domain
//*| =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

unit cdnr1;

interface

uses Vectors,
     OpenGL;

// ::: ширина и высота скриншота для хранения z-buffer
const ZBuf_w = 256;
      ZBuf_h = 256;

// ::: ширина и высота одного слоя с z-buffer
const ZLayer_w = 768; //1024; // 256*4
      ZLayer_h = 768; //1024; // 256*4

// ::: OpenGL-евские near и far для z-buffer
const my_NEAR=1;
      my_FAR=1000;

// ::: ширина и высота массива для хранения кружка коллизии
const KRUG_w = 16;
      KRUG_h = 16;

// ::: максимальные размеры одного квадрата в плоскости XZ
const KVADR_max_x = 100;
      KVADR_max_z = 100;

// ::: максимальное количество слоёв
const MAX_Layers = 10;


const zzz1 = (ZLayer_W div ZBuf_w)*KVADR_MAX_X;
const zzz2 = (ZLayer_H div ZBuf_h)*KVADR_MAX_Z;

// ::: максимальное значение перепада высот
const MAX_INC = 5 / (my_FAR - my_NEAR); // когда "взбираемся на горку"
      MAX_DEC = -5 / (my_FAR - my_NEAR); // когда "спрыгиваем со ступеньки"

var CollisionElapsed:single;      

// -=( память под чтение z-buffera )=-
type TZbuffer=packed array[0..ZBuf_w-1,0..ZBuf_h-1] of glFloat; // простой массив
var ZBuffer:TZbuffer;

// -=( память под хранение слоя z-buffera )=-
type TZLayer= array[0..ZLayer_w-1,0..ZLayer_h-1] of glFloat; // простой массив

// -=( слой ZBuffer )=-
type TZArea=record
             ZLayer:TZLayer; // сам слой
             HEIGHT:single;  // высота, с которой сфотографирован Z-Buffer
            end;

type TZAreas = array[0..MAX_Layers-1] of TZArea;

// -=( элемент массива с кругом коллизии )=-
type TCircleElement=record
                     Radius:single; // длина радиус-вектора, проведённого из
                                    // центра круга в данный элемент массива

                     AntiVector:TVector2D; // антивектор - вектор, который
                                           // следует прибавить к координатам
                                           // игрока, если в данный элемент
                                           // массива вторглась точка,
                                           // у которой высота(глубина)
                                           // слишком сильно отличается
                                           // от высоты (глубины) в центре круга

                     Valid:boolean; // принадлежит ли точка кругу
                                    // (данный признак нужен, так
                                    // как массив квадратный, а хранить
                                    // нужно "кругляшок")
                    end;

// -=( тип Массив с кругляшком из векторов AntiVector )=-
type TCollisionCircle=array[0..KRUG_w-1,0..KRUG_h-1] of TCircleElement;
var TestCircle:TCollisionCircle;

// -=( слои )=-
var ZAreas:TZAreas;

// -=( предельные размеры геометрии уровня по Y )=-
var min_Y, max_Y:single;

// -=( временные переменные для заполения Z-Buffer-а во внешнем цикле )=-
var z_i:integer;
    z_j:integer;
    z_k:integer;    
    z_i_max:integer;
    z_j_max:integer;
    z_k_max:integer;
    z_firstRun:boolean=true;

procedure SetMinMax(miny,maxy:single);
procedure BeforeRender;
function AfterRender:boolean;  // становится true, если весь цикл проработан
procedure SetPerspMode(WX,WY:integer);    

procedure MakeCollisionCircle(var ColCircle:TCollisionCircle; cdiametr:integer); // рассчёт кружка столкновений
procedure DoCollisionEngine(ColCircle:TCollisionCircle; var Player_x,Player_y,Player_ySCREEN,Player_z:single);  // проверка столкновений и Collision Responce

procedure ShowCollisionOpenGL(Monster_y:single);

function FindGoodLayer(y:single):integer;
implementation

procedure SetMinMax(miny,maxy:single);
begin
 min_Y:=miny;
 max_Y:=maxy;
end;

procedure BeforeRender;
var tmpx,tmpz:single;
begin

 if z_firstRun=true then
  begin
   z_i:=0;
   z_j:=0;
   z_k:=0;

   z_i_max:=(ZLayer_W div ZBuf_w);
   z_j_max:=(ZLayer_H div ZBuf_h);
   z_k_max:=Max_Layers;

   // переход в параллельное проецирования
   glMatrixMode(GL_PROJECTION);
   glPushMatrix();
   glLoadIdentity();

   glOrtho(-KVADR_MAX_X/2, KVADR_MAX_X/2,
           -KVADR_MAX_Z/2, KVADR_MAX_Z/2,
               my_NEAR, my_FAR); // переходим в параллельное проецирование

   glMatrixMode(GL_MODELVIEW);
   glPushMatrix();
   glLoadIdentity();

   glPopMatrix;
   glPopMatrix;

   glViewport(0, 0, zbuf_W,zbuf_H); // выставляем виевпорт нужного размера

   z_firstRun:=false;
  end;

  if z_k_max>1 then
   ZAreas[z_k].HEIGHT:=min_Y+(z_k/(z_k_max-1))*(max_Y-min_Y)
  else
   ZAreas[z_k].HEIGHT:=min_Y;   

  tmpX:=(z_i - (z_i_max-1)/2)*KVADR_MAX_X;
  tmpZ:=(z_j - (z_j_max-1)/2)*KVADR_MAX_Z;


  gluLookAt(tmpX,ZAreas[z_k].HEIGHT  ,tmpZ,  // смотрим с высоты HEIGHT
            tmpX,ZAreas[z_k].HEIGHT-10,tmpZ,
            1,0,0);
end;

function AfterRender:boolean;
var AllDone:boolean;
var i,j:integer;
begin

  AllDone:=false;

  // считываем  zbuffer
  glReadPixels(0, 0, zbuf_W, zbuf_H, GL_DEPTH_COMPONENT, GL_FLOAT, @Zbuffer);

  for i:=0 to zbuf_W-1 do
   for j:=0 to zbuf_H-1 do
    begin
     ZAreas[z_k].ZLayer[z_i*zBuf_w + i,
                        z_j*zBuf_h + j]:=ZBuffer[i,j]
    end;

  z_k:=z_k+1;
  if z_k>z_k_max-1 then
   begin
    z_k:=0;
    z_i:=z_i+1;
    if z_i>z_i_max-1 then
     begin
      z_i:=0;
      z_j:=z_j+1;
      if z_j>z_j_max-1 then
       begin
       ///
        AllDone:=true;
        z_FirstRun:=true;
       ///
       end;
     end;
   end;

   result:=AllDone;

end;

procedure SetPerspMode(WX,WY:integer);
begin
 // переходим в перспективную проекцию
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(45.0, WX/WY, 1, 1000.0);
  glMatrixMode(GL_MODELVIEW);

  glViewport(0, 0, WX,WY); // восстанавливаем нормальный ViewPort

end;


procedure MakeCollisionCircle(var ColCircle:TCollisionCircle; cdiametr:integer); // рассчёт кружка столкновений
var i,j:integer;  // для циклов
    tmpx,tmpy,radius:single; // временные переменные
begin

 for i:=0 to KRUG_W-1 do    // пройдёмся по всему массиву
  for j:=0 to KRUG_H-1 do
   begin
    tmpx:=i-(KRUG_W-1)/2;     // вычитаем из конца вектора начало
    tmpy:=j-(KRUG_H-1)/2;     // (начало вектора - в центре массива, конец - в элементе i,j)

    radius:=sqrt(tmpx*tmpx+tmpy*tmpy); // узнаём радиус (длину вектора tmpx,tmpy)

    ColCircle[i,j].Valid:=false; // пока считаем, что элемент i,j массива ColCircle
                                 // не принадлежит кругу

    // два условия, при которых рассчёты не нужны и вываливаемся на следующую итерацию
    if radius = 0 then continue; // вываливаемся
    if radius>=cdiametr/2 then continue; // вываливаемся

    ColCircle[i,j].Radius:=radius; // записываем радиус

    ColCircle[i,j].Valid:=true; // принадлежит кружку

    tmpx:=-tmpx/radius; // создаём единичный вектор
    tmpy:=-tmpy/radius;

    // рассчитываем антивектор, который вытолкнет кружок
    // по кратчайшему расстоянию, если
    // в элементе i,j окажется инородный элемент
    ColCircle[i,j].AntiVector.x:=(tmpx*(cdiametr/2-radius)) *(1/(ZLayer_w-1)) * zzz1;
    ColCircle[i,j].AntiVector.y:=(tmpy*(cdiametr/2-radius)) *(1/(ZLayer_h-1)) * zzz2;

   end;



end;

function FindGoodLayer(y:single):integer;
var i:integer;
var good:integer;
    delta:single;
begin
 good:=0;
 delta:=1000000;


 for i:=0 to MAX_Layers-1 do
   if (zAreas[i].HEIGHT-y>0) and
      (zAreas[i].HEIGHT-y<delta) then
        begin
         good:=i;
         delta:=zAreas[i].HEIGHT-y
        end;

if delta=1000000 then good:=MAX_Layers-1;        

 result:=good;
end;

////////////////////////////////////////////////////////////////////////////////
procedure DoCollisionEngine(ColCircle:TCollisionCircle; var Player_x,Player_y,Player_ySCREEN,Player_z:single);  // проверка столкновений и Collision Responce
var i,j:integer;  // для циклов
    tmpX,tmpZ:integer; // временные
    PlayerCoordInLayerX,PlayerCoordInLayerZ:integer; // координаты игрока в массиве zbuffer

    // ИНДЕКСЫ "ЛУЧШЕЙ" ТОЧКИ
    // лучшая точка - это точка с инородным элементом,
    // которая ближе всего находится к центру массива ColCircle
    BestIndexI, BestIndexJ :integer; // индексы лучшего элемента
    BestIndexRadius:single; // радиус из центра массива ColCircle до лучшего элемента
    CenterDepth:single; // глубина в центре массива

    tmpDepth:single; // временная переменная

    k:integer; // для массива

    GoodLayer:integer;

    Difference:single;

    HowMuch:integer;

begin

howMuch:=0;

player_ySCREEN:=Player_ySCREEN+(Player_y-Player_ySCREEN)*(0.010*CollisionElapsed);


 repeat
   inc(howMuch);
   if howMuch>100 then exit;

   BestIndexRadius:=1000000;  // Заведомо бредовое число

   PlayerCoordInLayerX:=round( (2*Player_x/zzz1+1) * (ZLayer_W-1)/2 ); // координаты игрока внутри массива zLayer
   PlayerCoordInLayerZ:=round( (2*Player_z/zzz2+1) * (ZLayer_H-1)/2 );
   GoodLayer:=FindGoodLayer(Player_y+5);

   CenterDepth:=zAreas[GoodLayer].ZLayer[PlayerCoordInLayerX, PlayerCoordInLayerZ]; // узнаём глубину в той точке, где находится игрок
   Player_Y:=zAreas[GoodLayer].HEIGHT-CenterDepth*(MY_FAR-MY_NEAR);

   for i:=0 to KRUG_w-1 do // массив пробегает значения
    for j:=0 to KRUG_h-1 do // по массиву с кружком (массиву ColCircle)
     begin
      tmpx:=i-(KRUG_W-1) div 2;  // смещаем кружок так, чтобы он
      tmpz:=j-(KRUG_H-1) div 2;   // совпал с центром игрока

      tmpx:=PlayerCoordInLayerX+tmpx; // теперь цикл будет ходить
      tmpz:=PlayerCoordInLayerZ+tmpz;  // как бы относительно центра игрока

      // ЕСЛИ ЧТО НЕ ТАК - ВЫВАЛИВАЕМСЯ И ИДЁМ НА СЛЕДУЮЩУЮ ИТЕРАЦИЮ ЦИКЛА
      if tmpx<0 then continue;
      if tmpz<0 then continue;
      if tmpx>ZLayer_W-1 then continue;
      if tmpz>ZLayer_H-1 then continue;

      tmpDepth:=zAreas[GoodLayer].ZLayer[tmpx,tmpz]; // какая здесь глубина?

       Difference:=tmpDepth-CenterDepth;

       if ((Difference>0) and (Difference>MAX_INC)) or
          ((Difference<0) and (Difference<MAX_DEC)) then // если глубина слишком отлична от глубины в центре
        if {(ColCircle[i,j].Radius<BestIndexRadius) and} ColCircle[i,j].Valid then // и ранее не было найдено точек лучше
         begin // то НАИЛУЧШАЯ ТОЧКА, которая НАИЛУЧШИМ ОБРАЗОМ
          BestIndexRadius:=ColCircle[i,j].Radius; // УДОВЛЕТВОРЯЕТ
          BestIndexI:=i;                 // УСЛОВИЮ
          BestIndexJ:=j;                          // МАКСИМАЛЬНОЙ
          Player_x:=Player_x+ColCircle[BestIndexI,BestIndexJ].AntiVector.x/40;
          Player_z:=Player_z+ColCircle[BestIndexI,BestIndexJ].AntiVector.y/40;
         end;                                     // ПРИБЛИЖЕННОСТИ К ЦЕНТРУ МАССИВА

     end;


  until BestIndexRadius=1000000;
end;

procedure ShowCollisionOpenGL(Monster_y:single);
var i,j:integer;
    ttt:integer;
begin

  glEnable(GL_BLEND);
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
 glBlendFunc(GL_SRC_ALPHA, GL_ONE);
  ttt:=FindGoodLayer(Monster_y+5);
 glDisable(GL_TEXTURE_2D);
 glBegin(GL_QUADS);
// if false then
  for i:=0 to ZLayer_w-1 do
   for j:=0 to ZLayer_h-1 do
    if (i/10=i div 10) and (j/10=j div 10) then
    begin
    if ZAreas[ttt].zlayer[i,j]<1 then begin
    glColor4f(1,0.1,0.1,0.5);
//    else glColor3f(0.3,0.3,0.3);
//        if (i=j) and (i=0) then glColor3f(1,1,1);
    glVertex3f((i/ZLayer_w-0.5)* (ZLayer_W div ZBuf_w)*KVADR_MAX_X,
                ZAreas[ttt].HEIGHT-ZAreas[ttt].Zlayer[i,j]*(MY_FAR-MY_NEAR),
                (j/ZLayer_h-0.5)* (ZLayer_H div ZBuf_h)*KVADR_MAX_Z );
    glVertex3f((i/ZLayer_w-0.5)* (ZLayer_W div ZBuf_w)*KVADR_MAX_X,
                ZAreas[ttt].HEIGHT-ZAreas[ttt].Zlayer[i,j]*(MY_FAR-MY_NEAR),
                (j/ZLayer_h-0.5)* (ZLayer_H div ZBuf_h)*KVADR_MAX_Z+1 );
    glVertex3f((i/ZLayer_w-0.5)* (ZLayer_W div ZBuf_w)*KVADR_MAX_X+1,
                ZAreas[ttt].HEIGHT-ZAreas[ttt].Zlayer[i,j]*(MY_FAR-MY_NEAR),
                (j/ZLayer_h-0.5)* (ZLayer_H div ZBuf_h)*KVADR_MAX_Z+1 );
    glVertex3f((i/ZLayer_w-0.5)* (ZLayer_W div ZBuf_w)*KVADR_MAX_X+1,
                ZAreas[ttt].HEIGHT-ZAreas[ttt].Zlayer[i,j]*(MY_FAR-MY_NEAR),
                (j/ZLayer_h-0.5)* (ZLayer_H div ZBuf_h)*KVADR_MAX_Z );


                end;
    end;

 glEnd;

  glDisable(GL_BLEND);


 glColor3f(1,1,1);

end;


end.
