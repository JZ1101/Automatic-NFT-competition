<template>
  <div class="Balance">
    <h1>Your Balance</h1>
    <p>{{ balance }} GA (GoodArtist Tokens)</p>
    <p>Token contract address: {{ contractAddress }}</p>
    <input v-model="recipient" placeholder="Recipient address">
    <input v-model.number="amount" type="number" placeholder="Amount to send">
    <button @click="transferTokens">Transfer</button>
    <button @click="fetchBalance">Refresh Balance</button>
  </div>
</template>

<script>
import { ethers } from 'ethers';
import { ref, onMounted } from 'vue';
import tokenABI from '@/contracts/tokenABI';

const contractAddress = "0x1195127e1E5DDd81b33A8764a5762C71132c8A7F";

export default {
setup() {
  const balance = ref('0');
  const recipient = ref('');
  const amount = ref(0);

  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const contract = new ethers.Contract(contractAddress, tokenABI, provider.getSigner());

  const fetchBalance = async () => {
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();
    const address = await signer.getAddress();
    const balanceBigNumber = await contract.balanceOf(address);
    balance.value = ethers.utils.formatUnits(balanceBigNumber, 6);
  };

  const transferTokens = async () => {
    try {
      const tx = await contract.transfer(recipient.value, ethers.utils.parseUnits(amount.value.toString(), 6));
      await tx.wait();
      fetchBalance();
      alert('Transfer successful!');
    } catch (error) {
      console.error('Transfer failed:', error);
      alert('Transfer failed! See console for details.');
    }
  };
  
  contract.on("Transfer", (from, to, amount, event) => {
  console.log(`Good Artist Token transfer from ${from} to ${to} amount ${amount}`);
  fetchBalance();
  });

  onMounted(fetchBalance);

  return { balance, recipient, amount, fetchBalance, transferTokens,contractAddress };
}
};
</script>

<style scoped>
.Balance {
  margin-top: 120px;
}
p{
  margin: 20px;
}
</style>
