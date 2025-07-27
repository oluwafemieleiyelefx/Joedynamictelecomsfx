//+------------------------------------------------------------------+
//|                                               DESUS_Pro_EA.mq5   |
//|         Joedynamictelecomsfx Strategy by Oluwafemi Eleiyele     |
//+------------------------------------------------------------------+
#property copyright "Joedynamictelecomsfx"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>
CTrade trade;

input double InterferenceValue = 1482.9;
input double RiskFactor = 0.02;   // 2% risk per trade
input double LotSize = 0.01;

datetime lastTradeTime;

double CalculateRange(double high, double low) {
   return high - low;
}

double CalculateMidpoint(double high, double low) {
   return low + ((high - low) / 2);
}

void OpenTrade(string symbol, double price, double sl, double tp, bool isBuy) {
   if (isBuy) {
      trade.Buy(LotSize, symbol, price, sl, tp, "DESUS Buy");
   } else {
      trade.Sell(LotSize, symbol, price, sl, tp, "DESUS Sell");
   }
   lastTradeTime = TimeCurrent();
}

bool CanTradeToday() {
   datetime now = TimeCurrent();
   return TimeDay(now) != TimeDay(lastTradeTime);
}

int OnInit() {
   lastTradeTime = 0;
   return INIT_SUCCEEDED;
}

void OnTick() {
   if (!CanTradeToday()) return;

   MqlRates dailyRates[];
   if (CopyRates(_Symbol, PERIOD_D1, 1, 2, dailyRates) != 2) return;

   double high = dailyRates[1].high;
   double low = dailyRates[1].low;
   double range = CalculateRange(high, low);
   double midpoint = CalculateMidpoint(high, low);

   double entryBuy = midpoint + (range / 4);
   double entrySell = midpoint - (range / 4);

   double slBuy = entryBuy - (range * 2);
   double tpBuy = entryBuy + (range * 3);

   double slSell = entrySell + (range * 2);
   double tpSell = entrySell - (range * 3);

   if (SymbolInfoDouble(_Symbol, SYMBOL_BID) > entryBuy) {
      OpenTrade(_Symbol, entryBuy, slBuy, tpBuy, true);
   } else if (SymbolInfoDouble(_Symbol, SYMBOL_BID) < entrySell) {
      OpenTrade(_Symbol, entrySell, slSell, tpSell, false);
   }
}
