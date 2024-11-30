;; Title: Bitcoin-Backed NFT Platform

;; Summary:
;; This smart contract implements a Bitcoin-backed NFT platform on the Stacks blockchain. It allows users to mint, transfer, stake, and burn NFTs backed by real-world assets. Additionally, it includes a governance token mechanism for rewarding NFT staking.

;; Description:
;; The Bitcoin-Backed NFT Platform provides a comprehensive solution for managing NFTs tied to real-world assets. Key features include:
;; - **Minting NFTs**: Users can mint new NFTs by providing a unique token ID, asset type, and asset value.
;; - **Transferring NFTs**: NFTs can be transferred between users with checks to ensure the sender is the owner and the NFT is not actively staked.
;; - **Staking NFTs**: Owners can stake their NFTs to earn governance tokens as rewards. Staking information is tracked, and rewards are calculated based on the asset value and staking duration.
;; - **Unstaking NFTs**: Users can unstake their NFTs to claim rewards. The staking information is reset, and governance tokens are credited to the user's account.
;; - **Burning NFTs**: Owners can burn their NFTs, provided they are not staked, to remove them from circulation.
;; - **Governance Token Redemption**: Users can redeem their accumulated governance tokens for equivalent value or governance actions.

;; The contract includes various error handling mechanisms to ensure secure and authorized operations. It also provides read-only functions to retrieve NFT metadata and governance token balances.

(define-non-fungible-token bitcoin-backed-nft (buff 32))

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-NOT-FOUND (err u2))
(define-constant ERR-ALREADY-MINTED (err u3))
(define-constant ERR-INVALID-TRANSFER (err u4))
(define-constant ERR-STAKING-ERROR (err u5))
(define-constant ERR-INSUFFICIENT-BALANCE (err u6))

;; Storage
(define-map nft-metadata 
    {token-id: (buff 32)} 
    {
        owner: principal,
        asset-type: (string-utf8 50),  ;; Type of real-world asset
        asset-value: uint,             ;; Monetary value
        mint-timestamp: uint,
        staking-start: (optional uint),
        staking-rewards: uint
    }
)

;; Map to track NFT staking
(define-map nft-staking 
    {token-id: (buff 32)} 
    {
        staked-by: principal,
        stake-start-block: uint,
        total-staked-blocks: uint
    }
)

;; Governance token mapping for staking rewards
(define-map governance-tokens 
    principal 
    uint
)

;; Read-only functions for metadata retrieval
(define-read-only (get-nft-metadata (token-id (buff 32)))
    (map-get? nft-metadata {token-id: token-id})
)

(define-read-only (get-governance-tokens (user principal))
    (default-to u0 (map-get? governance-tokens user))
)

;; Mint a new Bitcoin-backed NFT
(define-public (mint-nft 
    (token-id (buff 32))
    (asset-type (string-utf8 50))
    (asset-value uint)
)
    (begin
        ;; Check if NFT already exists
        (asserts! (is-none (nft-get-owner? bitcoin-backed-nft token-id)) ERR-ALREADY-MINTED)
        
        ;; Mint the NFT
        (try! (nft-mint? bitcoin-backed-nft token-id tx-sender))
        
        ;; Store NFT metadata
        (map-set nft-metadata 
            {token-id: token-id}
            {
                owner: tx-sender,
                asset-type: asset-type,
                asset-value: asset-value,
                mint-timestamp: block-height,
                staking-start: none,
                staking-rewards: u0
            }
        )
        
        (ok token-id)
    )
)

;; Transfer NFT with additional checks
(define-public (transfer-nft 
    (token-id (buff 32))
    (sender principal)
    (recipient principal)
)
    (let 
        (
            (metadata (unwrap! (map-get? nft-metadata {token-id: token-id}) ERR-NOT-FOUND))
        )
        ;; Verify sender is current owner
        (asserts! (is-eq sender (get owner metadata)) ERR-UNAUTHORIZED)
        
        ;; Ensure no active staking
        (asserts! (is-none (get staking-start metadata)) ERR-INVALID-TRANSFER)
        
        ;; Transfer NFT
        (try! (nft-transfer? bitcoin-backed-nft token-id sender recipient))
        
        ;; Update metadata
        (map-set nft-metadata 
            {token-id: token-id}
            (merge metadata {owner: recipient})
        )
        
        (ok true)
    )
)

;; Stake NFT for governance and rewards
(define-public (stake-nft (token-id (buff 32)))
    (let 
        (
            (metadata (unwrap! (map-get? nft-metadata {token-id: token-id}) ERR-NOT-FOUND))
            (current-block block-height)
        )
        ;; Verify owner
        (asserts! (is-eq tx-sender (get owner metadata)) ERR-UNAUTHORIZED)
        
        ;; Ensure not already staked
        (asserts! (is-none (get staking-start metadata)) ERR-STAKING-ERROR)
        
        ;; Update NFT metadata with staking info
        (map-set nft-metadata 
            {token-id: token-id}
            (merge metadata 
                {
                    staking-start: (some current-block)
                }
            )
        )
        
        ;; Create staking entry
        (map-set nft-staking 
            {token-id: token-id}
            {
                staked-by: tx-sender,
                stake-start-block: current-block,
                total-staked-blocks: u0
            }
        )
        
        (ok true)
    )
)