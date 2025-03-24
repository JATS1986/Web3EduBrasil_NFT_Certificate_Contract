# Web3EduBrasil_NFT_Certificate_Contract
Projeto solidity NFT (didático) através da WEB3EDU

## Passos para o desenvolvimento do projeto através da IDE VScode e Foundry

### 1 Criação do projeto em Foundry (usuário já deve ter instalado anteriormente):

- Abertura do terminal e execução do comando em bash:
forge init certificate-contract

- Ir para o caminho:
cd certificate-contract

- Instalação das dependências (OpenZeppelin para ERC721), ainda no bash:
forge install OpenZeppelin/openzeppelin-contracts --no-commit

### 2 Realizar alterações básicas para produção do projeto:

- Alteração do nome do arquivo principal e exclusão dos outros na pasta script e test:
Counter.sol para "NOME_DESEJADO.sol" na pasta "src"

- Adicionado o caminho das libs no foundry.toml (caso necessário se não for instalado):
[profile.default]
libs = ["lib"]

### 3 O "PROJETO":

Criação de um contrato inteligente modelo ERC-721 (NFT) que tem a finalidade da produção de Certificados de Cursos disponibilizados pela Instituição competente "CourseCertificate.sol". Sendo liberado para o mint através dos alunos que tiverem a permissão após cumprimento dos requisitos estipulados pela instituição.

- Funções presentes no contrato "CourseCertificate":
- 1 Mint de Certificados:
  - Somente a instituição (owner) pode emitir NFTs;
- 2 Metadados no OpenSea:
  - O tokenURI retorna JSON com atributos customizados;
- 3 Hospedagem de Metadados:
  - Opção 1 (Simples): Use data:application/json (metadados diretamente na blockchain);
  - Opção 2 (Recomendada): Hospede o JSON em IPFS (ex: Pinata)

### 4 Execuções práticas para o desenvolvimento do PROJETO:

- Código para a compilação do Contrato no terminal em bash, gera os artefatos de compilação (bytecode, ABI, metadados) na pasta out/ - verifica erros de sintaxe, dependências e otimiza o código (se configurado):
forge build

- Utilização:
Sempre que você modificar o código de um contrato.
Antes de executar testes (forge test) ou implantar (forge script).
Para garantir que o código está livre de erros de compilação.

### 5 Criação do contrato de teste CourseCertificate.t.sol:
- Objetivo: 
Verifica se o contrato foi implantado corretamente

- Verificações: 
Se o dono do contrato é a instituição (institution) / O estudante não possui tokens inicialmente

- Código para a execução do testes:
forge test -vvv
ou usando o nome do contrato e mais alguns detalhes:
forge test --match-contract CourseCertificateTest -vvv

### 6 Criação do contrato do script CourseCertificate.s.sol:
- Objetivo:
Permite implantar o contrato em diferentes redes (testnet/mainnet), vamos usar a local do Foundry em que se tem controles pré-definidos.

### 7 Teste local no fork ANVIL

- Rodar o anvil com tempo determinado (o valor pode ser alterado que representa a quantidade em segundos - exemplo de uso):
anvil --block-time 30

----------------------------------- Outros possíveis exemplos de uso ----------------------------------------

- Verificação dos blocos através do uso do CAST pelo foundry é possível fazer as análises dos blocos e até consulta (consulta o bloco atual):
cast block-number --rpc-url http://localhost:8545

- Minerar Blocos Manualmente (Opcional - Cada execução cria um novo bloco instantaneamente):
cast rpc evm_mine --rpc-url http://localhost:8545

- Definir Blocos com Timestamp Específico:
cast rpc evm_setNextBlockTimestamp 1700000000 --rpc-url http://localhost:8545
cast rpc evm_mine --rpc-url http://localhost:8545 # Cria o bloco

- Acelerar o Tempo
cast rpc evm_increaseTime 3600 --rpc-url http://localhost:8545 # +1 hora
cast rpc evm_mine --rpc-url http://localhost:8545 # Aplica a mudança

### 8 Cria um arquivo externo na raiz .env para variáveis de ambiente

- Normalmente, utiliza-se este arquivo para declarar variáveis que são sensíveis a exposição, então, por prática de segurança, deixa-nas armazenadas neste arquivo como utilizam o .gitgnore para evitar a publicação. Então, no projeto foi armazenados a princípio seguindo a lógica do contrato para o PROJETO com tais variáveis:
RPC_URL=http://localhost:8545
INSTITUTION_ADDRESS="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" # Endereço da conta (0) do Anvil
INSTITUTION_PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" # Chave conta (0) do Anvil

- Carregue as Variáveis de Ambiente em outro terminal "bash" (no VS Code, escolhe a opção de divisão de terminal, para melhor visualização da execução dos próximos passos e mint na blockchain local):
source .env

- Abre o terminal em "bash" para exportar apontando para a blockchain local do Anvil:
export RPC_URL=http://localhost:8545

- No terminal em "bash" exporta apontando a primeira conta do Anvil que tem a chave privada:
export INSTITUTION_PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"

- Ainda no terminal em "bash" exporta apontando o primeiro endereço do Anvil:
export INSTITUTION_ADDRESS="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"

- Confirmação das variáveis de ambiente no Anvil:
echo $RPC_URL # Deve mostrar "http://localhost:8545"
echo $INSTITUTION_PRIVATE_KEY # Deve mostrar a chave da conta (0)
echo $INSTITUTION_ADDRESS # Deve mostrar o endereço da conta (0)

- Implantação do contrato em rede local (PC):
forge script script/CourseCertificate.s.sol:CourseCertificateScript --rpc-url $RPC_URL --private-key $INSTITUTION_PRIVATE_KEY --broadcast -vvvv

- Após implementação do script irá:
Cria uma nova instância do "CourseCertificate" na blockchain / Passa "institutionAddress" para o construtor (define o dono) através da execução da função "OwnershipTransferred" em que a Intituição é dona (owner) da contrato

- Verificação da implantação do contrato ao owner específico
cast call <CONTRACT_ADDRESS> "owner(uint256)" --rpc-url $RPC_URL

### 9 Criação de um novo script de interação "Interact.s.sol" com o contrato "CourseCertificate.s.sol" para emitir o certificado para o aluno

- Atualização do arquivo .env para implementação de novas variáveis de ambiente, visto que agora a instituição é dona (owner) do contrato "CourseCertificate" e possuí um endereço na blockchain local, então, aplica para um aluno que deseja mintar o certificado um endereço (2° do Anvil, atenção, poderia ser entre os outros 9 que ainda não foram utilizados):
STUDENT_ADDRESS="0x70997970C51812dc3A010C7d01b50e0d17dc79C8" # Endereço da conta (1) do Anvil
STUDENT_PRIVATE_KEY="0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d" # Chave conta (1)
CONTRACT_ADDRESS="0x5FbDB2315678afecb367f032d93F642f64180aa3" # Endereço do contrato implantado (Anvil)

- Novamente, carregue as Variáveis de Ambiente no terminal "bash":
source .env

- Exporta o contrato implementado para a blockchain do Anvil
export CONTRACT_ADDRESS="0x5FbDB2315678afecb367f032d93F642f64180aa3"  # Endereço do contrato implantado
export STUDENT_ADDRESS="0x70997970C51812dc3A010C7d01b50e0d17dc79C8"  # Endereço do aluno (segunda conta do Anvil)
export STUDENT_PRIVATE_KEY="0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d" # Chave conta (1)

- Confirmação das variáveis de ambiente no Anvil:
echo $CONTRACT_ADDRESS # Deve mostrar o contrato implementado
echo $STUDENT_ADDRESS # Deve mostrar o endereço da conta (1)
echo $STUDENT_PRIVATE_KEY # Deve mostrar a chave da conta (1)

- Execute o script "Interact" para emitir um certificado de forma que haverá a leitura das variáveis de ambiente CONTRACT_ADDRESS para localizar o contrato implantado e o STUDENT_ADDRESS para definir o destinatário do certificado:
forge script script/Interact.s.sol:InteractScript --rpc-url $RPC_URL --private-key $INSTITUTION_PRIVATE_KEY --broadcast -vvvv

- O fluxo na blockchain ocorre:
 1. Transação Assinada: A chave privada da instituição ($INSTITUTION_PRIVATE_KEY) assina a transação.
 2. Chamada à Função: A função mintCertificate é executada no contrato.
 3. Evento CertificateMinted: É emitido, registrando a criação do certificado.
 4. Confirmação: A transação é incluída em um bloco no Anvil.

- Verifique a confirmação que o certificado foi emitido e apresenta o dono (owner - contrato respectivo ao "estudante" permitido):
cast call $CONTRACT_ADDRESS "ownerOf(uint256)" 123 --rpc-url $RPC_URL

- Emite a URI Base64 com os dados do certificado:
cast call $CONTRACT_ADDRESS "tokenURI(uint256)" 123 --rpc-url $RPC_URL

- Para obtenção da transformação dos dados codificados, segue:
  1. **Remover o prefixo "0x"**: A string começa com "0x" e identifique a parte UTF-8 codificada. O valor real começa após o cabeçalho ABI, mas não faz parte dos dados em si;
  2. **Exclusão da cadeia de zeros longa**: Faz a exclusão da sequência de zeros e mais 3 dígitos após a quantidade os zeros (sejam eles números ou letras), como também os zeros no fim da calda da string;
  3. **Converter hexadecimal para base64**: Para converter a string hexadecimal em uma sequência de bytes ainda bem bash: echo "VALORES_QUE_SOBRARAM_DA_STRING" | xxd -r -p
  4. **Decodificar base64 para texto**: Decodificador base64 para transformar os bytes em texto legível, retira o cabeçalho "data:application/json;base64," até a vírgula e ainda em bash: echo "STRING_RESULTANTE_DO_BASE64" | base64 -d

- Exemplo presente, após executar o script "Interact.s.sol" com os dados presentes do aluno, junto aos contidos em "CourseCertificate.sol" resultaram na string:

0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000015d646174613a6170706c69636174696f6e2f6a736f6e3b6261736536342c65794a755957316c496a6f67496b4e6c636e52705a6d6c6a595752764947526c4946646c596a4d694c434a6b5a584e6a636d6c7764476c766269493649434a445a584a3061575a705932466b6279426c62576c306157527649484276636942436247396a61324e6f59576c7549464e6a6147397662434973496d463064484a70596e56305a584d694f69426265794a30636d4670644639306558426c496a6f67496b567a6448566b595735305a53497349434a32595778315a53493649434a4262476c6a5a534a394c48736964484a686158526664486c775a53493649434a4464584a7a6279497349434a32595778315a53493649434a585a57497a496e307365794a30636d4670644639306558426c496a6f67496b5268644745694c434169646d4673645755694f6941694d5463304d4451354d4441784d434a395858303d000000

Assim, aos passos:
- 1. 0x:
0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000015d646174613a6170706c69636174696f6e2f6a736f6e3b6261736536342c65794a755957316c496a6f67496b4e6c636e52705a6d6c6a595752764947526c4946646c596a4d694c434a6b5a584e6a636d6c7764476c766269493649434a445a584a3061575a705932466b6279426c62576c306157527649484276636942436247396a61324e6f59576c7549464e6a6147397662434973496d463064484a70596e56305a584d694f69426265794a30636d4670644639306558426c496a6f67496b567a6448566b595735305a53497349434a32595778315a53493649434a4262476c6a5a534a394c48736964484a686158526664486c775a53493649434a4464584a7a6279497349434a32595778315a53493649434a585a57497a496e307365794a30636d4670644639306558426c496a6f67496b5268644745694c434169646d4673645755694f6941694d5463304d4451354d4441784d434a395858303d000000 | xxd -r -p

- 2. 0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000015d + 000000, em bash:
echo "646174613a6170706c69636174696f6e2f6a736f6e3b6261736536342c65794a755957316c496a6f67496b4e6c636e52705a6d6c6a595752764947526c4946646c596a4d694c434a6b5a584e6a636d6c7764476c766269493649434a445a584a3061575a705932466b6279426c62576c306157527649484276636942436247396a61324e6f59576c7549464e6a6147397662434973496d463064484a70596e56305a584d694f69426265794a30636d4670644639306558426c496a6f67496b567a6448566b595735305a53497349434a32595778315a53493649434a4262476c6a5a534a394c48736964484a686158526664486c775a53493649434a4464584a7a6279497349434a32595778315a53493649434a585a57497a496e307365794a30636d4670644639306558426c496a6f67496b5268644745694c434169646d4673645755694f6941694d5463304d4451354d4441784d434a395858303d" | xxd -r -p

- 3. Hex -> base64, em bash:
echo "eyJuYW1lIjogIkNlcnRpZmljYWRvIGRlIFdlYjMiLCJkZXNjcmlwdGlvbiI6ICJDZXJ0aWZpY2FkbyBlbWl0aWRvIHBvciBCbG9ja2NoYWluIFNjaG9vbCIsImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIkVzdHVkYW50ZSIsICJ2YWx1ZSI6ICJBbGljZSJ9LHsidHJhaXRfdHlwZSI6ICJDdXJzbyIsICJ2YWx1ZSI6ICJXZWIzIn0seyJ0cmFpdF90eXBlIjogIkRhdGEiLCAidmFsdWUiOiAiMTc0MDQ5MDAxMCJ9XX0=" | base64 -d

- 4. base64 -> texto:
{
  "name": "Certificado de Web3",
  "description": "Certificado emitido por Blockchain School",
  "attributes": [
    {
      "trait_type": "Estudante", 
      "value": "Alice"
      },
    {
      "trait_type": "Curso", 
      "value": "Web3"
      },
    {
      "trait_type": "Data", 
      "value": "1740490010"
    }
  ]
}

#### Formas de uso com a rede testnet Sepolia

- Implantação usando a testnet da Sepolia com a rede e chave da Infura:
forge script script/CourseCertificate.s.sol:CourseCertificateScript \
--rpc-url https://sepolia.infura.io/v3/abc123 \
--private-key 0xabc... \
--broadcast

- Implante na rede (ex: Sepolia):
forge create --rpc-url [RPC_URL] \
--private-key [PRIVATE_KEY] \
src/CourseCertificate.sol:CourseCertificate \
--constructor-args [ENDEREÇO_DA_INSTITUIÇÃO]