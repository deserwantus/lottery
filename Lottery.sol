pragma solidity ^0.4.18;

contract Ownable {

	address public owner;

	function Ownable() public {
		owner = msg.sender;
	}

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address _owner) onlyOwner public {
		owner = _owner;
	}

}

contract Lottery is Ownable {

	uint public ticketsCapacity;
	uint public ticketPrice = 2 ether;
	uint public jackpot;
	uint public jackpotIncrement = 1 ether;
	uint public smallWinMultiplier;

	uint public jackpotWinnerNumber;

	mapping(uint => address) public tickets;
	mapping(address => uint) public winningMoney;

	function Lottery(uint _ticketsCapacity, uint _smallWinMultiplier) Ownable() public {

		owner = msg.sender;
		ticketsCapacity = _ticketsCapacity;
		smallWinMultiplier = _smallWinMultiplier;
	}

	function clearTickets() onlyOwner public {
		for(uint i = 1; i <= ticketsCapacity; i++) {
			tickets[i] = 0;
		}
	}

	function buyTicket(uint ticketNumber) payable public {
		require(ticketNumber > 0 && ticketNumber <= ticketsCapacity);
		require(msg.value >= ticketPrice);
		require(tickets[ticketNumber] == 0);

		tickets[ticketNumber] = msg.sender;
		jackpot += jackpotIncrement;

		winningMoney[owner] += ticketPrice / 4;
	}

	function play() onlyOwner public {
		uint smallWinnersCapacity = ticketsCapacity / 100 * 5;

		for(uint i = 1; i <= smallWinnersCapacity; i++) {
			uint smallWinnerNumber = uint(block.blockhash(block.number-1)) % ticketsCapacity + 1;
            address smallWinner = tickets[smallWinnerNumber];
			if(smallWinner != 0) {
				winningMoney[smallWinner] += ticketPrice * smallWinMultiplier;
			}
		}

		jackpotWinnerNumber = uint(block.blockhash(block.number-1)) % ticketsCapacity + 1;
		address jackpotWinner = tickets[jackpotWinnerNumber];
		if(jackpotWinner != 0) {
		    winningMoney[jackpotWinner] += jackpot;
			jackpot = 0;
			clearTickets();
		}
	}

	function withdraw() public {
	    uint amount = winningMoney[msg.sender];

	    if(amount > 0) {
	        msg.sender.transfer(amount);
	        winningMoney[msg.sender] = 0;
	    }
	}
}
