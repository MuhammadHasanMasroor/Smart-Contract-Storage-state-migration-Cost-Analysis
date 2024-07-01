//SPDX-License-Identifier: No-Idea!

pragma solidity 0.8.1;
//inheritance level proxy contract
abstract contract Upgradeable {
    mapping(bytes4 => uint32) _sizes;
    address _dest;

    function initialize() virtual public ;

    //IT IS USED AS A REPLACING FUNCTION WHERE WE CHANGE THE ADDRESS AND IT WILL CHANGE THE SMART CONTRACT 
    function replace(address target) public {
        _dest = target;
        target.delegatecall(abi.encodeWithSelector(bytes4(keccak256("initialize()"))));
    }
}

contract Dispatcher is Upgradeable {
//this will treat as a proxy contract

    //this will set's the target (the smart contract we will use)
    constructor(address target) {
        replace(target);
    }

    function initialize() override public{
        // Should only be called by on target contracts, not on the dispatcher
        assert(false);
    }

    //reroutes all the requests to the smart contract and give reaction as reverted or completed
    fallback() external {
        bytes4 sig;
        assembly { sig := calldataload(0) }
        uint len = _sizes[sig];
        address target = _dest;

        assembly {
            // return _dest.delegatecall(msg.data)
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(sub(gas(), 10000), target, 0x0, calldatasize(), 0, len)
            return(0, len) //we throw away any return data
        }
    }
}
//this will treat as a smart contract
contract Example is Upgradeable {
    uint _value;

    function initialize() override public {
        _sizes[bytes4(keccak256("getUint()"))] = 32;
    }

    //SETTING THE UNIT FOR DATA
    function getUint() public view returns (uint) {
        return _value*6;
    }

    function setUint(uint value) public {
        _value = value;
    }
}