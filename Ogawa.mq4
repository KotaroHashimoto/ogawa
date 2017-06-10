//+------------------------------------------------------------------+
//|                                                        Ogawa.mq4 |
//|                           Copyright 2017, Palawan Software, Ltd. |
//|                             https://coconala.com/services/204383 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Palawan Software, Ltd."
#property link      "https://coconala.com/services/204383"
#property description "Author: Kotaro Hashimoto <hasimoto.kotaro@gmail.com>"
#property version   "1.00"
#property strict

input double Band_Sigma = 2;
input int Band_Period = 20;

input double RSI_Upper = 67;
input double RSI_Bottom = 33;
input int RSI_Period = 9;

input int Start_Hour = 6;
input int End_Hour = 23;

int previousSignal;


int getBandSignal() {

  double upper = iBands(Symbol(), PERIOD_CURRENT, Band_Period, Band_Sigma, 0, PRICE_WEIGHTED, 1, 1);
  double lower = iBands(Symbol(), PERIOD_CURRENT, Band_Period, Band_Sigma, 0, PRICE_WEIGHTED, 2, 1);
  
  double price = (Bid + Ask) / 2.0;

  if(upper < price) {
    return OP_SELL;
  }

  if(price < lower) {
    return OP_BUY;
  }
  
  return -1;
}


int getRSISignal() {

  double rsi = iRSI(Symbol(), PERIOD_CURRENT, RSI_Period, PRICE_WEIGHTED, 1);
  
  if(RSI_Upper < rsi) {
    return OP_SELL;
  }
  
  if(rsi < RSI_Bottom) {
    return OP_BUY;
  }
  
  return -1;
}


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

  previousSignal = -1;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
  int h = TimeHour(TimeLocal());
  if(h < Start_Hour || End_Hour <= h) {
    return;
  }

  int band = getBandSignal();
  int rsi = getRSISignal();
  
  if(band == OP_BUY && rsi == OP_BUY && previousSignal != OP_BUY) {
    string sbj = "BUY " + Symbol() + " (" + DoubleToStr(Ask, Digits) + ")";
    string msg = "BUY " + Symbol() + " at " + DoubleToStr(Bid, Digits) + " - " + DoubleToStr(Ask, Digits) + ", " + TimeToStr(TimeLocal()) + ", " + AccountServer();

    bool mail = SendMail(sbj, msg);
    Print(sbj, msg);    
    previousSignal = OP_BUY;
  }
  
  else if(band == OP_SELL && rsi == OP_SELL && previousSignal != OP_SELL) {
    string sbj = "SELL " + Symbol() + " (" + DoubleToStr(Ask, Digits) + ")";
    string msg = "SELL " + Symbol() + " at " + DoubleToStr(Bid, Digits) + " - " + DoubleToStr(Ask, Digits) + ", " + TimeToStr(TimeLocal()) + ", " + AccountServer();

    bool mail = SendMail(sbj, msg);
    Print(sbj, msg);
    previousSignal = OP_SELL;    
  }
  
  else if(band == -1 && rsi == -1 && previousSignal != -1) {
    previousSignal = -1;
  }
}
//+------------------------------------------------------------------+
