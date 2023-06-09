//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "Prohibited zone"

#property indicator_chart_window
#property indicator_buffers 49
#property indicator_plots   49

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
input group "****************************  VWAP  ****************************"
input string                     vwapID    = "1";       // VWAP ID  (must be unique)
input PRICE_method               method    = Typical;    // Price Calculation method
input color                      vwapColor = Fuchsia;    // VWAP Color
input int                        arrowSize = 2;          // Arrow Size
input ENUM_ARROW_ANCHOR          Anchor    = ANCHOR_TOP; // Arrow Anchor Point
input ENUM_APPLIED_VOLUME        applied_volume = VOLUME_REAL; // tipo de volume

input group "****************************  VWAP BANDS  ****************************"
input int                        offset = 0;   // Offset das bandas
input double                     tamanho_banda = 0.33;   // Tamanho padrão das bandas
input color                      vwapColorUp = clrLime;    // Cor banda superior
input color                      vwapColorDown = clrRed;    // Cor banda inferior
input int                        espessura_linha = 2;   // Espessura das linhas
input int                        ThrottleRedraw = 60;      // ThrottleRedraw: delay (in seconds) for updating.
input bool                       exibe_bandas = true;      // ThrottleRedraw: delay (in seconds) for updating.

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double         vwapBuffer[];
double         vwapBandmais1[];
double         vwapBandmenos1[];

//--- global variables
int            startVWAP;
string         prefix;
int            iRatesTotal;
datetime       iTime[];
double         iOpen[], iHigh[], iLow[], iClose[];
long           obj_time;
bool           first = true;
int            counter = 0;
long bars = iBars(_Symbol, 0);

ENUM_ARROW_ANCHOR ancoragem = Anchor;
double tamanho_banda_calculada = (double)tamanho_banda / 100;
string tipo_vwap = "Typical";
PRICE_method metodo_vwap = method;
//string objeto_selecionado = "";
int TimerMB = 0;                      // For throttling updates of market profiles in slow systems.

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   SetIndexBuffer(0, vwapBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(0, PLOT_LABEL, "VWAP");
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, espessura_linha);

   SetIndexBuffer(1, vwapBandmais1, INDICATOR_DATA);
   SetIndexBuffer(2, vwapBandmenos1, INDICATOR_DATA);

   PlotIndexSetInteger(1, PLOT_LINE_COLOR, vwapColorUp);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(1, PLOT_LABEL, "VWAP");
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, espessura_linha);

   PlotIndexSetInteger(2, PLOT_LINE_COLOR, vwapColorDown);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(2, PLOT_LABEL, "VWAP");
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, espessura_linha);

   prefix = "Obj_" + vwapID;
   ChartRedraw(ChartID());

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator Deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

// Exclui o Objeto quando o indicador é excluído.
   if(reason != REASON_PARAMETERS && reason != REASON_CHARTCHANGE) {
      ObjectsDeleteAll(0, prefix);
      ChartRedraw(ChartID());
   }
}

//+------------------------------------------------------------------+
//| Custom indicator Chart Event function                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   if(id == CHARTEVENT_OBJECT_DRAG && sparam == prefix) {
      TimerMB = 0;
      obj_time = ObjectGetInteger(0, prefix, OBJPROP_TIME);
      for(int i = iRatesTotal - 1; i > 0; i--) {
         if(obj_time >= (long)iTime[i]) {
            startVWAP = i;
            break;
         }
      }
      CalculateVWAP();
      //ChartRedraw(ChartID());
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

// Delay the update of Market Profile if ThrottleRedraw is given.
   if ((ThrottleRedraw > 0) && (TimerMB > 0)) {
      if ((int)TimeLocal() - TimerMB < ThrottleRedraw) return rates_total;
   }

// Inicializa os Buffers
   if(first) {
      ArrayInitialize(vwapBuffer, 0);
      ArrayInitialize(vwapBandmais1, 0);
      ArrayInitialize(vwapBandmenos1, 0);

      ArrayResize(iTime,  rates_total, rates_total / 2);
      ArrayResize(iOpen,  rates_total, rates_total / 2);
      ArrayResize(iHigh,  rates_total, rates_total / 2);
      ArrayResize(iLow,   rates_total, rates_total / 2);
      ArrayResize(iClose, rates_total, rates_total / 2);

      CustomizeObject();
      first = false;
   }

// Carrega os vetores de preço
   counter = first ? 0 : MathMax(prev_calculated - 1, 0);
   for(int i = counter; i < rates_total; i++) {
      iRatesTotal = rates_total;
      iTime[i] = time[i];
      iOpen[i] = open[i];
      iHigh[i] = high[i];
      iLow[i] = low[i];
      iClose[i] = close[i];
   }

// Criação do Objeto Referência
   if(ObjectFind(0, prefix) != 0)
      CreateObject();

// Identifica a posição horizontal do objeto
   obj_time = ObjectGetInteger(0, prefix, OBJPROP_TIME);
   for(int i = iRatesTotal - 1; i > 0; i--) {
      if(obj_time >= (long)iTime[i]) {
         startVWAP = i;
         break;
      }
   }

// Calcula a VWAP
   CalculateVWAP();
//ChartRedraw(ChartID());

   return(rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateVWAP() {

   ArrayInitialize(vwapBuffer, 0);
   ArrayInitialize(vwapBandmais1, 0);
   ArrayInitialize(vwapBandmenos1, 0);

   long VolumeBuffer[];
   bars = iBars(_Symbol, 0);

   if (applied_volume == VOLUME_TICK) {
      int prices = CopyTickVolume(_Symbol, 0, 0, bars, VolumeBuffer);
   } else if (applied_volume == VOLUME_REAL) {
      int prices = CopyRealVolume(_Symbol, 0, 0, bars, VolumeBuffer);
   }

// Calcula a VWAP
   double sumPrice = 0, sumVol = 0, vwap = 0;;

   if(method == Open) {
      for(int i = startVWAP; i < iRatesTotal; i++) {
         sumPrice    += iOpen[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         vwapBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == High) {
      for(int i = startVWAP; i < iRatesTotal; i++) {
         sumPrice    += iHigh[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         vwapBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == Low) {
      for(int i = startVWAP; i < iRatesTotal; i++) {
         sumPrice    += iLow[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         vwapBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == Median) {
      for(int i = startVWAP; i < iRatesTotal; i++) {
         sumPrice    += ((iHigh[i] + iLow[i]) / 2) * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         vwapBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == Typical) {
      for(int i = startVWAP; i < iRatesTotal; i++) {
         sumPrice    += ((iHigh[i] + iLow[i] + iClose[i]) / 3) * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         vwapBuffer[i] = sumPrice / sumVol;
      }
      //output=(high[index]+low[index]+close[index])/3;
   } else if(method == Weighted) {
      for(int i = startVWAP; i < iRatesTotal; i++) {
         sumPrice    += ((iHigh[i] + iLow[i] + iClose[i] + iClose[i]) / 4) * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         vwapBuffer[i] = sumPrice / sumVol;
      }
   } else {
      for(int i = startVWAP; i < iRatesTotal; i++) {
         sumPrice    += iOpen[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         vwapBuffer[i] = sumPrice / sumVol;
      }
   }

   if (exibe_bandas == true) {
      for(int i = startVWAP; i < iRatesTotal; i++) {
         vwap = vwapBuffer[i];
         vwapBandmais1[i] = vwap + (((1 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos1[i] = vwap - (((1 + offset) * tamanho_banda_calculada) * vwap);
      }
   } else if (exibe_bandas == false) {
      for(int i = startVWAP; i < iRatesTotal; i++) {
         vwapBandmais1[i] = 0;
         vwapBandmenos1[i] = 0;
      }
   }

//---if a new bar occurs,the last value should be set to EMPTY VALUE, to avoid plotting strange lines
   static int LastTotalBars = 0;
   int i;
   if(i < iRatesTotal && LastTotalBars != iRatesTotal) {
      vwapBuffer[i] = 0.0;
      vwapBandmais1[i] = 0;
      vwapBandmenos1[i] = 0;
      LastTotalBars = iRatesTotal;
   }

   ChartRedraw(ChartID());
   TimerMB = (int)TimeLocal();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateObject() {
   int      offset = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR) - (int)ChartGetInteger(0, CHART_WIDTH_IN_BARS) / 2;
   datetime Hposition = iTime[iRatesTotal - offset];
   double   Vposition;

   if(Anchor == ANCHOR_TOP)
      Vposition = iLow[iRatesTotal - offset];
   else
      Vposition = iHigh[iRatesTotal - offset];

   ObjectCreate(0, prefix, OBJ_ARROW, 0, Hposition, Vposition);
//--- Código Wingdings
   ObjectSetInteger(0, prefix, OBJPROP_ARROWCODE, 233);
//--- definir o estilo da linha da borda
   ObjectSetInteger(0, prefix, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, prefix, OBJPROP_FILL, false);
//--- exibir em primeiro plano (false) ou fundo (true)
   ObjectSetInteger(0, prefix, OBJPROP_BACK, false);
//--- permitir (true) ou desabilitar (false) o modo de movimento do sinal com o mouse
//--- ao criar um objeto gráfico usando a função ObjectCreate, o objeto não pode ser
//--- destacado e movimentado por padrão. Dentro deste método, o parâmetro de seleção
//--- é verdade por padrão, tornando possível destacar e mover o objeto
   ObjectSetInteger(0, prefix, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, prefix, OBJPROP_SELECTED, true);
//--- ocultar (true) ou exibir (false) o nome do objeto gráfico na lista de objeto
   ObjectSetInteger(0, prefix, OBJPROP_HIDDEN, false);
//--- definir a prioridade para receber o evento com um clique do mouse no gráfico
   ObjectSetInteger(0, prefix, OBJPROP_ZORDER, 100);
   ObjectSetInteger(0, prefix, OBJPROP_FILL, true);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CustomizeObject() {
//--- Tamanho do objeto
   ObjectSetInteger(0, prefix, OBJPROP_WIDTH, arrowSize);
//--- Cor
   ObjectSetInteger(0, prefix, OBJPROP_COLOR, vwapColor);
//--- Código Wingdings
   if(Anchor == ANCHOR_TOP)
      ObjectSetInteger(0, prefix, OBJPROP_ARROWCODE, 233);

   if(Anchor == ANCHOR_BOTTOM)
      ObjectSetInteger(0, prefix, OBJPROP_ARROWCODE, 234);

//--- Ponto de Ancoragem
   ObjectSetInteger(0, prefix, OBJPROP_ANCHOR, Anchor);

   if(metodo_vwap == Open) {
      tipo_vwap = "Open";
   } else if(metodo_vwap == High) {
      tipo_vwap = "High";
   } else if(metodo_vwap == Low) {
      tipo_vwap = "Low";
   } else if(metodo_vwap == Median) {
      tipo_vwap = "Median";
   } else if(metodo_vwap == Typical) {
      tipo_vwap = "Typical";
   } else if(metodo_vwap == Weighted) {
      tipo_vwap = "Weighted";
   } else {
      tipo_vwap = "Close";
   }
}
//+------------------------------------------------------------------+
