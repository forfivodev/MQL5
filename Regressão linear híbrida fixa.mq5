//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "Regressão Linear Híbrida Fixa"
#property strict
#property indicator_chart_window
#property indicator_plots 67
#property indicator_buffers 67

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
input bool                       enableCanalCentral = true;
input bool                       enableCanal = true;
input bool                       enableCurvaCentral = false;
input bool                       enableCurva = false;
input int                        perioodos = 240;
input int                        WaitMilliseconds = 30000;                             // Timer (milliseconds) for recalculation

input ENUM_REG_SOURCE            RegressionSource = Close;                             // REGRESSÃO: fonte de dados

input group "***************  CANAL DE REGRESSÃO LINEAR ***************"
input color                      ChannelCentralColor             = clrYellow;                    // Linha central: cor
input int                        ChannelCentralWidth            = 3;                              // Linha central: largura
input ENUM_LINE_STYLE            ChannelCentralStyle             = STYLE_SOLID;                   // Linha central: estilo
input double                     ChannelDeviationsNumber          = 8;                        // CANAL DE REGRESSÃO: número de desvios
input double                     ChannelWidth         = 0.25;                             // CANAL DE REGRESSÃO: multiplicador do desvio
input double                     ChannelDeviationsOffset          = 0;                        // CANAL DE REGRESSÃO: deslocamento
input color                      RegChannelColor             = clrMagenta;             // CANAL DE REGRESSÃO: cor
input int                        RegChannelWidth            = 1;                       // CANAL DE REGRESSÃO: largura
input ENUM_LINE_STYLE            RegChannelStyle             = STYLE_DOT;              // CANAL DE REGRESSÃO: estilo

input group "***************  CURVA DE REGRESSÃO LINEAR ***************"
input bool                       RedutorVisual                 = true;
input double                     fator_reducao = 0.2;
input color                      CurveCentralColor             = clrYellow;                    // Linha central: cor
input int                        CurveCentralWidth            = 3;                              // Linha central: largura
input ENUM_LINE_STYLE            CurveCentralStyle             = STYLE_SOLID;                   // Linha central: estilo
input double                     CurveDeviationsNumber          = 8;                        // CURVA DE REGRESSÃO: número de desvios
input double                     CurveWidth         = 0.25;                             // CURVA DE REGRESSÃO: multiplicador do desvio
input double                     CurveDeviationsOffset          = 0;                        // CURVA DE REGRESSÃO: deslocamento
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

double regChannelBuffer[];
double upChannel1[], upChannel2[], upChannel3[], upChannel4[], upChannel5[], upChannel6[], upChannel7[], upChannel8[];
double upChannel9[], upChannel10[], upChannel11[], upChannel12[], upChannel13[], upChannel14[], upChannel15[], upChannel16[];
double downChannel1[], downChannel2[], downChannel3[], downChannel4[], downChannel5[], downChannel6[], downChannel7[], downChannel8[];
double downChannel9[], downChannel10[], downChannel11[], downChannel12[], downChannel13[], downChannel14[], downChannel15[], downChannel16[];

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

   ArrayInitialize(regChannelBuffer, 0);
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

   SetIndexBuffer(0, regChannelBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, ChannelCentralColor);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, ChannelCentralWidth);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, ChannelCentralStyle);
   PlotIndexSetString(0, PLOT_LABEL, "Canal de regressão linear");

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

   SetIndexBuffer(65, regCurveBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(65, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetInteger(65, PLOT_LINE_COLOR, CurveCentralColor);
   PlotIndexSetInteger(65, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(65, PLOT_LINE_WIDTH, CurveCentralWidth);
   PlotIndexSetInteger(65, PLOT_LINE_STYLE, CurveCentralStyle);
   PlotIndexSetString(65, PLOT_LABEL, "Curva de regressão linear");

   SetIndexBuffer(33, upCurve1, INDICATOR_DATA);
   SetIndexBuffer(34, upCurve2, INDICATOR_DATA);
   SetIndexBuffer(35, upCurve3, INDICATOR_DATA);
   SetIndexBuffer(36, upCurve4, INDICATOR_DATA);
   SetIndexBuffer(37, upCurve5, INDICATOR_DATA);
   SetIndexBuffer(38, upCurve6, INDICATOR_DATA);
   SetIndexBuffer(39, upCurve7, INDICATOR_DATA);
   SetIndexBuffer(40, upCurve8, INDICATOR_DATA);
   SetIndexBuffer(41, upCurve9, INDICATOR_DATA);
   SetIndexBuffer(42, upCurve10, INDICATOR_DATA);
   SetIndexBuffer(43, upCurve11, INDICATOR_DATA);
   SetIndexBuffer(44, upCurve12, INDICATOR_DATA);
   SetIndexBuffer(45, upCurve13, INDICATOR_DATA);
   SetIndexBuffer(46, upCurve14, INDICATOR_DATA);
   SetIndexBuffer(47, upCurve15, INDICATOR_DATA);
   SetIndexBuffer(48, upCurve16, INDICATOR_DATA);
   SetIndexBuffer(49, downCurve1, INDICATOR_DATA);
   SetIndexBuffer(50, downCurve2, INDICATOR_DATA);
   SetIndexBuffer(51, downCurve3, INDICATOR_DATA);
   SetIndexBuffer(52, downCurve4, INDICATOR_DATA);
   SetIndexBuffer(53, downCurve5, INDICATOR_DATA);
   SetIndexBuffer(54, downCurve6, INDICATOR_DATA);
   SetIndexBuffer(55, downCurve7, INDICATOR_DATA);
   SetIndexBuffer(56, downCurve8, INDICATOR_DATA);
   SetIndexBuffer(57, downCurve9, INDICATOR_DATA);
   SetIndexBuffer(58, downCurve10, INDICATOR_DATA);
   SetIndexBuffer(59, downCurve11, INDICATOR_DATA);
   SetIndexBuffer(60, downCurve12, INDICATOR_DATA);
   SetIndexBuffer(61, downCurve13, INDICATOR_DATA);
   SetIndexBuffer(62, downCurve14, INDICATOR_DATA);
   SetIndexBuffer(63, downCurve15, INDICATOR_DATA);
   SetIndexBuffer(64, downCurve16, INDICATOR_DATA);

   for (int i = 1; i <= 32; i++) {
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0); // restriction to draw empty values for the indicator
      PlotIndexSetInteger(i, PLOT_LINE_COLOR, RegChannelColor);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, RegChannelWidth);
      PlotIndexSetInteger(i, PLOT_LINE_STYLE, RegChannelStyle);
   }

   for (int i = 33; i <= 64; i++) {
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0); // restriction to draw empty values for the indicator
      PlotIndexSetInteger(i, PLOT_LINE_COLOR, RegCurveColor);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, RegCurveWidth);
      PlotIndexSetInteger(i, PLOT_LINE_STYLE, RegCurveStyle);
   }

   ArraySetAsSeries(regChannelBuffer, true);
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
      if (debug) Print("Regressão linear híbrida fixa" + " " + ativo + ":" + GetTimeFrame(Period()) + " ok");

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
   
   CalcBars = perioodos;
   
   
   if (CalcBars >= totalRates)
      CalcBars = totalRates;
      
   barFrom = CalcBars - 1;
   barTo = 0;   

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
      CopyClose(Symbol(), PERIOD_CURRENT, toBar, fromBar + 1, dataArray);
   else if (fonte == Open)
      CopyOpen(Symbol(), PERIOD_CURRENT, toBar, fromBar + 1, dataArray);
   else if (fonte == High)
      CopyHigh(Symbol(), PERIOD_CURRENT, toBar, fromBar + 1, dataArray);
   else if (fonte == Low)
      CopyLow(Symbol(), PERIOD_CURRENT, toBar, fromBar + 1, dataArray);
   else if (fonte == Typical) {
      double dataArrayClose[], dataArrayHigh[], dataArrayLow[];
      CopyClose(Symbol(), PERIOD_CURRENT, toBar, fromBar + 1, dataArrayClose);
      CopyHigh(Symbol(), PERIOD_CURRENT, toBar, fromBar + 1, dataArrayHigh);
      CopyLow(Symbol(), PERIOD_CURRENT, toBar, fromBar + 1, dataArrayLow);
      ArrayResize(dataArray, ArraySize(dataArrayClose));
      for(int i = 0; i < ArraySize(dataArrayClose); i++) {
         dataArray[i] = (dataArrayHigh[i] + dataArrayLow[i] + dataArrayClose[i]) / 3;
      }
   }

   ArrayReverse(dataArray);

   for(int n = 0; n < ArraySize(regChannelBuffer) - 1; n++) {
      regChannelBuffer[n] = 0.0;
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

   if (enableCanalCentral || enableCanal) {
      CalcAB(dataArray, fromBar, toBar, A, B);

      if (enableCanal)
         stdev = GetStdDev(dataArray, fromBar, 0); //calculate standand deviation

      for(int i = fromBar; i >= 0; i--) {
         int indiceAjustadoAoBuffer = i + toBar;
         regChannelBuffer[indiceAjustadoAoBuffer] = (A * (i) + B);

         if (enableCanal) {
            if (ChannelDeviationsNumber >= 16) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((13 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel14[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((14 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel15[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((15 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel16[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((16 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((13 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel14[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((14 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel15[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((15 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel16[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((16 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 15) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((13 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel14[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((14 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel15[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((15 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((13 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel14[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((14 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel15[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((15 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 14) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((13 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel14[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((14 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((13 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel14[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((14 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 13) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((13 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel13[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((13 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 12) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((12 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel12[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((12 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 11) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((11 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel11[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((11 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 10) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((10 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel10[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((10 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 9) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel9[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((9 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 8) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel8[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((8 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 7) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel7[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((7 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 6) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel6[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((6 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 5) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel5[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((5 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 4) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel4[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((4 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 3) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel3[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((3 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 2) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               upChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel2[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((2 + ChannelDeviationsOffset) * ChannelWidth);
            } else if (ChannelDeviationsNumber == 1) {
               upChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) + stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
               downChannel1[indiceAjustadoAoBuffer] = (A * (i) + B) - stdev * ((1 + ChannelDeviationsOffset) * ChannelWidth);
            }
         }
      }
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
string _timeFromLine;
string _timeToLine;

bool _lastOK = false;

color _timeToColor;
color _timeFromColor;
int _timeToWidth;
int _timeFromWidth;

MillisecondTimer *_updateTimer;

bool _isTimeframeEnabled = false;

bool _updateOnTick = true;
ENUM_TIMEFRAMES _dataPeriod;
//+------------------------------------------------------------------+
