//+------------------------------------------------------------------+
//|                                         Calculadora_de_risco.mq5 |
//|                                                  Aurélio Machado |
//|                         https://www.instagram.com/aureliotrader/ |
//+------------------------------------------------------------------+
#property copyright "Aurélio Machado"
#property link      "https://www.instagram.com/aureliotrader/"
#property version   "1.00"
#property indicator_chart_window
#include <Controls\Dialog.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Panel.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
#include <Controls\SpinEdit.mqh>
#include <Controls\WndClient.mqh>

CAppDialog AppWindow;
CEdit valor_risco;
CLabel risco_nome;
CLabel take_nome;
CEdit valor_take;
CLabel stop_nome;
CEdit valor_stop;
CButton btn_calcular;
CButton btn_limpar;
CLabel divisor;
CLabel nome_lot;
CLabel valor_lot;
CLabel nome_lucro;
CLabel valor_lucro;
CLabel nome_loss;
CLabel valor_loss;

#define INDENT_LEFT (11)      // recuo da esquerda (com permissão para a largura da borda)
#define INDENT_TOP (250)      // recuo da parte superior (com permissão para a largura da borda)
#define CONTROLS_GAP_X (5)       // gap pela coordenada X
//--- para os botões
#define BUTTON_WIDTH (100)     // tamanho pela coordenada X
#define BUTTON_HEIGHT (20)      // tamanho pela coordenada Y

double risco = 0.0;
double lot = 0.0;
int take = 0;
int stop = 0;

int OnInit(){
   
   AppWindow.Create(Symbol(),"Gerenciamento",0,20,20,250,330);
   AppWindow.Run();
   criar_estrutura();
   
   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]){
   
   //Comment(ObjectGetString(_Symbol,"Risco",OBJPROP_TEXT,0));
   risco = StringToDouble(ObjectGetString(_Symbol,"Valor_risco",OBJPROP_TEXT,0));
  
   //Calcular a quantidade de lots, a quantidade de lot, o risco retorno.
   
   return(rates_total);
}


void OnChartEvent(const int id,         // ID do evento  
                  const long& lparam,   // parâmetro do evento do tipo long
                  const double& dparam, // parâmetro do evento do tipo double
                  const string& sparam){ // parâmetro do evento do tipo string
  
   if(id==CHARTEVENT_OBJECT_CLICK){
      if(sparam=="btn_calcular"){
           risco = StringToDouble(ObjectGetString(_Symbol,"Valor_risco",OBJPROP_TEXT,0));
           take = StringToInteger(ObjectGetString(_Symbol,"Valor_take",OBJPROP_TEXT,0));
           stop = StringToInteger(ObjectGetString(_Symbol,"Valor_stop",OBJPROP_TEXT,0));
           if(risco == 0){
            Alert("O valor do risco não pode ser igual a zero");
           }
           if(stop == 0){
            Alert("O valor do stop não pode ser igual a zero");
           }
           if(stop != 0 && risco !=0){
            CalcularLot(risco,stop,take);
           }
           
        }
      if(sparam =="btn_limpar"){
         valor_risco.Text("");
         valor_loss.Text("");
         valor_lot.Text("");
         valor_lucro.Text("");
         valor_stop.Text("");
         valor_take.Text("");
         
      }
   }
   AppWindow.ChartEvent(id,lparam,dparam,sparam);
}
  
void criar_estrutura(){
   //Texto para o risco.
   risco_nome.Create(_Symbol,"Risco",0,15,15,100,35);
   risco_nome.Text("Risco:");
   AppWindow.Add(risco_nome);
   //Campo para digitar o risco.
   valor_risco.Create(Symbol(),"Valor_risco",0,55,15,100,35);
   AppWindow.Add(valor_risco);
   //Texto para o take.
   take_nome.Create(_Symbol,"Take",0,15,45,100,35);
   take_nome.Text("Take:");
   AppWindow.Add(take_nome);
   //Campo para digitar o take.
   valor_take.Create(_Symbol,"Valor_take",0,55,45,100,35);
   valor_take.Width(70);
   valor_take.Height(20);
   AppWindow.Add(valor_take);
   //Texto para o stop.
   stop_nome.Create(_Symbol,"Stop",0,15,75,100,35);
   stop_nome.Text("Stop:");
   AppWindow.Add(stop_nome);
   //Campo para digitar o stop.
   valor_stop.Create(_Symbol,"Valor_stop",0,55,75,100,35);
   valor_stop.Width(70);
   valor_stop.Height(20);
   AppWindow.Add(valor_stop);
   //Botão para realizar o calculo.
   btn_calcular.Create(_Symbol,"btn_calcular",0,15,105,100,35);
   btn_calcular.Width(70);
   btn_calcular.Height(20);
   btn_calcular.Text("Calcular");
   AppWindow.Add(btn_calcular);
   //Botão limpar tudo
   btn_limpar.Create(_Symbol,"btn_limpar",0,15,135,100,35);
   btn_limpar.Width(70);
   btn_limpar.Height(20);
   btn_limpar.Text("Limpar");
   AppWindow.Add(btn_limpar);
   //Divisor;
   divisor.Create(_Symbol,"divisor",0,15,165,100,35);
   divisor.Text("####################");
   AppWindow.Add(divisor);
   //Texto para o lot
   nome_lot.Create(_Symbol,"nome_lot",0,15,195,100,35);
   nome_lot.Text("Lot:");
   AppWindow.Add(nome_lot);
   //Valor do lot
   valor_lot.Create(_Symbol,"valor_lot",0,55,195,100,35);
   valor_lot.Text("0.0");
   AppWindow.Add(valor_lot);
   //Texto para o lucro
   nome_lucro.Create(_Symbol,"nome_lucro",0,15,225,100,35);
   nome_lucro.Text("Lucro:");
   AppWindow.Add(nome_lucro);
   //Valor do lucro
   valor_lucro.Create(_Symbol,"valor_lucro",0,55,225,100,35);
   valor_lucro.Text("$0.0");
   AppWindow.Add(valor_lucro);
   //Texto para o los
   nome_loss.Create(_Symbol,"nome_loss",0,15,255,100,35);
   nome_loss.Text("Loss:");
   AppWindow.Add(nome_loss);
   //Valor loss
   valor_loss.Create(_Symbol,"valor_loss",0,55,255,100,35);
   valor_loss.Text("-$0.0");
   AppWindow.Add(valor_loss);
}

void CalcularLot(double risco,int stop,int take){
   double tick_size = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tick_value = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double lot_step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
   if(tick_size == 0 || tick_value == 0 || lot_step == 0){
      Alert("Erro de plataforma");
   }
   
   double risco_financeiro = AccountInfoDouble(ACCOUNT_BALANCE)*risco/100;
   double money_lot_step = ((stop*_Point)/tick_size)*tick_value*lot_step;
   lot = NormalizeDouble((risco_financeiro/money_lot_step) * lot_step,2);
   valor_lot.Text(NormalizeDouble(lot,2));
   valor_lucro.Text("$"+NormalizeDouble(lot*take,2));
   valor_loss.Text("$-"+NormalizeDouble(lot*stop,2));
   
}