// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {CourseCertificate} from "../src/CourseCertificate.sol";

contract InteractScript is Script {
    //Função obrigatória em scripts do Foundry
    function run() external {
        
        CourseCertificate certificate = CourseCertificate(vm.envAddress("CONTRACT_ADDRESS"));

        // Use o endereço de um aluno (ex: segunda conta do Anvil)
        address student = vm.envAddress("STUDENT_ADDRESS");

        vm.startBroadcast();
        //Chama a função para emitir um certificado com os respectivos dados
        //TOKEN_ID, student, STUDENT_NAME, COURSE_NAME, INSTITUTION_NAME
        certificate.mintCertificate(123, student, "Alice", "Web3", "Blockchain School");
        vm.stopBroadcast();
    }
}