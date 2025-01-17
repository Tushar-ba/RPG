// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.27;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract RPGtoken20 is Initializable,ERC20Upgradeable,OwnableUpgradeable, {

    uint8 public FREE_CLAIM ;
    uint public PAY_FEE;
    address public OWNER;
    struct claimer{
        uint balance;
        bool alreadyClaimed;
    }

    mapping (address =>claimer) private claimerInfo;

    event claimedTokens(address _to,uint _FREE_CLAIM);
    event claimedFeePay(address _to,uint _FREE_CLAIM);

    error InsufficientFunds(uint available);
    error alreadyClaimed();
    error incorrectFee(uint _value);

    function initialize(string memory name, string memory symbol, uint value, uint8 _freeClaim, uint _payFee) public initializer{
        __ERC20_init(name,symbol);
        __Ownable_init(msg.sender);
        _mint(address(this),value * (10**decimals()));
        FREE_CLAIM = _freeClaim;
        PAY_FEE = _payFee;
        OWNER = msg.sender;
    }
    function mint(uint value) public onlyOwner() {
        _mint(address(this), value * (10**decimals()));
    }

    function ClaimFreeTokens() public{
        if(balanceOf(address(this))<FREE_CLAIM){
            revert InsufficientFunds(balanceOf(address(this)));
        }
        claimer storage info = claimerInfo[msg.sender];
        if(!info.alreadyClaimed && info.balance == 0){
        // _approve(address(this), msg.sender, FREE_CLAIM * (10**decimals()));
        _transfer(address(this), msg.sender,FREE_CLAIM);
        info.balance+=FREE_CLAIM; 
        info.alreadyClaimed = true;
        emit claimedTokens(msg.sender,FREE_CLAIM);
        }else{
            revert alreadyClaimed();
        }
    }
    function payAndClaimToken() external payable{
        claimer storage info = claimerInfo[msg.sender];
        if(info.alreadyClaimed){
            revert alreadyClaimed();
        }
        if(msg.value != PAY_FEE){
            revert incorrectFee(msg.value);
        }
        if(msg.value == PAY_FEE){
        _approve(address(this), msg.sender, FREE_CLAIM);
        _transfer(address(this), msg.sender,FREE_CLAIM);
        info.balance+=FREE_CLAIM; 
        info.alreadyClaimed = true; 
        emit claimedFeePay(msg.sender,FREE_CLAIM);
        }
    }

    function withDrawTheFee() public payable onlyOwner(){
        uint256 balance = address(this).balance; 
        require(address(this).balance > 0, "Not enough balance");
        (bool success,) = OWNER.call{value: balance}("");
        require(success,"Transfer failed");
    }

    function getDetails() public view returns(uint , bool){
        claimer memory info = claimerInfo[msg.sender];
        return (info.balance, info.alreadyClaimed);
    }
}