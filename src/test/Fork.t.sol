pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {Solenv} from "solenv/Solenv.sol";

contract ForkTest is Test {
    uint256 private ethereumFork;
    uint256 private polygonFork;

    // uint256 private optimismFork;

    function setUp() public {
        Solenv.config();
        string memory ethereumUrl = vm.envString("ETHEREUM_MAINNET_URL");
        string memory polygonUrl = vm.envString("POLYGON_MAINNET_URL");
        // string memory optimismUrl = vm.envString("OPTIMISM_MAINNET_URL");

        console2.log("Ethereum URL", ethereumUrl);
        console2.log("Polygon URL", polygonUrl);
        // console2.log("Optimism URL", optimismUrl);

        ethereumFork = vm.createFork(ethereumUrl);
        polygonFork = vm.createFork(polygonUrl);
        // optimismFork = vm.createFork(optimismUrl, 1_337_00);
    }

    function testForking1() public {
        vm.selectFork(ethereumFork);
    }
}
