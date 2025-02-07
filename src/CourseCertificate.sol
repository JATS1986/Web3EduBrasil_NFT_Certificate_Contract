// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";

contract CourseCertificate is ERC721, Ownable {
    uint256 private _tokenIdCounter;

    struct CertificateData {
        string studentName;
        string courseName;        
        string institutionName;
        uint256 completionDate;
    }

    mapping(uint256 => CertificateData) private _certificates;
    
    event CertificateMinted(address indexed student, uint256 tokenId);

    constructor(address institutionAddress) 
        ERC721("CourseCertificate", "CERT") 
        Ownable(institutionAddress) 
    {}

    function mintCertificate(
        address studentAddress,
        string memory studentName,
        string memory courseName,
        string memory institutionName
    ) external onlyOwner {
        uint256 tokenId = _tokenIdCounter++;
        _safeMint(studentAddress, tokenId);

        _certificates[tokenId] = CertificateData({
            studentName: studentName,
            courseName: courseName,
            completionDate: block.timestamp,
            institutionName: institutionName
        });
        
        emit CertificateMinted(studentAddress, tokenId);
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function getCertificateData(uint256 tokenId) public view returns (CertificateData memory) {
        require(_exists(tokenId), "Token nao existe");
        return _certificates[tokenId];
    }
    
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        require(_exists(tokenId), "Token nao existe");
        
        CertificateData memory data = _certificates[tokenId];
        string memory json = string(abi.encodePacked(
            '{"name": "Certificado de ', data.courseName, '",',
            '"description": "Certificado emitido por ', data.institutionName, '",',
            '"attributes": [',
            '{"trait_type": "Estudante", "value": "', data.studentName, '"},',
            '{"trait_type": "Curso", "value": "', data.courseName, '"},',
            '{"trait_type": "Data", "value": "', toString(data.completionDate), '"}',
            ']}'
        ));

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }
}
