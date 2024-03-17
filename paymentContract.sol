// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == msg.sender);
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(owner() == msg.sender);
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Registration is Ownable {

    uint256 public fee;
    Payment[] public payments;

    event feePaid (address user, string email, uint256 amount);

    struct Payment {
        address user;
        string email;
        uint256 amount;
    }

    constructor(uint256 _fee) Ownable(msg.sender) {
        fee = _fee;
    }


    function acceptPayment(string memory _email) public payable {
        require(msg.value == fee, "Amount must be equal to the fee");
        payments.push(Payment(msg.sender, _email, msg.value));
        emit feePaid(msg.sender, _email, msg.value);
    }

    function withdrawFunds() external onlyOwner {
        payable((owner())).transfer(address(this).balance);
    }

    function setFee(uint _fee) external onlyOwner {
        fee = _fee;
    }

    function getPaymentsByUser(address _user) public view returns(Payment[] memory) {
        uint256 count = 0;

        for(uint i = 0; i < payments.length; i++) {
            if (payments[i].user == _user) {
                count++;
            }
        }

        Payment[] memory userPayments = new Payment[](count);

        uint index = 0;
        for (uint i = 0; i < payments.length; i++) {
            if (payments[i].user == _user) {
                userPayments[index] = payments[i];
                index++;
            }
        }

        return userPayments;
    }

    function getAllPayments() external view returns(Payment[] memory) {
        return payments;
    }
}