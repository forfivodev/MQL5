//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "Fixed Linear Regression Curve"
#property strict
#property indicator_chart_window
#property indicator_plots 33
#property indicator_buffers 33

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
input string                     inputAtivo = "";                                       // ATIVO
input bool                       enableCurvaCentral = true;
input bool                       enableCurva = true;
input int                        perioodos = 240;
input int                        WaitMilliseconds = 30000;                             // Timer (milliseconds) for recalculation
input ENUM_REG_SOURCE            RegressionSource = Close;                             // REGRESSÃO: fonte de dados

input group "***************  CURVA DE REGRESSÃO LINEAR ***************"
input double                     CurveDeviationsNumber          = 4;                        // CURVA DE REGRESSÃO: número de desvios
input double                     CurveWidth         = 0.5;                             // CURVA DE REGRESSÃO: multiplicador do desvio
input double                     CurveDeviationsOffset          = 0;                        // CURVA DE REGRESSÃO: deslocamento
input bool                       RedutorVisual                 = true;
input double                     fator_reducao = 0.2;
input color                      CurveCentralColor             = clrYellow;                    // Linha central: cor
input int                        CurveCentralWidth            = 3;                              // Linha central: largura
input ENUM_LINE_STYLE            CurveCentralStyle             = STYLE_SOLID;                   // Linha central: estilo

input color                      RegCurveColor             = clrMagenta;             // CURVA DE REGRESSÃO: cor
input int                        RegCurveWidth            = 1;                       // CURVA DE REGRESSÃO: largura
input ENUM_LINE_STYLE            RegCurveStyle             = STYLE_DOT;              // CURVA DE REGRESSÃO: estilo

input bool debug = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int totalRates;
int DigitsM;                        // Number of digits normalized based on HistogramPointScale_calculated.

int barFrom, barTo, CalcBars;

double A, B, stdev;

long totalCandles = 0;
bool onlyRedraw = false;
bool calculating = false;

double regCurveBuffer[];
double upCurve1[], upCurve2[], upCurve3[], upCurve4[], upCurve5[], upCurve6[], upCurve7[], upCurve8[];
double upCurve9[], upCurve10[], upCurve11[], upCurve12[], upCurve13[], upCurve14[], upCurve15[], upCurve16[];
double downCurve1[], downCurve2[], downCurve3[], downCurve4[], downCurve5[], downCurve6[], downCurve7[], downCurve8[];
double downCurve9[], downCurve10[], downCurve11[], downCurve12[], downCurve13[], downCurve14[], downCurve15[], downCurve16[];

string ativo;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {

   if (inputAtivo != "")
      ativo = inputAtivo;

   _updateTimer = new MillisecondTimer(WaitMilliseconds, false);

   ArrayInitialize(regCurveBuffer, 0);
   ArrayInitialize(upCurve1, 0);
   ArrayInitialize(upCurve2, 0);
   ArrayInitialize(upCurve3, 0);
   ArrayInitialize(upCurve4, 0);
   ArrayInitialize(upCurve5, 0);
   ArrayInitialize(upCurve6, 0);
   ArrayInitialize(upCurve7, 0);
   ArrayInitialize(upCurve8, 0);
   ArrayInitialize(upCurve9, 0);
   ArrayInitialize(upCurve10, 0);
   ArrayInitialize(upCurve11, 0);
   ArrayInitialize(upCurve12, 0);
   ArrayInitialize(upCurve13, 0);
   ArrayInitialize(upCurve14, 0);
   ArrayInitialize(upCurve15, 0);
   ArrayInitialize(upCurve16, 0);
   ArrayInitialize(downCurve1, 0);
   ArrayInitialize(downCurve2, 0);
   ArrayInitialize(downCurve3, 0);
   ArrayInitialize(downCurve4, 0);
   ArrayInitialize(downCurve5, 0);
   ArrayInitialize(downCurve6, 0);
   ArrayInitialize(downCurve7, 0);
   ArrayInitialize(downCurve8, 0);
   ArrayInitialize(downCurve9, 0);
   ArrayInitialize(downCurve10, 0);
   ArrayInitialize(downCurve11, 0);
   ArrayInitialize(downCurve12, 0);
   ArrayInitialize(downCurve13, 0);
   ArrayInitialize(downCurve14, 0);
   ArrayInitialize(downCurve15, 0);
   ArrayInitialize(downCurve16, 0);

   SetIndexBuffer(0, regCurveBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, CurveCentralColor);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, CurveCentralWidth);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, CurveCentralStyle);
   PlotIndexSetString(0, PLOT_LABEL, "Curva de regressão linear");

   SetIndexBuffer(1, upCurve1, INDICATOR_DATA);
   SetIndexBuffer(2, upCurve2, INDICATOR_DATA);
   SetIndexBuffer(3, upCurve3, INDICATOR_DATA);
   SetIndexBuffer(4, upCurve4, INDICATOR_DATA);
   SetIndexBuffer(5, upCurve5, INDICATOR_DATA);
   SetIndexBuffer(6, upCurve6, INDICATOR_DATA);
   SetIndexBuffer(7, upCurve7, INDICATOR_DATA);
   SetIndexBuffer(8, upCurve8, INDICATOR_DATA);
   SetIndexBuffer(9, upCurve9, INDICATOR_DATA);
   SetIndexBuffer(10, upCurve10, INDICATOR_DATA);
   SetIndexBuffer(11, upCurve11, INDICATOR_DATA);
   SetIndexBuffer(12, upCurve12, INDICATOR_DATA);
   SetIndexBuffer(13, upCurve13, INDICATOR_DATA);
   SetIndexBuffer(14, upCurve14, INDICATOR_DATA);
   SetIndexBuffer(15, upCurve15, INDICATOR_DATA);
   SetIndexBuffer(16, upCurve16, INDICATOR_DATA);
   SetIndexBuffer(17, downCurve1, INDICATOR_DATA);
   SetIndexBuffer(18, downCurve2, INDICATOR_DATA);
   SetIndexBuffer(19, downCurve3, INDICATOR_DATA);
   SetIndexBuffer(20, downCurve4, INDICATOR_DATA);
   SetIndexBuffer(21, downCurve5, INDICATOR_DATA);
   SetIndexBuffer(22, downCurve6, INDICATOR_DATA);
   SetIndexBuffer(23, downCurve7, INDICATOR_DATA);
   SetIndexBuffer(24, downCurve8, INDICATOR_DATA);
   SetIndexBuffer(25, downCurve9, INDICATOR_DATA);
   SetIndexBuffer(26, downCurve10, INDICATOR_DATA);
   SetIndexBuffer(27, downCurve11, INDICATOR_DATA);
   SetIndexBuffer(28, downCurve12, INDICATOR_DATA);
   SetIndexBuffer(29, downCurve13, INDICATOR_DATA);
   SetIndexBuffer(30, downCurve14, INDICATOR_DATA);
   SetIndexBuffer(31, downCurve15, INDICATOR_DATA);
   SetIndexBuffer(32, downCurve16, INDICATOR_DATA);

   for (int i = 1; i <= 33; i++) {
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0); // restriction to draw empty values for the indicator
      PlotIndexSetInteger(i, PLOT_LINE_COLOR, RegCurveColor);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, RegCurveWidth);
      PlotIndexSetInteger(i, PLOT_LINE_STYLE, RegCurveStyle);
   }

   ArraySetAsSeries(regCurveBuffer, true);
   ArraySetAsSeries(upCurve1, true);
   ArraySetAsSeries(upCurve2, true);
   ArraySetAsSeries(upCurve3, true);
   ArraySetAsSeries(upCurve4, true);
   ArraySetAsSeries(upCurve5, true);
   ArraySetAsSeries(upCurve6, true);
   ArraySetAsSeries(upCurve7, true);
   ArraySetAsSeries(upCurve8, true);
   ArraySetAsSeries(upCurve9, true);
   ArraySetAsSeries(upCurve10, true);
   ArraySetAsSeries(upCurve11, true);
   ArraySetAsSeries(upCurve12, true);
   ArraySetAsSeries(upCurve13, true);
   ArraySetAsSeries(upCurve14, true);
   ArraySetAsSeries(upCurve15, true);
   ArraySetAsSeries(upCurve16, true);
   ArraySetAsSeries(downCurve1, true);
   ArraySetAsSeries(downCurve2, true);
   ArraySetAsSeries(downCurve3, true);
   ArraySetAsSeries(downCurve4, true);
   ArraySetAsSeries(downCurve5, true);
   ArraySetAsSeries(downCurve6, true);
   ArraySetAsSeries(downCurve7, true);
   ArraySetAsSeries(downCurve8, true);
   ArraySetAsSeries(downCurve9, true);
   ArraySetAsSeries(downCurve10, true);
   ArraySetAsSeries(downCurve11, true);
   ArraySetAsSeries(downCurve12, true);
   ArraySetAsSeries(downCurve13, true);
   ArraySetAsSeries(downCurve14, true);
   ArraySetAsSeries(downCurve15, true);
   ArraySetAsSeries(downCurve16, true);

   EventSetMillisecondTimer(WaitMilliseconds);
   ChartRedraw();

   CalcBars = perioodos;
   barFrom = CalcBars - 1;
   barTo = 0;

   return (INIT_SUCCEEDED);
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
      if (debug) Print("Curva de regressão linear comum " + " " + ativo + ":" + GetTimeFrame(Period()) + " ok");

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

   calculating = true;

   totalRates = SeriesInfoInteger(ativo, PERIOD_CURRENT, SERIES_BARS_COUNT);

   if (CalcBars >= totalRates)
      return false;

   CalculateRegression(barFrom, barTo, RegressionSource);

   ChartRedraw();

   calculating = false;

   return(true);
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
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
//
   if(id == CHARTEVENT_CHART_CHANGE && calculating == false) {
      _lastOK = true;
      CheckTimer();
      return;
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculateRegression(int fromBar, int toBar, ENUM_REG_SOURCE fonte) {

   double dataArray[];

   if (fonte == Close)
      CopyClose(Symbol(), PERIOD_CURRENT, toBar, fromBar, dataArray);
   else if (fonte == Open)
      CopyOpen(Symbol(), PERIOD_CURRENT, toBar, fromBar, dataArray);
   else if (fonte == High)
      CopyHigh(Symbol(), PERIOD_CURRENT, toBar, fromBar, dataArray);
   else if (fonte == Low)
      CopyLow(Symbol(), PERIOD_CURRENT, toBar, fromBar, dataArray);
   else if (fonte == Typical) {
      double dataArrayClose[], dataArrayHigh[], dataArrayLow[];
      CopyClose(Symbol(), PERIOD_CURRENT, toBar, fromBar, dataArrayClose);
      CopyHigh(Symbol(), PERIOD_CURRENT, toBar, fromBar, dataArrayHigh);
      CopyLow(Symbol(), PERIOD_CURRENT, toBar, fromBar, dataArrayLow);
      ArrayResize(dataArray, ArraySize(dataArrayClose));
      for(int i = 0; i < ArraySize(dataArrayClose); i++) {
         dataArray[i] = (dataArrayHigh[i] + dataArrayLow[i] + dataArrayClose[i]) / 3;
      }
   }

   ArrayReverse(dataArray);

   for(int n = 0; n < ArraySize(regCurveBuffer) - 1; n++) {
      regCurveBuffer[n] = 0.0;
      upCurve1[n] = 0.0;
      downCurve1[n] = 0.0;
      upCurve2[n] = 0.0;
      downCurve2[n] = 0.0;
      upCurve3[n] = 0.0;
      downCurve3[n] = 0.0;
      upCurve4[n] = 0.0;
      downCurve4[n] = 0.0;
      upCurve5[n] = 0.0;
      downCurve5[n] = 0.0;
      upCurve6[n] = 0.0;
      downCurve6[n] = 0.0;
      upCurve7[n] = 0.0;
      downCurve7[n] = 0.0;
      upCurve8[n] = 0.0;
      downCurve8[n] = 0.0;
      upCurve9[n] = 0.0;
      downCurve9[n] = 0.0;
      upCurve10[n] = 0.0;
      downCurve10[n] = 0.0;
      upCurve11[n] = 0.0;
      downCurve11[n] = 0.0;
      upCurve12[n] = 0.0;
      downCurve12[n] = 0.0;
      upCurve13[n] = 0.0;
      downCurve13[n] = 0.0;
      upCurve14[n] = 0.0;
      downCurve14[n] = 0.0;
      upCurve15[n] = 0.0;
      downCurve15[n] = 0.0;
      upCurve16[n] = 0.0;
      downCurve16[n] = 0.0;
   }

   if (enableCurvaCentral || enableCurva) {
      for(int i = fromBar; i >= 0; i--) {
         int indiceAjustadoAoBuffer = i + toBar;
         CalcAB(dataArray, ArraySize(dataArray) - 1, i, A, B);
         regCurveBuffer[indiceAjustadoAoBuffer] = (A * (i) + B);

         if (enableCurva) {
            if (RedutorVisual && i <= (int)((1 - fator_reducao) * CalcBars - 1)) {

               stdev = GetStdDev(dataArray, ArraySize(dataArray) - 1, i); //calculate standand deviation
               //while (stdev>=50)
               //stdev = stdev/2;
                  
                  
               if (CurveDeviationsNumber >= 16) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  upCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  upCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  upCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  upCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  upCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  upCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  upCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  upCurve10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + CurveDeviationsOffset) * CurveWidth);
                  upCurve11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + CurveDeviationsOffset) * CurveWidth);
                  upCurve12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + CurveDeviationsOffset) * CurveWidth);
                  upCurve13[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((13 + CurveDeviationsOffset) * CurveWidth);
                  upCurve14[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((14 + CurveDeviationsOffset) * CurveWidth);
                  upCurve15[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((15 + CurveDeviationsOffset) * CurveWidth);
                  upCurve16[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((16 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  downCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  downCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  downCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  downCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  downCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  downCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  downCurve10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + CurveDeviationsOffset) * CurveWidth);
                  downCurve11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + CurveDeviationsOffset) * CurveWidth);
                  downCurve12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + CurveDeviationsOffset) * CurveWidth);
                  downCurve13[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((13 + CurveDeviationsOffset) * CurveWidth);
                  downCurve14[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((14 + CurveDeviationsOffset) * CurveWidth);
                  downCurve15[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((15 + CurveDeviationsOffset) * CurveWidth);
                  downCurve16[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((16 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 15) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  upCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  upCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  upCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  upCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  upCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  upCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  upCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  upCurve10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + CurveDeviationsOffset) * CurveWidth);
                  upCurve11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + CurveDeviationsOffset) * CurveWidth);
                  upCurve12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + CurveDeviationsOffset) * CurveWidth);
                  upCurve13[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((13 + CurveDeviationsOffset) * CurveWidth);
                  upCurve14[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((14 + CurveDeviationsOffset) * CurveWidth);
                  upCurve15[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((15 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  downCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  downCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  downCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  downCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  downCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  downCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  downCurve10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + CurveDeviationsOffset) * CurveWidth);
                  downCurve11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + CurveDeviationsOffset) * CurveWidth);
                  downCurve12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + CurveDeviationsOffset) * CurveWidth);
                  downCurve13[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((13 + CurveDeviationsOffset) * CurveWidth);
                  downCurve14[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((14 + CurveDeviationsOffset) * CurveWidth);
                  downCurve15[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((15 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 14) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  upCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  upCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  upCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  upCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  upCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  upCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  upCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  upCurve10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + CurveDeviationsOffset) * CurveWidth);
                  upCurve11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + CurveDeviationsOffset) * CurveWidth);
                  upCurve12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + CurveDeviationsOffset) * CurveWidth);
                  upCurve13[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((13 + CurveDeviationsOffset) * CurveWidth);
                  upCurve14[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((14 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  downCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  downCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  downCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  downCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  downCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  downCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  downCurve10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + CurveDeviationsOffset) * CurveWidth);
                  downCurve11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + CurveDeviationsOffset) * CurveWidth);
                  downCurve12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + CurveDeviationsOffset) * CurveWidth);
                  downCurve13[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((13 + CurveDeviationsOffset) * CurveWidth);
                  downCurve14[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((14 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 13) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  upCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  upCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  upCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  upCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  upCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  upCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  upCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  upCurve10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + CurveDeviationsOffset) * CurveWidth);
                  upCurve11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + CurveDeviationsOffset) * CurveWidth);
                  upCurve12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + CurveDeviationsOffset) * CurveWidth);
                  upCurve13[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((13 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  downCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  downCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  downCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  downCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  downCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  downCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  downCurve10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + CurveDeviationsOffset) * CurveWidth);
                  downCurve11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + CurveDeviationsOffset) * CurveWidth);
                  downCurve12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + CurveDeviationsOffset) * CurveWidth);
                  downCurve13[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((13 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 12) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  upCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  upCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  upCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  upCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  upCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  upCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  upCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  upCurve10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + CurveDeviationsOffset) * CurveWidth);
                  upCurve11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + CurveDeviationsOffset) * CurveWidth);
                  upCurve12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  downCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  downCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  downCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  downCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  downCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  downCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  downCurve10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + CurveDeviationsOffset) * CurveWidth);
                  downCurve11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + CurveDeviationsOffset) * CurveWidth);
                  downCurve12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 11) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  upCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  upCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  upCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  upCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  upCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  upCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  upCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  upCurve10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + CurveDeviationsOffset) * CurveWidth);
                  upCurve11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  downCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  downCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  downCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  downCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  downCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  downCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  downCurve10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + CurveDeviationsOffset) * CurveWidth);
                  downCurve11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 10) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  upCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  upCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  upCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  upCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  upCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  upCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  upCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  upCurve10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  downCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  downCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  downCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  downCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  downCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  downCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  downCurve10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 9) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  upCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  upCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  upCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  upCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  upCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  upCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  upCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  downCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  downCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  downCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  downCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  downCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  downCurve9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 8) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  upCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  upCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  upCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  upCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  upCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  upCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  downCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  downCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  downCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  downCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  downCurve8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 7) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  upCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  upCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  upCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  upCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  upCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  downCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  downCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  downCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  downCurve7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 6) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  upCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  upCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  upCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  upCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  downCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  downCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  downCurve6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 5) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  upCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  upCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  upCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  downCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  downCurve5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 4) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  upCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  upCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  downCurve4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 3) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  upCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 2) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  upCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + CurveDeviationsOffset) * CurveWidth);
               } else if (CurveDeviationsNumber == 1) {
                  upCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
                  downCurve1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + CurveDeviationsOffset) * CurveWidth);
               }
            }
         }
      }

      int u = 0;
   }



   return 1;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//Linear Regression Calculation for sample data: arr[]
//line equation  y = f(x)  = ax + b
void CalcAB(const double &arr[], int start, int end, double & a, double & b) {

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
double GetStdDev(const double & arr[], int start, int end) {
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
bool _lastOK = false;

MillisecondTimer *_updateTimer;

ENUM_TIMEFRAMES _dataPeriod;

//+------------------------------------------------------------------+
