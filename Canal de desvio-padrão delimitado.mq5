//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "Delimited Deviation Channel"
#property strict
#property indicator_chart_window
#property indicator_plots 34
#property indicator_buffers 34

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime             data_inicial;         // Data inicial para mostrar as linhas
datetime             data_final;         // Data final para mostrar as linhas

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_REG_SOURCE {
   Open,           // Open
   High,           // High
   Low,             // Low
   Close,         // Close
   Typical,     // Typical
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "***************  GERAL ***************"
input int                        WaitMilliseconds = 5000;                             // Timer (milliseconds) for recalculation
bool                       EnableEvents = true;                                   // Ativa os eventos de teclado
input datetime                   DefaultInitialDate = "2018.01.04 10:00:00";                 // Data inicial padrão
input datetime                   DefaultFinalDate = -1;       // Data final padrão

input group "***************  DELIMITADORES ***************"
input string                     Id = "+cdd";                                          // IDENTIFICADOR
input color                      TimeFromColor = clrLime;                              // ESQUERDO: cor
input int                        TimeFromWidth = 1;                                    // ESQUERDO: largura
input ENUM_LINE_STYLE            TimeFromStyle = STYLE_DASH;                           // ESQUERDO: estilo
input color                      TimeToColor = clrRed;                                 // DIREITO: cor
input int                        TimeToWidth = 1;                                      // DIREITO: largura
input ENUM_LINE_STYLE            TimeToStyle = STYLE_DASH;                             // DIREITO: estilo
input bool                       AutoLimitLines = true;                                // Automatic limit left and right lines
input bool                       FitToLines = true;                                    // Automatic fit histogram inside lines
input bool                       KeepRightLineUpdated = true;                          // Automatic update of the rightmost line
input int                        ShiftCandles = 6;                                     // Distance in candles to adjust on automatic

input group "***************  REGRESSÃO LINEAR ***************"
input ENUM_REG_SOURCE            RegressionSource = Close;                             // REGRESSÃO: fonte de dados
input color                      RegColor             = clrMagenta;                    // REGRESSÃO: cor
input int                        RegWidth            = 1;                              // REGRESSÃO: largura
input ENUM_LINE_STYLE            RegStyle             = STYLE_SOLID;                   // REGRESSÃO: estilo

input group "***************  CANAL DE REGRESSÃO LINEAR ***************"
input double                     DeviationsNumber          = 1;                        // CANAL DE REGRESSÃO: número de desvios
input double                     ChannelWidth         = 1;                             // CANAL DE REGRESSÃO: multiplicador do desvio
input double                     DeviationsOffset          = 0;                        // CANAL DE REGRESSÃO: deslocamento
input color                      RegChannelColor             = clrMagenta;             // CANAL DE REGRESSÃO: cor
input int                        RegChannelWidth            = 1;                       // CANAL DE REGRESSÃO: largura
input ENUM_LINE_STYLE            RegChannelStyle             = STYLE_DOT;              // CANAL DE REGRESSÃO: estilo

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int         heightScreen;
int         widthScreen;
int         totalRates;
int         DigitsM;                        // Number of digits normalized based on HistogramPointScale_calculated.

datetime    timeFrom;
datetime    timeTo;
datetime    minimumDate;
datetime    maximumDate;

int         barFrom, barTo;

long        totalCandles = 0;
bool        onlyRedraw = false;

double      regBuffer[];
double      stDevBuffer[];
double      upChannel1[], upChannel2[], upChannel3[], upChannel4[], upChannel5[], upChannel6[], upChannel7[], upChannel8[];
double      upChannel9[], upChannel10[], upChannel11[], upChannel12[], upChannel13[], upChannel14[], upChannel15[], upChannel16[];
double      downChannel1[], downChannel2[], downChannel3[], downChannel4[], downChannel5[], downChannel6[], downChannel7[], downChannel8[];
double      downChannel9[], downChannel10[], downChannel11[], downChannel12[], downChannel13[], downChannel14[], downChannel15[], downChannel16[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit() {

   _timeFromLine = Id + "-from";
   _timeToLine = Id + "-to";
   _simLine = Id + "-sim";

   data_inicial = DefaultInitialDate;
   if ((DefaultFinalDate == -1) || (DefaultFinalDate > iTime(_Symbol, PERIOD_CURRENT, 0)))
      data_final = iTime(_Symbol, PERIOD_CURRENT, 0) + PeriodSeconds(PERIOD_CURRENT) * ShiftCandles;

   _timeToColor = TimeToColor;
   _timeFromColor = TimeFromColor;
   _timeToWidth = TimeToWidth;
   _timeFromWidth = TimeFromWidth;

   _updateTimer = new MillisecondTimer(WaitMilliseconds, false);

   ArrayInitialize(regBuffer, 0);
   ArrayInitialize(upChannel1, 0);
   ArrayInitialize(upChannel2, 0);
   ArrayInitialize(upChannel3, 0);
   ArrayInitialize(upChannel4, 0);
   ArrayInitialize(upChannel5, 0);
   ArrayInitialize(upChannel6, 0);
   ArrayInitialize(upChannel7, 0);
   ArrayInitialize(upChannel8, 0);
   ArrayInitialize(upChannel9, 0);
   ArrayInitialize(upChannel10, 0);
   ArrayInitialize(upChannel11, 0);
   ArrayInitialize(upChannel12, 0);
   ArrayInitialize(upChannel13, 0);
   ArrayInitialize(upChannel14, 0);
   ArrayInitialize(upChannel15, 0);
   ArrayInitialize(upChannel16, 0);
   ArrayInitialize(downChannel1, 0);
   ArrayInitialize(downChannel2, 0);
   ArrayInitialize(downChannel3, 0);
   ArrayInitialize(downChannel4, 0);
   ArrayInitialize(downChannel5, 0);
   ArrayInitialize(downChannel6, 0);
   ArrayInitialize(downChannel7, 0);
   ArrayInitialize(downChannel8, 0);
   ArrayInitialize(downChannel9, 0);
   ArrayInitialize(downChannel10, 0);
   ArrayInitialize(downChannel11, 0);
   ArrayInitialize(downChannel12, 0);
   ArrayInitialize(downChannel13, 0);
   ArrayInitialize(downChannel14, 0);
   ArrayInitialize(downChannel15, 0);
   ArrayInitialize(downChannel16, 0);

   SetIndexBuffer(0, regBuffer, INDICATOR_DATA);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, RegColor);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, RegWidth);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, RegStyle);
   PlotIndexSetString(0, PLOT_LABEL, "Curva de regressão linear");

   SetIndexBuffer(1, upChannel1, INDICATOR_DATA);
   SetIndexBuffer(2, upChannel2, INDICATOR_DATA);
   SetIndexBuffer(3, upChannel3, INDICATOR_DATA);
   SetIndexBuffer(4, upChannel4, INDICATOR_DATA);
   SetIndexBuffer(5, upChannel5, INDICATOR_DATA);
   SetIndexBuffer(6, upChannel6, INDICATOR_DATA);
   SetIndexBuffer(7, upChannel7, INDICATOR_DATA);
   SetIndexBuffer(8, upChannel8, INDICATOR_DATA);
   SetIndexBuffer(9, upChannel9, INDICATOR_DATA);
   SetIndexBuffer(10, upChannel10, INDICATOR_DATA);
   SetIndexBuffer(11, upChannel11, INDICATOR_DATA);
   SetIndexBuffer(12, upChannel12, INDICATOR_DATA);
   SetIndexBuffer(13, upChannel13, INDICATOR_DATA);
   SetIndexBuffer(14, upChannel14, INDICATOR_DATA);
   SetIndexBuffer(15, upChannel15, INDICATOR_DATA);
   SetIndexBuffer(16, upChannel16, INDICATOR_DATA);
   SetIndexBuffer(17, downChannel1, INDICATOR_DATA);
   SetIndexBuffer(18, downChannel2, INDICATOR_DATA);
   SetIndexBuffer(19, downChannel3, INDICATOR_DATA);
   SetIndexBuffer(20, downChannel4, INDICATOR_DATA);
   SetIndexBuffer(21, downChannel5, INDICATOR_DATA);
   SetIndexBuffer(22, downChannel6, INDICATOR_DATA);
   SetIndexBuffer(23, downChannel7, INDICATOR_DATA);
   SetIndexBuffer(24, downChannel8, INDICATOR_DATA);
   SetIndexBuffer(25, downChannel9, INDICATOR_DATA);
   SetIndexBuffer(26, downChannel10, INDICATOR_DATA);
   SetIndexBuffer(27, downChannel11, INDICATOR_DATA);
   SetIndexBuffer(28, downChannel12, INDICATOR_DATA);
   SetIndexBuffer(29, downChannel13, INDICATOR_DATA);
   SetIndexBuffer(30, downChannel14, INDICATOR_DATA);
   SetIndexBuffer(31, downChannel15, INDICATOR_DATA);
   SetIndexBuffer(32, downChannel16, INDICATOR_DATA);

   for (int i = 1; i <= 33; i++) {
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0); // restriction to draw empty values for the indicator
      PlotIndexSetInteger(i, PLOT_LINE_COLOR, RegChannelColor);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, RegChannelWidth);
      PlotIndexSetInteger(i, PLOT_LINE_STYLE, RegChannelStyle);
   }

// indexing the elements in buffers as timeseries
   ArraySetAsSeries(regBuffer, true);
   ArraySetAsSeries(upChannel1, true);
   ArraySetAsSeries(upChannel2, true);
   ArraySetAsSeries(upChannel3, true);
   ArraySetAsSeries(upChannel4, true);
   ArraySetAsSeries(upChannel5, true);
   ArraySetAsSeries(upChannel6, true);
   ArraySetAsSeries(upChannel7, true);
   ArraySetAsSeries(upChannel8, true);
   ArraySetAsSeries(upChannel9, true);
   ArraySetAsSeries(upChannel10, true);
   ArraySetAsSeries(upChannel11, true);
   ArraySetAsSeries(upChannel12, true);
   ArraySetAsSeries(upChannel13, true);
   ArraySetAsSeries(upChannel14, true);
   ArraySetAsSeries(upChannel15, true);
   ArraySetAsSeries(upChannel16, true);
   ArraySetAsSeries(downChannel1, true);
   ArraySetAsSeries(downChannel2, true);
   ArraySetAsSeries(downChannel3, true);
   ArraySetAsSeries(downChannel4, true);
   ArraySetAsSeries(downChannel5, true);
   ArraySetAsSeries(downChannel6, true);
   ArraySetAsSeries(downChannel7, true);
   ArraySetAsSeries(downChannel8, true);
   ArraySetAsSeries(downChannel9, true);
   ArraySetAsSeries(downChannel10, true);
   ArraySetAsSeries(downChannel11, true);
   ArraySetAsSeries(downChannel12, true);
   ArraySetAsSeries(downChannel13, true);
   ArraySetAsSeries(downChannel14, true);
   ArraySetAsSeries(downChannel15, true);
   ArraySetAsSeries(downChannel16, true);

   EventSetMillisecondTimer(WaitMilliseconds);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void verifyDates() {

   minimumDate = iTime(_Symbol, PERIOD_CURRENT, iBars(_Symbol, PERIOD_CURRENT) - 2);
   maximumDate = iTime(_Symbol, PERIOD_CURRENT, 0);

   timeFrom = GetObjectTime1(_timeFromLine);
   timeTo = GetObjectTime1(_timeToLine);

   data_inicial = DefaultInitialDate;
   if ((DefaultFinalDate == -1) || (DefaultFinalDate > iTime(_Symbol, PERIOD_CURRENT, 0)))
      data_final = iTime(_Symbol, PERIOD_CURRENT, 0) + PeriodSeconds(PERIOD_CURRENT) * ShiftCandles;

   if ((timeFrom == 0) || (timeTo == 0)) {
      timeFrom = data_inicial;
      timeTo = data_final;
      DrawVLine(_timeFromLine, timeFrom, _timeFromColor, _timeFromWidth, TimeFromStyle, true, false, true, 1000);
      DrawVLine(_timeToLine, timeTo, _timeToColor, _timeToWidth, TimeToStyle, true, false, true, 1000);
   }

   if (ObjectGetInteger(0, _timeFromLine, OBJPROP_SELECTED) == false) {
      timeFrom = data_inicial;
   }

   if (ObjectGetInteger(0, _timeToLine, OBJPROP_SELECTED) == false) {
      timeTo = data_final;
   }

   if ((timeFrom < minimumDate) || (timeFrom > maximumDate))
      timeFrom = minimumDate;

   if ((timeTo >= maximumDate) || (timeTo < minimumDate))
      timeTo = maximumDate + PeriodSeconds(PERIOD_CURRENT) * ShiftCandles;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
   return(1);
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
void OnDeinit(const int reason) {

   if(UninitializeReason() == REASON_REMOVE) {
      ObjectDelete(0, _timeFromLine);
      ObjectDelete(0, _timeToLine);
   }

   delete(_updateTimer);
   ChartRedraw();

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckTimer() {
   EventKillTimer();

   if(_updateTimer.Check() || !_lastOK) {
      _lastOK = Update();
      Print("Canal de desvio delimitado ok");

      EventSetMillisecondTimer(WaitMilliseconds);

      _updateTimer.Reset();
   } else {
      EventSetTimer(1);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Update() {

   verifyDates();

   totalRates = SeriesInfoInteger(_Symbol, PERIOD_CURRENT, SERIES_BARS_COUNT);


   datetime shiftedTimeTo;

   ObjectSetInteger(0, _timeFromLine, OBJPROP_TIME, 0, timeFrom);
   ObjectSetInteger(0, _timeToLine, OBJPROP_TIME, 0, timeTo);

//ObjectSetInteger(0, _timeFromLine, OBJPROP_SELECTED, true); // if we dont do this, the line can be deselected
//ObjectSetInteger(0, _timeToLine, OBJPROP_SELECTED, true); // if we dont do this, the line can be deselected

   if(timeFrom > timeTo)
      Swap(timeFrom, timeTo);



   if(!GetRangeBars(timeFrom, timeTo, barFrom, barTo))
      return(false);

   _updateOnTick = barTo < 0;

   double lowPrice;

   int primeiroCandle = WindowFirstVisibleBar();
   int ultimoCandle = WindowFirstVisibleBar() - WindowBarsPerChart();
   double histogramWidthBars;
   int lineFromPosition = 0, lineToPosition = 0;
   if (FitToLines == true) {
      lineFromPosition = iBarShift(_Symbol, PERIOD_CURRENT, GetObjectTime1(_timeFromLine), 0);
      lineToPosition = iBarShift(_Symbol, PERIOD_CURRENT, GetObjectTime1(_timeToLine), 0);
   }

   CalculateRegression(barFrom, barTo, RegressionSource);

   _lastOK = true;
   ChartRedraw();
   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetObjectTime1(const string name) {
   datetime time;

   if(!ObjectGetInteger(0, name, OBJPROP_TIME, 0, time))
      return(0);

   return(time);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MathRound(const double value, const double error) {
   return(error == 0 ? value : MathRound(value / error) * error);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
void Swap(T &value1, T &value2) {
   T tmp = value1;
   value1 = value2;
   value2 = tmp;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int miBarShift(string symbol, ENUM_TIMEFRAMES timeframe, datetime time, bool exact = false) {
   if(time < 0)
      return(-1);

   datetime arr[];
   datetime time1;
   CopyTime(symbol, timeframe, 0, 1, arr);
   time1 = arr[0];

   if(CopyTime(symbol, timeframe, time, time1, arr) <= 0)
      return(-1);

   if(ArraySize(arr) > 2)
      return(ArraySize(arr) - 1);

   return(time < time1 ? 1 : 0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime miTime(string symbol, ENUM_TIMEFRAMES timeframe, int index) {
   if(index < 0)
      return(-1);

   datetime arr[];

   if(CopyTime(symbol, timeframe, index, 1, arr) <= 0)
      return(-1);

   return(arr[0]);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int WindowBarsPerChart() {
   return((int)ChartGetInteger(0, CHART_WIDTH_IN_BARS));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int WindowFirstVisibleBar() {
   return((int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR));
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
int GetTimeBarRight(datetime time, ENUM_TIMEFRAMES period = PERIOD_CURRENT) {
   int bar = miBarShift(_Symbol, period, time);
   datetime t = miTime(_Symbol, period, bar);

   if((t != time) && (bar == 0)) {
      bar = (int)((miTime(_Symbol, period, 0) - time) / PeriodSeconds(period));
   } else {
      if(t < time)
         bar--;
   }

   return(bar);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetBarTime(const int shift, ENUM_TIMEFRAMES period = PERIOD_CURRENT) {
   if(shift >= 0)
      return(miTime(_Symbol, period, shift));
   else
      return(miTime(_Symbol, period, 0) - shift * PeriodSeconds(period));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawVLine(const string name, const datetime time1, const color lineColor, const int width, const int style, const bool back = true, const bool hidden = true, const bool selectable = true, const int zorder = 0) {
   ObjectDelete(0, name);

   ObjectCreate(0, name, OBJ_VLINE, 0, time1, 0);
   ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
   ObjectSetInteger(0, name, OBJPROP_BACK, back);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, hidden);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, selectable);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, zorder);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetRangeBars(const datetime ptimeFrom, const datetime ptimeTo, int &barFrom, int &barTo) {
   barFrom = GetTimeBarRight(ptimeFrom);
   barTo = GetTimeBarRight(ptimeTo);
   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define KEY_RIGHT   68
#define KEY_LEFT  65

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   if(id == CHARTEVENT_OBJECT_DRAG) {
      if((sparam == _timeFromLine) || (sparam == _timeToLine)) {
         _lastOK = false;
         ChartRedraw();
         CheckTimer();
      }
   }

   if(id == CHARTEVENT_CHART_CHANGE) {
      int firstVisibleBar = WindowFirstVisibleBar();
      int lastVisibleBar = firstVisibleBar - WindowBarsPerChart();

      _lastOK = false;
      CheckTimer();
      return;
   }

   static bool keyPressed = false;
   int barraLimite, barraNova, barraFrom, barraTo, primeiraBarraVisivel, ultimaBarraVisivel, ultimaBarraSerie;
   datetime tempoTimeFrom, tempoTimeTo, tempoBarra0, tempoUltimaBarraSerie;

   if(id == CHARTEVENT_KEYDOWN) {
      if(lparam == KEY_RIGHT || lparam == KEY_LEFT) {
         if(!keyPressed)
            keyPressed = true;
         else
            keyPressed = false;

         // definição das variáveis comuns
         if ((ObjectGetInteger(0, _timeToLine, OBJPROP_SELECTED) == true) || (ObjectGetInteger(0, _timeFromLine, OBJPROP_SELECTED) == true)) {
            totalCandles = Bars(_Symbol, PERIOD_CURRENT);
            ultimaBarraSerie = totalCandles - 1;
            ultimaBarraVisivel = WindowFirstVisibleBar();
            barraFrom = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, _timeFromLine, OBJPROP_TIME));
            barraTo = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, _timeToLine, OBJPROP_TIME));
            tempoTimeFrom = GetObjectTime1(_timeFromLine);
            tempoTimeTo = GetObjectTime1(_timeToLine);
            tempoBarra0 = iTime(_Symbol, PERIOD_CURRENT, 0);

            tempoUltimaBarraSerie = iTime(_Symbol, PERIOD_CURRENT, totalCandles - 1);
         }
      }

      switch(int(lparam))  {
      case KEY_RIGHT: {
         if (ObjectGetInteger(0, _timeToLine, OBJPROP_SELECTED) == true) {
            if (barraFrom <= primeiraBarraVisivel)
               barraLimite = barraFrom;
            else
               barraLimite = primeiraBarraVisivel;

            EnableEvents == true ? barraNova = barraTo - 1 : barraNova = barraTo;
            if (barraNova >= 0) {
               datetime tempoNovo = iTime(_Symbol, PERIOD_CURRENT, barraNova);
               ObjectSetInteger(0, _timeToLine, OBJPROP_TIME, 0, tempoNovo);
               timeTo = tempoNovo;
               _lastOK = false;
               CheckTimer();
            } else if (barraNova < 0) {
               datetime tempoNovo = iTime(_Symbol, PERIOD_CURRENT, 0) + PeriodSeconds(PERIOD_CURRENT);
               ObjectSetInteger(0, _timeToLine, OBJPROP_TIME, 0, tempoNovo);
               timeTo = tempoNovo;
               _lastOK = false;
               CheckTimer();
            }
         }

         if (ObjectGetInteger(0, _timeFromLine, OBJPROP_SELECTED) == true) {
            barraLimite = 0;
            if (barraTo >= 0)
               barraLimite = barraTo;

            EnableEvents == true ? barraNova = barraTo - 1 : barraNova = barraTo;
            if (barraNova > barraLimite) {
               datetime tempoNovo = iTime(_Symbol, PERIOD_CURRENT, barraNova);
               ObjectSetInteger(0, _timeFromLine, OBJPROP_TIME, 0, tempoNovo);
               timeFrom = tempoNovo;
               _lastOK = false;
               CheckTimer();
            }
         }


      }
      break;

      case KEY_LEFT:  {
         if (ObjectGetInteger(0, _timeToLine, OBJPROP_SELECTED) == true) {
            barraTo = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, _timeToLine, OBJPROP_TIME));
            if (tempoTimeTo <= tempoUltimaBarraSerie) {
               barraNova = 0;
            } else {
               if (tempoTimeTo > tempoBarra0) {
                  barraNova = 0;
               } else {
                  EnableEvents == true ? barraNova = barraTo + 1 : barraNova = barraTo;
               }
            }

            datetime tempoNovo = iTime(_Symbol, PERIOD_CURRENT, barraNova);
            ObjectSetInteger(0, _timeToLine, OBJPROP_TIME, 0, tempoNovo);
            timeTo = tempoNovo;
            _lastOK = false;
            CheckTimer();
         }

         if (ObjectGetInteger(0, _timeFromLine, OBJPROP_SELECTED) == true) {
            if (tempoTimeFrom <= tempoUltimaBarraSerie)
               barraNova = barraFrom;
            else
               EnableEvents == true ? barraNova = barraFrom + 1 : barraNova = barraFrom;

            barraLimite = ultimaBarraSerie;

            if (barraNova < barraLimite) {
               datetime tempoNovo = iTime(_Symbol, PERIOD_CURRENT, barraNova);
               ObjectSetInteger(0, _timeFromLine, OBJPROP_TIME, 0, tempoNovo);
               timeFrom = tempoNovo;
               _lastOK = false;
               CheckTimer();
            }
         }
      }
      break;
      }
      return;

   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculateRegression(int fromBar, int toBar, ENUM_REG_SOURCE tipo) {

   double dataArray[];

   if (toBar < 0)
      toBar = 0;
   int CalcBars = MathAbs(fromBar - toBar) + 1;

   if (tipo == Close)
      CopyClose(Symbol(), PERIOD_CURRENT, toBar, CalcBars, dataArray);
   else if (tipo == Open)
      CopyOpen(Symbol(), PERIOD_CURRENT, toBar, CalcBars, dataArray);
   else if (tipo == High)
      CopyHigh(Symbol(), PERIOD_CURRENT, toBar, CalcBars, dataArray);
   else if (tipo == Low)
      CopyLow(Symbol(), PERIOD_CURRENT, toBar, CalcBars, dataArray);
   else if (tipo == Typical) {
      double dataArrayClose[], dataArrayHigh[], dataArrayLow[];
      CopyClose(Symbol(), PERIOD_CURRENT, toBar, CalcBars, dataArrayClose);
      CopyHigh(Symbol(), PERIOD_CURRENT, toBar, CalcBars, dataArrayHigh);
      CopyLow(Symbol(), PERIOD_CURRENT, toBar, CalcBars, dataArrayLow);
      ArrayResize(dataArray, ArraySize(dataArrayClose));
      for(int i = 0; i < ArraySize(dataArrayClose); i++) {
         dataArray[i] = (dataArrayHigh[i] + dataArrayLow[i] + dataArrayClose[i]) / 3;
      }
      ArrayFree(dataArrayClose);
      ArrayFree(dataArrayHigh);
      ArrayFree(dataArrayLow);
   }

   ArrayReverse(dataArray);
   ArrayResize(stDevBuffer, ArraySize(regBuffer));

   for(int n = 0; n < ArraySize(regBuffer) - 1; n++) {
      regBuffer[n] = 0.0;
      upChannel1[n] = 0.0;
      downChannel1[n] = 0.0;
      upChannel2[n] = 0.0;
      downChannel2[n] = 0.0;
      upChannel3[n] = 0.0;
      downChannel3[n] = 0.0;
      upChannel4[n] = 0.0;
      downChannel4[n] = 0.0;
      upChannel5[n] = 0.0;
      downChannel5[n] = 0.0;
      upChannel6[n] = 0.0;
      downChannel6[n] = 0.0;
      upChannel7[n] = 0.0;
      downChannel7[n] = 0.0;
      upChannel8[n] = 0.0;
      downChannel8[n] = 0.0;
      upChannel9[n] = 0.0;
      downChannel9[n] = 0.0;
      upChannel10[n] = 0.0;
      downChannel10[n] = 0.0;
      upChannel11[n] = 0.0;
      downChannel11[n] = 0.0;
      upChannel12[n] = 0.0;
      downChannel12[n] = 0.0;
      upChannel13[n] = 0.0;
      downChannel13[n] = 0.0;
      upChannel14[n] = 0.0;
      downChannel14[n] = 0.0;
      upChannel15[n] = 0.0;
      downChannel15[n] = 0.0;
      upChannel16[n] = 0.0;
      downChannel16[n] = 0.0;
      stDevBuffer[n] = 0.0;
   }

   int indiceFinal = CalcBars - 1;
   int indiceInicial;
   if (barTo >= 0)
      indiceInicial = barTo;
   else
      indiceInicial = 0;

   double A = 0, B = 0;
   CalcAB(dataArray, indiceFinal, indiceInicial, A, B);
   double stdev = GetStdDev(dataArray, indiceFinal, indiceInicial); //calculate standand deviation

   for(int i = indiceFinal; i >= 0; i--) {
      int indiceAjustadoAoBuffer = i + toBar;
      //stDevBuffer[indiceAjustadoAoBuffer] = stdev;
      regBuffer[indiceAjustadoAoBuffer] = (A * (i) + B);

      if (DeviationsNumber >= 16) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + DeviationsOffset) * ChannelWidth);
         upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + DeviationsOffset) * ChannelWidth);
         upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + DeviationsOffset) * ChannelWidth);
         upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + DeviationsOffset) * ChannelWidth);
         upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + DeviationsOffset) * ChannelWidth);
         upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + DeviationsOffset) * ChannelWidth);
         upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + DeviationsOffset) * ChannelWidth);
         upChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + DeviationsOffset) * ChannelWidth);
         upChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + DeviationsOffset) * ChannelWidth);
         upChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + DeviationsOffset) * ChannelWidth);
         upChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((13 + DeviationsOffset) * ChannelWidth);
         upChannel14[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((14 + DeviationsOffset) * ChannelWidth);
         upChannel15[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((15 + DeviationsOffset) * ChannelWidth);
         upChannel16[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((16 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + DeviationsOffset) * ChannelWidth);
         downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + DeviationsOffset) * ChannelWidth);
         downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + DeviationsOffset) * ChannelWidth);
         downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + DeviationsOffset) * ChannelWidth);
         downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + DeviationsOffset) * ChannelWidth);
         downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + DeviationsOffset) * ChannelWidth);
         downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + DeviationsOffset) * ChannelWidth);
         downChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + DeviationsOffset) * ChannelWidth);
         downChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + DeviationsOffset) * ChannelWidth);
         downChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + DeviationsOffset) * ChannelWidth);
         downChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((13 + DeviationsOffset) * ChannelWidth);
         downChannel14[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((14 + DeviationsOffset) * ChannelWidth);
         downChannel15[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((15 + DeviationsOffset) * ChannelWidth);
         downChannel16[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((16 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 15) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + DeviationsOffset) * ChannelWidth);
         upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + DeviationsOffset) * ChannelWidth);
         upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + DeviationsOffset) * ChannelWidth);
         upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + DeviationsOffset) * ChannelWidth);
         upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + DeviationsOffset) * ChannelWidth);
         upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + DeviationsOffset) * ChannelWidth);
         upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + DeviationsOffset) * ChannelWidth);
         upChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + DeviationsOffset) * ChannelWidth);
         upChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + DeviationsOffset) * ChannelWidth);
         upChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + DeviationsOffset) * ChannelWidth);
         upChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((13 + DeviationsOffset) * ChannelWidth);
         upChannel14[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((14 + DeviationsOffset) * ChannelWidth);
         upChannel15[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((15 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + DeviationsOffset) * ChannelWidth);
         downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + DeviationsOffset) * ChannelWidth);
         downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + DeviationsOffset) * ChannelWidth);
         downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + DeviationsOffset) * ChannelWidth);
         downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + DeviationsOffset) * ChannelWidth);
         downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + DeviationsOffset) * ChannelWidth);
         downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + DeviationsOffset) * ChannelWidth);
         downChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + DeviationsOffset) * ChannelWidth);
         downChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + DeviationsOffset) * ChannelWidth);
         downChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + DeviationsOffset) * ChannelWidth);
         downChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((13 + DeviationsOffset) * ChannelWidth);
         downChannel14[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((14 + DeviationsOffset) * ChannelWidth);
         downChannel15[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((15 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 14) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + DeviationsOffset) * ChannelWidth);
         upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + DeviationsOffset) * ChannelWidth);
         upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + DeviationsOffset) * ChannelWidth);
         upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + DeviationsOffset) * ChannelWidth);
         upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + DeviationsOffset) * ChannelWidth);
         upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + DeviationsOffset) * ChannelWidth);
         upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + DeviationsOffset) * ChannelWidth);
         upChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + DeviationsOffset) * ChannelWidth);
         upChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + DeviationsOffset) * ChannelWidth);
         upChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + DeviationsOffset) * ChannelWidth);
         upChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((13 + DeviationsOffset) * ChannelWidth);
         upChannel14[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((14 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + DeviationsOffset) * ChannelWidth);
         downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + DeviationsOffset) * ChannelWidth);
         downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + DeviationsOffset) * ChannelWidth);
         downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + DeviationsOffset) * ChannelWidth);
         downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + DeviationsOffset) * ChannelWidth);
         downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + DeviationsOffset) * ChannelWidth);
         downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + DeviationsOffset) * ChannelWidth);
         downChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + DeviationsOffset) * ChannelWidth);
         downChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + DeviationsOffset) * ChannelWidth);
         downChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + DeviationsOffset) * ChannelWidth);
         downChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((13 + DeviationsOffset) * ChannelWidth);
         downChannel14[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((14 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 13) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + DeviationsOffset) * ChannelWidth);
         upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + DeviationsOffset) * ChannelWidth);
         upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + DeviationsOffset) * ChannelWidth);
         upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + DeviationsOffset) * ChannelWidth);
         upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + DeviationsOffset) * ChannelWidth);
         upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + DeviationsOffset) * ChannelWidth);
         upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + DeviationsOffset) * ChannelWidth);
         upChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + DeviationsOffset) * ChannelWidth);
         upChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + DeviationsOffset) * ChannelWidth);
         upChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + DeviationsOffset) * ChannelWidth);
         upChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((13 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + DeviationsOffset) * ChannelWidth);
         downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + DeviationsOffset) * ChannelWidth);
         downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + DeviationsOffset) * ChannelWidth);
         downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + DeviationsOffset) * ChannelWidth);
         downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + DeviationsOffset) * ChannelWidth);
         downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + DeviationsOffset) * ChannelWidth);
         downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + DeviationsOffset) * ChannelWidth);
         downChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + DeviationsOffset) * ChannelWidth);
         downChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + DeviationsOffset) * ChannelWidth);
         downChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + DeviationsOffset) * ChannelWidth);
         downChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((13 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 12) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + DeviationsOffset) * ChannelWidth);
         upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + DeviationsOffset) * ChannelWidth);
         upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + DeviationsOffset) * ChannelWidth);
         upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + DeviationsOffset) * ChannelWidth);
         upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + DeviationsOffset) * ChannelWidth);
         upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + DeviationsOffset) * ChannelWidth);
         upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + DeviationsOffset) * ChannelWidth);
         upChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + DeviationsOffset) * ChannelWidth);
         upChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + DeviationsOffset) * ChannelWidth);
         upChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + DeviationsOffset) * ChannelWidth);
         downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + DeviationsOffset) * ChannelWidth);
         downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + DeviationsOffset) * ChannelWidth);
         downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + DeviationsOffset) * ChannelWidth);
         downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + DeviationsOffset) * ChannelWidth);
         downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + DeviationsOffset) * ChannelWidth);
         downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + DeviationsOffset) * ChannelWidth);
         downChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + DeviationsOffset) * ChannelWidth);
         downChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + DeviationsOffset) * ChannelWidth);
         downChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 11) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + DeviationsOffset) * ChannelWidth);
         upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + DeviationsOffset) * ChannelWidth);
         upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + DeviationsOffset) * ChannelWidth);
         upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + DeviationsOffset) * ChannelWidth);
         upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + DeviationsOffset) * ChannelWidth);
         upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + DeviationsOffset) * ChannelWidth);
         upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + DeviationsOffset) * ChannelWidth);
         upChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + DeviationsOffset) * ChannelWidth);
         upChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + DeviationsOffset) * ChannelWidth);
         downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + DeviationsOffset) * ChannelWidth);
         downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + DeviationsOffset) * ChannelWidth);
         downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + DeviationsOffset) * ChannelWidth);
         downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + DeviationsOffset) * ChannelWidth);
         downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + DeviationsOffset) * ChannelWidth);
         downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + DeviationsOffset) * ChannelWidth);
         downChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + DeviationsOffset) * ChannelWidth);
         downChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 10) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + DeviationsOffset) * ChannelWidth);
         upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + DeviationsOffset) * ChannelWidth);
         upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + DeviationsOffset) * ChannelWidth);
         upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + DeviationsOffset) * ChannelWidth);
         upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + DeviationsOffset) * ChannelWidth);
         upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + DeviationsOffset) * ChannelWidth);
         upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + DeviationsOffset) * ChannelWidth);
         upChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + DeviationsOffset) * ChannelWidth);
         downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + DeviationsOffset) * ChannelWidth);
         downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + DeviationsOffset) * ChannelWidth);
         downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + DeviationsOffset) * ChannelWidth);
         downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + DeviationsOffset) * ChannelWidth);
         downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + DeviationsOffset) * ChannelWidth);
         downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + DeviationsOffset) * ChannelWidth);
         downChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 9) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + DeviationsOffset) * ChannelWidth);
         upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + DeviationsOffset) * ChannelWidth);
         upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + DeviationsOffset) * ChannelWidth);
         upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + DeviationsOffset) * ChannelWidth);
         upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + DeviationsOffset) * ChannelWidth);
         upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + DeviationsOffset) * ChannelWidth);
         upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + DeviationsOffset) * ChannelWidth);
         downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + DeviationsOffset) * ChannelWidth);
         downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + DeviationsOffset) * ChannelWidth);
         downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + DeviationsOffset) * ChannelWidth);
         downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + DeviationsOffset) * ChannelWidth);
         downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + DeviationsOffset) * ChannelWidth);
         downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 8) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + DeviationsOffset) * ChannelWidth);
         upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + DeviationsOffset) * ChannelWidth);
         upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + DeviationsOffset) * ChannelWidth);
         upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + DeviationsOffset) * ChannelWidth);
         upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + DeviationsOffset) * ChannelWidth);
         upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + DeviationsOffset) * ChannelWidth);
         downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + DeviationsOffset) * ChannelWidth);
         downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + DeviationsOffset) * ChannelWidth);
         downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + DeviationsOffset) * ChannelWidth);
         downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + DeviationsOffset) * ChannelWidth);
         downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 7) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + DeviationsOffset) * ChannelWidth);
         upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + DeviationsOffset) * ChannelWidth);
         upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + DeviationsOffset) * ChannelWidth);
         upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + DeviationsOffset) * ChannelWidth);
         upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + DeviationsOffset) * ChannelWidth);
         downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + DeviationsOffset) * ChannelWidth);
         downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + DeviationsOffset) * ChannelWidth);
         downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + DeviationsOffset) * ChannelWidth);
         downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 6) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + DeviationsOffset) * ChannelWidth);
         upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + DeviationsOffset) * ChannelWidth);
         upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + DeviationsOffset) * ChannelWidth);
         upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + DeviationsOffset) * ChannelWidth);
         downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + DeviationsOffset) * ChannelWidth);
         downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + DeviationsOffset) * ChannelWidth);
         downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 5) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + DeviationsOffset) * ChannelWidth);
         upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + DeviationsOffset) * ChannelWidth);
         upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + DeviationsOffset) * ChannelWidth);
         downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + DeviationsOffset) * ChannelWidth);
         downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 4) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + DeviationsOffset) * ChannelWidth);
         upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + DeviationsOffset) * ChannelWidth);
         downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 3) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 2) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + DeviationsOffset) * ChannelWidth);
      } else if (DeviationsNumber == 1) {
         upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + DeviationsOffset) * ChannelWidth);
         downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + DeviationsOffset) * ChannelWidth);
      }
   }

   return 1;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//Linear Regression Calculation for sample data: arr[]
//line equation  y = f(x)  = ax + b
void CalcAB(const double& arr[], int start, int end, double& a, double& b) {

   a = 0.0;
   b = 0.0;
   int size = MathAbs(start - end) + 1;
   if(size < 2)
      return;

   double sumxy = 0.0, sumx = 0.0, sumy = 0.0, sumx2 = 0.0;
   for(int i = start; i >= end; i--) {
      sumxy += i * arr[i];
      sumy += arr[i];
      sumx += i;
      sumx2 += i * i;
   }

   double M = size * sumx2 - sumx * sumx;
   if(M == 0.0)
      return;

   a = (size * sumxy - sumx * sumy) / M;
   b = (sumy - a * sumx) / size;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStdDev(const double &arr[], int start, int end) {
   int size = MathAbs(start - end) + 1;
   if(size < 2)
      return(0.0);

   double sum = 0.0;
   for(int i = start; i >= end; i--) {
      sum = sum + arr[i];
   }

   sum = sum / size;

   double sum2 = 0.0;
   for(int i = start; i >= end; i--) {
      sum2 = sum2 + (arr[i] - sum) * (arr[i] - sum);
   }

   sum2 = sum2 / (size - 1);
   sum2 = MathSqrt(sum2);

   return(sum2);
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
//|                                                                  |
//+------------------------------------------------------------------+
string _timeFromLine;
string _timeToLine;
string _simLine;

bool _lastOK = false;

long _intervalStep = 0;

color _prevBackgroundColor = clrNONE;

int _rangeCount;

color _timeToColor;
color _timeFromColor;
int _timeToWidth;
int _timeFromWidth;

int _firstVisibleBar = 0;
int _lastVisibleBar = 0;

MillisecondTimer *_updateTimer;

bool _isTimeframeEnabled = false;

bool _updateOnTick = true;
ENUM_TIMEFRAMES _dataPeriod;

ENUM_ANCHOR_POINT _anchor_poc;
ENUM_ANCHOR_POINT _anchor_va;
datetime _labelSide;
//+------------------------------------------------------------------+
