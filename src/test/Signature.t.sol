// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {DSTest} from "ds-test/test.sol";
import {console2} from "forge-std/console2.sol";
import {Signature} from "../Signature.sol";

contract SignatureTest is DSTest {
    Signature private signature;

    function setUp() public {
        signature = new Signature();
    }

    function testVerify() public {
        string memory message = "secret message";
        bytes32 hash = signature.getHash(message);
        console2.logBytes32(hash);

        // in browser's console with MetaMask:
        //
        // const account = '0x3083A9c26582C01Ec075373A8327016A15c1269B'
        // const message = '0x9c97d796ed69b7e69790ae723f51163056db3d55a7a6a82065780460162d4812'
        //
        // ethereum.request({method: 'personal_sign', params: [account, message]})
        // 0xb0dde1b88975ccd3bf46d2269156fdaf3857a6c5d01a2f1800836f5c814763937945c2628d99d9b9a854428a4270620236ebe2782e58b9ed6b37ffcf5c7d513a1c

        bytes32 signedHash = signature.getSignedHash(hash);
        console2.logBytes32(signedHash);

        bytes
            memory sig = hex"b0dde1b88975ccd3bf46d2269156fdaf3857a6c5d01a2f1800836f5c814763937945c2628d99d9b9a854428a4270620236ebe2782e58b9ed6b37ffcf5c7d513a1c";

        address signer = signature.recover(signedHash, sig);
        console2.logAddress(signer);

        assertEq(signer, 0x3083A9c26582C01Ec075373A8327016A15c1269B);

        bool valid = signature.verify(signer, message, sig);
        assertTrue(valid);
    }
}
