//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2022, 2023"
#property description "Níveis dolarizados"
#property indicator_chart_window

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enum_ativo {
   Win,
   Wdo,
   Ações
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input datetime dataInicial = "2021.01.04 10:00:00";
input enum_ativo ativo = Win;
input string inputId = "levels";
input double inputPrecoInicial = 4;
input double cotacaoDolar = 3.6555;
input double inputMax  = 0;
input double inputIntervalo = 50;
input double inputDesvio = 1;
input bool preencher = true;
input int larguraLinha = 3;
input color corPrimaria = clrOrange;
input color corSecundaria = clrOrange;
input int WaitMilliseconds = 300000;  // Timer (milliseconds) for recalculation

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double intervalo;
string id;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   _updateTimer = new MillisecondTimer(WaitMilliseconds, false);
   EventSetMillisecondTimer(WaitMilliseconds);

   Update();

   ChartRedraw();

   return(INIT_SUCCEEDED);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ObjectsDeleteAll(0, inputId);
   delete(_updateTimer);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Update() {

   id = inputId + "_";
   ObjectsDeleteAll(0, id + "up_");
   ObjectsDeleteAll(0, id + "down_");

   double onetick = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double dataArray[];
   long totalRates = SeriesInfoInteger(_Symbol, PERIOD_CURRENT, SERIES_BARS_COUNT);

   double intervaloCalculado;
   double desvio, divisor;
   if (ativo == Ações) {
      intervaloCalculado = inputIntervalo / 100;
      desvio = inputDesvio;
      divisor = 1;
   } else if (ativo == Win) {
      intervaloCalculado = inputIntervalo;
      desvio = inputDesvio;
      divisor = 100;
   } else if (ativo == Wdo) {
      intervaloCalculado = inputIntervalo;
      desvio = inputDesvio;
      divisor = 1;
      onetick = 0.500;
   }


   long qtd;
   long nBandas = 100 / inputIntervalo;
   double max, min;
   if (inputMax <= 0) {
      double arrayMax[], arrayMin[];
      ArrayResize(arrayMax, totalRates);
      CopyHigh(_Symbol, PERIOD_CURRENT, 0, totalRates, arrayMax);
      max = arrayMax[ArrayMaximum(arrayMax)];
      min = 0;
      qtd = max / onetick;
   } else {
      qtd = inputMax / onetick;
   }
   double total = 0;

   double precoInicial = 0, precoFinal = 0;
   double preco, precoDolar, resto;
   color cor = corSecundaria;
   datetime hoje = iTime(NULL, PERIOD_CURRENT, 0);
   for(int i = 0; i < qtd - 1; i++) {
      total++;
      preco = (max - i * onetick);
      if (ativo == Ações) {
         precoDolar = (max - i * onetick) / cotacaoDolar;
         resto = MathMod(precoDolar, divisor);
      } else if (ativo == Win) {
         precoDolar = (max - i * onetick) / cotacaoDolar;
         resto = MathMod(precoDolar, divisor);
      } else if (ativo == Wdo) {
         precoDolar = (max - i * onetick) / cotacaoDolar / 10;
         resto = MathMod(precoDolar, divisor) * 100;
      }

      string name = id + "up_" + i;

      if (resto <= desvio ||
            (resto >= (2 * intervaloCalculado - desvio) && resto <= (2 * intervaloCalculado + desvio)) ||
            (nBandas > 4 && resto >= (4 * intervaloCalculado - desvio) && resto <= (4 * intervaloCalculado + desvio)) ||
            (nBandas > 4 && resto >= (6 * intervaloCalculado - desvio) && resto <= (6 * intervaloCalculado + desvio)) ||
            (nBandas > 8 && resto >= (8 * intervaloCalculado - desvio) && resto <= (8 * intervaloCalculado + desvio)) ||
            (nBandas > 8 && resto >= (10 * intervaloCalculado - desvio) && resto <= (10 * intervaloCalculado + desvio)) ||
            (nBandas > 8 && resto >= (12 * intervaloCalculado - desvio) && resto <= (12 * intervaloCalculado + desvio)) ||
            (nBandas > 8 && resto >= (14 * intervaloCalculado - desvio) && resto <= (14 * intervaloCalculado + desvio)) ||
            (resto >= (100 - desvio))) {
         if (precoInicial == 0)
            precoInicial = preco;
         else
            precoFinal = preco;
         cor = corPrimaria;
         int z = 0;
      } else if ((resto >= (intervaloCalculado - desvio) && resto <= (intervaloCalculado + desvio)) ||
                 (resto >= (3 * intervaloCalculado - desvio) && resto <= (3 * intervaloCalculado + desvio)) ||
                 (nBandas > 4 && resto >= (5 * intervaloCalculado - desvio) && resto <= (5 * intervaloCalculado + desvio)) ||
                 (nBandas > 4 && resto >= (7 * intervaloCalculado - desvio) && resto <= (7 * intervaloCalculado + desvio)) ||
                 (nBandas > 8 && resto >= (9 * intervaloCalculado - desvio) && resto <= (9 * intervaloCalculado + desvio)) ||
                 (nBandas > 8 && resto >= (11 * intervaloCalculado - desvio) && resto <= (11 * intervaloCalculado + desvio)) ||
                 (nBandas > 8 && resto >= (13 * intervaloCalculado - desvio) && resto <= (13 * intervaloCalculado + desvio)) ||
                 (nBandas > 8 && resto >= (15 * intervaloCalculado - desvio) && resto <= (15 * intervaloCalculado + desvio))
                ) {
         if (precoInicial == 0)
            precoInicial = preco;
         else
            precoFinal = preco;
         cor = corSecundaria;
         int z = 0;
      } else {
         if (precoInicial > 0 && precoFinal > 0) {
            //ObjectCreate(0, name, OBJ_RECTANGLE, 0, dataInicial, precoInicial, hoje, precoInicial);
            //ObjectSetInteger(0, name, OBJPROP_COLOR, cor);
            //ObjectSetInteger(0, name, OBJPROP_WIDTH, larguraLinha);
            //ObjectSetInteger(0, name, OBJPROP_FILL, preencher);

            double midPrice = precoInicial - (MathAbs(precoInicial - precoFinal) / 2);
            //if (ativo == Wdo)
            //   midPrice = midPrice / 10;

            ObjectCreate(0, name + "_mid", OBJ_HLINE, 0, dataInicial, midPrice );
            ObjectSetInteger(0, name + "_mid", OBJPROP_COLOR, cor);
            if (ativo == Wdo)
               ObjectSetString(0, name + "_mid", OBJPROP_TEXT, NormalizeDouble(midPrice / cotacaoDolar / 10, 1));
            else if (ativo == Win)
               ObjectSetString(0, name + "_mid", OBJPROP_TEXT, NormalizeDouble(midPrice / cotacaoDolar, 1));
            else if (ativo == Ações)
               ObjectSetString(0, name + "_mid", OBJPROP_TEXT, NormalizeDouble(midPrice / cotacaoDolar, 2));
         }
         precoInicial = 0;
         precoFinal = 0;
         cor = corSecundaria;
      }

   }

   return true;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[]) {
//--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
   CheckTimer();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckTimer() {
   EventKillTimer();

   if(_updateTimer.Check() || !_lastOK) {
      _lastOK = Update();
      //if (debug) Print("Regressão linear híbrida " + " " + _Symbol + ":" + GetTimeFrame(Period()) + " ok");

      EventSetMillisecondTimer(WaitMilliseconds);

      _updateTimer.Reset();
   } else {
      EventSetTimer(1);
   }
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   if(id == CHARTEVENT_CHART_CHANGE) {
      _lastOK = true;
      CheckTimer();
      return;
   }
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

bool _lastOK = false;
MillisecondTimer *_updateTimer;
//+------------------------------------------------------------------+
