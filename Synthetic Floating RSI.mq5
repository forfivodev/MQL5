//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link "mladenfx@gmail.com"
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "Synthetic Floating RSI"

#property indicator_separate_window
#property indicator_buffers 11
#property indicator_plots   9
#property indicator_label1  "Filling - RSI"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'45,45,45',C'45,45,45'
#property indicator_label2  "RSI"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  C'65,65,65',clrLime,clrRed
#property indicator_width2  3
#property indicator_label3  "Signal -RSI"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  C'65,65,65',clrLime,clrRed
#property indicator_width3  1

#property indicator_label4  "REG"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrYellow
#property indicator_width4  1

#property indicator_label5  "STDEV +1"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_width5  1

#property indicator_label6  "STDEV -1"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_width6  1

#property indicator_label7  "STDEV +2"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrMagenta
#property indicator_width7  1

#property indicator_label8  "STDEV -2"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrMagenta
#property indicator_width8  1

//#property indicator_level1  80
//#property indicator_level2  20
//#property indicator_minimum 0
//#property indicator_maximum 110
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum tipoEscala {
   x1,
   x10,
   x100,
   x1000
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- input parameters
input int                inpEmaPeriod1   = 30;  // Ema 1 period
input int                inpRsiPeriod1   = 20;  // Rsi 1 period
input int                inpEmaPeriod2   = 20;  // Ema 2 period
input int                inpRsiPeriod2   = 10;  // Rsi 2 period
input int                inpEmaPeriod3   = 10;  // Ema 3 period
input int                inpRsiPeriod3   =  5;  // Rsi 3 period
input double             InpExtremeOverbought       =  80.0; // Extreme overbought
input double             InpOverbought  =  70.0; // Overbought
//input double             InpMid    =  0.0; // Oversold
input double             InpOversold    =  30.0; // Oversold
input double             InpExtremeOversold       =  20.0; // Extreme oversold
input color              regColor                            = clrBlack;     // Indicator color
input color              regColorMid                            = clrYellow;     // Indicator color
input color              regColorOverbought                  = clrRed;         // Overbought color
input color              regColorOversold                    = clrLime;        // Oversold color
input ENUM_APPLIED_PRICE inpPrice = PRICE_CLOSE; // Price
input int                inpSignalPeriod = 8;
input bool               showLevelColor = false;    // Show levels in colors
input tipoEscala inputEscala = "100";
input  int    inpFlLookBack   = 20;    // Floating levels look back period
input  double inpFlLevelUp    = 90;    // Floating levels up level %
input  double inpFlLevelDown  = 10;    // Floating levels down level %
input datetime                   DefaultInitialDate              = "2020.1.1 9:00:00";          // Data inicial padrão

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- buffers declarations
double val[], valc[], levup[], levdn[], signal[], signalc[];
double regChannelBuffer[];
double upChannel1[], upChannel2[];
double downChannel1[], downChannel2[];
double A, B, stdev;
datetime data_inicial;
int barFrom;

double         upper;
double         overbought;
double         oversold;
double         lower;
double multEscala = 1;
double totalVolume = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   if (inputEscala == x1) {
      multEscala = 0.01;
   } else if (inputEscala == x10) {
      multEscala = 0.1;
   } else if (inputEscala == x100) {
      multEscala = 1;
   } else {
      multEscala = 10;
   }

   overbought = (fabs(InpOverbought) < 0.1 ? 0.1 : InpOverbought > 99.9 ? 99.9 : fabs(InpOverbought));
   oversold = (-fabs(InpOversold) > -0.1 ? -0.1 : -fabs(InpOversold) < -99.9 ? -99.9 : -fabs(InpOversold));
   upper = (fabs(InpExtremeOverbought) <= overbought ? overbought + 0.1 : InpExtremeOverbought > 100.0 ? 100.0 : fabs(InpExtremeOverbought));
   lower = (-fabs(InpExtremeOversold) >= oversold ? oversold - 0.1 : -fabs(InpExtremeOversold) < -100.0 ? -100.0 : -fabs(InpExtremeOversold));

//--- indicator buffers mapping
   SetIndexBuffer(0, levup, INDICATOR_DATA);
   SetIndexBuffer(1, levdn, INDICATOR_DATA);
   SetIndexBuffer(2, val, INDICATOR_DATA);
   SetIndexBuffer(3, valc, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4, signal, INDICATOR_DATA);
   SetIndexBuffer(5, signalc, INDICATOR_COLOR_INDEX);
//SetIndexBuffer(6, mid, INDICATOR_DATA);

   ArrayInitialize(regChannelBuffer, 0);
   ArrayInitialize(upChannel1, 0);
   ArrayInitialize(downChannel1, 0);
   ArrayInitialize(upChannel2, 0);
   ArrayInitialize(downChannel2, 0);

   SetIndexBuffer(6, regChannelBuffer, INDICATOR_DATA);
   SetIndexBuffer(7, upChannel1, INDICATOR_DATA);
   SetIndexBuffer(8, downChannel1, INDICATOR_DATA);
   SetIndexBuffer(9, upChannel2, INDICATOR_DATA);
   SetIndexBuffer(10, downChannel2, INDICATOR_DATA);

   ArraySetAsSeries(regChannelBuffer, true);
   ArraySetAsSeries(upChannel1, true);
   ArraySetAsSeries(downChannel1, true);
   ArraySetAsSeries(upChannel2, true);
   ArraySetAsSeries(downChannel2, true);

//IndicatorSetInteger(INDICATOR_LEVELS, 4);
//IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, InpExtremeOverbought * multEscala);
//IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, InpOverbought * multEscala);
//IndicatorSetDouble(INDICATOR_LEVELVALUE, 2, InpOversold * multEscala);
//IndicatorSetDouble(INDICATOR_LEVELVALUE, 3, InpExtremeOversold * multEscala);
//IndicatorSetDouble(INDICATOR_LEVELVALUE, 4, InpMid * multEscala);

//IndicatorSetString(INDICATOR_LEVELTEXT, 0, "Extreme overbought");
//IndicatorSetString(INDICATOR_LEVELTEXT, 1, "Overbought");
//IndicatorSetString(INDICATOR_LEVELTEXT, 2, "Oversold");
//IndicatorSetString(INDICATOR_LEVELTEXT, 3, "Extreme oversold");
   if(showLevelColor) {
      IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, regColorOverbought);
      IndicatorSetInteger(INDICATOR_LEVELCOLOR, 1, regColorOverbought);
      IndicatorSetInteger(INDICATOR_LEVELCOLOR, 2, regColorOversold);
      IndicatorSetInteger(INDICATOR_LEVELCOLOR, 3, regColorOversold);
      //IndicatorSetInteger(INDICATOR_LEVELCOLOR, 4, regColorMid);
   } else {
      IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, C'65,65,65');
      IndicatorSetInteger(INDICATOR_LEVELCOLOR, 1, C'65,65,65');
      IndicatorSetInteger(INDICATOR_LEVELCOLOR, 2, C'65,65,65');
      IndicatorSetInteger(INDICATOR_LEVELCOLOR, 3, C'65,65,65');
      //IndicatorSetInteger(INDICATOR_LEVELCOLOR, 4, C'65,65,65');
   }

   for (int i = 0; i < 10; i++) {
      PlotIndexSetInteger(i, PLOT_SHOW_DATA, false);       //--- repeat for each plot
   }

   data_inicial = DefaultInitialDate;
   barFrom = iBarShift(NULL, PERIOD_CURRENT, data_inicial);

   IndicatorSetInteger(INDICATOR_DIGITS, 1);
   IndicatorSetString(INDICATOR_SHORTNAME, "SF RSI");

//--- indicator short name assignment
//IndicatorSetString(INDICATOR_SHORTNAME, "Synthetic RSI (" + (string)inpRsiPeriod1 + "," + (string)inpEmaPeriod1 + "," + (string)inpRsiPeriod2 + "," + (string)inpEmaPeriod2 + "," + (string)inpRsiPeriod3 + "," + (string)inpEmaPeriod3 + ")");
//---
   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

   if(Bars(_Symbol, _Period) < rates_total)
      return(prev_calculated);

   int i = (int)MathMax(prev_calculated - 20, 1);

   for(; i < rates_total && !_StopFlag; i++) {
      double price = getPrice(inpPrice, open, close, high, low, i, rates_total);
      double rsi1 = iRsi(iEma(price, inpEmaPeriod1, i, rates_total, 0), inpRsiPeriod1, i, rates_total, 0);
      double rsi2 = iRsi(iEma(price, inpEmaPeriod2, i, rates_total, 1), inpRsiPeriod2, i, rates_total, 1);
      double rsi3 = iRsi(iEma(price, inpEmaPeriod3, i, rates_total, 2), inpRsiPeriod3, i, rates_total, 2);
      val[i]     = ((rsi3 + 2.0 * rsi2 + 3.0 * rsi1) / 6.0);
      signal[i]  = iEma(val[i], inpSignalPeriod, i, rates_total, 3);

      int _start = MathMax(i - inpFlLookBack, 0);
      double min = val[ArrayMinimum(val, _start, inpFlLookBack)];
      double max = val[ArrayMaximum(val, _start, inpFlLookBack)];
      double range = max - min;
      levup[i] = min + inpFlLevelUp * range / 100.0 ;
      //mid[i] = min + 50 * range / 100.0;
      levdn[i] = min + inpFlLevelDown * range / 100.0 ;

      //valc[i]  = (val[i] >= levup[i] && val[i] >= InpOverbought) ? 1 : (val[i] <= levdn[i] && val[i] <= InpOversold) ? 2 : 0;
      //signalc[i] = valc[i];
   }

   double dataArray[];
   ArrayCopy(dataArray, val);
   ArrayReverse(dataArray);
   barFrom = iBarShift(NULL, PERIOD_CURRENT, data_inicial);

   CalcAB(dataArray, 0, barFrom, A, B);
   stdev = GetStdDev(dataArray, 0, barFrom); //calculate standand deviation


   for(int n = 0; n < ArraySize(regChannelBuffer) - 1; n++) {
      regChannelBuffer[n] = 0.0;
      upChannel2[n] = 0.0;
      upChannel1[n] = 0.0;
      downChannel1[n] = 0.0;
      downChannel2[n] = 0.0;
   }

   for (int i = 0; i < barFrom  && !_StopFlag; i++) {
      upChannel2[i] = (A * (i) + B) + 1.5 * stdev;
      upChannel1[i] = (A * (i) + B) + 1 * stdev;
      regChannelBuffer[i] = (A * (i) + B);
      downChannel1[i] = (A * (i) + B) - 1 * stdev;
      downChannel2[i] = (A * (i) + B) - 1.5 * stdev;
   }

   double temp1[], temp2[], temp3[], temp4[];
   ArrayCopy(temp1, upChannel1);
   ArrayCopy(temp2, upChannel2);
////ArrayReverse(temp1);

   ArrayCopy(temp3, downChannel1);
   ArrayCopy(temp4, downChannel2);
//ArrayReverse(temp2);

   for (int i = 0; i < rates_total  && !_StopFlag; i++) {
      //valc[i]  = (val[i] >= levup[i] && val[i] >= InpOverbought * multEscala && levup[i] >= InpExtremeOverbought * multEscala) ? 1 : (val[i] <= levdn[i] && val[i] <= InpOversold * multEscala && levdn[i] <= InpExtremeOversold * multEscala) ? 2 : 0;
      valc[i]  = (val[i] >= temp1[i]) ? 1 : (val[i] <= temp3[i]) ? 2 : 0;

   }

   return (i);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define rsiInstances 3
#define rsiInstancesSize 3
double workRsi[][rsiInstances * rsiInstancesSize];
#define _price  0
#define _prices 3
#define _change 1
#define _changa 2

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iRsi(double price, double period, int r, int bars, int instanceNo = 0) {
   if(ArrayRange(workRsi, 0) != bars)
      ArrayResize(workRsi, bars);

   int z = instanceNo * rsiInstancesSize;

   workRsi[r][z + _price] = price;
   double alpha = 1.0 / MathMax(period, 1);
   if(r < period) {
      int k;
      double sum = 0;
      for(k = 0; k < period && (r - k - 1) >= 0; k++) sum += MathAbs(workRsi[r - k][z + _price] - workRsi[r - k - 1][z + _price]);
      workRsi[r][z + _change] = (workRsi[r][z + _price] - workRsi[0][z + _price]) / MathMax(k, 1);
      workRsi[r][z + _changa] =                                         sum / MathMax(k, 1);
   } else {
      double change = workRsi[r][z + _price] - workRsi[r - 1][z + _price];
      workRsi[r][z + _change] = workRsi[r - 1][z + _change] + alpha * (        change  - workRsi[r - 1][z + _change]);
      workRsi[r][z + _changa] = workRsi[r - 1][z + _changa] + alpha * (MathAbs(change) - workRsi[r - 1][z + _changa]);
   }
   return(50.0 * (workRsi[r][z + _change] / MathMax(workRsi[r][z + _changa], DBL_MIN) + 1));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double workEma[][4];
double iEma(double price, double period, int r, int _bars, int instanceNo = 0) {
   if(ArrayRange(workEma, 0) != _bars) ArrayResize(workEma, _bars);

   workEma[r][instanceNo] = price;
   if(r > 0 && period > 1)
      workEma[r][instanceNo] = workEma[r - 1][instanceNo] + (2.0 / (1.0 + period)) * (price - workEma[r - 1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPrice(ENUM_APPLIED_PRICE tprice, const double &open[], const double &close[], const double &high[], const double &low[], int i, int _bars) {
   switch(tprice) {
   case PRICE_CLOSE:
      return(close[i]);
   case PRICE_OPEN:
      return(open[i]);
   case PRICE_HIGH:
      return(high[i]);
   case PRICE_LOW:
      return(low[i]);
   case PRICE_MEDIAN:
      return((high[i] + low[i]) / 2.0);
   case PRICE_TYPICAL:
      return((high[i] + low[i] + close[i]) / 3.0);
   case PRICE_WEIGHTED:
      return((high[i] + low[i] + close[i] + close[i]) / 4.0);
   }
   return(0);
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
   for(int i = start; i < end; i++) {
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
   for(int i = start; i < end; i++) {
      sum = sum + arr[i];
   }

   sum = sum / size;

   double sum2 = 0.0;
   for(int i = start; i < end; i++) {
      sum2 = sum2 + (arr[i] - sum) * (arr[i] - sum);
   }

   sum2 = sum2 / (size - 1);
   sum2 = MathSqrt(sum2);

   return(sum2);
}
//+------------------------------------------------------------------+
