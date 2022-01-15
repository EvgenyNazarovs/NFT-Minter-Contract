// SPDX-License-Identified: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 limit = 50;

    string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>";
    string svgPartTwo = "</style><rect width='100%' height='100%' fill='";
    string svgBlackFont = ".base { fill: black; font-family: serif; font-size: 24px; }";
    string svgWhiteFont = ".base { fill: white; font-family: serif; font-size: 24px; }";
    string svgPartThree = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
    
    string[] writers = [
        "Dostoyevsky",
        "Kafka",
        "Joyce",
        "Proust",
        "Delillo",
        "Bolano",
        "Tolstoy",
        "Chekhov",
        "Bernhard",
        "Dickens"
        ];

    string[] actions = [
        "Loves",
        "Adores",
        "Craves",
        "Likes",
        "Demolishes"
    ];

    string[] foods = [
        "Sushi",
        "Burgers",
        "Pizzas",
        "Cheesecakes",
        "Cakes",
        "Cookies",
        "Pasta",
        "Avocadoes",
        "Veggies",
        "Potatoes"
    ];

    string[] colours = ["##06174B",  "#BA3548", "#EC5333", "#EAC22F", "#4D962D"];

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721 ("Cyprus", "Cyp") {
        console.log("Professor Lockdown is at it AGAIN!");
    }

    function pickRandomWriter(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        rand = rand % writers.length;
        return writers[rand];
    }

    function pickRandomAction(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % actions.length;
        return actions[rand];
    }

    function pickRandomFood(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % foods.length;
        return foods[rand];
    }

    function pickRandomColour(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("COLOUR", Strings.toString(tokenId))));
        rand = rand % colours.length;
        return colours[rand];
    }

    function pickFontColour(string memory colour) internal view returns (string memory) {
        return (keccak256(bytes(colour)) == keccak256(bytes("#EAC22F"))
            || keccak256(bytes(colour)) == keccak256(bytes("#EC5333")))
            ? svgBlackFont
            : svgWhiteFont;
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function getTotalMintedNFTs() public view returns (uint256) {
        return _tokenIds.current();
    }
 
    function makeAnEpicNFT() public {
        uint256 newItemId = _tokenIds.current();
        require(newItemId < limit, "The NFT minting limit has been reached!");

        console.log("total minted so far: ", getTotalMintedNFTs());

        string memory writer = pickRandomWriter(newItemId);
        string memory action = pickRandomAction(newItemId);
        string memory food = pickRandomFood(newItemId);
        string memory combinedWord = string(abi.encodePacked(writer, action, food));

        string memory randomColour = pickRandomColour(newItemId);
        string memory font = pickFontColour(randomColour);
        string memory finalSvg = string(abi.encodePacked(
            svgPartOne,
            font,
            svgPartTwo,
            randomColour,
            svgPartThree,
            combinedWord,
            "</text></svg>"
            ));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        combinedWord,
                        '", "description": "HE IS AT IT AGAIN!!", "image": "data:image/svg+xml;base64,', 
                        Base64.encode(bytes(finalSvg)), '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");


        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, finalTokenUri);
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
        _tokenIds.increment();
        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}

