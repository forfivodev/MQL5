//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2021, 2022, 2023"
#property description "Marcador do bola"
#property strict

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- input parameters
input datetime data_inicial = "2021.08.18 09:00";         // Data inicial para mostrar as linhas
input datetime data_final = "2021.09.30 18:00";         // Data final para mostrar as linhas
input double ponto1 = 23000; // Ponto 1
input double dolpt = 5.1574;
input ENUM_ANCHOR_POINT InpAnchor = ANCHOR_LEFT_LOWER; // Tipo de ancoragem
input int tamanho_fonte = 7; //Tamanho da fonte das legendas

int shift = 0;                              // Horizontal shift of the channel

//+------------------------------------------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_inicial;
int min_rates_final;
datetime tempo;
input   bool        Show_labels    = true;
//input double distancia_borda = 3; //Distância da borda do gráfico
string          sDailyStr = "", sWeeklyStr  = "", sMonthlyStr = "";
int barras_visiveis = ChartGetInteger(0, CHART_VISIBLE_BARS);

//+------------------------------------------------------------------+
//| iBarShift2() function                                            |
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
int OnInit() {

//---- initialization of variables
   min_rates_inicial = 1;
//fechamento_dolarizado = fechamento / dolar;
   if(Show_labels) {

      tempo = iTime("WIN$", PERIOD_CURRENT, 0) + PeriodSeconds(PERIOD_CURRENT) * 12;

      ////////////////////////////////////////// 500 /////////////////////////////////////
      int ponto = ponto1;
      int real;
      int dolar;
      for(int i = 0; i < 20; i++) {
         ponto = ponto - 100;
         real = (int)(ponto * dolpt);
         dolar = (int)(ponto);

         ObjectCreate(0, "ponto" + i, OBJ_HLINE, 0, data_inicial, real, tempo, real);
         ObjectSetInteger(0, "ponto" + i, OBJPROP_COLOR, clrRoyalBlue);
         ObjectSetInteger(0, "ponto" + i, OBJPROP_STYLE, STYLE_DOT);
         //ObjectSetString(0, "ponto" + i, OBJPROP_TOOLTIP, volume);
         //ObjectSetInteger(0, "ponto" + i, OBJPROP_WIDTH, volume / filterVoume);

         ObjectCreate(0, "pontot" + i, OBJ_TEXT, 0, tempo, real);
         ObjectSetInteger(0, "pontot" + i, OBJPROP_ANCHOR, InpAnchor);
         ObjectSetInteger(0, "pontot" + i, OBJPROP_COLOR, clrRoyalBlue);
         ObjectSetInteger(0, "pontot" + i, OBJPROP_FONTSIZE, tamanho_fonte);
         ObjectSetString(0, "pontot" + i, OBJPROP_FONT, "Verdana");
         ObjectSetString(0, "pontot" + i, OBJPROP_TEXT, (int)(ponto));
      }
   }

//---- initializations of a variable for the indicator short name
   string shortname = "Marcação do bola";
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME, shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits + 1);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int pReason) {
   if(!Show_labels) {
      ObjectDelete(0, "ponto1+500");
      ObjectDelete(0, "ponto1-500");
      ObjectDelete(0, "ponto2+500");
      ObjectDelete(0, "ponto2-500");
      ObjectDelete(0, "ponto2+500");
      ObjectDelete(0, "ponto2-500");

      ObjectDelete(0, "ponto1-200");
      ObjectDelete(0, "ponto2-200");
      ObjectDelete(0, "ponto3-200");

      ObjectDelete(0, "ponto1-100");
      ObjectDelete(0, "ponto2-100");
      ObjectDelete(0, "ponto3-100");

      ObjectDelete(0, "ponto1-50");
      ObjectDelete(0, "ponto2-50");
      ObjectDelete(0, "ponto3-50");

      ObjectDelete(0, "ponto1");
      ObjectDelete(0, "ponto2");
      ObjectDelete(0, "ponto3");

      ObjectDelete(0, "ponto1-950");
      ObjectDelete(0, "ponto2-950");
      ObjectDelete(0, "ponto3-950");

      ObjectDelete(0, "ponto1-900");
      ObjectDelete(0, "ponto2-900");
      ObjectDelete(0, "ponto3-900");

      ObjectDelete(0, "ponto1-800");
      ObjectDelete(0, "ponto2-800");
      ObjectDelete(0, "ponto3-800");
   }
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

   int limit_inicial = prev_calculated;
   int limit_final;
//fechamento_dolarizado = fechamento / dolar;

//---- checking the number of bars to be enough for the calculation
   if(rates_total < min_rates_inicial) {
      return(0);
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
//--- pressionamento de tecla
//   if(id == CHARTEVENT_CLICK  || id == CHARTEVENT_CHART_CHANGE) {
//
//   }
}
//+------------------------------------------------------------------+
