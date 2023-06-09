//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2022, 2023"
#property description "BBands profit"
#property indicator_chart_window

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum tipoAtivo {
   Ind,
   Dol
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input tipoAtivo ativo = Ind;
input color  cor = clrRoyalBlue;
input double dolar1 = 5.1574;
input double dolar2 = 5.3952;
input bool dolarizar = false;
input int  inputCotacaoDolar = 1;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCsvData {
 public:
   double            price;
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCsvData CsvList[];
double filterVoume;
string nomeArquivo;
double r1;
double r2;
double cotacaoDolar;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

   if (ativo == Ind)
      nomeArquivo = "indbbands.csv";
   else
      nomeArquivo = "dolbbands.csv";

   if (inputCotacaoDolar == 1)
      cotacaoDolar = dolar1;
   else
      cotacaoDolar = dolar2;

   ReadCsvData();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ArrayFree(CsvList);
   ObjectsDeleteAll(0, "bbands_profit_");
   ChartRedraw();
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
void ReadCsvData() {
   double preco;
   ArrayFree(CsvList);
   ObjectsDeleteAll(0, "bbands_profit_line");
   ArrayResize(CsvList, 0);
   int fHandle = FileOpen(nomeArquivo, FILE_BIN | FILE_READ);
   if(fHandle == INVALID_HANDLE) {
      Print("failed to open csv file, error code: ", GetLastError());
      return;
   }
   uchar buf[];
   int ii, csvColumnSz = 1; //yahoo finance csv has 7 columns
   string readStr = "";
   FileSeek(fHandle, 0, SEEK_SET);
   FileReadArray(fHandle, buf, 0, WHOLE_ARRAY);
   FileClose(fHandle);
   readStr = CharArrayToString(buf, 0, WHOLE_ARRAY, CP_UTF8); //yahoo csv's text coding is utf-8
   if(readStr != "") {
      string elArr[], dataArr[], tmpStr = "";
      datetime x1 = iTime(NULL, PERIOD_D1, 2);
      datetime x2 = iTime(NULL, PERIOD_CURRENT, 0);
      StringSplit(readStr, '\n', elArr); //yahoo's csv row separator is 0x0a (i.e. \n)

      for(ii = 0; ii < ArraySize(elArr); ii++) {
         if(elArr[ii] == "" || StringToDouble(elArr[ii]) == 0) //filter out empty row and first title row
            continue;
         StringSplit(elArr[ii], ';', dataArr); // ';' is an inline separator
         if(ArraySize(dataArr) < csvColumnSz || StringToDouble(dataArr[0]) == 0)
            continue;

         if (dolarizar)
            preco = StringToDouble(dataArr[0]) / cotacaoDolar;
         else
            preco = StringToDouble(dataArr[0]);

         ArrayResize(CsvList, ArraySize(CsvList) + 1);
         int lastIndex = ArraySize(CsvList) - 1;
         CsvList[lastIndex].price = preco;

      }

      for(int i = 0; i < ArraySize(CsvList); i++) {
         string nomeLinha = "bbands_profit__line" + i;
         double preco = CsvList[i].price;

         ObjectCreate(0, nomeLinha, OBJ_HLINE, 0, x1, preco, x2, preco);
         ObjectSetInteger(0, nomeLinha, OBJPROP_COLOR, cor);
         ObjectSetString(0, nomeLinha, OBJPROP_TOOLTIP,
                         "\nPreço US$: " + NormalizeDouble(preco, 0) +
                         "\nPreço R$: " + NormalizeDouble(preco * cotacaoDolar, 0));
      }
   }

   int k = 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
   if(id == CHARTEVENT_OBJECT_ENDEDIT) {
      ReadCsvData();
      ChartRedraw();
   }
}
//+------------------------------------------------------------------+
