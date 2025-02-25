// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//Implementação do padrão NFT ERC-721
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//Permite restringir funções ao dono do contrato (a instituição)
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
//Implementação de codificação Base64 (usada em tokenURI)
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
//Implementação para transformação de números inteiros em strings
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

//O contrato herda funcionalidades de ERC721 (NFT) e Ownable (controle de acesso)
contract CourseCertificate is ERC721, Ownable {
    //Contador para gerar IDs únicos de NFTs
    uint256 private _tokenIdCounter;

    //Estrutura para armazenar metadados do certificado
    struct CertificateData {
        string studentName;
        string courseName;
        string institutionName;
        uint256 completionDate;
    }

    //Mapeia cada ID de token aos seus dados (armazenamento on-chain)
    mapping(uint256 => CertificateData) private _certificates;
    //Emitido quando um certificado é criado. Permite rastrear mintings via blockchain
    event CertificateMinted(address indexed student, uint256 tokenId);
    //Inicializa o NFT com nome "CourseCertificate" e símbolo "CERT".
    //Define institutionAddress como dono do contrato (só ele pode emitir certificados)
    constructor(address institutionAddress)
        ERC721("CourseCertificate", "CERT") 
        Ownable(institutionAddress)
    {}
    //Função que cria o certificado NFT com os dados para um estudante
    function mintCertificate(
        address studentAddress,
        string memory studentName,
        string memory courseName,
        string memory institutionName
    //Restringe ao dono (instituição) pode chamar essa função
    ) external onlyOwner {
        //Gera um novo ID único, incrementando o contador de tokens
        uint256 tokenId = _tokenIdCounter++;
        //Função do ERC721 que mint o NFT para a carteira do estudante (com verificação de segurança)
        _safeMint(studentAddress, tokenId);
        //Armazena os metadados do certificado no mapping
        _certificates[tokenId] = CertificateData({
            studentName: studentName,
            courseName: courseName,
            completionDate: block.timestamp,
            institutionName: institutionName
        });
        //Dispara o evento para registro da criação do certificado na blockchain       
        emit CertificateMinted(studentAddress, tokenId);
    }
    //Função de verificação se um token existe
    function _exists(uint256 tokenId) internal view returns (bool) {
        //Função do ERC721 que retorna o dono do token. Se for address(0), o token não existe
        return _ownerOf(tokenId) != address(0);
    }
    //Função que retorna os metadados de um certificado
    function getCertificateData(uint256 tokenId) public view returns (CertificateData memory) {
        //Verifica se o token foi mintado (função do ERC721)
        require(_exists(tokenId), "Token nao existe");
        //Retorna os metadados armazenados no mapping
        return _certificates[tokenId];
    }
    //Sobrescreve a função tokenURI (gerando URI dos metadados do NFT) do ERC721
    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        //Verifica se o token existe para garantir sua criação
        require(_exists(tokenId), "Token nao existe");
        
        CertificateData memory data = _certificates[tokenId];
        //Constrói um JSON com os metadados (formatado para OpenSea)
        string memory json = string(abi.encodePacked(
            '{"name": "Certificado de ', data.courseName, '",',
            '"description": "Certificado emitido por ', data.institutionName, '",',
            '"attributes": [',
            '{"trait_type": "Estudante", "value": "', data.studentName, '"},',
            '{"trait_type": "Curso", "value": "', data.courseName, '"},',
            '{"trait_type": "Data", "value": "', Strings.toString(data.completionDate), '"}',
            ']}'
        ));
        //Codifica o JSON em Base64 (para gerar uma URI válida de metadados) 
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    function revokeCertificate(uint256 tokenId) external onlyOwner {
        _burn(tokenId); // Queima o NFT
        delete _certificates[tokenId]; // Remove os metadados
    }
}
