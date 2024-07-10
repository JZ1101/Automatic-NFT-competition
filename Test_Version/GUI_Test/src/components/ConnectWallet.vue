<template>
    <button @click="connectWallet">Connect Wallet</button>
  </template>
  
  <script>
import { ethers } from 'ethers';

export default {
  name: 'ConnectWallet',
  emits: ['wallet-connected'],
  methods: {
    async connectWallet() {
      if (window.ethereum) {
        try {
          await window.ethereum.request({ method: 'eth_requestAccounts' });
          const provider = new ethers.providers.Web3Provider(window.ethereum);
          const signer = provider.getSigner();
          const address = await signer.getAddress();
          console.log('Connected address:', address);
          this.$emit('wallet-connected', address); // Emit the connected address
        } catch (error) {
          console.error('Error connecting to wallet:', error);
        }
      } else {
        console.log('Please install MetaMask!');
      }
    },
  },
};
</script>
  