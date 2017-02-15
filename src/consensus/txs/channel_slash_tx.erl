-module(channel_slash_tx).
-export([doit/4, make/6]).
-record(cs, {from, nonce, fee = 0, 
	     scriptpubkey, scriptsig}).
make(From, Fee, ScriptPubkey, ScriptSig, Accounts,Channels) ->
    SPK = testnet_sign:data(ScriptPubkey),
    CID = spk:cid(SPK),
    {_, Acc, Proof1} = account:get(From, Accounts),
    {_, Channel, Proofc} = channel:get(CID, Channels),
    Acc1 = channel:acc1(Channel),
    Acc2 = channel:acc2(Channel),
    Accb = case From of
	       Acc1 -> Acc2;
	       Acc2 -> Acc1
	   end,
    {_, _, Proof2} = account:get(Accb, Accounts),
    Tx = #cs{from = From, nonce = account:nonce(Acc)+1, 
	      fee = Fee, 
	      scriptpubkey = ScriptPubkey, 
	      scriptsig = ScriptSig},
    {Tx, [Proof1, Proof2, Proofc]}.

doit(Tx, Channels, Accounts, NewHeight) ->
    %From = Tx#cs.from,
    %CID = Tx#cs.cid,
    SignedSPK = Tx#cs.scriptpubkey,
    SPK = testnet_sign:data(SignedSPK),
    CID = spk:cid(SPK),
    {_, OldChannel, _} = channel:get(CID, Channels),
    Channel = channel:update(CID, Channels, none, channel:rent(OldChannel), 0,0,channel:mode(OldChannel), channel:delay(OldChannel), NewHeight),
    true = testnet_sign:verify(SignedSPK, Accounts),
    Acc1 = channel:acc1(Channel),
    Acc2 = channel:acc2(Channel),
    Acc1 = spk:acc1(SPK),
    Acc2 = spk:acc2(SPK),
    true = channel:entropy(Channel) == spk:entropy(SPK),
    Mode = channel:mode(Channel),
    SR = spk:slash_reward(SPK),
    Fee = Tx#cs.fee,
    Nonce = Tx#cs.nonce,
    {ID, Acc1Fee, Acc2Fee} = 
	case Mode of
	    2 -> {Acc1, SR, 0};
	    1 -> {Acc2, 0, SR};
	    _ -> Acc1 = Acc2
	end,
    {Amount, NewCNonce} = spk:run(fast, Tx#cs.scriptsig, SPK, NewHeight, 1, Accounts, Channels),
    true = NewCNonce > channel:nonce(Channel),
    %delete the channel. empty the channel into the accounts.
    NewChannels = channel:delete(CID, Channels),
    true = (-1 < (channel:bal1(Channel)-Acc1Fee-Amount)),%channels can only delete money that was inside the channel.
    true = (-1 < (channel:bal2(Channel)-Acc2Fee+Amount)),
    Account1 = account:update(Acc1, Accounts, channel:bal1(Channel)-Acc1Fee-Amount, none, NewHeight),
    Account2 = account:update(Acc2, Accounts, channel:bal2(Channel)-Acc2Fee+Amount, none, NewHeight),
    Account3 = account:update(ID, Accounts, SR-Fee, Nonce, NewHeight),
    Accounts2 = account:write(Accounts, Account1),
    Accounts3 = account:write(Accounts2, Account3),
    NewAccounts = account:write(Accounts3, Account2), 
   {NewChannels, NewAccounts}. 
		      
