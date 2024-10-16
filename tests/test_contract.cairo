use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};
use token_sale::token_sale::token_sale::{ITokensaleDispatcher, ITokensaleDispatcherTrait};

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let class_hash = declare(name).unwrap().contract_class();
    let (address, _) = class_hash.deploy(@ArrayTrait::<felt252>::new()).unwrap();
    address
}

#[test]
fn get_token_name() {
    let contract_address = deploy_contract("TokenSale");
    let token_dispatcher = ITokensaleDispatcher { contract_address };
    assert!(token_dispatcher.atotal_supply() == 1000, "Not the total supply");
}
