// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {CourseCertificate} from "../src/CourseCertificate.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol"; // Importe para acessar o custom error

contract CourseCertificateTest is Test {
    CourseCertificate public certificate;
    
    address public institution = address(0x123); // Endereço da instituição
    address public student = address(0x456); // Endereço do estudante

    function setUp() public {
        vm.prank(institution);
        certificate = new CourseCertificate(institution); // Implanta o contrato
    }

    // Testa se o contrato é implantado corretamente
    function test_Deployment() public {
        assertEq(certificate.owner(), institution, "A instituicao deve ser a dona");
        assertEq(certificate.balanceOf(student), 0, "Estudante nao possui tokens inicialmente");
    }

    // Testa a emissao de um certificado
    function test_MintCertificate() public {
        vm.prank(institution); // Simula a instituição chamando a função
        certificate.mintCertificate(
            student,
            "Joao Silva",
            "Blockchain Basics",
            "Web3EduBr"
        );

        // Verifica se o estudante recebeu o NFT
        assertEq(certificate.ownerOf(0), student, "Estudante deve ser dono do token 0");
        assertEq(certificate.balanceOf(student), 1, "Saldo do estudante deve ser 1");

        // Verifica os metadados armazenados
        CourseCertificate.CertificateData memory data = certificate.getCertificateData(0);
        assertEq(data.studentName, "Joao Silva", "Nome do estudante incorreto");
        assertEq(data.courseName, "Blockchain Basics", "Nome do curso incorreto");
        assertEq(data.institutionName, "Web3EduBr", "Nome da instituicao incorreto");
        assertEq(data.completionDate, block.timestamp, "Data de conclusao incorreta");
    }

    // Testa se apenas o dono pode emitir certificados
    function test_OnlyOwnerCanMint() public {
        vm.prank(student); // Simula um nao-dono chamando a função
        // Define o erro esperado (OwnableUnauthorizedAccount) com o endereço do student
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                student
            )
        );
        // Tentativa de mint por não-dono
        certificate.mintCertificate(
            student,
            "Jose Souza",
            "Smart Contracts",
            "Web3 Academy"
        );
    }

    // Testa a recuperacao de dados de um token inexistente
    function test_GetNonExistentCertificate() public {
        vm.expectRevert("Token nao existe");
        certificate.getCertificateData(999); // Token que nao existe
    }
}
