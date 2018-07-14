pragma solidity ^0.4.11;


contract CrowdFund {

    address owner;

    struct Fund {

        uint256 ether_raised;
        uint256 total_ether;
        bool is_funded;
        bool is_paid;
        address receiver_address;

    }

    mapping (uint256 => Fund) FundIdMap;

    function CrowdFund () public {

        owner = msg.sender;

    }

    function fund (uint256 _fundId, uint256 _total_ether) public payable returns (bool) {

        Fund fund = FundIdMap[_fundId];

        //check if is_funded == true
        require(fund.is_funded == false);
        require(fund.is_paid == false);
        
        if (fund.total_ether == 0) {
            
            fund.total_ether = _total_ether;
            
        }

        //check if ether_raised <= total_ether
        if (fund.ether_raised == fund.total_ether) {
            fund.is_funded = true;
            address(msg.sender).transfer(msg.value);
            return true;
        }

        //time to take fund in smart contract
        if (msg.value > fund.total_ether) {
            uint256 remaining_ether = msg.value - fund.total_ether;
            fund.ether_raised = fund.total_ether;
            fund.is_funded = true;
            address(msg.sender).transfer(remaining_ether);
            return true;
        }
        
        if (msg.value <= fund.total_ether) {
            fund.ether_raised = fund.ether_raised + msg.value;
            if (fund.ether_raised == fund.total_ether) {
                fund.is_funded = true;
                return true;
            }
        }

    }
    
    function give_payout (address _volunteer_address, uint256 _fundId) returns (bool) {
        
        require(owner == msg.sender);
        
        Fund fund = FundIdMap[_fundId];
        
        address(_volunteer_address).transfer(fund.ether_raised);
        
        fund.is_paid = true;
        
        fund.receiver_address = _volunteer_address;
        
        return true;
        
    }
    
    function getFundStatus (uint256 _fundId) constant returns (uint256 _total_ether, uint256 _ether_raised) {
        
        return (FundIdMap[_fundId].total_ether, FundIdMap[_fundId].ether_raised);
        
    }

}
