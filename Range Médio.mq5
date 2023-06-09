//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "Range Médio"
#property indicator_chart_window
#property indicator_buffers 16
#property indicator_plots   16

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double up1[], up2[], up3[], up4[], up5[], up6[], up7[], up8[], down1[], down2[], down3[], down4[], down5[], down6[], down7[], down8[];
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
datetime ExtTimeBuffer[];
double media[];
double stdev[];
double rangeArray[];
double qtd = 365;
datetime data_inicial;
int barFrom;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input datetime                   DefaultInitialDate              = "2021.1.1 9:00:00";          // Data inicial padrão

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   data_inicial = DefaultInitialDate;
   barFrom = iBarShift(NULL, PERIOD_D1, data_inicial);
   qtd = barFrom;

//--- indicator buffers mapping
   SetIndexBuffer(0, up1, INDICATOR_DATA);
   SetIndexBuffer(1, up2, INDICATOR_DATA);
   SetIndexBuffer(2, up3, INDICATOR_DATA);
   SetIndexBuffer(3, up4, INDICATOR_DATA);
   SetIndexBuffer(4, up5, INDICATOR_DATA);
   SetIndexBuffer(5, up6, INDICATOR_DATA);
   SetIndexBuffer(6, up7, INDICATOR_DATA);
   SetIndexBuffer(7, up8, INDICATOR_DATA);
   SetIndexBuffer(8, down1, INDICATOR_DATA);
   SetIndexBuffer(9, down2, INDICATOR_DATA);
   SetIndexBuffer(10, down3, INDICATOR_DATA);
   SetIndexBuffer(11, down4, INDICATOR_DATA);
   SetIndexBuffer(12, down5, INDICATOR_DATA);
   SetIndexBuffer(13, down6, INDICATOR_DATA);
   SetIndexBuffer(14, down7, INDICATOR_DATA);
   SetIndexBuffer(15, down8, INDICATOR_DATA);

   for(int i = 0; i <= 15; i++) {
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_ARROW );
      PlotIndexSetInteger(i, PLOT_LINE_COLOR, clrDimGray);
      PlotIndexSetString(i, PLOT_LABEL, "RM ");
      //PlotIndexSetInteger(i,PLOT_LINE_WIDTH,1);
      PlotIndexSetInteger(i, PLOT_ARROW, 158);
   }

   PlotIndexSetInteger(7, PLOT_LINE_COLOR, clrMagenta);
   PlotIndexSetInteger(6, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, clrOrange);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, clrYellow);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, clrGreen);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrRoyalBlue);

   PlotIndexSetInteger(15, PLOT_LINE_COLOR, clrMagenta);
   PlotIndexSetInteger(14, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(13, PLOT_LINE_COLOR, clrOrange);
   PlotIndexSetInteger(12, PLOT_LINE_COLOR, clrYellow);
   PlotIndexSetInteger(11, PLOT_LINE_COLOR, clrGreen);
   PlotIndexSetInteger(8, PLOT_LINE_COLOR, clrRoyalBlue);

   double total = 0;

   ArrayResize(rangeArray, qtd * 2);
   ArrayResize(media, qtd * 2);
   ArrayResize(stdev, qtd * 2);

   ArrayInitialize(up1, 0);
   ArrayInitialize(up2, 0);
   ArrayInitialize(up3, 0);
   ArrayInitialize(up4, 0);
   ArrayInitialize(up5, 0);
   ArrayInitialize(up6, 0);
   ArrayInitialize(up7, 0);
   ArrayInitialize(up8, 0);
   ArrayInitialize(down1, 0);
   ArrayInitialize(down2, 0);
   ArrayInitialize(down3, 0);
   ArrayInitialize(down4, 0);
   ArrayInitialize(down5, 0);
   ArrayInitialize(down6, 0);
   ArrayInitialize(down7, 0);
   ArrayInitialize(down8, 0);

   ArraySetAsSeries(up1, true);
   ArraySetAsSeries(up2, true);
   ArraySetAsSeries(up3, true);
   ArraySetAsSeries(up4, true);
   ArraySetAsSeries(up5, true);
   ArraySetAsSeries(up6, true);
   ArraySetAsSeries(up7, true);
   ArraySetAsSeries(up8, true);
   ArraySetAsSeries(down1, true);
   ArraySetAsSeries(down2, true);
   ArraySetAsSeries(down3, true);
   ArraySetAsSeries(down4, true);
   ArraySetAsSeries(down5, true);
   ArraySetAsSeries(down6, true);
   ArraySetAsSeries(down7, true);
   ArraySetAsSeries(down8, true);

   CopyTime(_Symbol, PERIOD_D1, 0, qtd * 2, ExtTimeBuffer);
   CopyOpen(_Symbol, PERIOD_D1, 0, qtd * 2, ExtOpenBuffer);
   CopyHigh(_Symbol, PERIOD_D1, 0, qtd * 2, ExtHighBuffer);
   CopyLow(_Symbol, PERIOD_D1, 0, qtd * 2, ExtLowBuffer);
   CopyClose(_Symbol, PERIOD_D1, 0, qtd * 2, ExtCloseBuffer);

   ArraySetAsSeries(ExtTimeBuffer, true);
   ArraySetAsSeries(ExtOpenBuffer, true);
   ArraySetAsSeries(ExtHighBuffer, true);
   ArraySetAsSeries(ExtLowBuffer, true);
   ArraySetAsSeries(ExtCloseBuffer, true);

   double max, min, range;
   for (int i = 0 ; i < qtd; i++) {
      ArrayInitialize(rangeArray, 0);
      total = 0;
      for (int j = i ; j < i + qtd; j++) {
         max = ExtHighBuffer[j];
         min = ExtLowBuffer[j];
         rangeArray[j] = MathAbs(max - min);
         total = total + rangeArray[j];

      }
      media[i] = total / qtd;
      stdev[i] = GetStdDev(rangeArray, qtd);
   }

//   for (int k = 0; k< qtd; k++){
//      int barraDoDia = k;
//      datetime dataInicial = iTime(_Symbol, PERIOD_D1, barraDoDia);
//      datetime dataFinal = GetBarTime(0, PERIOD_CURRENT);
//      if (barraDoDia < 0)
//         dataFinal = GetBarTime(0, PERIOD_CURRENT);
//      else
//         dataFinal = iTime(_Symbol, PERIOD_D1, barraDoDia - 1);
//
//      int firstDayBar = iBarShift(_Symbol, PERIOD_CURRENT, dataInicial);
//      int lastDayBar = iBarShift(_Symbol, PERIOD_CURRENT, dataFinal);
//
//      int numeroBarrasDoDia = MathAbs(lastDayBar - firstDayBar);
//      ArrayResize(up1, numeroBarrasDoDia);
//      ArrayResize(up2, numeroBarrasDoDia);
//      ArrayResize(up3, numeroBarrasDoDia);
//      ArrayResize(up4, numeroBarrasDoDia);
//      ArrayResize(up5, numeroBarrasDoDia);
//      ArrayResize(up6, numeroBarrasDoDia);
//      ArrayResize(up7, numeroBarrasDoDia);
//      ArrayResize(up8, numeroBarrasDoDia);
//
//      ArrayResize(down1, numeroBarrasDoDia);
//      ArrayResize(down2, numeroBarrasDoDia);
//      ArrayResize(down3, numeroBarrasDoDia);
//
//      if (ExtCloseBuffer[barraDoDia] >= ExtOpenBuffer[barraDoDia]){
//         for (int i=lastDayBar; i<= firstDayBar; i++){
//            up1[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia] - 0.75 * stdev[barraDoDia];
//            up2[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia] - 0.5 * stdev[barraDoDia];
//            up3[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia] - 0.25 * stdev[barraDoDia];;
//            up4[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia];
//            up5[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia] + 1 * stdev[barraDoDia];
//            up6[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia] + 2 * stdev[barraDoDia];
//            up7[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia] + 3 * stdev[barraDoDia];
//            up8[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia] + 4 * stdev[barraDoDia];
//         }
//       } else {
//         for (int i=lastDayBar ; i< firstDayBar; i++){
//            down1[i] = ExtHighBuffer[barraDoDia] - media[barraDoDia];
//            down2[i] = ExtHighBuffer[barraDoDia] - media[barraDoDia] - 1 * stdev[barraDoDia];
//            down3[i] = ExtHighBuffer[barraDoDia] - media[barraDoDia] - 2 * stdev[barraDoDia];
//         }
//       }
//    }


   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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

   for (int k = 0; k < qtd; k++) {
      int barraDoDia = k;
      datetime dataInicial = iTime(_Symbol, PERIOD_D1, barraDoDia);
      datetime dataFinal = GetBarTime(0, PERIOD_CURRENT);
      if (barraDoDia < 1)
         dataFinal = GetBarTime(0, PERIOD_CURRENT);
      else
         dataFinal = iTime(_Symbol, PERIOD_D1, barraDoDia - 1);

      int firstDayBar = iBarShift(_Symbol, PERIOD_CURRENT, dataInicial);
      int lastDayBar = iBarShift(_Symbol, PERIOD_CURRENT, dataFinal);

      if (ExtCloseBuffer[barraDoDia] >= ExtOpenBuffer[barraDoDia]) {
         for (int i = lastDayBar; i <= firstDayBar; i++) {
            up1[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia] - 1 * stdev[barraDoDia];
            up2[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia] - 0.75 * stdev[barraDoDia];
            up3[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia] - 0.5 * stdev[barraDoDia];;
            up4[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia];
            up5[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia] + 0.5 * stdev[barraDoDia];
            up6[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia] + 1 * stdev[barraDoDia];
            up7[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia] + 2 * stdev[barraDoDia];
            up8[i] = ExtLowBuffer[barraDoDia] + media[barraDoDia] + 3 * stdev[barraDoDia];
         }
      } else {
         for (int i = lastDayBar ; i < firstDayBar; i++) {

            down1[i] = ExtHighBuffer[barraDoDia] - (media[barraDoDia] - 1 * stdev[barraDoDia]);
            down2[i] = ExtHighBuffer[barraDoDia] - (media[barraDoDia] - 0.75 * stdev[barraDoDia]);
            down3[i] = ExtHighBuffer[barraDoDia] - (media[barraDoDia] - 0.5 * stdev[barraDoDia]);
            down4[i] = ExtHighBuffer[barraDoDia] - media[barraDoDia];
            down5[i] = ExtHighBuffer[barraDoDia] - (media[barraDoDia] + 0.5 * stdev[barraDoDia]);
            down6[i] = ExtHighBuffer[barraDoDia] - (media[barraDoDia] + 1 * stdev[barraDoDia]);
            down7[i] = ExtHighBuffer[barraDoDia] - (media[barraDoDia] + 2 * stdev[barraDoDia]);
            down8[i] = ExtHighBuffer[barraDoDia] - (media[barraDoDia] + 3 * stdev[barraDoDia]);
         }
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStdDev(const double &arr[], int size) {
   if(size < 2)
      return(0.0);

   double sum = 0.0;
   for(int i = 0; i < size; i++) {
      sum = sum + arr[i];
   }

   sum = sum / size;

   double sum2 = 0.0;
   for(int i = 0; i < size; i++) {
      sum2 = sum2 + (arr[i] - sum) * (arr[i] - sum);
   }

   sum2 = sum2 / (size - 1);
   sum2 = MathSqrt(sum2);

   return(sum2);
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
datetime miTime(string symbol, ENUM_TIMEFRAMES timeframe, int index) {
   if(index < 0)
      return(-1);

   datetime arr[];

   if(CopyTime(symbol, timeframe, index, 1, arr) <= 0)
      return(-1);

   return(arr[0]);
}
//+------------------------------------------------------------------+
