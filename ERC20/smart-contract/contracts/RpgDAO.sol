// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../Interface/IRpgNFT.sol";

contract DAO is Initializable, OwnableUpgradeable, AccessControlUpgradeable {
    uint public nextProposalId;
    IRpgNFT public rpgNFTContract;

    struct Proposal {
        uint proposalId;
        string proposalDescription;
        uint numberOfVotesFor;
        uint numberOfVotesAgainst;
        bool isProposalOn;
    }

    struct Voter {
        bool votedFor;
        bool votedAgainst;
    }

    mapping(uint => Proposal) public proposals;
    mapping(uint => mapping(address => Voter)) public voters;

    event ProposalCreated(uint id, string description);
    event Voted(uint proposalId, address voter, bool voteFor);

    error YouDoNotHaveTheNFT();
    error NoRole();
    error AlreadyVoted();
    error ProposalNotActive();

    function initialize(address _NFTContractAddress) external initializer {
        __Ownable_init();
        __AccessControl_init();
        rpgNFTContract = IRpgNFT(_NFTContractAddress);
    }

    function createProposal(string calldata _description) external {
        uint proposalId = nextProposalId++;
        (, IRpgNFT.Role role, ,) = rpgNFTContract.getNFTdetails(msg.sender);
        if (role != IRpgNFT.Role.King && role != IRpgNFT.Role.Queen) {
            revert YouDoNotHaveTheNFT();
        }

        proposals[proposalId] = Proposal({
            proposalId: proposalId,
            proposalDescription: _description,
            isProposalOn: true,
            numberOfVotesFor: 0,
            numberOfVotesAgainst: 0
        });

        emit ProposalCreated(proposalId, _description);
    }

    function voteForProposal(uint _proposalId, bool _voteFor) external {
        Proposal storage proposal = proposals[_proposalId];
        if (!proposal.isProposalOn) {
            revert ProposalNotActive();
        }
        Voter storage voter = voters[_proposalId][msg.sender];
        if (voter.votedFor || voter.votedAgainst) {
            revert AlreadyVoted();
        }
        uint voteWeight = getVoteWeight(msg.sender);
        if (_voteFor) {
            proposal.numberOfVotesFor += voteWeight;
            voter.votedFor = true;
        } else {
            proposal.numberOfVotesAgainst += voteWeight;
            voter.votedAgainst = true;
        }

        emit Voted(_proposalId, msg.sender, _voteFor);
    }

    function getVoteWeight(address _voter) internal view returns (uint) {
        (, IRpgNFT.Role role, ,) = rpgNFTContract.getNFTdetails(_voter);

        if (role == IRpgNFT.Role.King) {
            return 3;
        } else if (role == IRpgNFT.Role.Queen) {
            return 2;
        } else if (role == IRpgNFT.Role.Commoner || role == IRpgNFT.Role.Joker) {
            return 1;
        } else {
            revert NoRole();
        }
    }
}
