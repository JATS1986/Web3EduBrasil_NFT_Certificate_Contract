// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {CourseCertificate} from "../src/CourseCertificate.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol"; // Importe para acessar o custom error
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract CourseCertificateTest is Test {
    CourseCertificate public certificate;
    
    address public institution = address(0x123); // Endereço da instituição
    address public student = address(0x456); // Endereço do estudante
    address public attacker = address(0x789); // Endereço de atacante externo

    string constant STUDENT_NAME = "Joao Silva";
    string constant COURSE_NAME = "Blockchain Avancado";
    string constant INSTITUTION_NAME = "Web3 Academy";

    function setUp() public {
        vm.prank(institution);
        certificate = new CourseCertificate(institution); // Implanta o contrato
    }

    // Testa se o contrato é implantado corretamente
    function test_Deployment() public view {
        assertEq(certificate.owner(), institution, "A instituicao deve ser a dona");
        assertEq(certificate.balanceOf(student), 0, "Estudante nao possui tokens inicialmente");
    }

    // Testa a emissao de um certificado
    function test_MintCertificate() public {
        vm.prank(institution); // Simula a instituição chamando a função
        certificate.mintCertificate(
            student, 
            STUDENT_NAME, 
            COURSE_NAME, 
            INSTITUTION_NAME
        );

        // Verifica se o estudante recebeu o NFT
        assertEq(certificate.ownerOf(0), student, "Estudante deve ser dono do token 0");
        assertEq(certificate.balanceOf(student), 1, "Saldo do estudante deve ser 1");

        // Verifica os metadados armazenados
        CourseCertificate.CertificateData memory data = certificate.getCertificateData(0);
        assertEq(data.studentName, STUDENT_NAME, "Nome do estudante incorreto");
        assertEq(data.courseName, COURSE_NAME, "Nome do curso incorreto");
        assertEq(data.institutionName, INSTITUTION_NAME, "Instituicao incorreta");
        assertEq(data.completionDate, block.timestamp, "Data de conclusao incorreta");
        /* O estudante é dono do token ID 0
        O saldo do estudante é 1 
        Os metadados armazenados (nome, curso, instituição, data) estão corretos */
    }

    // Testa se apenas o dono pode emitir certificados
    function test_OnlyOwnerCanMint() public {
        vm.prank(attacker); // Simula um nao-dono chamando a função
        // Define o erro esperado (OwnableUnauthorizedAccount) com o endereço do student
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                attacker
            )
        );
        // Tentativa de mint por não-dono
        certificate.mintCertificate(
            student,
            STUDENT_NAME,
            COURSE_NAME,
            INSTITUTION_NAME
        );
        /* Um endereço não autorizado (atacante) tenta emitir um certificado 
        Verifica se a transação é revertida com a mensagem Ownable: caller is not the owner */
    }    
    
    // Teste de metadados (tokenURI)
    function test_TokenURI() public {
        vm.prank(institution);
        certificate.mintCertificate(student, STUDENT_NAME, COURSE_NAME, INSTITUTION_NAME);
        
        string memory uri = certificate.tokenURI(0);

        // Verifica se o JSON contem os dados corretos
        string memory expectedJson = string(abi.encodePacked(
            '{"name": "Certificado de ', COURSE_NAME, '",',
            '"description": "Certificado emitido por ', INSTITUTION_NAME, '",',
            '"attributes": [',
            '{"trait_type": "Estudante", "value": "', STUDENT_NAME, '"},',
            '{"trait_type": "Curso", "value": "', COURSE_NAME, '"},',
            '{"trait_type": "Data", "value": "', Strings.toString(block.timestamp), '"}',
            ']}'
        ));

        // Codifica o JSON esperado em Base64
        string memory expectedUri = string(
            abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(expectedJson)))
        );

        // Compara as URIs diretamente
        assertEq(uri, expectedUri, "URI incorreta");
    }

    // Teste de recuperação de dados de certificado inexistente
    function test_GetNonExistentCertificate() public {
        vm.expectRevert("Token nao existe");
        certificate.getCertificateData(999); // Token que nao existe
    }

    // Testa se a data de conclusão do certificado é registrada corretamente, mesmo em diferentes condições de tempo.
    function test_CompletionDate() public {
        uint256 specificTime = 1700000000; // Congela o tempo em 13/11/2023
        vm.warp(specificTime);
        vm.prank(institution);
        certificate.mintCertificate(student, STUDENT_NAME, COURSE_NAME, INSTITUTION_NAME);
        
        CourseCertificate.CertificateData memory data = certificate.getCertificateData(0);
        assertEq(data.completionDate, specificTime, "Data especifica incorreta"); // Teste deterministico
    }

    // Testa se um certificado pode ser revogado pela instituição
    function test_RevokeCertificate() public {
        // Emite um certificado
        vm.prank(institution);
        certificate.mintCertificate(student, STUDENT_NAME, COURSE_NAME, INSTITUTION_NAME);
        
        // Revoga o certificado 
        vm.prank(institution);
        certificate.revokeCertificate(0); // Função a ser implementada
        
        // Verificações
        assertEq(certificate.balanceOf(student), 0, "Certificado nao foi queimado");
        // Verifica limpeza de dados
        vm.expectRevert("Token nao existe");
        certificate.getCertificateData(0);
    }

    // Teste de revogação por não-dono
    function test_NonOwnerRevoke() public {
        vm.prank(institution);
        certificate.mintCertificate(student, STUDENT_NAME, COURSE_NAME, INSTITUTION_NAME);
        
        vm.prank(attacker);
        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(keccak256("OwnableUnauthorizedAccount(address)")),
                attacker
            )
        );
        certificate.revokeCertificate(0);
    }
}
