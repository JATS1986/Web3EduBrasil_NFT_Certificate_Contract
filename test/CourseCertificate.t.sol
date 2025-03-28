// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {CourseCertificate} from "../src/CourseCertificate.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract CourseCertificateTest is Test {
    CourseCertificate public certificate;

    address public institution = address(0x123); // Endereço da instituição
    address public student = address(0x456); // Endereço do estudante
    address public attacker = address(0x789); // Endereço de atacante externo

    uint256 constant TOKEN_ID = 123; // ID fixo para testes
    string constant STUDENT_NAME = "Joao Silva";
    string constant COURSE_NAME = "Blockchain Avancado";
    string constant INSTITUTION_NAME = "Web3 Academy";

    function setUp() public {
        vm.prank(institution);
        certificate = new CourseCertificate(institution, "Solidity Developer", "SOLDEV"); // Implanta o contrato
    }

    // Testa se o contrato é implantado corretamente
    function test_Deployment() public view {
        assertEq(certificate.owner(), institution, "A instituicao deve ser a dona");
        assertEq(certificate.balanceOf(student), 0, "Estudante nao possui tokens inicialmente");
    }

    // Testa a emissao de um certificado
    function test_MintCertificate() public {
        vm.prank(institution); // Simula a instituição chamando a função
        certificate.mintCertificate(TOKEN_ID, student, STUDENT_NAME, COURSE_NAME, INSTITUTION_NAME);

        // Verifica se o estudante recebeu o NFT com um TOKEN_ID
        assertEq(certificate.ownerOf(TOKEN_ID), student, "Dono incorreto");
        assertEq(certificate.balanceOf(student), 1, "Saldo incorreto");

        // Verifica os metadados armazenados
        CourseCertificate.CertificateData memory data = certificate.getCertificateData(TOKEN_ID);
        assertEq(data.studentName, STUDENT_NAME, "Nome do estudante incorreto");
        assertEq(data.courseName, COURSE_NAME, "Nome do curso incorreto");
        assertEq(data.institutionName, INSTITUTION_NAME, "Instituicao incorreta");
        assertEq(data.completionDate, block.timestamp, "Data de conclusao incorreta");
        /* O estudante é dono do token ID 123
        O saldo do estudante é 1 
        Os metadados armazenados (nome, curso, instituição, data) estão corretos */
    }

    // Testa se apenas o dono pode emitir certificados
    function test_OnlyOwnerCanMint() public {
        vm.prank(attacker); // Simula um nao-dono chamando a função
        // Define o erro esperado (OwnableUnauthorizedAccount) com o endereço do student
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, attacker));
        // Tentativa de mint por não-dono
        certificate.mintCertificate(TOKEN_ID, student, STUDENT_NAME, COURSE_NAME, INSTITUTION_NAME);
        /* Um endereço não autorizado (atacante) tenta emitir um certificado 
        Verifica se a transação é revertida com a mensagem Ownable: caller is not the owner */
    }

    // Teste de metadados (tokenURI)
    function test_TokenURI() public {
        vm.prank(institution);
        certificate.mintCertificate(TOKEN_ID, student, STUDENT_NAME, COURSE_NAME, INSTITUTION_NAME);

        string memory uri = certificate.tokenURI(TOKEN_ID); // Usa TOKEN_ID

        console.log("URI: ", uri);


        // Verifica se o JSON contem os dados corretos
        string memory expectedJson = string(
            abi.encodePacked(
                '{"name": "Certificado de ',
                COURSE_NAME,
                '",',
                '"description": "Certificado emitido por ',
                INSTITUTION_NAME,
                '",',
                '"attributes": [',
                '{"trait_type": "Estudante", "value": "',
                STUDENT_NAME,
                '"},',
                '{"trait_type": "Curso", "value": "',
                COURSE_NAME,
                '"},',
                '{"trait_type": "Data", "value": "',
                Strings.toString(block.timestamp),
                '"}',
                "]}"
            )
        );

        // Codifica o JSON esperado em Base64
        string memory expectedUri =
            string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(expectedJson))));

        // Compara as URIs diretamente
        assertEq(uri, expectedUri, "URI incorreta");
    }

    // Teste de recuperação de dados de certificado inexistente
    function test_GetNonExistentCertificate() public {
        vm.expectRevert(abi.encodeWithSelector(CourseCertificate.TokenDoesNotExist.selector, TOKEN_ID));
        certificate.getCertificateData(TOKEN_ID); // Token que nao existe
    }

    // Testa se a data de conclusão do certificado é registrada corretamente, mesmo em diferentes condições de tempo.
    function test_CompletionDate() public {
        uint256 specificTime = 1700000000; // Congela o tempo em 13/11/2023
        vm.warp(specificTime);
        vm.prank(institution);
        certificate.mintCertificate(TOKEN_ID, student, STUDENT_NAME, COURSE_NAME, INSTITUTION_NAME);

        CourseCertificate.CertificateData memory data = certificate.getCertificateData(TOKEN_ID);
        assertEq(data.completionDate, specificTime, "Data de conclusao incorreta"); // Teste deterministico
    }

    // Testa se um certificado pode ser revogado pela instituição
    function test_RevokeCertificate() public {
        // Emite um certificado
        vm.prank(institution);
        certificate.mintCertificate(TOKEN_ID, student, STUDENT_NAME, COURSE_NAME, INSTITUTION_NAME);


        //TESTE TEMPORARIO para verificar se o tokenID pode ser reutilizado
        vm.prank(institution);
        vm.expectRevert(abi.encodeWithSelector(CourseCertificate.TokenIdAlreadyExists.selector, TOKEN_ID));
        certificate.mintCertificate(TOKEN_ID, student, "JOSE DA SILVA", "WEB3EDU SOLIDITY" , "WEB3EDUTECH");

        // Revoga o certificado
        vm.prank(institution);
        certificate.revokeCertificate(TOKEN_ID); // Usa TOKEN_ID

        // Verificações
        assertEq(certificate.balanceOf(student), 0, "Certificado nao foi queimado");
        // Verifica limpeza de dados
        vm.expectRevert(abi.encodeWithSelector(CourseCertificate.TokenDoesNotExist.selector, TOKEN_ID));
        certificate.getCertificateData(TOKEN_ID);

        //Verifica se o ID pode ser  reutilizado
        vm.prank(institution);
        certificate.mintCertificate(TOKEN_ID, student, "JOSE DA SILVA", "WEB3EDU SOLIDITY" , "WEB3EDUTECH");
        assertEq(certificate.ownerOf(TOKEN_ID), student, "Dono incorreto");
        assertEq(certificate.balanceOf(student), 1, "Saldo incorreto");
        CourseCertificate.CertificateData memory data = certificate.getCertificateData(TOKEN_ID);
        assertEq(data.studentName, "JOSE DA SILVA", "Nome do estudante incorreto");
        assertEq(data.courseName, "WEB3EDU SOLIDITY", "Nome do curso incorreto");
        assertEq(data.institutionName, "WEB3EDUTECH", "Instituicao incorreta");
        assertEq(data.completionDate, block.timestamp, "Data de conclusao incorreta");
    }

    // Teste de revogação por não-dono
    function test_NonOwnerRevoke() public {
        vm.prank(institution);
        certificate.mintCertificate(TOKEN_ID, student, STUDENT_NAME, COURSE_NAME, INSTITUTION_NAME);

        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("OwnableUnauthorizedAccount(address)")), attacker));
        certificate.revokeCertificate(TOKEN_ID);
    }



}
