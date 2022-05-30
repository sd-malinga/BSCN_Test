// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
contract GoldToken is ERC20, Ownable, ReentrancyGuard {
    uint256 public ETH_COLLECTED; //ETH COLLECTED FROM THE CROWDSALE 
    uint256 public MAX_ALLOWED = 0.5 ether; //MAX AMOUNT ALLOWED PER USER


    //Mapping to users address to the amount user have deposited using crowdsale

    mapping(address=>uint256) public valueDeposited;

    event CrowdSale(
        address buyer,
        uint256 amount
    ); 
    constructor() ERC20("Gold Token", "GOLD") {
        _mint(address(this), 10000*10**9 * 10**18);
    }


    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
    

    /* 
    @dev Crowsale function: sells GOLD to the msg sender with the price 1 ether = 1000 tokens
    @dev calculate amount of GOLD to be transferred
    @dev transfers GOLD to the msg.sender
    @dev burns 2% of the GOLD Transferred from the smart Contract
    @dev increases the value deposited in the contract
     */
     
    function crowdSale() external payable nonReentrant {
        uint256 amt = msg.value;
        require((ETH_COLLECTED += amt ) <= 10 ether, "Sale Completed");
        require((valueDeposited[msg.sender] += amt) <= 0.5 ether, "Limit Exceed");
        uint256 amtTrans = 1000 * amt;
        uint256 amtBurn = (amtTrans * 2)/100;
        crowdTransfer(msg.sender, amtTrans);
        _burn(address(this), amtBurn);   
    }

    function crowdTransfer(address to, uint256 amt) internal {
        _transfer(address(this), to, amt);
        emit CrowdSale(
            to,
            amt
        );
    }
    
}