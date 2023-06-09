//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "Big Volume Candles + Range"
#property strict
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   1
#property indicator_label1  "Big Volume Candles + Range"
#property indicator_type1   DRAW_COLOR_CANDLES

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TIPO_VOLUME {
   Ticks,
   Real
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input TIPO_VOLUME                tipo              = Real;
input int                        Periodos          = 20;
input double                     VolUltra          = 3;
input double                     VolVeryHigh       = 2.4;
input double                     VolHigh           = 1.5;
input double                     VolMedium         = 0;
input double                     VolLow            = 0;
input int                        BackLimit         = 2000;
input int                        WaitMilliseconds  = 1000;   // Timer (milliseconds) for recalculation

input color                      colorNoColor      = C'65,65,65';
input color                      colorUltra        = clrFuchsia;
input color                      colorVeryHigh     = clrRed;
input color                      colorHigh         = clrOrange;
input color                      colorMedium       = clrYellow;
input color                      colorLow          = clrCyan;

input bool                       debug = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];
long volBuffer[];
double rangeBuffer[], realRangeBuffer[], ratioBuffer[], powerBuffer[];

double _VolUltra = 99999;
double _VolVeryHigh = 99999;
double _VolHigh = 99999;
double _VolMedium = 99999;
double _VolLow = 99999;

int totalRates;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   _updateTimer = new MillisecondTimer(WaitMilliseconds, false);

   SetIndexBuffer(0, ExtOpenBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtHighBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ExtLowBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, ExtCloseBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, ExtColorsBuffer, INDICATOR_COLOR_INDEX);

//--- don't show indicator data in DataWindow
   PlotIndexSetInteger(0, PLOT_SHOW_DATA, false);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 6);

//Specify colors for each index
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, colorNoColor);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, colorUltra);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 2, colorVeryHigh);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 3, colorHigh);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 4, colorMedium);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 5, colorLow);

   if (VolUltra > 0) _VolUltra = VolUltra;
   if (VolVeryHigh > 0) _VolVeryHigh = VolVeryHigh;
   if (VolHigh > 0) _VolHigh = VolHigh;
   if (VolMedium > 0) _VolMedium = VolMedium;
   if (VolLow > 0) _VolLow = VolLow;

   _lastOK = false;
   EventSetMillisecondTimer(WaitMilliseconds);
//ChartRedraw();

   return (INIT_SUCCEEDED);

}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
   return (1);
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
//EventKillTimer();

   if(_updateTimer.Check() || !_lastOK) {
      _lastOK = Update();
      if (debug) Print("Big Volume Candles " + " " + _Symbol + ":" + GetTimeFrame(Period()) + " ok");

      //EventSetTimer(WaitMilliseconds);

      ChartRedraw();

      _updateTimer.Reset();
   } else {
      EventSetTimer(1);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Update() {

//CalculateRegression(barFrom, barTo, RegressionSource);
   totalRates = SeriesInfoInteger(_Symbol, PERIOD_CURRENT, SERIES_BARS_COUNT);
   ArrayResize(volBuffer, totalRates);

   CopyOpen(_Symbol, PERIOD_CURRENT, 0, totalRates, ExtOpenBuffer);
   CopyHigh(_Symbol, PERIOD_CURRENT, 0, totalRates, ExtHighBuffer);
   CopyLow(_Symbol, PERIOD_CURRENT, 0, totalRates, ExtLowBuffer);
   CopyClose(_Symbol, PERIOD_CURRENT, 0, totalRates, ExtCloseBuffer);

   if (tipo == Ticks)
      CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, totalRates, volBuffer);
   else
      CopyRealVolume(_Symbol, PERIOD_CURRENT, 0, totalRates, volBuffer);

   ArrayResize(rangeBuffer, totalRates);
   ArrayResize(realRangeBuffer, totalRates);
   ArrayResize(ratioBuffer, totalRates);
   ArrayResize(powerBuffer, totalRates);

   ArrayInitialize(rangeBuffer, 0);
   ArrayInitialize(realRangeBuffer, 0);
   ArrayInitialize(ratioBuffer, 0);
   ArrayInitialize(powerBuffer, 0);
//ArraySetAsSeries(rangeBuffer, true);
//ArraySetAsSeries(realRangeBuffer, true);
//ArraySetAsSeries(ratioBuffer, true);

   for (int i = totalRates - 1; i > Periodos; i--) {
      double totalVolume = 0, mediaVolume = 0, totalRange = 0, totalPower = 0, mediaRange = 0, mediaPower = 0;
      for (int k = i; k > i - Periodos; k--) {
         totalVolume = totalVolume + volBuffer[k];
         rangeBuffer[k] = MathAbs(ExtHighBuffer[k] - ExtLowBuffer[k]);
         realRangeBuffer[k] = MathAbs(ExtOpenBuffer[k] - ExtCloseBuffer[k]);
         ratioBuffer[k] = realRangeBuffer[k] / rangeBuffer[k];
         powerBuffer[k] = volBuffer[k] * ratioBuffer[k];
         totalRange = totalRange + rangeBuffer[k];
         totalPower = totalPower + powerBuffer[k];
      }
      mediaVolume = totalVolume / Periodos;
      mediaRange = totalRange / Periodos;
      mediaPower = totalPower / Periodos;

      ExtColorsBuffer[i] = 0;
      //if (volBuffer[i] >= mediaVolume * _VolUltra) {
      //   ExtColorsBuffer[i] = 1;
      //} else if ((volBuffer[i] < mediaVolume * _VolUltra) && (volBuffer[i] >= mediaVolume * _VolVeryHigh)) {
      //   ExtColorsBuffer[i] = 2;
      //} else if ((volBuffer[i] < mediaVolume * _VolVeryHigh) && (volBuffer[i] >= mediaVolume * _VolHigh)) {
      //   ExtColorsBuffer[i] = 3;
      //} else if ((volBuffer[i] < mediaVolume * _VolHigh) && (volBuffer[i] >= mediaVolume * _VolMedium)) {
      //   ExtColorsBuffer[i] = 4;
      //} else if ((volBuffer[i] < mediaVolume * _VolMedium) && (volBuffer[i] >= mediaVolume * _VolLow)) {
      //   ExtColorsBuffer[i] = 5;
      //}

      if (powerBuffer[i] >= mediaPower * _VolUltra) {
         ExtColorsBuffer[i] = 1;
      } else if ((powerBuffer[i] < mediaPower * _VolUltra) && (powerBuffer[i] >= mediaPower * _VolVeryHigh)) {
         ExtColorsBuffer[i] = 2;
      } else if ((powerBuffer[i] < mediaPower * _VolVeryHigh) && (powerBuffer[i] >= mediaPower * _VolHigh)) {
         ExtColorsBuffer[i] = 3;
      } else if ((powerBuffer[i] < mediaPower * _VolHigh) && (powerBuffer[i] >= mediaPower * _VolMedium)) {
         ExtColorsBuffer[i] = 4;
      } else if ((powerBuffer[i] < mediaPower * _VolMedium) && (powerBuffer[i] >= mediaPower * _VolLow)) {
         ExtColorsBuffer[i] = 5;
      }

   }

//ChartRedraw();
   ArrayFree(ExtCloseBuffer);
   ArrayFree(ExtHighBuffer);
   ArrayFree(ExtLowBuffer);
   ArrayFree(ExtOpenBuffer);

   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   delete(_updateTimer);
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _lastOK = false;
MillisecondTimer *_updateTimer;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

//   if(id == CHARTEVENT_CHART_CHANGE) {
//      _lastOK = false;
//      CheckTimer();
//      return;
//
//   }
}

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
//+------------------------------------------------------------------+
