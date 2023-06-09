//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "GreenDog"
#property link      "krot@inbox.ru" // v2.3 simplified trendline only no comments
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "TrendLines"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input ENUM_TIMEFRAMES inputPeriodo = PERIOD_CURRENT;
input string inputAtivo = "";
input int    LevDP = 2;       // Fractal Period or Levels Demar Pint
input int    qSteps = 10;     // Number  Trendlines per UpTrend or DownTrend
input int    BackStep = 0;  // Number of Steps Back
input int    showBars = 3000; // Bars Back To Draw
input int    ArrowCode = 167;
input color  UpTrendColor = clrLime;
input color  DownTrendColor = clrRed;
input color  buyFractalColor = clrNONE;
input color  sellFractalColor = clrNONE;
input int    colorFactor = 160;
input int    TrendlineWidth = 3;
input ENUM_LINE_STYLE TrendlineStyle = STYLE_SOLID;
input string  UniqueID  = "TrendLINE"; // Indicator unique ID
input int WaitMilliseconds = 2000;  // Timer (milliseconds) for recalculation
input double fatorLimitador = 1;
input double dolar1 = 5.1574;
input double dolar2 = 5.3952;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Buf1[], Fractal1[];
double Buf2[], Fractal2[];
double precoAtual;

string ativo;
int _showBars = showBars;
ENUM_TIMEFRAMES periodo;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {

   ativo = inputAtivo;
   StringToUpper(ativo);
   if (ativo == "")
      ativo = _Symbol;

   periodo = inputPeriodo;

   _updateTimer = new MillisecondTimer(WaitMilliseconds, false);

   SetIndexBuffer(0, Fractal1, INDICATOR_DATA);
   ArraySetAsSeries(Fractal1, true);

   SetIndexBuffer(1, Fractal2, INDICATOR_DATA);
   ArraySetAsSeries(Fractal2, true);

   SetIndexBuffer(2, Buf1, INDICATOR_CALCULATIONS);
   ArraySetAsSeries(Buf1, true);

   SetIndexBuffer(3, Buf2, INDICATOR_CALCULATIONS);
   ArraySetAsSeries(Buf2, true);

   PlotIndexSetInteger(0, PLOT_ARROW, ArrowCode);
   PlotIndexSetInteger(1, PLOT_ARROW, ArrowCode);

   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);

   PlotIndexSetInteger(0, PLOT_LINE_COLOR, sellFractalColor);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, buyFractalColor);

   EventSetMillisecondTimer(WaitMilliseconds);

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int  reason) {

   delete(_updateTimer);
   ObjectsDeleteAll(0, UniqueID);
   ChartRedraw();

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Update() {

   long totalRates = SeriesInfoInteger(ativo, PERIOD_CURRENT, SERIES_BARS_COUNT);
   double onetick = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

   ArrayInitialize(Buf1, 0.0);
   ArrayInitialize(Buf2, 0.0);
   ArrayInitialize(Fractal1, 0.0);
   ArrayInitialize(Fractal2, 0.0);

   precoAtual = iClose(ativo, PERIOD_CURRENT, 0);

   static datetime prevTime = 0;
//if(prevTime != iTime(_Symbol, PERIOD_CURRENT, 0)) { // New Bar
   int cnt = 0;
   if(_showBars == 0 || _showBars > totalRates - 1)
      _showBars = totalRates - 1;

   for(cnt = _showBars; cnt > LevDP; cnt--) {
      Buf1[cnt] = DemHigh(cnt, LevDP);
      Buf2[cnt] = DemLow(cnt, LevDP);
      Fractal1[cnt] =  Buf1[cnt];
      Fractal2[cnt] =  Buf2[cnt];
   }
   for(cnt = 1; cnt <= qSteps; cnt++)
      (TDMain(cnt));

//prevTime = iTime(_Symbol, PERIOD_CURRENT, 0);
//}
   ChartRedraw();

   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

   return(rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer() {
   CheckTimer();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckTimer() {
   EventKillTimer();

   if(_updateTimer.Check() || !_lastOK) {
      _lastOK = Update();
      //if (debug) Print("Regressão linear híbrida " + " " + _Symbol + ":" + GetTimeFrame(Period()) + " ok");

      EventSetMillisecondTimer(WaitMilliseconds);

      _updateTimer.Reset();
   } else {
      EventSetTimer(1);
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TDMain(int Step) {
   int H1, H2, L1, L2;
   string Rem;

//   DownTrendLines
   H1 = GetTD(Step + BackStep, Buf1);
   H2 = GetNextHighTD(H1);

   if(H1 < 0 || H2 < 0) {
      //Print("Demark: Not enough bars on the chart for construction");
   } else {
      Rem = UniqueID + " Down " + IntegerToString(Step);
      ObjectDelete(0, Rem);
      double preco1 = iHigh(ativo, periodo, H2);
      double preco2 = iHigh(ativo, periodo, H1);

      ObjectCreate(0, Rem, OBJ_TREND, 0, iTime(ativo, periodo, H2), preco1, iTime(ativo, periodo, H1), preco2);
      ObjectSetInteger(0, Rem, OBJPROP_RAY_RIGHT, true);
      //int r = MathRandRange(0, 255);
      //int g = MathRandRange(0, 160);
      //int b = MathRandRange(0, 160);
      //ObjectSetInteger(0, Rem, OBJPROP_COLOR, StringToColor(255 + "," + g + "," + b));
      ObjectSetInteger(0, Rem, OBJPROP_COLOR, DownTrendColor);
      ObjectSetInteger(0, Rem, OBJPROP_WIDTH, TrendlineWidth);
      ObjectSetInteger(0, Rem, OBJPROP_STYLE, TrendlineStyle);
      //string s = "Dolarizado 1: " + DoubleToString(dolar1 * preco2, 0) +
      //           "\nDolarizado 2: " + DoubleToString(dolar2 * preco2, 0);
      //ObjectSetString(0, Rem, OBJPROP_TOOLTIP, s);
   }

   filterTrend(Rem);

//    UpTrendLines
   L1 = GetTD(Step + BackStep, Buf2);
   L2 = GetNextLowTD(L1);

   if(L1 < 0 || L2 < 0) {
      //Print("Demark: Not enough bars on the chart for construction");
   } else {
      Rem = UniqueID + " Up " + IntegerToString(Step);
      ObjectDelete(0, Rem);
      double preco1 = iLow(ativo, periodo, L2);
      double preco2 = iLow(ativo, periodo, L1);

      ObjectCreate(0, Rem, OBJ_TREND, 0, iTime(ativo, periodo, L2), preco1, iTime(ativo, periodo, L1), preco2);
      ObjectSetInteger(0, Rem, OBJPROP_RAY_RIGHT, true);
      //int r = MathRandRange(0, 160);
      //int g = MathRandRange(0, 160);
      //int b = MathRandRange(0, 255);
      //ObjectSetInteger(0, Rem, OBJPROP_COLOR, StringToColor(r + "," + g + "," + 255));
      ObjectSetInteger(0, Rem, OBJPROP_COLOR, UpTrendColor);
      ObjectSetInteger(0, Rem, OBJPROP_WIDTH, TrendlineWidth);
      ObjectSetInteger(0, Rem, OBJPROP_STYLE, TrendlineStyle);
      //string s = "Dolarizado 1: " + DoubleToString(dolar1 * preco2, 0) +
      //           "\nDolarizado 2: " + DoubleToString(dolar2 * preco2, 0);
      //ObjectSetString(0, Rem, OBJPROP_TOOLTIP, s);
   }

   filterTrend(Rem);

   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool filterTrend(string s) {
   double p = ObjectGetValueByTime(0, s, iTime(ativo, PERIOD_CURRENT, 0), 0);

   if (p < precoAtual * (1 - fatorLimitador) || p > precoAtual * (1 + fatorLimitador))
      ObjectDelete(0, s);

   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MathRandRange(double x, double y) {
   return(x + MathMod(MathRand(), MathAbs(x - (y + 1))));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetTD(int P, const double& Arr[]) {
   int i = 0, j = 0;
   while(j < P) {
      i++;
      while(Arr[i] == 0) {
         i++;
         if(i > _showBars - 2)
            return(-1);
      }
      j++;
   }
   return (i);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetNextHighTD(int P) {
   int i = P + 1;
   while(Buf1[i] <= iHigh(ativo, periodo, P)) {
      i++;
      if(i > _showBars - 2)
         return(-1);
   }
   return (i);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetNextLowTD(int P) {
   int i = P + 1;
   while(Buf2[i] >= iLow(ativo, periodo, P) || Buf2[i] == 0) {
      i++;
      if(i > _showBars - 2)
         return(-1);
   }
   return (i);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DemHigh(int cnt, int sh) {
   if(iHigh(ativo, periodo, cnt) >= iHigh(ativo, periodo, cnt + sh) && iHigh(ativo, periodo, cnt) > iHigh(ativo, periodo, cnt - sh)) {
      if(sh > 1)
         return(DemHigh(cnt, sh - 1));
      else
         return(iHigh(ativo, periodo, cnt));
   } else
      return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DemLow(int cnt, int sh) {
   if(iLow(ativo, periodo, cnt) <= iLow(ativo, periodo, cnt + sh) && iLow(ativo, periodo, cnt) < iLow(ativo, periodo, cnt - sh)) {
      if(sh > 1)
         return(DemLow(cnt, sh - 1));
      else
         return(iLow(ativo, periodo, cnt));
   } else
      return(0);
}

//+------------------------------------------------------------------+

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   if(id == CHARTEVENT_CHART_CHANGE) {
      _lastOK = true;
      CheckTimer();
      return;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MillisecondTimer {

 private:
   int               _milliseconds;
 private:
   uint              _lastTick;

 public:
   void              MillisecondTimer(const int milliseconds, const bool reset = true) {
      _milliseconds = milliseconds;

      if(reset)
         Reset();
      else
         _lastTick = 0;
   }

 public:
   bool              Check() {
      uint now = getCurrentTick();
      bool stop = now >= _lastTick + _milliseconds;

      if(stop)
         _lastTick = now;

      return(stop);
   }

 public:
   void              Reset() {
      _lastTick = getCurrentTick();
   }

 private:
   uint              getCurrentTick() const {
      return(GetTickCount());
   }

};

//+---------------------------------------------------------------------+
//| GetTimeFrame function - returns the textual timeframe               |
//+---------------------------------------------------------------------+
string GetTimeFrame(int lPeriod) {
   switch(lPeriod) {
   case PERIOD_M1:
      return("M1");
   case PERIOD_M2:
      return("M2");
   case PERIOD_M3:
      return("M3");
   case PERIOD_M4:
      return("M4");
   case PERIOD_M5:
      return("M5");
   case PERIOD_M6:
      return("M6");
   case PERIOD_M10:
      return("M10");
   case PERIOD_M12:
      return("M12");
   case PERIOD_M15:
      return("M15");
   case PERIOD_M20:
      return("M20");
   case PERIOD_M30:
      return("M30");
   case PERIOD_H1:
      return("H1");
   case PERIOD_H2:
      return("H2");
   case PERIOD_H3:
      return("H3");
   case PERIOD_H4:
      return("H4");
   case PERIOD_H6:
      return("H6");
   case PERIOD_H8:
      return("H8");
   case PERIOD_H12:
      return("H12");
   case PERIOD_D1:
      return("D1");
   case PERIOD_W1:
      return("W1");
   case PERIOD_MN1:
      return("MN1");
   }
   return IntegerToString(lPeriod);
}

bool _lastOK = false;
MillisecondTimer *_updateTimer;
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
