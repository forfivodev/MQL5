//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "Chart shift and scale"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- input parameters
input group "****************************  Configurações principais ****************************"
input int afastamento = 20; //Afastamento da borda direita em candles
input double max = 10000000;
input double min = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {
   string shortname = "Chart Shift and Scale";
   IndicatorSetString(INDICATOR_SHORTNAME, shortname);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits + 1);

   Update();
   ChartRedraw();

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Update() {

//   int bars_count=ChartGetInteger(0,CHART_VISIBLE_BARS,0);
//   int bar=WindowFirstVisibleBar();
//
//   for(int i=0; i<bars_count; i++,bar--);
//
//   double bars_price_max=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,bars_count,0));
//   double bars_price_min=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,bars_count,0));
//
//   double chart_price_max= bars_price_max + (( bars_price_max - bars_price_min ) /(100-2*afastamento)*afastamento);
//   double chart_price_min= bars_price_min - (( bars_price_max - bars_price_min ) /(100-2*afastamento)*afastamento);
//
//   ChartSetDouble(0,CHART_FIXED_MAX,chart_price_max);
//   ChartSetDouble(0,CHART_FIXED_MIN,chart_price_min);

   ChartSetInteger(0, CHART_SCALEFIX, 0, true);
   ChartSetDouble(0, CHART_FIXED_MAX, max);
   ChartSetDouble(0, CHART_FIXED_MIN, min);

//ChartSetDouble(0,CHART_POINTS_PER_BAR,100);
//ChartSetInteger(0,CHART_HEIGHT_IN_PIXELS, 0, 10000);

////ChartSetDouble(0, CHART_PRICE_MAX, 105000);
//ChartSetDouble(0, CHART_PRICE_MIN, 102000);

   ChartSetInteger(0, CHART_SHIFT, 1);
   ChartSetDouble(0, CHART_SHIFT_SIZE, afastamento);
}

//+------------------------------------------------------------------+
//| Custom indicator Deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
   return(1);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

//if(id == CHARTEVENT_CHART_CHANGE) {
//   Update();
//}

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int WindowFirstVisibleBar() {
   return((int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR));
}
//+------------------------------------------------------------------+
