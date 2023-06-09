//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2021, 2022, 2023"
#property description "Infinite VWAP"
#property indicator_chart_window
#property indicator_buffers 20
#property indicator_plots   20

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum PRICE_method {
   Close,
   Open,
   High,
   Low,
   Median,  // Median Price (HL/2)
   Typical, // Typical Price (HLC/3)
   Weighted // Weighted Close (HLCC/4)
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- input parameters
input int                              IndicatorId = 1;                       // VWAP Id  (must be unique)
input PRICE_method                     method    = Typical;                   // Price Calculation method
input color                            vwapColor = Fuchsia;                   // VWAP Color
input int                              arrowSize = 2;                         // Arrow Size
input int                              espessura_linha = 1;                   // Espessura das linhas
input ENUM_APPLIED_VOLUME              applied_volume = VOLUME_REAL;          // tipo de volume
input int                              WaitMilliseconds  = 10000;              // Timer (milliseconds) for recalculation
input bool randomColor = false;
input bool debug = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- indicator buffers
double         vwapBuffer1[], vwapBuffer2[], vwapBuffer3[], vwapBuffer4[], vwapBuffer5[], vwapBuffer6[], vwapBuffer7[], vwapBuffer8[], vwapBuffer9[], vwapBuffer10[];
double         vwapBuffer11[], vwapBuffer12[], vwapBuffer13[], vwapBuffer14[], vwapBuffer15[], vwapBuffer16[], vwapBuffer17[], vwapBuffer18[], vwapBuffer19[], vwapBuffer20[];
int            startVWAP1 = 0, startVWAP2 = 0, startVWAP3 = 0, startVWAP4 = 0, startVWAP5 = 0, startVWAP6 = 0, startVWAP7 = 0, startVWAP8 = 0, startVWAP9 = 0, startVWAP10 = 0;
int            startVWAP11 = 0, startVWAP12 = 0, startVWAP13 = 0, startVWAP14 = 0, startVWAP15 = 0, startVWAP16 = 0, startVWAP17 = 0, startVWAP18 = 0, startVWAP19 = 0, startVWAP20 = 0;
int            indicatorNumber;
string         indicatorPrefix;
datetime       arrayTime[];
double         arrayOpen[], arrayHigh[], arrayLow[], arrayClose[];
string         prefix[20];
long           VolumeBuffer[];
int            startVwap[20];
long           obj_time;
bool           first = true;
int            barras_visiveis, teste;
datetime       Hposition;
double         Vposition;
int            totalRates;
string         tipo_vwap = "Typical";
int            vwapNumber = 0;
int            vwapCount = 0;
int            defaultvwapCount = 1;
string prefixo;
//color tempColor;
int len;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   indicatorNumber = IndicatorId;
   indicatorPrefix = "Infinite_VWAP_";
   len = StringLen(indicatorPrefix) + StringLen(indicatorNumber) + StringLen("_VWAP_");

//tempColor = vwapColor;
//if (vwapColor != clrLime && vwapColor != clrYellow && vwapColor != clrFuchsia && vwapColor != clrRed && vwapColor != clrNavy)
//   tempColor = clrFuchsia;

   int i = 0;
   vwapCount = 0;
   prefixo = indicatorPrefix + indicatorNumber + "_VWAP_";

   int totalObjetos = ObjectGetInteger(0, prefixo + 1, OBJPROP_TIME);
   if (totalObjetos > 0) {
      while(i < ObjectsTotal(0, 0, -1)) {
         string objName = ObjectName(0, i, 0, -1);
         string temp = StringSubstr(objName, 0, len);
         if(temp != prefixo) {
            i++;
            continue;
         } else {
            i++;
            vwapCount++;
            continue;
         }
      }
      //tempColor = ObjectGetInteger(0, prefixo + 1, OBJPROP_COLOR);;
   } else {
      vwapCount = defaultvwapCount;
   }
//ArrayResize(prefix, vwapCount);
//ArrayResize(startVwap, vwapCount);

   SetIndexBuffer(0, vwapBuffer1, INDICATOR_DATA);
   SetIndexBuffer(1, vwapBuffer2, INDICATOR_DATA);
   SetIndexBuffer(2, vwapBuffer3, INDICATOR_DATA);
   SetIndexBuffer(3, vwapBuffer4, INDICATOR_DATA);
   SetIndexBuffer(4, vwapBuffer5, INDICATOR_DATA);
   SetIndexBuffer(5, vwapBuffer6, INDICATOR_DATA);
   SetIndexBuffer(6, vwapBuffer7, INDICATOR_DATA);
   SetIndexBuffer(7, vwapBuffer8, INDICATOR_DATA);
   SetIndexBuffer(8, vwapBuffer9, INDICATOR_DATA);
   SetIndexBuffer(9, vwapBuffer10, INDICATOR_DATA);
   SetIndexBuffer(10, vwapBuffer11, INDICATOR_DATA);
   SetIndexBuffer(11, vwapBuffer12, INDICATOR_DATA);
   SetIndexBuffer(12, vwapBuffer13, INDICATOR_DATA);
   SetIndexBuffer(13, vwapBuffer14, INDICATOR_DATA);
   SetIndexBuffer(14, vwapBuffer15, INDICATOR_DATA);
   SetIndexBuffer(15, vwapBuffer16, INDICATOR_DATA);
   SetIndexBuffer(16, vwapBuffer17, INDICATOR_DATA);
   SetIndexBuffer(17, vwapBuffer18, INDICATOR_DATA);
   SetIndexBuffer(18, vwapBuffer19, INDICATOR_DATA);
   SetIndexBuffer(19, vwapBuffer20, INDICATOR_DATA);

   Print("vwapCount: " + vwapCount);
   Print("prefix: " + ArraySize(prefix));

   for (int i = 0; i <= vwapCount - 1; i++) {
      prefix[i] = indicatorPrefix + indicatorNumber + "_VWAP_" + (i + 1);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(i, PLOT_LABEL, "VWAP" + i);
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, espessura_linha);
      //PlotIndexSetInteger(i, PLOT_LINE_COLOR, tempColor);
   }

   ArrayInitialize(startVwap, 0);

   if (vwapCount == 0) {
      ArrayInitialize(vwapBuffer1, 0);
      ArrayInitialize(vwapBuffer2, 0);
      ArrayInitialize(vwapBuffer3, 0);
      ArrayInitialize(vwapBuffer4, 0);
      ArrayInitialize(vwapBuffer5, 0);
      ArrayInitialize(vwapBuffer6, 0);
      ArrayInitialize(vwapBuffer7, 0);
      ArrayInitialize(vwapBuffer8, 0);
      ArrayInitialize(vwapBuffer9, 0);
      ArrayInitialize(vwapBuffer10, 0);
      ArrayInitialize(vwapBuffer11, 0);
      ArrayInitialize(vwapBuffer12, 0);
      ArrayInitialize(vwapBuffer13, 0);
      ArrayInitialize(vwapBuffer14, 0);
      ArrayInitialize(vwapBuffer15, 0);
      ArrayInitialize(vwapBuffer16, 0);
      ArrayInitialize(vwapBuffer17, 0);
      ArrayInitialize(vwapBuffer18, 0);
      ArrayInitialize(vwapBuffer19, 0);
      ArrayInitialize(vwapBuffer20, 0);
   } else {
      if (vwapCount == 1) ArrayInitialize(vwapBuffer1, 0);
      else if (vwapCount == 2) ArrayInitialize(vwapBuffer2, 0);
      else if (vwapCount == 3) ArrayInitialize(vwapBuffer3, 0);
      else if (vwapCount == 4) ArrayInitialize(vwapBuffer4, 0);
      else if (vwapCount == 5) ArrayInitialize(vwapBuffer5, 0);
      else if (vwapCount == 6) ArrayInitialize(vwapBuffer6, 0);
      else if (vwapCount == 7) ArrayInitialize(vwapBuffer7, 0);
      else if (vwapCount == 8) ArrayInitialize(vwapBuffer8, 0);
      else if (vwapCount == 9) ArrayInitialize(vwapBuffer9, 0);
      else if (vwapCount == 10) ArrayInitialize(vwapBuffer10, 0);
      else if (vwapCount == 11) ArrayInitialize(vwapBuffer11, 0);
      else if (vwapCount == 12) ArrayInitialize(vwapBuffer12, 0);
      else if (vwapCount == 13) ArrayInitialize(vwapBuffer13, 0);
      else if (vwapCount == 14) ArrayInitialize(vwapBuffer14, 0);
      else if (vwapCount == 15) ArrayInitialize(vwapBuffer15, 0);
      else if (vwapCount == 16) ArrayInitialize(vwapBuffer16, 0);
      else if (vwapCount == 17) ArrayInitialize(vwapBuffer17, 0);
      else if (vwapCount == 18) ArrayInitialize(vwapBuffer18, 0);
      else if (vwapCount == 19) ArrayInitialize(vwapBuffer19, 0);
      else if (vwapCount == 20) ArrayInitialize(vwapBuffer20, 0);
   }

   for (int i = 0; i <= vwapCount - 1; i++) {
      datetime timeArrow = GetObjectTime1(prefix[i]);
      if (timeArrow == 0 && vwapCount >= 1) {
         CreateObject(prefix[i]);
         //CustomizeObject(prefix[i]);
      } else if (timeArrow != 0 && vwapCount < 1) {
         ObjectDelete(0, prefix[i]);
      }
   }

   createButton("botaoAtivo" + indicatorNumber, indicatorNumber * 20, 15, 15, 15, vwapColor, indicatorNumber, ALIGN_CENTER, false, true, false, false, "Esconde os botões");

   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, 0, true);

   _updateTimer = new MillisecondTimer(WaitMilliseconds, false);
   EventSetMillisecondTimer(WaitMilliseconds);

//ChartRedraw();

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator Deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   delete(_updateTimer);

   if(reason != REASON_PARAMETERS && reason != REASON_CHARTCHANGE) {
      ObjectDelete(0, prefixo);
      ChartRedraw();
   }
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
   vwapNumber = 0;
   CheckTimer();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Update() {


   totalRates = SeriesInfoInteger(_Symbol, PERIOD_CURRENT, SERIES_BARS_COUNT);
   prepareData(vwapNumber);

   if (vwapNumber == 0) {
      ArrayInitialize(vwapBuffer1, 0);
      ArrayInitialize(vwapBuffer2, 0);
      ArrayInitialize(vwapBuffer3, 0);
      ArrayInitialize(vwapBuffer4, 0);
      ArrayInitialize(vwapBuffer5, 0);
      ArrayInitialize(vwapBuffer6, 0);
      ArrayInitialize(vwapBuffer7, 0);
      ArrayInitialize(vwapBuffer8, 0);
      ArrayInitialize(vwapBuffer9, 0);
      ArrayInitialize(vwapBuffer10, 0);
      ArrayInitialize(vwapBuffer11, 0);
      ArrayInitialize(vwapBuffer12, 0);
      ArrayInitialize(vwapBuffer13, 0);
      ArrayInitialize(vwapBuffer14, 0);
      ArrayInitialize(vwapBuffer15, 0);
      ArrayInitialize(vwapBuffer16, 0);
      ArrayInitialize(vwapBuffer17, 0);
      ArrayInitialize(vwapBuffer18, 0);
      ArrayInitialize(vwapBuffer19, 0);
      ArrayInitialize(vwapBuffer20, 0);

      if (vwapCount >= 1) CalculateVWAP(startVwap[0], vwapBuffer1);
      if (vwapCount >= 2) CalculateVWAP(startVwap[1], vwapBuffer2);
      if (vwapCount >= 3) CalculateVWAP(startVwap[2], vwapBuffer3);
      if (vwapCount >= 4) CalculateVWAP(startVwap[3], vwapBuffer4);
      if (vwapCount >= 5) CalculateVWAP(startVwap[4], vwapBuffer5);
      if (vwapCount >= 6) CalculateVWAP(startVwap[5], vwapBuffer6);
      if (vwapCount >= 7) CalculateVWAP(startVwap[6], vwapBuffer7);
      if (vwapCount >= 8) CalculateVWAP(startVwap[7], vwapBuffer8);
      if (vwapCount >= 9) CalculateVWAP(startVwap[8], vwapBuffer9);
      if (vwapCount >= 10) CalculateVWAP(startVwap[9], vwapBuffer10);
      if (vwapCount >= 11) CalculateVWAP(startVwap[10], vwapBuffer11);
      if (vwapCount >= 12) CalculateVWAP(startVwap[11], vwapBuffer12);
      if (vwapCount >= 13) CalculateVWAP(startVwap[12], vwapBuffer13);
      if (vwapCount >= 14) CalculateVWAP(startVwap[13], vwapBuffer14);
      if (vwapCount >= 15) CalculateVWAP(startVwap[14], vwapBuffer15);
      if (vwapCount >= 16) CalculateVWAP(startVwap[15], vwapBuffer16);
      if (vwapCount >= 17) CalculateVWAP(startVwap[16], vwapBuffer17);
      if (vwapCount >= 18) CalculateVWAP(startVwap[17], vwapBuffer18);
      if (vwapCount >= 19) CalculateVWAP(startVwap[18], vwapBuffer19);
      if (vwapCount >= 20) CalculateVWAP(startVwap[19], vwapBuffer20);
   } else {
      if (vwapNumber == 1) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer1);
      else if (vwapNumber == 2) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer2);
      else if (vwapNumber == 3) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer3);
      else if (vwapNumber == 4) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer4);
      else if (vwapNumber == 5) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer5);
      else if (vwapNumber == 6) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer6);
      else if (vwapNumber == 7) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer7);
      else if (vwapNumber == 8) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer8);
      else if (vwapNumber == 9) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer9);
      else if (vwapNumber == 10) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer10);
      else if (vwapNumber == 11) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer11);
      else if (vwapNumber == 12) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer12);
      else if (vwapNumber == 13) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer13);
      else if (vwapNumber == 14) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer14);
      else if (vwapNumber == 15) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer15);
      else if (vwapNumber == 16) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer16);
      else if (vwapNumber == 17) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer17);
      else if (vwapNumber == 18) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer18);
      else if (vwapNumber == 19) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer19);
      else if (vwapNumber == 20) CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer20);
   }

   ChartRedraw();

   return(true);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void prepareData(int count = 0) {
   if (count == 0) {
      for (int i = 0; i <= vwapCount - 1; i++) {
         startVwap[i] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[i], OBJPROP_TIME)) + 1;
      }
   } else {
      if (count == 1) startVwap[0] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[0], OBJPROP_TIME)) + 1;
      else  if (count == 2) startVwap[1] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[1], OBJPROP_TIME)) + 1;
      else  if (count == 3) startVwap[2] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[2], OBJPROP_TIME)) + 1;
      else  if (count == 4) startVwap[3] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[3], OBJPROP_TIME)) + 1;
      else  if (count == 5) startVwap[4] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[4], OBJPROP_TIME)) + 1;
      else  if (count == 6) startVwap[5] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[5], OBJPROP_TIME)) + 1;
      else  if (count == 7) startVwap[6] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[6], OBJPROP_TIME)) + 1;
      else  if (count == 8) startVwap[7] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[7], OBJPROP_TIME)) + 1;
      else  if (count == 9) startVwap[8] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[8], OBJPROP_TIME)) + 1;
      else  if (count == 10) startVwap[9] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[9], OBJPROP_TIME)) + 1;
      else  if (count == 11) startVwap[10] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[10], OBJPROP_TIME)) + 1;
      else  if (count == 12) startVwap[11] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[11], OBJPROP_TIME)) + 1;
      else  if (count == 13) startVwap[12] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[12], OBJPROP_TIME)) + 1;
      else  if (count == 14) startVwap[13] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[13], OBJPROP_TIME)) + 1;
      else  if (count == 15) startVwap[14] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[14], OBJPROP_TIME)) + 1;
      else  if (count == 16) startVwap[15] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[15], OBJPROP_TIME)) + 1;
      else  if (count == 17) startVwap[16] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[16], OBJPROP_TIME)) + 1;
      else  if (count == 18) startVwap[17] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[17], OBJPROP_TIME)) + 1;
      else  if (count == 19) startVwap[18] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[18], OBJPROP_TIME)) + 1;
      else  if (count == 20) startVwap[19] = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[19], OBJPROP_TIME)) + 1;
   }

   int maxIndex = startVwap[ArrayMaximum(startVwap)];

   if (applied_volume == VOLUME_TICK) {
      teste = CopyTickVolume(_Symbol, 0, 0, maxIndex, VolumeBuffer);
   } else if (applied_volume == VOLUME_REAL) {
      teste = CopyRealVolume(_Symbol, 0, 0, maxIndex, VolumeBuffer);
   }

   teste = CopyLow(_Symbol, PERIOD_CURRENT, 0, maxIndex, arrayLow);
   teste = CopyClose(_Symbol, PERIOD_CURRENT, 0, maxIndex, arrayClose);
   teste = CopyHigh(_Symbol, PERIOD_CURRENT, 0, maxIndex, arrayHigh);
   teste = CopyOpen(_Symbol, PERIOD_CURRENT, 0, maxIndex, arrayOpen);

   ArraySetAsSeries(arrayOpen, true);
   ArraySetAsSeries(arrayLow, true);
   ArraySetAsSeries(arrayClose, true);
   ArraySetAsSeries(arrayHigh, true);
   ArraySetAsSeries(VolumeBuffer, true);

   ArraySetAsSeries(vwapBuffer1, true);
   ArraySetAsSeries(vwapBuffer2, true);
   ArraySetAsSeries(vwapBuffer3, true);
   ArraySetAsSeries(vwapBuffer4, true);
   ArraySetAsSeries(vwapBuffer5, true);
   ArraySetAsSeries(vwapBuffer6, true);
   ArraySetAsSeries(vwapBuffer7, true);
   ArraySetAsSeries(vwapBuffer8, true);
   ArraySetAsSeries(vwapBuffer9, true);
   ArraySetAsSeries(vwapBuffer10, true);
   ArraySetAsSeries(vwapBuffer11, true);
   ArraySetAsSeries(vwapBuffer12, true);
   ArraySetAsSeries(vwapBuffer13, true);
   ArraySetAsSeries(vwapBuffer14, true);
   ArraySetAsSeries(vwapBuffer15, true);
   ArraySetAsSeries(vwapBuffer16, true);
   ArraySetAsSeries(vwapBuffer17, true);
   ArraySetAsSeries(vwapBuffer18, true);
   ArraySetAsSeries(vwapBuffer19, true);
   ArraySetAsSeries(vwapBuffer20, true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateVWAP(int index, double & targetBuffer[]) {

   ArrayInitialize(targetBuffer, 0);

   double sumPrice = 0, sumVol = 0, vwap = 0;

   if(method == Open) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayOpen[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == High) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayHigh[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == Low) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayLow[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == Median) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += ((arrayHigh[i] + arrayLow[i]) / 2) * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == Typical) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += ((arrayHigh[i] + arrayLow[i] + arrayClose[i]) / 3) * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == Weighted) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += ((arrayHigh[i] + arrayLow[i] + arrayClose[i] + arrayClose[i]) / 4) * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBuffer[i] = sumPrice / sumVol;
      }
   } else {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayClose[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBuffer[i] = sumPrice / sumVol;
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateObject(string name, int candle = 0, double price = 0, int direcao = 0) {

   int offset = 0;
   if (candle == 0 || price == 0) {
      barras_visiveis = (int)ChartGetInteger(0, CHART_WIDTH_IN_BARS);
      offset = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR) - barras_visiveis / 2;
   }

   if (candle == 0) {
      Hposition = iTime(_Symbol, PERIOD_CURRENT, offset);
   } else {
      Hposition = iTime(_Symbol, PERIOD_CURRENT, candle);
   }

   if (price == 0) {
      Vposition = iHigh(_Symbol, PERIOD_CURRENT, barras_visiveis - offset);
   } else {
      Vposition = price;
   }

   ObjectCreate(0, name, OBJ_ARROW, 0, Hposition, Vposition);

   if (direcao == 0)
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, 233);
   else if (direcao == 1)
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, 234);

   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
//ObjectSetInteger(0, name, OBJPROP_COLOR, tempColor);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, true);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 100);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CustomizeObject(string name) {

   ArrayInitialize(vwapBuffer1, 0);
   ArrayInitialize(vwapBuffer2, 0);
   ArrayInitialize(vwapBuffer3, 0);
   ArrayInitialize(vwapBuffer4, 0);
   ArrayInitialize(vwapBuffer5, 0);
   ArrayInitialize(vwapBuffer6, 0);
   ArrayInitialize(vwapBuffer7, 0);
   ArrayInitialize(vwapBuffer8, 0);
   ArrayInitialize(vwapBuffer9, 0);
   ArrayInitialize(vwapBuffer10, 0);
   ArrayInitialize(vwapBuffer11, 0);
   ArrayInitialize(vwapBuffer12, 0);
   ArrayInitialize(vwapBuffer13, 0);
   ArrayInitialize(vwapBuffer14, 0);
   ArrayInitialize(vwapBuffer15, 0);
   ArrayInitialize(vwapBuffer16, 0);
   ArrayInitialize(vwapBuffer17, 0);
   ArrayInitialize(vwapBuffer18, 0);
   ArrayInitialize(vwapBuffer19, 0);
   ArrayInitialize(vwapBuffer20, 0);

   int posicao = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, name, OBJPROP_TIME));
   double preco = ObjectGetDouble(0, name, OBJPROP_PRICE);
   if (preco == 0) {
      preco = iLow(_Symbol, PERIOD_CURRENT, posicao);
   }

   Hposition = iTime(_Symbol, PERIOD_CURRENT, posicao);

   ObjectMove(0, name, 0, Hposition, preco);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, arrowSize);
//ObjectSetInteger(0, name, OBJPROP_COLOR, tempColor);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createButton(string name, int x, int y, int largura, int altura, color cor, string texto, ENUM_ALIGN_MODE alinhamento, bool back, bool hidden, bool selectable, bool selected, string tooltip) {

   ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_BUTTON, 0, x, 0);
   ObjectSetString(0, name, OBJPROP_NAME, name);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, altura);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, largura);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, cor);
   ObjectSetString(0, name, OBJPROP_TEXT, texto);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, selectable);
   ObjectSetInteger(0, name, OBJPROP_ALIGN, alinhamento);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 1000);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, selected);
   ObjectSetInteger(0, name, OBJPROP_STATE, 0, selected);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tooltip);

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

bool _lastOK = false;
MillisecondTimer *_updateTimer;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckTimer() {
   EventKillTimer();

   if(_updateTimer.Check() || !_lastOK) {
      _lastOK = Update();

      EventSetMillisecondTimer(WaitMilliseconds);

      ChartRedraw();
      if (debug) Print("VWAP Midas " + " " + _Symbol + ":" + GetTimeFrame(Period()) + " ok");

      _updateTimer.Reset();
   } else {
      EventSetTimer(1);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define KEY_SHIFT  16
#define KEY_H   72
#define KEY_L   76
#define KEY_Q   81
#define KEY_C  67
static bool ctrl_pressed = false;
static int ctrl_count = 0;

//+------------------------------------------------------------------+
//| Custom indicator Chart Event function                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long & lparam, const double & dparam, const string & sparam) {

   vwapNumber = 0; // inicializamos o valor para evitar qualquer erro de tamanho de array após um mouse drag

   if(id == CHARTEVENT_KEYDOWN) {

      //int shift = GetAsyncKeyState(16);
      if (ctrl_pressed == false && lparam == KEY_SHIFT) {
         ctrl_pressed = true;
         ctrl_count++;
         if (ctrl_count > 1)
            return;
      } else if (ctrl_pressed == true) {
         if(lparam == KEY_Q) {
            if (vwapCount > 1) {
               ObjectDelete(0, prefix[vwapCount - 1]);
               ChartRedraw();
               _lastOK = false;
               CheckTimer();
            } else {
               Print("Não é possível excluir todas as vwaps.");
            }
         }

//         if(randomColor == false && lparam == KEY_C) {
//            if (vwapCount >= 1) {
//               if (tempColor == clrLime) {
//                  tempColor = clrFuchsia;
//               } else if (tempColor == clrFuchsia) {
//                  tempColor = clrYellow;
//               } else if(tempColor == clrYellow) {
//                  tempColor = clrRed;
//               } else if(tempColor == clrRed) {
//                  tempColor = clrRoyalBlue;
//               } else if(tempColor == clrRoyalBlue) {
//                  tempColor = clrLime;
//               }
//
//               for (int i = 0; i <= vwapCount - 1; i++) {
//                  PlotIndexSetInteger(i, PLOT_LINE_COLOR, tempColor);
//                  ObjectSetInteger(0, prefixo + (i + 1), OBJPROP_COLOR, tempColor);
//               }
//               ChartRedraw();
//            } else {
//               Print("Não é possível excluir todas as vwaps.");
//            }
//         }
      }

   }

   static ulong clickTimeMemory;
   if(ctrl_pressed && id == CHARTEVENT_CLICK && ObjectGetInteger(0, "btnAtivo" + indicatorPrefix, OBJPROP_STATE) == true) {
      ulong clickTime = GetTickCount();
      if(clickTime < clickTimeMemory + 500) {
         clickTimeMemory = 0;
         int x = (int)lparam;
         int y = (int)dparam;
         datetime dt = 0;
         double clickprice = 0, highprice = 0, lowprice = 0, price = 0;
         int window = 0, direcao = 0;
         if(ChartXYToTimePrice(0, x, y, window, dt, clickprice)) {
            int cnt = iBarShift(Symbol(), PERIOD_CURRENT, dt, false);
            highprice = iHigh(_Symbol, PERIOD_CURRENT, cnt);
            lowprice = iLow(_Symbol, PERIOD_CURRENT, cnt);
            if (clickprice > highprice) {
               price = highprice + 0.002 * highprice;
               direcao = 1;
            }

            if (clickprice < lowprice) {
               price = lowprice - 0.002 * lowprice;
               direcao = 0;
            }

            vwapCount++;
            if (vwapCount <= 20) {
               //int r = MathRand();
               //int g = MathRand();
               //int b = MathRand();
               //tempColor = r + g + b;
               ArrayResize(prefix, vwapCount);
               ArrayResize(startVwap, vwapCount);
               startVwap[vwapCount - 1] = cnt;
               prefix[vwapCount - 1] = indicatorPrefix + indicatorNumber + "_VWAP_" + (vwapCount);
               CreateObject(prefix[vwapCount - 1], cnt, price, direcao);
               //CustomizeObject(prefix[vwapCount - 1]);
               for (int i = 0; i <= vwapCount - 1; i++) {
                  PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
                  PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
                  PlotIndexSetString(i, PLOT_LABEL, "VWAP" + i);
                  PlotIndexSetInteger(i, PLOT_LINE_WIDTH, espessura_linha);
                  PlotIndexSetInteger(i, PLOT_LINE_COLOR, vwapColor);
               }
               ChartRedraw();
               vwapNumber = 0;
               _lastOK = false;
               CheckTimer();
            } else {
               Print("Limite de vwaps atingido. Adicione outro indicador ao gráfico.");
            }
         }
         ctrl_count = 0;
      } else {
         ctrl_pressed = false;
         clickTimeMemory = clickTime;
      }

   }

   if(id == CHARTEVENT_OBJECT_CLICK) {
      if (sparam == "btnAtivo1") {
         //ObjectSetInteger(0, "btnAtivo1", OBJPROP_STATE, true);
         ObjectSetInteger(0, "btnAtivo2", OBJPROP_STATE, false);
         //ObjectSetInteger(0, "btnAtivo"+1, OBJPROP_SELECTED, true);
         //ObjectSetInteger(0, "btnAtivo"+2, OBJPROP_SELECTED, false);
         ChartRedraw(0);
      }
      if (sparam == "btnAtivo2") {
         ObjectSetInteger(0, "btnAtivo1", OBJPROP_STATE, false);
         //ObjectSetInteger(0, "btnAtivo2", OBJPROP_STATE, true);
         //ObjectSetInteger(0, "btnAtivo"+1, OBJPROP_SELECTED, true);
         //ObjectSetInteger(0, "btnAtivo"+2, OBJPROP_SELECTED, false);
         ChartRedraw(0);
      }
   }

   if(id == CHARTEVENT_OBJECT_DRAG) {
      if (sparam == prefix[0]) vwapNumber = 1;
      else if (sparam == prefix[1]) vwapNumber = 2;
      else if (sparam == prefix[2]) vwapNumber = 3;
      else if (sparam == prefix[3]) vwapNumber = 4;
      else if (sparam == prefix[4]) vwapNumber = 5;
      else if (sparam == prefix[5]) vwapNumber = 6;
      else if (sparam == prefix[6]) vwapNumber = 7;
      else if (sparam == prefix[7]) vwapNumber = 8;
      else if (sparam == prefix[8]) vwapNumber = 9;
      else if (sparam == prefix[9]) vwapNumber = 10;
      else if (sparam == prefix[10]) vwapNumber = 11;
      else if (sparam == prefix[11]) vwapNumber = 12;
      else if (sparam == prefix[12]) vwapNumber = 13;
      else if (sparam == prefix[13]) vwapNumber = 14;
      else if (sparam == prefix[14]) vwapNumber = 15;
      else if (sparam == prefix[15]) vwapNumber = 16;
      else if (sparam == prefix[16]) vwapNumber = 17;
      else if (sparam == prefix[17]) vwapNumber = 18;
      else if (sparam == prefix[18]) vwapNumber = 19;
      else if (sparam == prefix[19]) vwapNumber = 20;

      _lastOK = false;
      CheckTimer();
   }

   if(id == CHARTEVENT_CHART_CHANGE) {
      _lastOK = true;
      CheckTimer();
   }

   if(id == CHARTEVENT_OBJECT_DELETE) {
      string temp = StringSubstr(sparam, 0, len);
      if(temp == prefixo) {
         vwapCount--;
      }

      string tempArray[];
      ArrayResize(tempArray, vwapCount);
      int contador = 0, indiceRemocao;
      for (int i = 0; i <= ArraySize(prefix) - 1; i++) {
         if(prefix[i] == sparam) {
            indiceRemocao = i;
            tempArray[contador] = prefix[i];
            contador++;
         }
      }

      ArrayRemove(prefix, indiceRemocao, 1);
      ArrayRemove(startVwap, indiceRemocao, 1);

      vwapNumber = 0;
      _lastOK = false;
      CheckTimer();
   }
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
//| iBarShift2() function                                             |
//+------------------------------------------------------------------+
int iBarShift2(string symbol, ENUM_TIMEFRAMES timeframe, datetime time) {
   if(time < 0) {
      return(-1);
   }
   datetime Arr[], time1;

   time1 = (datetime)SeriesInfoInteger(symbol, timeframe, SERIES_LASTBAR_DATE);

   if(CopyTime(symbol, timeframe, time, time1, Arr) > 0) {
      int size = ArraySize(Arr);
      return(size - 1);
   } else {
      return(-1);
   }
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
