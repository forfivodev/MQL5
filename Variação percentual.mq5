//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "Variação percentual"
#property strict

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- input parameters
input group "****************************  Configurações principais ****************************"
input string id = "1";
//input bool                       ForceDefaultDate = false;
//input datetime                   input_data_inicial = -1;         // Data inicial para mostrar as linhas
//input datetime                   input_data_final = -1;         // Data final para mostrar as linhas
input double                     input_fechamento = 0; // Ponto de partida
input double                     inputPercentual = 0.5;
input double                     input_dolar = 0; // Cotação de referência do US$ (opcional)

input group "****************************  Configurações das variações ****************************"
input color                      VarColorUp = clrLime;    // Cor variação positiva
input color                      VarColorMid = clrYellow;    // Cor fechamento
input color                      VarColorDown = clrRed;    // Cor variação negativa
input ENUM_LINE_STYLE            estilo_variacao = STYLE_DASH; // Estilo das linhas
input int                        espessura_linha_variacao = 1;   // Espessura das linhas
input int                        recuo = 5;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fechamento_dolarizado;
double dolar;
double fechamento;
datetime data_inicial;
datetime data_final;
double percentual;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {

   fechamento = input_fechamento;
   //data_inicial = ontem;
   //data_final = hoje;
   percentual = inputPercentual / 100;



   string shortname = "Variação percentual";
   IndicatorSetString(INDICATOR_SHORTNAME, shortname);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits + 1);

   Update(data_inicial);
   ChartRedraw();

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Update(datetime data1) {

   datetime ontem = StringToTime(TimeToString(TimeCurrent(), TIME_DATE)) ;
   datetime hoje = StringToTime(TimeToString(TimeCurrent() + (PeriodSeconds(PERIOD_D1)), TIME_DATE));

   if(GlobalVariableGet("dolar_global") > 0 && input_dolar == 0) {
      dolar = GlobalVariableGet("dolar_global");
   } else {
      dolar = input_dolar;
   }

   if(dolar == 0)
      dolar = 1;

   if(data1 <= 0) {
      data1 = ontem;
      fechamento = iClose(_Symbol, PERIOD_D1, 1);
   }

   if(data_final <= 0) {
      data_final = hoje;
   }

   //if (ForceDefaultDate) {
   if (input_fechamento <= 0)
      fechamento = iClose(_Symbol, PERIOD_D1, 1);
   else
      fechamento = input_fechamento;
   data1 = ontem;

   data_final = hoje;
   //}

   data_inicial = data1;

   data_final = iTime(_Symbol, PERIOD_CURRENT, 0);

   ObjectsDeleteAll(0, "percentual" + "_" + id);

   ObjectCreate(0, "percentual1" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 24 * percentual), data_final, dolar * fechamento * (1 + 24 * percentual));
   ObjectCreate(0, "percentual2" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 23 * percentual), data_final, dolar * fechamento * (1 + 23 * percentual));
   ObjectCreate(0, "percentual3" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 22 * percentual), data_final, dolar * fechamento * (1 + 22 * percentual));
   ObjectCreate(0, "percentual4" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 21 * percentual), data_final, dolar * fechamento * (1 + 21 * percentual));
   ObjectCreate(0, "percentual5" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 20 * percentual), data_final, dolar * fechamento * (1 + 20 * percentual));
   ObjectCreate(0, "percentual6" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 19 * percentual), data_final, dolar * fechamento * (1 + 19 * percentual));
   ObjectCreate(0, "percentual7" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 18 * percentual), data_final, dolar * fechamento * (1 + 18 * percentual));
   ObjectCreate(0, "percentual8" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 17 * percentual), data_final, dolar * fechamento * (1 + 17 * percentual));
   ObjectCreate(0, "percentual9" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 16 * percentual), data_final, dolar * fechamento * (1 + 16 * percentual));
   ObjectCreate(0, "percentual10" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 15 * percentual), data_final, dolar * fechamento * (1 + 15 * percentual));
   ObjectCreate(0, "percentual11" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 14 * percentual), data_final, dolar * fechamento * (1 + 14 * percentual));
   ObjectCreate(0, "percentual12" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 13 * percentual), data_final, dolar * fechamento * (1 + 13 * percentual));
   ObjectCreate(0, "percentual13" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 12 * percentual), data_final, dolar * fechamento * (1 + 12 * percentual));
   ObjectCreate(0, "percentual14" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 11 * percentual), data_final, dolar * fechamento * (1 + 11 * percentual));
   ObjectCreate(0, "percentual15" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 10 * percentual), data_final, dolar * fechamento * (1 + 10 * percentual));
   ObjectCreate(0, "percentual16" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 9 * percentual), data_final, dolar * fechamento * (1 + 9 * percentual));
   ObjectCreate(0, "percentual17" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 8 * percentual), data_final, dolar * fechamento * (1 + 8 * percentual));
   ObjectCreate(0, "percentual18" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 7 * percentual), data_final, dolar * fechamento * (1 + 7 * percentual));
   ObjectCreate(0, "percentual19" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 6 * percentual), data_final, dolar * fechamento * (1 + 6 * percentual));
   ObjectCreate(0, "percentual20" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 5 * percentual), data_final, dolar * fechamento * (1 + 5 * percentual));
   ObjectCreate(0, "percentual21" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 4 * percentual), data_final, dolar * fechamento * (1 + 4 * percentual));
   ObjectCreate(0, "percentual22" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 3 * percentual), data_final, dolar * fechamento * (1 + 3 * percentual));
   ObjectCreate(0, "percentual23" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 2 * percentual), data_final, dolar * fechamento * (1 + 2 * percentual));
   ObjectCreate(0, "percentual24" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 + 1 * percentual), data_final, dolar * fechamento * (1 + 1 * percentual));

   ObjectCreate(0, "percentual0" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento, data_final, dolar * fechamento);

   ObjectCreate(0, "percentual-1" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 1 * percentual), data_final, dolar * fechamento * (1 - 1 * percentual));
   ObjectCreate(0, "percentual-2" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 2 * percentual), data_final, dolar * fechamento * (1 - 2 * percentual));
   ObjectCreate(0, "percentual-3" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 3 * percentual), data_final, dolar * fechamento * (1 - 3 * percentual));
   ObjectCreate(0, "percentual-4" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 4 * percentual), data_final, dolar * fechamento * (1 - 4 * percentual));
   ObjectCreate(0, "percentual-5" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 5 * percentual), data_final, dolar * fechamento * (1 - 5 * percentual));
   ObjectCreate(0, "percentual-6" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 6 * percentual), data_final, dolar * fechamento * (1 - 6 * percentual));
   ObjectCreate(0, "percentual-7" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 7 * percentual), data_final, dolar * fechamento * (1 - 7 * percentual));
   ObjectCreate(0, "percentual-8" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 8 * percentual), data_final, dolar * fechamento * (1 - 8 * percentual));
   ObjectCreate(0, "percentual-9" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 9 * percentual), data_final, dolar * fechamento * (1 - 9 * percentual));
   ObjectCreate(0, "percentual-10" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 10 * percentual), data_final, dolar * fechamento * (1 - 10 * percentual));
   ObjectCreate(0, "percentual-11" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 11 * percentual), data_final, dolar * fechamento * (1 - 11 * percentual));
   ObjectCreate(0, "percentual-12" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 12 * percentual), data_final, dolar * fechamento * (1 - 12 * percentual));
   ObjectCreate(0, "percentual-13" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 13 * percentual), data_final, dolar * fechamento * (1 - 13 * percentual));
   ObjectCreate(0, "percentual-14" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 14 * percentual), data_final, dolar * fechamento * (1 - 14 * percentual));
   ObjectCreate(0, "percentual-15" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 15 * percentual), data_final, dolar * fechamento * (1 - 15 * percentual));
   ObjectCreate(0, "percentual-16" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 16 * percentual), data_final, dolar * fechamento * (1 - 16 * percentual));
   ObjectCreate(0, "percentual-17" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 17 * percentual), data_final, dolar * fechamento * (1 - 17 * percentual));
   ObjectCreate(0, "percentual-18" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 18 * percentual), data_final, dolar * fechamento * (1 - 18 * percentual));
   ObjectCreate(0, "percentual-19" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 19 * percentual), data_final, dolar * fechamento * (1 - 19 * percentual));
   ObjectCreate(0, "percentual-20" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 20 * percentual), data_final, dolar * fechamento * (1 - 20 * percentual));
   ObjectCreate(0, "percentual-21" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 21 * percentual), data_final, dolar * fechamento * (1 - 21 * percentual));
   ObjectCreate(0, "percentual-22" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 22 * percentual), data_final, dolar * fechamento * (1 - 22 * percentual));
   ObjectCreate(0, "percentual-23" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 23 * percentual), data_final, dolar * fechamento * (1 - 23 * percentual));
   ObjectCreate(0, "percentual-24" + "_" + id, OBJ_TREND, 0, data_inicial, dolar * fechamento * (1 - 24 * percentual), data_final, dolar * fechamento * (1 - 24 * percentual));

   ObjectSetInteger(0, "percentual1" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual2" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual3" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual4" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual5" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual6" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual7" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual8" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual9" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual10" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual11" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual12" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual13" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual14" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual15" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual16" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual17" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual18" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual19" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual20" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual21" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual22" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual23" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual24" + "_" + id, OBJPROP_COLOR, VarColorUp);

   ObjectSetInteger(0, "percentual0" + "_" + id, OBJPROP_COLOR, VarColorMid);

   ObjectSetInteger(0, "percentual-1" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-2" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-3" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-4" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-5" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-6" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-7" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-8" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-9" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-10" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-11" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-12" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-13" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-14" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-15" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-16" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-17" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-18" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-19" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-20" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-21" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-22" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-23" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-24" + "_" + id, OBJPROP_COLOR, VarColorDown);


   ObjectSetInteger(0, "percentual1" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual2" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual3" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual4" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual5" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual6" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual7" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual8" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual9" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual10" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual11" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual12" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual13" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual14" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual15" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual16" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual17" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual18" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual19" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual20" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual21" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual22" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual23" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual24" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);

   ObjectSetInteger(0, "percentual0" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);

   ObjectSetInteger(0, "percentual-1" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-2" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-3" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-4" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-5" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-6" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-7" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-8" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-9" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-10" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-11" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-12" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-13" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-14" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-15" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-16" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-17" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-18" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-19" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-20" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-21" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-22" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-23" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);
   ObjectSetInteger(0, "percentual-24" + "_" + id, OBJPROP_WIDTH, espessura_linha_variacao);

   ObjectSetInteger(0, "percentual1" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual2" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual3" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual4" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual5" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual6" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual7" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual8" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual9" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual10" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual11" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual12" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual13" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual14" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual15" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual16" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual17" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual18" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual19" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual20" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual21" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual22" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual23" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual24" + "_" + id, OBJPROP_STYLE, estilo_variacao);

   ObjectSetInteger(0, "percentual0" + "_" + id, OBJPROP_STYLE, estilo_variacao);

   ObjectSetInteger(0, "percentual-1" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-2" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-3" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-4" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-5" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-6" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-7" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-8" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-9" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-10" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-11" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-12" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-13" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-14" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-15" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-16" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-17" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-18" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-19" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-20" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-21" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-22" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-23" + "_" + id, OBJPROP_STYLE, estilo_variacao);
   ObjectSetInteger(0, "percentual-24" + "_" + id, OBJPROP_STYLE, estilo_variacao);

   data_inicial = iTime(_Symbol, PERIOD_CURRENT, 0) + PeriodSeconds(PERIOD_CURRENT) * recuo;

//datetime tempdate = data_inicial - PeriodSeconds(PERIOD_CURRENT) * 7;
   ObjectCreate(0, "percentual1_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 24 * percentual));
   ObjectCreate(0, "percentual2_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 23 * percentual));
   ObjectCreate(0, "percentual3_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 22 * percentual));
   ObjectCreate(0, "percentual4_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 21 * percentual));
   ObjectCreate(0, "percentual5_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 20 * percentual));
   ObjectCreate(0, "percentual6_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 19 * percentual));
   ObjectCreate(0, "percentual7_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 18 * percentual));
   ObjectCreate(0, "percentual8_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 17 * percentual));
   ObjectCreate(0, "percentual9_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 16 * percentual));
   ObjectCreate(0, "percentual10_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 15 * percentual));
   ObjectCreate(0, "percentual11_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 14 * percentual));
   ObjectCreate(0, "percentual12_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 13 * percentual));
   ObjectCreate(0, "percentual13_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 12 * percentual));
   ObjectCreate(0, "percentual14_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 11 * percentual));
   ObjectCreate(0, "percentual15_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 10 * percentual));
   ObjectCreate(0, "percentual16_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 9 * percentual));
   ObjectCreate(0, "percentual17_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 8 * percentual));
   ObjectCreate(0, "percentual18_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 7 * percentual));
   ObjectCreate(0, "percentual19_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 6 * percentual));
   ObjectCreate(0, "percentual20_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 5 * percentual));
   ObjectCreate(0, "percentual21_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 4 * percentual));
   ObjectCreate(0, "percentual22_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 3 * percentual));
   ObjectCreate(0, "percentual23_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 2 * percentual));
   ObjectCreate(0, "percentual24_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 + 1 * percentual));

   ObjectCreate(0, "percentual0_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento);

   ObjectCreate(0, "percentual-1_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 1 * percentual));
   ObjectCreate(0, "percentual-2_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 2 * percentual));
   ObjectCreate(0, "percentual-3_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 3 * percentual));
   ObjectCreate(0, "percentual-4_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 4 * percentual));
   ObjectCreate(0, "percentual-5_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 5 * percentual));
   ObjectCreate(0, "percentual-6_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 6 * percentual));
   ObjectCreate(0, "percentual-7_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 7 * percentual));
   ObjectCreate(0, "percentual-8_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 8 * percentual));
   ObjectCreate(0, "percentual-9_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 9 * percentual));
   ObjectCreate(0, "percentual-10_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 10 * percentual));
   ObjectCreate(0, "percentual-11_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 11 * percentual));
   ObjectCreate(0, "percentual-12_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 12 * percentual));
   ObjectCreate(0, "percentual-13_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 13 * percentual));
   ObjectCreate(0, "percentual-14_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 14 * percentual));
   ObjectCreate(0, "percentual-15_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 15 * percentual));
   ObjectCreate(0, "percentual-16_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 16 * percentual));
   ObjectCreate(0, "percentual-17_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 17 * percentual));
   ObjectCreate(0, "percentual-18_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 18 * percentual));
   ObjectCreate(0, "percentual-19_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 19 * percentual));
   ObjectCreate(0, "percentual-20_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 20 * percentual));
   ObjectCreate(0, "percentual-21_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 21 * percentual));
   ObjectCreate(0, "percentual-22_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 22 * percentual));
   ObjectCreate(0, "percentual-23_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 23 * percentual));
   ObjectCreate(0, "percentual-24_texto" + "_" + id, OBJ_TEXT, 0, data_inicial, dolar * fechamento * (1 - 24 * percentual));

   ObjectSetString(0, "percentual1_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(24 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual2_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(23 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual3_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(22 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual4_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(21 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual5_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(20 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual6_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(19 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual7_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(18 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual8_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(17 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual9_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(16 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual10_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(15 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual11_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(14 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual12_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(13 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual13_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(12 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual14_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(11 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual15_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(10 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual16_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(9 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual17_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(8 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual18_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(7 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual19_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(6 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual20_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(5 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual21_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(4 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual22_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(3 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual23_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(2 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual24_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(1 * percentual * 100, 2) + "%");

   ObjectSetString(0, "percentual0_texto" + "_" + id, OBJPROP_TEXT, "0.0%");

   ObjectSetString(0, "percentual-1_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-1 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-2_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-2 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-3_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-3 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-4_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-4 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-5_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-5 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-6_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-6 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-7_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-7 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-8_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-8 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-9_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-9 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-10_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-10 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-11_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-11 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-12_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-12 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-13_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-13 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-14_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-14 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-15_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-15 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-16_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-16 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-17_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-17 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-18_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-18 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-19_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-19 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-20_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-20 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-21_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-21 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-22_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-22 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-23_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-23 * percentual * 100, 2) + "%");
   ObjectSetString(0, "percentual-24_texto" + "_" + id, OBJPROP_TEXT, DoubleToString(-24 * percentual * 100, 2) + "%");

   ObjectSetInteger(0, "percentual1_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual2_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual3_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual4_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual5_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual6_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual7_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual8_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual9_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual10_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual11_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual12_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual13_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual14_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual15_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual16_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual17_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual18_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual19_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual20_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual21_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual22_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual23_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);
   ObjectSetInteger(0, "percentual24_texto" + "_" + id, OBJPROP_COLOR, VarColorUp);

   ObjectSetInteger(0, "percentual0_texto" + "_" + id, OBJPROP_COLOR, VarColorMid);

   ObjectSetInteger(0, "percentual-1_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-2_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-3_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-4_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-5_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-6_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-7_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-8_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-9_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-10_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-11_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-12_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-13_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-14_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-15_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-16_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-17_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-18_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-19_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-20_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-21_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-22_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-23_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   ObjectSetInteger(0, "percentual-24_texto" + "_" + id, OBJPROP_COLOR, VarColorDown);
   
   ObjectSetInteger(0, "percentual1_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual2_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual3_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual4_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual5_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual6_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual7_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual8_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual9_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual10_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual11_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual12_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual13_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual14_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual15_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual16_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual17_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual18_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual19_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual20_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual21_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual22_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual23_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual24_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   
   ObjectSetInteger(0, "percentual-0_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   
   ObjectSetInteger(0, "percentual-1_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-2_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-3_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-4_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-5_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-6_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-7_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-8_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-9_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-10_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-11_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-12_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-13_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-14_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-15_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-16_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-17_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-18_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-19_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-20_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-21_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-22_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-23_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, "percentual-24_texto" + "_" + id, OBJPROP_ANCHOR, ANCHOR_CENTER);
   
}

//+------------------------------------------------------------------+
//| Custom indicator Deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   if(reason != REASON_PARAMETERS && reason != REASON_CHARTCHANGE) {
      ObjectsDeleteAll(0, "percentual");
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
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   if(id == CHARTEVENT_CHART_CHANGE) {
      int firstVisibleBar = WindowFirstVisibleBar();
      int barra_data_inicial = iBarShift(_Symbol, PERIOD_CURRENT, data_inicial);
      //if (firstVisibleBar > barra_data_inicial)
      //   data_inicial = input_data_inicial;
      //else
         data_inicial = iTime(_Symbol, PERIOD_CURRENT, firstVisibleBar);

      Update(data_inicial);

   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int WindowFirstVisibleBar() {
   return((int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR));
}
//+------------------------------------------------------------------+
