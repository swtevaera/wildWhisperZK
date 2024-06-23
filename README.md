# tevaera-onchain-game-poc
### 0. install packages
```
yarn 
```
### 1. run POT15 ceremony 
```
yarn ptau
```
### 2. Build zkeys and verification keys for impostor circuit, then export to Solidity contract
```
yarn setupimpostor
```

### 3. Build zkeys and verification keys for crewmate circuit, then export to Solidity contract
```
yarn setupcrewmate
```
### 4. Build zkeys and verification keys for task circuit, then export to Solidity contract
```
yarn setuptask
```

### 5. Build zkeys and verification keys for killProof circuit, then export to Solidity contract
```
yarn setupkillproof
```
### 6. Build zkeys and verification keys for sabotage circuit, then export to Solidity contract
```
yarn setupSabotage
```

### test 
### 1. test the impostor circuit
```
 node "./test/impostor.js" 
```
### 2. test the crewmate circuit
```
 node "./test/crewmate.js" 
```

### 3. test the killProof circuit
```
 node "./test/killProof.js" 
```
### 4. test the task circuit
```
 node "./test/task.js" 
```
### 5. test the sabotage circuit
```
 node "./test/sabotage.js" 
```
