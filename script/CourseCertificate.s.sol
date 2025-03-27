// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {CourseCertificate} from "../src/CourseCertificate.sol";

contract CourseCertificateScript is Script {
    //Função obrigatória em scripts do Foundry
    function run() external returns (CourseCertificate) {
        // Configuração do ambiente para implantação
        address institutionAddress = vm.envAddress("INSTITUTION_ADDRESS"); // Endereço da instituição (variável de ambiente - .env)

        vm.startBroadcast(); // Inicia a transação na blockchain
        CourseCertificate certificate = new CourseCertificate(institutionAddress, "Solidity Developer", "SOLDEV"); // Implanta o contrato, passando o endereço da instituição para o construtor
        vm.stopBroadcast(); // Finaliza a transação

        return certificate; // Retorna a instância do contrato implantado para uso futuro (opcional)
    }
}
