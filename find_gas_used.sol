pragma solidity ^0.4.x;

contract TestSStore12 {
    uint public totalgas = msg.gas;
    uint128 v1;
    uint128 v2;
    
    function store (uint128 _a, uint128 _b) external {
      v1 = _a;
      v2 = _b;
    }
}