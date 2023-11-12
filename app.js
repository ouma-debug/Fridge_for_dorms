window.addEventListener('load', async () => {
    const infuraProjectId = '39a22c6cf92c4811940739fd8e62523b';
    const web3 = new Web3(`https://sepolia.infura.io/v3/${infuraProjectId}`);

    const userAccessControlAddress = '0x6Cf71Ed5d026199d86f7EBa711b78Ad8c0aA1d40';
    const userAccessControlABI = [
        // ... (userAccessControlABI remains the same)
    ];
    const userAccessControl = new web3.eth.Contract(userAccessControlABI, userAccessControlAddress);

    const checkAccessButton = document.getElementById('checkAccessButton');
    const userAddressInput = document.getElementById('userAddress');
    const message = document.getElementById('message');

    checkAccessButton.addEventListener('click', async () => {
        const userAddress = userAddressInput.value;
        const owner = await userAccessControl.methods.owner().call();

        if (owner === userAddress) {
            message.innerHTML = 'You are the owner.';
        } else {
            const allowed = await userAccessControl.methods.allowedUsers(userAddress).call();
            if (allowed) {
                try {
                    const valueInEther = 0.1;
                    const recipientAddress = '0xcaE621d53427E7a5dC90cE5425c72DaBa2DfCD9d';
                    const transactionObject = {
                        to: recipientAddress,
                        value: web3.utils.toWei(valueInEther.toString(), 'ether'),
                        gas: 300000,
                        gasPrice: web3.utils.toWei('50', 'gwei'),
                    };

                    await web3.eth.sendTransaction(transactionObject);

                    const accessCode = await userAccessControl.methods.accessCodes(userAddress).call();
                    message.innerHTML = `Access granted. Your 4-digit code is: ${accessCode}`;
                } catch (error) {
                    message.innerHTML = 'Failed to pay the application fee.';
                }
            } else {
                message.innerHTML = 'This address is not allowed.';
            }
        }
    });
});
