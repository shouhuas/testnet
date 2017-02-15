-module(order_book).
-export([doit/5]).

-record(shares_sold, {ht=0, hf=0, hb=0, lt=0, lf=0, lb=0}).
%h means high difficulty
%l means low difficulty
%t means true
%f means false
%b means bad_question

doit(_NewTrades, _OpenOrders, _SharesSold, _Accounts, _LiquidityConstant) ->
    %calculate the price of trades in this round. So that we know how much to refund traders who trade in this round.
    %It should choose the price so that the maximum number of shares get traded.
    %openOrders is a trie. Its root is hashed into the block headers.
    %actually, openOrders needs two representations. One long-term one on the hard drive in merkle trie format, and another short-term one in ram that is ordered.
    %so besides the account-trie of open orders, we need to keep track of how many open orders there are at every price.
    %That way, the block maker can't censor open orders.

    %a single block only closes orders at a few prices. It would be nice if the block maker only had to provide proofs for how manh open orders there are at those few prices, instead of all the prices. So the number of shares sold at each price should be in a merkle trie.
    NewOpenOrders = ok,
    NewSharesSold = ok,
    NewAccounts = ok,
    {NewOpenOrders, NewSharesSold, NewAccounts}.



