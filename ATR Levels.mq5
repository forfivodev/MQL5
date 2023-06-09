//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© 2021, MetaQuotes Ltd."
#property copyright "© GM, 2021, 2022"
#property indicator_chart_window
#property indicator_buffers 34
#property indicator_plots 34

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum tipoIndicador {
   High,
   Low
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input tipoIndicador tipo = High;
input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;  // Timeframe
input datetime datainicial = "2021.1.1 9:00:00";   // Data inicial
input bool useCustomPeriod = false;                // Usar período manual
input int input_periodos = 0;                    // Período manual
input double margemATR = 0.5;                      // Multiplicador ATR
input double deslocamento = 0;                     // Offset ATR

input color cor0 = clrWhite;
input color cor1 = clrPaleTurquoise;
input color cor2 = clrRoyalBlue;
input color cor3 = clrMediumSeaGreen;
input color cor4 = clrGreen;
input color cor5 = clrGold;
input color cor6 = clrDarkOrange;
input color cor7 = clrRed;
input color cor8 = clrDarkViolet;
input color cor9 = clrPurple;
input color cor10 = clrMagenta;

//input double multiplicador1 = 2.5;
//input double multiplicador2 = 5;
//input double multiplicador3 = 7.5;
//input double multiplicador4 = 10;
//input double multiplicador5 = 12.5;
//input double multiplicador6 = 15;
//input double multiplicador7 = 17.5;
//input double multiplicador8 = 20;

input double desvio = 2.5;
input double inicial = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int iATR_handle;
double ATR[];
double atr1mais[], atr1[], atr1menos[], atr2mais[], atr2[], atr2menos[], atr3mais[], atr3[], atr3menos[], atr4mais[], atr4[], atr4menos[], atr5mais[], atr5[], atr5menos[], atr6mais[], atr6[], atr6menos[];
double atr7mais[], atr7[], atr7menos[], atr8mais[], atr8[], atr8menos[], atr9mais[], atr9[], atr9menos[], atr10mais[], atr10[], atr10menos[];
double startmais[], start[], startmenos[];
double multiplicador1 = 1 * desvio;
double multiplicador2 = 2 * desvio;
double multiplicador3 = 3 * desvio;
double multiplicador4 = 4 * desvio;
double multiplicador5 = 5 * desvio;
double multiplicador6 = 6 * desvio;
double multiplicador7 = 7 * desvio;
double multiplicador8 = 8 * desvio;
double multiplicador9 = 9 * desvio;
double multiplicador10 = 10 * desvio;

input int largura = 3;
int periodos = 200;

int    bars_calculated = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   int totalRates = SeriesInfoInteger(_Symbol, Timeframe, SERIES_BARS_COUNT);
   int barFrom = iBarShift(_Symbol, Timeframe, datainicial);

   if (useCustomPeriod)
      periodos = input_periodos;
   else
      periodos = barFrom;

   SetIndexBuffer(0, ATR, INDICATOR_CALCULATIONS);

   SetIndexBuffer(1, startmais, INDICATOR_DATA);
   SetIndexBuffer(2, start, INDICATOR_DATA);
   SetIndexBuffer(3, startmenos, INDICATOR_DATA);

   SetIndexBuffer(4, atr1mais, INDICATOR_DATA);
   SetIndexBuffer(5, atr1, INDICATOR_DATA);
   SetIndexBuffer(6, atr1menos, INDICATOR_DATA);

   SetIndexBuffer(7, atr2mais, INDICATOR_DATA);
   SetIndexBuffer(8, atr2, INDICATOR_DATA);
   SetIndexBuffer(9, atr2menos, INDICATOR_DATA);

   SetIndexBuffer(10, atr3mais, INDICATOR_DATA);
   SetIndexBuffer(11, atr3, INDICATOR_DATA);
   SetIndexBuffer(12, atr3menos, INDICATOR_DATA);

   SetIndexBuffer(13, atr4mais, INDICATOR_DATA);
   SetIndexBuffer(14, atr4, INDICATOR_DATA);
   SetIndexBuffer(15, atr4menos, INDICATOR_DATA);

   SetIndexBuffer(16, atr5mais, INDICATOR_DATA);
   SetIndexBuffer(17, atr5, INDICATOR_DATA);
   SetIndexBuffer(18, atr5menos, INDICATOR_DATA);

   SetIndexBuffer(19, atr6mais, INDICATOR_DATA);
   SetIndexBuffer(20, atr6, INDICATOR_DATA);
   SetIndexBuffer(21, atr6menos, INDICATOR_DATA);

   SetIndexBuffer(22, atr7mais, INDICATOR_DATA);
   SetIndexBuffer(23, atr7, INDICATOR_DATA);
   SetIndexBuffer(24, atr7menos, INDICATOR_DATA);

   SetIndexBuffer(25, atr8mais, INDICATOR_DATA);
   SetIndexBuffer(26, atr8, INDICATOR_DATA);
   SetIndexBuffer(27, atr8menos, INDICATOR_DATA);

   SetIndexBuffer(28, atr9mais, INDICATOR_DATA);
   SetIndexBuffer(29, atr9, INDICATOR_DATA);
   SetIndexBuffer(30, atr9menos, INDICATOR_DATA);

   SetIndexBuffer(31, atr10mais, INDICATOR_DATA);
   SetIndexBuffer(32, atr10, INDICATOR_DATA);
   SetIndexBuffer(33, atr10menos, INDICATOR_DATA);

   for (int i = 1; i <= 33; i++) {

      PlotIndexSetInteger(i, PLOT_LINE_COLOR, C'128,128,128');
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(i, PLOT_LABEL, "ATR" + i + " / Períodos: " + periodos);
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, largura);
      PlotIndexSetInteger(i, PLOT_LINE_STYLE, STYLE_DOT);
   }

   PlotIndexSetInteger(1, PLOT_LINE_COLOR, cor0);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, cor0);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, cor0);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, largura);

   PlotIndexSetInteger(4, PLOT_LINE_COLOR, cor1);
   PlotIndexSetInteger(4, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, cor1);
   PlotIndexSetInteger(5, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(6, PLOT_LINE_COLOR, cor1);
   PlotIndexSetInteger(6, PLOT_LINE_WIDTH, largura);

   PlotIndexSetInteger(7, PLOT_LINE_COLOR, cor2);
   PlotIndexSetInteger(7, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(8, PLOT_LINE_COLOR, cor2);
   PlotIndexSetInteger(8, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(9, PLOT_LINE_COLOR, cor2);
   PlotIndexSetInteger(9, PLOT_LINE_WIDTH, largura);

   PlotIndexSetInteger(10, PLOT_LINE_COLOR, cor3);
   PlotIndexSetInteger(10, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(11, PLOT_LINE_COLOR, cor3);
   PlotIndexSetInteger(11, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(12, PLOT_LINE_COLOR, cor3);
   PlotIndexSetInteger(12, PLOT_LINE_WIDTH, largura);

   PlotIndexSetInteger(13, PLOT_LINE_COLOR, cor4);
   PlotIndexSetInteger(13, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(14, PLOT_LINE_COLOR, cor4);
   PlotIndexSetInteger(14, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(15, PLOT_LINE_COLOR, cor4);
   PlotIndexSetInteger(15, PLOT_LINE_WIDTH, largura);

   PlotIndexSetInteger(16, PLOT_LINE_COLOR, cor5);
   PlotIndexSetInteger(16, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(17, PLOT_LINE_COLOR, cor5);
   PlotIndexSetInteger(17, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(18, PLOT_LINE_COLOR, cor5);
   PlotIndexSetInteger(18, PLOT_LINE_WIDTH, largura);

   PlotIndexSetInteger(19, PLOT_LINE_COLOR, cor6);
   PlotIndexSetInteger(19, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(20, PLOT_LINE_COLOR, cor6);
   PlotIndexSetInteger(20, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(21, PLOT_LINE_COLOR, cor6);
   PlotIndexSetInteger(21, PLOT_LINE_WIDTH, largura);

   PlotIndexSetInteger(22, PLOT_LINE_COLOR, cor7);
   PlotIndexSetInteger(22, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(23, PLOT_LINE_COLOR, cor7);
   PlotIndexSetInteger(23, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(24, PLOT_LINE_COLOR, cor7);
   PlotIndexSetInteger(24, PLOT_LINE_WIDTH, largura);

   PlotIndexSetInteger(25, PLOT_LINE_COLOR, cor8);
   PlotIndexSetInteger(25, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(26, PLOT_LINE_COLOR, cor8);
   PlotIndexSetInteger(26, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(27, PLOT_LINE_COLOR, cor8);
   PlotIndexSetInteger(27, PLOT_LINE_WIDTH, largura);

   PlotIndexSetInteger(28, PLOT_LINE_COLOR, cor9);
   PlotIndexSetInteger(28, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(29, PLOT_LINE_COLOR, cor9);
   PlotIndexSetInteger(29, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(30, PLOT_LINE_COLOR, cor9);
   PlotIndexSetInteger(30, PLOT_LINE_WIDTH, largura);

   PlotIndexSetInteger(31, PLOT_LINE_COLOR, cor10);
   PlotIndexSetInteger(31, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(32, PLOT_LINE_COLOR, cor10);
   PlotIndexSetInteger(32, PLOT_LINE_WIDTH, largura);
   PlotIndexSetInteger(33, PLOT_LINE_COLOR, cor10);
   PlotIndexSetInteger(33, PLOT_LINE_WIDTH, largura);

   iATR_handle = iATR(_Symbol, PERIOD_CURRENT, periodos);

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

//--- número de valores copiados a partir do indicador iATR
   int values_to_copy;
//--- determinar o número de valores calculados no indicador
   int calculated = BarsCalculated(iATR_handle);
   if(calculated <= 0) {
      return(0);
   }

//--- se é o princípio de cálculo do indicador ou se é o número de valores modificados do indicador iATR
//--- ou se é necessário cálculo do indicador para duas ou mais barras (isso significa que algo mudou no histórico do preço)
   if(prev_calculated == 0 || calculated != bars_calculated || rates_total > prev_calculated + 1) {
      //--- se o array iATRBuffer é maior do que o número de valores no indicador iATR para símbolo/período, então não copiamos tudo
      //--- caso contrário, copiamos menor do que o tamanho dos buffers do indicador
      if(calculated > rates_total)
         values_to_copy = rates_total;
      else
         values_to_copy = calculated;
   } else {
      //--- isso significa que não é a primeira vez do cálculo do indicador, é desde a última chamada de OnCalculate())
      //--- para o cálculo não mais do que uma barra é adicionada
      values_to_copy = (rates_total - prev_calculated) + 1;
   }
//--- preencher o array iATRBuffer com valores do indicador Average True Range
//--- se FillArrayFromBuffer retorna falso, significa que a informação não está pronta ainda, sair da operação
   if(!FillArrayFromBuffer(ATR, iATR_handle, values_to_copy))
      return(0);

//--- memorizar o número de valores no indicador Accelerator Oscillator
   bars_calculated = calculated;
//
   ArrayInitialize(startmais, 0);
   ArrayInitialize(start, 0);
   ArrayInitialize(startmenos, 0);

   ArrayInitialize(atr1mais, 0);
   ArrayInitialize(atr1, 0);
   ArrayInitialize(atr1menos, 0);

   ArrayInitialize(atr2mais, 0);
   ArrayInitialize(atr2, 0);
   ArrayInitialize(atr2menos, 0);

   ArrayInitialize(atr3mais, 0);
   ArrayInitialize(atr3, 0);
   ArrayInitialize(atr3menos, 0);

   ArrayInitialize(atr4mais, 0);
   ArrayInitialize(atr4, 0);
   ArrayInitialize(atr4menos, 0);

   ArrayInitialize(atr5mais, 0);
   ArrayInitialize(atr5, 0);
   ArrayInitialize(atr5menos, 0);

   ArrayInitialize(atr6mais, 0);
   ArrayInitialize(atr6, 0);
   ArrayInitialize(atr6menos, 0);

   ArrayInitialize(atr7mais, 0);
   ArrayInitialize(atr7, 0);
   ArrayInitialize(atr7menos, 0);

   ArrayInitialize(atr8mais, 0);
   ArrayInitialize(atr8, 0);
   ArrayInitialize(atr8menos, 0);

   ArrayInitialize(atr9mais, 0);
   ArrayInitialize(atr9, 0);
   ArrayInitialize(atr9menos, 0);

   ArrayInitialize(atr10mais, 0);
   ArrayInitialize(atr10, 0);
   ArrayInitialize(atr10menos, 0);


   datetime minimumDate = iTime(_Symbol, PERIOD_CURRENT, iBars(_Symbol, PERIOD_CURRENT) - 1);

   datetime now  = datainicial;
   datetime bod  = now - now % (24 * 60 * 60);
   int      iBod = iBarShift(_Symbol, _Period, bod);

//double maxima = iHigh(NULL, PERIOD_D1, 0);
   double maxima = iHigh(NULL, Timeframe, iHighest(NULL, Timeframe, MODE_HIGH, iBod, 0));
//double minima = iLow(NULL, PERIOD_D1, 0);
   double minima = iLow(NULL, Timeframe, iLowest(NULL, Timeframe, MODE_LOW, iBod, 0));

   double numero, indice, ultimoatr;
   string texto;
   ENUM_ANCHOR_POINT ancoragem;

   if (inicial == "" || inicial == 0) {
      if (tipo == High) {
         numero = maxima;
         indice = iHighest(NULL, Timeframe, MODE_HIGH, iBod, 0);
         texto = "Max";
         ancoragem = ANCHOR_RIGHT_UPPER;
      } else {
         numero = minima;
         indice = iLowest(NULL, Timeframe, MODE_LOW, iBod, 0);
         texto = "Min";
         ancoragem = ANCHOR_RIGHT_LOWER;
      }
   } else {
      numero = inicial;
      indice = rates_total - 1;
   }


   for (int i = rates_total - indice - 1; i < rates_total; i++) { //para evitar linhas fantasma no gráfico
      ultimoatr = ATR[i];
      start[i] = numero;
   }

   for (int i = rates_total - indice - 1; i < rates_total; i++) {
      ultimoatr = ATR[i];

      startmais[i] = numero + margemATR * ultimoatr;
      startmenos[i] = numero - margemATR * ultimoatr;

      if (tipo == Low) {
         atr1mais[i] = numero + (deslocamento + multiplicador1 + margemATR) * ultimoatr;
         atr1[i] = numero + (deslocamento + multiplicador1) * ultimoatr;
         atr1menos[i] = numero + (deslocamento + multiplicador1 - margemATR) * ultimoatr;

         atr2mais[i] = numero + (deslocamento + multiplicador2 + margemATR) * ultimoatr;
         atr2[i] = numero + (deslocamento + multiplicador2) * ultimoatr;
         atr2menos[i] = numero + (deslocamento + multiplicador2 - margemATR) * ultimoatr;

         atr3mais[i] = numero + (deslocamento + multiplicador3 + margemATR) * ultimoatr;
         atr3[i] = numero + (deslocamento + multiplicador3) * ultimoatr;
         atr3menos[i] = numero + (deslocamento + multiplicador3 - margemATR) * ultimoatr;

         atr4mais[i] = numero + (deslocamento + multiplicador4 + margemATR) * ultimoatr;
         atr4[i] = numero + (deslocamento + multiplicador4) * ultimoatr;
         atr4menos[i] = numero + (deslocamento + multiplicador4 - margemATR) * ultimoatr;

         atr5mais[i] = numero + (deslocamento + multiplicador5 + margemATR) * ultimoatr;
         atr5[i] = numero + (deslocamento + multiplicador5) * ultimoatr;
         atr5menos[i] = numero + (deslocamento + multiplicador5 - margemATR) * ultimoatr;

         atr6mais[i] = numero + (deslocamento + multiplicador6 + margemATR) * ultimoatr;
         atr6[i] = numero + (deslocamento + multiplicador6) * ultimoatr;
         atr6menos[i] = numero + (deslocamento + multiplicador6 - margemATR) * ultimoatr;

         atr7mais[i] = numero + (deslocamento + multiplicador7 + margemATR) * ultimoatr;
         atr7[i] = numero + (deslocamento + multiplicador7) * ultimoatr;
         atr7menos[i] = numero + (deslocamento + multiplicador7 - margemATR) * ultimoatr;

         atr8mais[i] = numero + (deslocamento + multiplicador8 + margemATR) * ultimoatr;
         atr8[i] = numero + (deslocamento + multiplicador8) * ultimoatr;
         atr8menos[i] = numero + (deslocamento + multiplicador8 - margemATR) * ultimoatr;

         atr9mais[i] = numero + (deslocamento + multiplicador9 + margemATR) * ultimoatr;
         atr9[i] = numero + (deslocamento + multiplicador9) * ultimoatr;
         atr9menos[i] = numero + (deslocamento + multiplicador9 - margemATR) * ultimoatr;

         atr10mais[i] = numero + (deslocamento + multiplicador10 + margemATR) * ultimoatr;
         atr10[i] = numero + (deslocamento + multiplicador10) * ultimoatr;
         atr10menos[i] = numero + (deslocamento + multiplicador10 - margemATR) * ultimoatr;

      } else {
         atr1mais[i] = numero - (deslocamento + multiplicador1 + margemATR) * ultimoatr;
         atr1[i] = numero - (deslocamento + multiplicador1) * ultimoatr;
         atr1menos[i] = numero - (deslocamento + multiplicador1 - margemATR) * ultimoatr;

         atr2mais[i] = numero - (deslocamento + multiplicador2 + margemATR) * ultimoatr;
         atr2[i] = numero - (deslocamento + multiplicador2) * ultimoatr;
         atr2menos[i] = numero - (deslocamento + multiplicador2 - margemATR) * ultimoatr;

         atr3mais[i] = numero - (deslocamento + multiplicador3 + margemATR) * ultimoatr;
         atr3[i] = numero - (deslocamento + multiplicador3) * ultimoatr;
         atr3menos[i] = numero - (deslocamento + multiplicador3 - margemATR) * ultimoatr;

         atr4mais[i] = numero - (deslocamento + multiplicador4 + margemATR) * ultimoatr;
         atr4[i] = numero - (deslocamento + multiplicador4) * ultimoatr;
         atr4menos[i] = numero - (deslocamento + multiplicador4 - margemATR) * ultimoatr;

         atr5mais[i] = numero - (deslocamento + multiplicador5 + margemATR) * ultimoatr;
         atr5[i] = numero - (deslocamento + multiplicador5) * ultimoatr;
         atr5menos[i] = numero - (deslocamento + multiplicador5 - margemATR) * ultimoatr;

         atr6mais[i] = numero - (deslocamento + multiplicador6 + margemATR) * ultimoatr;
         atr6[i] = numero - (deslocamento + multiplicador6) * ultimoatr;
         atr6menos[i] = numero - (deslocamento + multiplicador6 - margemATR) * ultimoatr;

         atr7mais[i] = numero - (deslocamento + multiplicador7 + margemATR) * ultimoatr;
         atr7[i] = numero - (deslocamento + multiplicador7) * ultimoatr;
         atr7menos[i] = numero - (deslocamento + multiplicador7 - margemATR) * ultimoatr;

         atr8mais[i] = numero - (deslocamento + multiplicador8 + margemATR) * ultimoatr;
         atr8[i] = numero - (deslocamento + multiplicador8) * ultimoatr;
         atr8menos[i] = numero - (deslocamento + multiplicador8 - margemATR) * ultimoatr;

         atr9mais[i] = numero - (deslocamento + multiplicador9 + margemATR) * ultimoatr;
         atr9[i] = numero - (deslocamento + multiplicador9) * ultimoatr;
         atr9menos[i] = numero - (deslocamento + multiplicador9 - margemATR) * ultimoatr;

         atr10mais[i] = numero - (deslocamento + multiplicador10 + margemATR) * ultimoatr;
         atr10[i] = numero - (deslocamento + multiplicador10) * ultimoatr;
         atr10menos[i] = numero - (deslocamento + multiplicador10 - margemATR) * ultimoatr;
      }
   }

   double margem_temp = 0;
   if (tipo == High) {

      ObjectCreate(0, "textostart1" + "_High", OBJ_TEXT, 0, iTime(NULL, Timeframe, indice), numero + margemATR * ultimoatr);
      ObjectCreate(0, "textoatr1" + "_High", OBJ_TEXT, 0, iTime(NULL, Timeframe, rates_total - periodos), numero - (numero - atr1[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr2" + "_High", OBJ_TEXT, 0, iTime(NULL, Timeframe, rates_total - periodos), numero - (numero - atr2[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr3" + "_High", OBJ_TEXT, 0, iTime(NULL, Timeframe, rates_total - periodos), numero - (numero - atr3[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr4" + "_High", OBJ_TEXT, 0, iTime(NULL, Timeframe, rates_total - periodos), numero - (numero - atr4[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr5" + "_High", OBJ_TEXT, 0, iTime(NULL, Timeframe, rates_total - periodos), numero - (numero - atr5[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr6" + "_High", OBJ_TEXT, 0, iTime(NULL, Timeframe, rates_total - periodos), numero - (numero - atr6[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr7" + "_High", OBJ_TEXT, 0, iTime(NULL, Timeframe, rates_total - periodos), numero - (numero - atr7[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr8" + "_High", OBJ_TEXT, 0, iTime(NULL, Timeframe, rates_total - periodos), numero - (numero - atr8[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr9" + "_High", OBJ_TEXT, 0, iTime(NULL, Timeframe, rates_total - periodos), numero - (numero - atr9[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr10" + "_High", OBJ_TEXT, 0, iTime(NULL, Timeframe, rates_total - periodos), numero - (numero - atr10[(int)MathMax(rates_total - indice - 2, periodos)]));

      ObjectSetString(0, "textostart1" + "_High", OBJPROP_TEXT, texto);
      ObjectSetInteger(0, "textostart1" + "_High", OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, "textostart1" + "_High", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr1" + "_High", OBJPROP_TEXT, "" + multiplicador1);
      ObjectSetInteger(0, "textoatr1" + "_High", OBJPROP_COLOR, cor1);
      ObjectSetInteger(0, "textoatr1" + "_High", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr2" + "_High", OBJPROP_TEXT, "" + multiplicador2);
      ObjectSetInteger(0, "textoatr2" + "_High", OBJPROP_COLOR, cor2);
      ObjectSetInteger(0, "textoatr2" + "_High", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr3" + "_High", OBJPROP_TEXT, "" + multiplicador3);
      ObjectSetInteger(0, "textoatr3" + "_High", OBJPROP_COLOR, cor3);
      ObjectSetInteger(0, "textoatr3" + "_High", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr4" + "_High", OBJPROP_TEXT, "" + multiplicador4);
      ObjectSetInteger(0, "textoatr4" + "_High", OBJPROP_COLOR, cor4);
      ObjectSetInteger(0, "textoatr4" + "_High", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr5" + "_High", OBJPROP_TEXT, "" + multiplicador5);
      ObjectSetInteger(0, "textoatr5" + "_High", OBJPROP_COLOR, cor5);
      ObjectSetInteger(0, "textoatr5" + "_High", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr6" + "_High", OBJPROP_TEXT, "" + multiplicador6);
      ObjectSetInteger(0, "textoatr6" + "_High", OBJPROP_COLOR, cor6);
      ObjectSetInteger(0, "textoatr6" + "_High", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr7" + "_High", OBJPROP_TEXT, "" + multiplicador7);
      ObjectSetInteger(0, "textoatr7" + "_High", OBJPROP_COLOR, cor7);
      ObjectSetInteger(0, "textoatr7" + "_High", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr8" + "_High", OBJPROP_TEXT, "" + multiplicador8);
      ObjectSetInteger(0, "textoatr8" + "_High", OBJPROP_COLOR, cor8);
      ObjectSetInteger(0, "textoatr8" + "_High", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr9" + "_High", OBJPROP_TEXT, "" + multiplicador9);
      ObjectSetInteger(0, "textoatr9" + "_High", OBJPROP_COLOR, cor9);
      ObjectSetInteger(0, "textoatr9" + "_High", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr10" + "_High", OBJPROP_TEXT, "" + multiplicador10);
      ObjectSetInteger(0, "textoatr10" + "_High", OBJPROP_COLOR, cor10);
      ObjectSetInteger(0, "textoatr10" + "_High", OBJPROP_ANCHOR, ancoragem);

   } else {

      ObjectCreate(0, "textostart1" + "_Low", OBJ_TEXT, 0, iTime(NULL, Timeframe, indice), numero - margemATR * ultimoatr);
      ObjectCreate(0, "textoatr1" + "_Low", OBJ_TEXT, 0, iTime(NULL, Timeframe, MathMin(rates_total - periodos, indice)), numero - (numero - atr1[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr2" + "_Low", OBJ_TEXT, 0, iTime(NULL, Timeframe, MathMin(rates_total - periodos, indice)), numero - (numero - atr2[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr3" + "_Low", OBJ_TEXT, 0, iTime(NULL, Timeframe, MathMin(rates_total - periodos, indice)), numero - (numero - atr3[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr4" + "_Low", OBJ_TEXT, 0, iTime(NULL, Timeframe, MathMin(rates_total - periodos, indice)), numero - (numero - atr4[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr5" + "_Low", OBJ_TEXT, 0, iTime(NULL, Timeframe, MathMin(rates_total - periodos, indice)), numero - (numero - atr5[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr6" + "_Low", OBJ_TEXT, 0, iTime(NULL, Timeframe, MathMin(rates_total - periodos, indice)), numero - (numero - atr6[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr7" + "_Low", OBJ_TEXT, 0, iTime(NULL, Timeframe, MathMin(rates_total - periodos, indice)), numero - (numero - atr7[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr8" + "_Low", OBJ_TEXT, 0, iTime(NULL, Timeframe, MathMin(rates_total - periodos, indice)), numero - (numero - atr8[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr9" + "_Low", OBJ_TEXT, 0, iTime(NULL, Timeframe, MathMin(rates_total - periodos, indice)), numero - (numero - atr9[(int)MathMax(rates_total - indice - 2, periodos)]));
      ObjectCreate(0, "textoatr10" + "_Low", OBJ_TEXT, 0, iTime(NULL, Timeframe, MathMin(rates_total - periodos, indice)), numero - (numero - atr10[(int)MathMax(rates_total - indice - 2, periodos)]));

      ObjectSetString(0, "textostart1" + "_Low", OBJPROP_TEXT, texto);
      ObjectSetInteger(0, "textostart1" + "_Low", OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, "textostart1" + "_Low", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr1" + "_Low", OBJPROP_TEXT, "" + multiplicador1);
      ObjectSetInteger(0, "textoatr1" + "_Low", OBJPROP_COLOR, cor1);
      ObjectSetInteger(0, "textoatr1" + "_Low", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr2" + "_Low", OBJPROP_TEXT, "" + multiplicador2);
      ObjectSetInteger(0, "textoatr2" + "_Low", OBJPROP_COLOR, cor2);
      ObjectSetInteger(0, "textoatr2" + "_Low", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr3" + "_Low", OBJPROP_TEXT, "" + multiplicador3);
      ObjectSetInteger(0, "textoatr3" + "_Low", OBJPROP_COLOR, cor3);
      ObjectSetInteger(0, "textoatr3" + "_Low", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr4" + "_Low", OBJPROP_TEXT, "" + multiplicador4);
      ObjectSetInteger(0, "textoatr4" + "_Low", OBJPROP_COLOR, cor4);
      ObjectSetInteger(0, "textoatr4" + "_Low", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr5" + "_Low", OBJPROP_TEXT, "" + multiplicador5);
      ObjectSetInteger(0, "textoatr5" + "_Low", OBJPROP_COLOR, cor5);
      ObjectSetInteger(0, "textoatr5" + "_Low", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr6" + "_Low", OBJPROP_TEXT, "" + multiplicador6);
      ObjectSetInteger(0, "textoatr6" + "_Low", OBJPROP_COLOR, cor6);
      ObjectSetInteger(0, "textoatr6" + "_Low", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr7" + "_Low", OBJPROP_TEXT, "" + multiplicador7);
      ObjectSetInteger(0, "textoatr7" + "_Low", OBJPROP_COLOR, cor7);
      ObjectSetInteger(0, "textoatr7" + "_Low", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr8" + "_Low", OBJPROP_TEXT, "" + multiplicador8);
      ObjectSetInteger(0, "textoatr8" + "_Low", OBJPROP_COLOR, cor8);
      ObjectSetInteger(0, "textoatr8" + "_Low", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr9" + "_Low", OBJPROP_TEXT, "" + multiplicador9);
      ObjectSetInteger(0, "textoatr9" + "_Low", OBJPROP_COLOR, cor9);
      ObjectSetInteger(0, "textoatr9" + "_Low", OBJPROP_ANCHOR, ancoragem);

      ObjectSetString(0, "textoatr10" + "_Low", OBJPROP_TEXT, "" + multiplicador10);
      ObjectSetInteger(0, "textoatr10" + "_Low", OBJPROP_COLOR, cor10);
      ObjectSetInteger(0, "textoatr10" + "_Low", OBJPROP_ANCHOR, ancoragem);

   }

//--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Preenchendo os buffers do indicator a partir do indicador iATR   |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[],  // buffer do indicador para valores ATR values
                         int ind_handle,    // manipulador do indicador iATR
                         int amount         // número de valores copiados
                        ) {
//--- redefinir o código de erro
   ResetLastError();
//--- preencher parte do array iATRBuffer com valores a partir do buffer do indicador que tem índice 0(zero)
   if(CopyBuffer(ind_handle, 0, 0, amount, values) < 0) {
      //--- Se a cópia falhar, informe o código de erro
      //--- parar com resultado zero - significa que indicador é considerado como não calculado
      return(false);

   }
//--- está tudo bem
   return(true);
}

//+------------------------------------------------------------------+
//| Função de desinicialização do indicador                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   if(iATR_handle != INVALID_HANDLE)
      IndicatorRelease(iATR_handle);

   ObjectDelete(0, "textoatr");
   ObjectDelete(0, "textostart");
}
//+------------------------------------------------------------------+
