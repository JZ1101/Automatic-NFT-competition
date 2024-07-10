<template>
  <div>
    <h4>Thank you for using this decentralized application</h4>
    <h4>You can browse the 'About' section before you connect your wallet </h4>
    <h4>You will need to connect your Metamask wallet to access 'Main', 'Winner' and balance section</h4>
    <ConnectWallet @wallet-connected="handleWalletConnected" class = "button-3d"/>
  </div>
</template>

<script>
import { ref } from 'vue';
import ConnectWallet from '@/components/ConnectWallet.vue';
import { useRouter } from 'vue-router';

export default {
  components: {
    ConnectWallet,
  },
  setup() {
    const router = useRouter();
    const walletAddress = ref('');

     const handleWalletConnected = (address) => {
      walletAddress.value = address; // store address
      alert(`Wallet ${walletAddress.value} is connected`); // show an alert with connected wallet address
      router.push({ name: 'Main' }); // navigate to main page
    };
    return { handleWalletConnected};
  },
};
</script>


<style scoped>

.button-3d {
  margin-top: 50px;
  padding: 10px 20px;
  background-color: #29ea50;
  border: none;
  color: white;
  outline: none;
  cursor: pointer;
  position: relative;
  border-radius: 5px;
  font-size: 16px;
  transition: all 0.3s ease;
  box-shadow: 0 4px #a5f5c5;
}


h4{
  margin-top: 30px;
  font-size: 20px;
  font-weight: bold;
  color: #000000;
}
</style>



