<template>
  <div class="MainPage">
    <h1>Current Term: {{ currentTerm.topic }}</h1>
    <h3>Term No.{{ currentTerm.id }}</h3>
    <button @click="publishNFT">Publish New NFT</button>
    <button @click="endTerm">End Term & Earn</button>
    <div v-if="nfts.length > 0" class="nft-list">
      <div class="nft-item" v-for="nft in paginatedNfts" :key="nft.address">
        <img :src="nft.imageUrl" alt="NFT image" class="nft-image">
        <div class="nft-info">
          <h3>{{ nft.title }}</h3>
          <p>{{ nft.description }}</p>
          <p>Address: {{ nft.address }}</p>
          <p>Owner: {{ nft.owner }}</p>
          <p>Votes: {{ nft.voteCount }}</p>
          <button @click="voteForNFT(nft.address)">Vote</button>
        </div>
      </div>
    </div>
    <p v-else>No NFTs found for the current term.</p>
    <nav v-if="pageCount > 1">
      <button @click="currentPage--" :disabled="currentPage <= 1">Previous</button>
      <span>Page {{ currentPage }} of {{ pageCount }}</span>
      <button @click="currentPage++" :disabled="currentPage >= pageCount">Next</button>
    </nav>
  </div>
</template>

<script>
import { ethers } from 'ethers';
import { ref, onMounted, onUnmounted, computed } from 'vue';
import competitionABI from '@/contracts/competitionABI'; // ABI for competition contract
import tokenURIABI from '@/contracts/tokenURIABI'; // ABI for nft contract

const contractAddress = "0xFBf8c2794De9152a7f692a47CA624cD2EE30501C"; // competition address

export default {
  setup() {
    const nfts = ref([]);
    const currentTerm = ref({ id: '', topic: '' });
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const contract = new ethers.Contract(contractAddress, competitionABI, provider);
    const fetchCurrentTermDetails = async () => {
      const termId = await contract.currentTermId();
      const term = await contract.terms(termId);
      currentTerm.value = { id: term.id.toString(), topic: term.topic };
    };
    async function loadNFTs() {
      await provider.send("eth_requestAccounts", []);
      const currentTermId = await contract.currentTermId();
      const nftAddresses = await contract.getCurrentTermNFTs();

      const metadataPromises = nftAddresses.map(async (nftAddress) => {
        const voteCount = await contract.getNFTVoteCount(currentTermId, nftAddress);
        const tokenId = await contract.NFT_ID(nftAddress); 
        const nftContract = new ethers.Contract(nftAddress, tokenURIABI, provider);
        
        let owner;
        try {
          owner = await nftContract.ownerOf(tokenId);
        } catch (error) {
          console.error('Error fetching owner:', error);
          owner = 'Unknown Owner';
        }

        try {
          const tokenURI = await nftContract.tokenURI(tokenId);
          console.log("Token URI:", tokenURI);
          const response = await fetch(tokenURI);
          
          if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
          }
          const metadata = await response.json();
          console.log("Raw JSON Response:", metadata);

          return {
            address: nftAddress,
            owner: owner,
            imageUrl: metadata.image || 'default_image.png', 
            title: metadata.name || 'Unknown Title',
            description: metadata.description || 'No description available.',
            voteCount: voteCount
          };
        } catch (error) {
          console.error('Error fetching or parsing NFT metadata:', error);
          return {
            address: nftAddress,
            owner: owner,
            imageUrl: 'default_image.png',
            title: 'Metadata Not Found',
            description: 'Unable to fetch metadata for this NFT.',
            voteCount: voteCount
          };
        }
      });

      nfts.value = await Promise.all(metadataPromises);
    }




    async function voteForNFT(nftAddress) {
      const signer = provider.getSigner();
      const contractWithSigner = contract.connect(signer);
      try {
        await contractWithSigner.vote(nftAddress);
        await loadNFTs(); // reload NFTs 
        alert('Vote successful!');
      } catch (error) {
        console.error('Error voting for NFT:', error);
        alert('Failed to vote. See console for details.');
      }
    }

    async function publishNFT() {
      const nftAddress = prompt("Enter NFT address:");
      const tokenId = prompt("Enter token ID:");
      if (!nftAddress || !tokenId) return alert("NFT address and token ID are required.");

      const signer = provider.getSigner();
      const contractWithSigner = contract.connect(signer);
      try {
        await contractWithSigner.publish(nftAddress, tokenId,{ gasLimit: 1000000 });
        await loadNFTs(); // reload NFTs
        
        
        alert('NFT published request successfully!');
      } catch (error) {
        console.error('Error publishing NFT:', error);
        alert('Failed to publish. See console for details.');
      }
    }



    
    async function endTerm() {
      const signer = provider.getSigner();
      const contractWithSigner = contract.connect(signer);
      try {
        const transactionResponse = await contractWithSigner.endTerm();
        console.log('Transaction response:', transactionResponse);
        await transactionResponse.wait(); // Wait for the transaction to be mined
        await loadNFTs(); // reload NFTs
        alert('Term ended successfully!');
      } catch (error) {
        console.error('Error ending the term:', error);
        alert('Failed to end the term. See console for details.');
      }
    }
    function listenToContractEvents() {
      const contractWithSigner = contract.connect(provider.getSigner());

      contractWithSigner.on('TermEndNotification', (termId, topic) => {
        console.log(`Term ${termId} ended with topic ${topic}.`);
        // logs tracking from smart contract
        loadNFTs();
      });

      contractWithSigner.on('RewardNotification', (recipient, amount, termId) => {
        console.log(`Reward of ${amount} sent to ${recipient} for term ${termId}.`);
        // logs tracking from smart contract
      });
    }
    const currentPage = ref(1);
    const itemsPerPage = 4;
    // pageCount = number of NFts / itemsPerPage
    const pageCount = computed(() => {
      return nfts.value.length ? Math.ceil(nfts.value.length / itemsPerPage) : 0;
    });

    const paginatedNfts = computed(() => {
      if (nfts.value.length) {
        const start = (currentPage.value - 1) * itemsPerPage;
        return nfts.value.slice(start, start + itemsPerPage);
      } else {
        return [];
      }
    });


   

    onMounted(() => {
      loadNFTs();
      listenToContractEvents();
      fetchCurrentTermDetails();
    });
    onUnmounted(() => {
      contract.removeAllListeners();
    });
     // Return the properties and currentPage
     return { nfts, voteForNFT, publishNFT, endTerm, currentTerm, currentPage, pageCount, paginatedNfts };
  }
};
</script>

<style scoped>
h1{
  margin-top: 150px;
}
.nft-list {
  display: grid;
  grid-template-columns: repeat(2, 1fr); /* Creates two columns */
  gap: 32px; 
  margin: 0 auto; 
  max-width: 1200px; 
  padding: 0 16px; 
}

.nft-item {
  background-color: #f8f8f8; 
  border: 1px solid #c9c6c6; 
  border-radius: 8px; 
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.247); 
  padding: 16px; 
  width: 550px;
}

.nft-image {
  max-width: 100%; 
  height: auto; 
  margin-bottom: 16px; 
}
</style>

