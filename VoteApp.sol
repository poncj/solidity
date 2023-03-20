// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol"; // i am done!

contract VoteApp {

    address public owner;

    uint internal autoincrementSession = 0;
    uint internal autoincrementVote = 0;
    //uint internal autoincrementSessionVotes = 0;

    struct Session {
        uint256 _id;
        string _name;
        uint8 _status;
        string[] _options;
        address _createdBy;
    }

    struct Vote {
        uint256 _id;
        uint256 _id_session;
        address _votedBy;
        uint256 _id_option;
    }

    struct SessionView {
        uint256 id_session;
        string name;
        uint8 status;
    }

    Session[] internal table_session;
    Vote[] internal table_vote;
    uint256[][] internal table_session_votes; // id_session -> id_vote;

    enum SessionStatus {
        Created,
        Started,
        Closed
    }

    constructor() {
        owner = msg.sender;
    }

    function createSession(string memory _name, string[] memory _options) public {
        
        Session memory _session;
        _session._id = autoincrementSession;
        _session._name = _name;
        _session._status = uint8(SessionStatus.Created);
        _session._options = _options;
        _session._createdBy = msg.sender;

        table_session.push(_session);
        table_session_votes.push([_session._id]);
        
        autoincrementSession++;
        //autoincrementSessionVotes++;
    }


    function updateOptions(uint256 _id_session, string[] memory _options) public {
        require(isSessionOwner(_id_session), "Only session owner");
        require(table_session[_id_session]._status == uint8(SessionStatus.Created), "Cannot change ongoing voting");
        table_session[_id_session]._options = _options;
    }


    function closeSession(uint256 _id_session) public {
        require(isSessionOwner(_id_session), "Only session owner");
        table_session[_id_session]._status = uint8(SessionStatus.Closed);
    }

    function startSession(uint256 _id_session) public {
        require(isSessionOwner(_id_session), "Only session owner");
        require(table_session[_id_session]._status == uint8(SessionStatus.Created), "Session isn't new");
        table_session[_id_session]._status = uint8(SessionStatus.Started);
    }

    function makeVote(uint256 _id_session, uint256 _id_option) public {
        
        require(table_session[_id_session]._status == uint8(SessionStatus.Started), "Session is not started");
        require(!alreadyVoted(_id_session), "Already voted");
        
        if (_id_option > table_session[_id_session]._options.length - 1) {
            revert("has no such option");
        }


        Vote memory _vote;
        _vote._id = autoincrementVote;
        _vote._id_session = _id_session;
        _vote._votedBy = msg.sender;
        _vote._id_option = _id_option;
        
        table_vote.push(_vote);
        autoincrementVote++;

        table_session_votes[_vote._id_session].push(_vote._id);
    }

    function getOptions(uint256 _id_session) public view returns(string[] memory) {
        return table_session[_id_session]._options;
    }
    
    /*
        bool flag = flags[dynamicIndex][lengthTwoIndex];
        
        Documentation:

        For example, if you have a variable uint[][5] memory x,
        you access the seventh uint in the third dynamic array using x[2][6], 
        and to access the third dynamic array, use x[2]. 
        Again, if you have an array T[5] a for a type T that can also be an array,
        then a[2] always has type T.
    */

    function getVotes(uint256 _id_session) internal view returns(uint[] memory) {
    
        uint256 length = table_session_votes[_id_session].length;
        
        uint256[] memory votes = new uint256[](length);
        votes = table_session_votes[_id_session];

        return votes; // returns [id_session, id_vote, id_vote, id_vote] | FIX LATER
    }

    function countVotes(uint256 _id_session) public view returns(string[] memory) {

        uint256[] memory votes = getVotes(_id_session);
        string[] memory options = getOptions(_id_session); 
        uint256[] memory counted = new uint256[](votes.length);
        string[] memory report = new string[](options.length);

        // count from i = 1;
        for (uint256 i = 1; i < votes.length; i++) {   
            counted[table_vote[votes[i]]._id_option]++;
        }

        for (uint256 i = 0; i < options.length; i++) { // table_session_votes   
            string memory report_string = string.concat(options[i], " voted ");
            report_string = string.concat(report_string, Strings.toString(counted[i]));
            report[i] = report_string;
        }

        return report;
    }

    function countVotesOption(uint256 _id_session, uint256 _id_option) public view returns(string memory) {

        uint256[] memory votes = getVotes(_id_session);
        string[] memory options = getOptions(_id_session); 
        uint256[] memory counted = new uint256[](votes.length);

        // count from i = 1;
        for (uint256 i = 1; i < votes.length; i++) { // table_session_votes   
            counted[table_vote[votes[i]]._id_option]++;
        }
        
        string memory report_string = string.concat(options[_id_option], " voted ");
        report_string = string.concat(report_string, Strings.toString(counted[_id_option]));
        
        return report_string;
    }

    function alreadyVoted (uint256 _id_session) public view returns(bool) {

        for (uint256 i = 1; i < table_session_votes[_id_session].length; i++) {
            if (table_vote[table_session_votes[_id_session][i]]._votedBy == msg.sender) {
                return true;
            }
        }

        return false;
    }

    function isSessionOwner(uint256 _id_session) public view returns(bool) {
        return table_session[_id_session]._createdBy == msg.sender;
    }

    function getSessionList() public view returns(SessionView[] memory) {
        
        SessionView[] memory _SessionViewArray = new SessionView[](table_session.length);

        for (uint256 i = 0; i < table_session.length; i++) {
            SessionView memory _SessionView;
            _SessionView.id_session = table_session[i]._id;
            _SessionView.name = table_session[i]._name;
            _SessionViewArray[i] = _SessionView;
        }
        
        return _SessionViewArray;
    }


    function getMySessionList() public view returns(SessionView[] memory) {        
        
        SessionView[] memory _SessionViewArray = new SessionView[](table_session.length);

        for (uint256 i = 0; i < table_session.length; i++) {
            if (table_session[i]._createdBy == msg.sender) {
                SessionView memory _SessionView;
                _SessionView.id_session = table_session[i]._id;
                _SessionView.name = table_session[i]._name;
                _SessionView.status = table_session[i]._status;
                _SessionViewArray[i] = _SessionView;
            }
        }
        
        return _SessionViewArray;
    }
   
}   
