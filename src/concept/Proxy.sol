// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract Proxy {
    address private impl;

    function setImpl(address _impl) public {
        impl = _impl;
    }

    function getImpl() public view returns (address) {
        return impl;
    }

    fallback() external {
        // We're not using the Solidity's delegatecall because we want the
        // Proxy contract to return whatever was returned from the
        // callee and we don’t know return data type in advance.
        // Since Solidity is a statically-typed language, it requires us to
        // define function return type before compilation.

        assembly {
            // Load call data into memory

            // Read 32-bytes of memory at address 0x40, which is a special slot
            // that contains the index of the next free memory slot.
            let ptr := mload(0x40)
            // Get call data size and copy it to a slot located at ptr.
            calldatacopy(ptr, 0, calldatasize())

            // Relay the call

            let result := delegatecall(
                // How much gas is remaining in the current call.
                // How much gas the implementation contract is
                // allowed to spend -- "go ahead and spend all gas left".
                gas(),
                // The .slot is a Solidity feature allowing us to get the
                // slot address of a state variable. So here we read the
                // value at impl.slot address. We need to do that since Yul
                // doesn't do anything with state variables -- state
                // variables is a syntactic sugar of Solidity.
                sload(impl.slot),
                ptr,
                calldatasize(),
                // These 2 arguments define where in memory to store return data:
                0, // out
                0 // outsize
            )
            // We're not aware of what data each call returns.
            // Hence we don't use them.

            // Get the size of the data returns by the relayed call.
            let size := returndatasize()
            // Save it to a slot at index ptr.
            returndatacopy(ptr, 0, size)

            // Return if the relayed call was successfull, otherwise -- revert.
            // We're using the data returned by the relayed call in both cases:
            // we want to return what was returned by the call and we want to
            // revert with the same message if the call has reverted.
            switch result
            case 0 {
              revert (ptr, size)
            }
            default {
              return (ptr, size)
            }
        }
    }
}

library StorageSlot {
    function getAddressAt(bytes32 _slot) internal view returns (address a) {
        assembly {
            a := sload(_slot)
        }
    }

    function setAddressAt(bytes32 _slot, address _address) internal {
        assembly {
            sstore(_slot, _address)
        }
    }
}