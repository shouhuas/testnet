the new way of doing channel slash has a different problem.
We need the channel to finish at the highest nonce possible. The third party could be bribed to choose a different final state.
We need some way to do the channel_slash transaction again and again, until a higher nonce cannot be found.
Each slasher puts up a deposit, and takes the deposit of the previous.
If the same channel_slash exists for a long enough time period, then anyone can do a channel_timeout transaction, to close the channel.


We should use a CLI program to talk to the node instead of using erlang directly.
It should be able to access everything in /src/networking/internal_handler.erl
We should add everything from easy to internal_handler.erl

We need to update download_blocks so that peers get ranked, and we spend more time talking to higher-ranked peers.
There is a problem where if you crash while syncing with a peer, then you skip trying to sync with any peer lower on the list. this is very bad.

make the api networking/handler be entirely encrypted. This is to protect information about the channels. https://github.com/BumblebeeBat/pink_crypto/blob/master/src/encryption.erl

download_blocks could be more efficient.

maybe nodes need to advertise their own IP/port combo as a peer?

It would be nice if there were some macros for chalang/src/compiler_lisp2.erl that did backtracking. that way we wouldn't have to think about control flow when making smart contracts.




Updates for next time we restart at a genesis block:

proof of existence transaction type.

each tx with a fee needs a to reference a recent hash. Everyone needs to be incentivized to make the hash as recent as possible.

blocks should have headers.

blocks should point to the previous header, not the previous block.

Mining should be on headers, not on blocks.

We need to reward the miner with the transaction fees, to incentivize him to include them. block:absorb_txs

making a channel should require both parties to sign, that way attackers can't trick servers into dropping their channel state.

