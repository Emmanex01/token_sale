#[starknet::interface]
pub trait ITokensale<TContractState> {
    fn mint(ref self: TContractState, amount: u256);
    fn atotal_supply(self: @TContractState) -> u256;
}

#[starknet::contract]
pub mod TokenSale {
    // Import all required
    use core::num::traits::Zero;
    use openzeppelin::token::erc20::{ERC20Component, ERC20HooksEmptyImpl}; // import openzeppelin 
    use openzeppelin::access::ownable::OwnableComponent;
    use core::starknet::get_caller_address;

    // declare component with component macro
    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage, // holds component state
        #[substorage(v0)]
        ownable: OwnableComponent::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event
    }

    // Implement the component function
    #[abi(embed_v0)]
    impl ERC20MixinImpl =
        ERC20Component::ERC20MixinImpl<ContractState>; // can be accessed externally 
    impl ERC20InternalImpl =
        ERC20Component::InternalImpl<ContractState>; // restricted to internal usage
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl InternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        let name = "Token Sale";
        let symbol = "TS";

        self.erc20.initializer(name, symbol);
        self.ownable.initializer(owner);
    }

    // contract implementation
    #[abi(embed_v0)]
    impl ITokenSaleImpl of super::ITokensale<ContractState> {
        fn mint(ref self: ContractState, amount: u256) {
            let caller = get_caller_address();
            assert!(caller.is_non_zero(), "Zero caller address");
             // This function can only be called by the owner
            self.ownable.assert_only_owner();
            self.erc20.mint(caller, amount);
        }
        fn atotal_supply(self: @ContractState) -> u256 {
            self.erc20.total_supply()
        }
    }
}
