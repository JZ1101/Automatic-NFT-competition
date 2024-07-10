<template>
    <div class="Leaderboard" justify="center">
      <h1 style="margin-top: 150px">All Term Winners</h1>
      <div v-for="(term, termIndex) in terms" :key="termIndex" style="margin-top: 50px">
        <h2>Term {{ term.id }}: {{ term.topic }}</h2>
        <!-- Check winners -->
        <ul v-if="term.winners && term.winners.length > 0">
          <li v-for="(winner, winnerIndex) in term.winners" :key="winnerIndex">
            Winner {{ winnerIndex + 1 }}:
            <ul>
              <li>NFT Address: {{ winner.nftAddress }}</li>
              <li>Current Owner Address: {{ winner.owner }}</li>
              <li>Votes: {{ winner.voteCount }}</li>
              <!-- image of the NFT -->
              <li>
                <img :src="winner.imageUrl" alt="NFT Image" style="max-width: 200px;" @error="handleImageError(winnerIndex)">
                <p v-if="winner.imageLoadError">Failed to load image</p>
              </li>
            </ul>
          </li>
          
        </ul>
        <!-- if no winners -->
        <p v-else>No artwork achieved one or more votes in this term, hence no winners</p>
      </div>
      <p style="margin-bottom: 150px"></p>
      <div v-if="terms.length === 0">
        <p>Loading terms...</p>
      </div>
    </div>
  </template>
  
  <script>
  import { ethers } from 'ethers';
  import { ref, onMounted } from 'vue';
  import competitionABI from '@/contracts/competitionABI';
  import tokenURIABI from '@/contracts/tokenURIABI'; 
  
  export default {
    
    setup() {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const contractAddress = "0x3561Ee1b93a3B585544be44e50c8cf7AD92b2ca7";
      const contract = new ethers.Contract(contractAddress, competitionABI, provider);
      const terms = ref([]);
  
      const fetchAllWinners = async () => {
      const currentTermId = await contract.currentTermId();
      for (let termId = 1; termId < currentTermId; termId++) {// until the last term before current term
        const termDetails = await contract.terms(termId);
        const [winningAddresses, voteCounts] = await contract.determineWinners(termId);

        // fetch NFT metadata for each winner
        const winners = (await Promise.all(winningAddresses.map(async (address, index) => {
          if (address === '0x0000000000000000000000000000000000000000' || !address) {return null;}
          const nftContract = new ethers.Contract(address, tokenURIABI, provider);
          let owner; 

          try {
            const tokenId = await contract.NFT_ID(address);
            owner = await nftContract.ownerOf(tokenId); // assign owner 
            const tokenURI = await nftContract.tokenURI(tokenId);
            const metadataResponse = await fetch(tokenURI);
            const metadata = await metadataResponse.json();
            const imageUrl = metadata.image || 'default_image.png'; 
            return {
              nftAddress: address,
              voteCount: voteCounts[index],
              owner,
              imageUrl,
              imageLoadError: false // initialize error flag
            };
          }catch (error) {
            console.error('Error retrieving NFT details:', error);
            return {
              nftAddress: address,
              voteCount: voteCounts[index],
              owner, 
              imageUrl: '', 
              imageLoadError: true // set error
            };
          }
        }))).filter(winner => winner !== null); 

        terms.value.push({
          id: termId,
          topic: termDetails.topic,
          winners
        });
      }
    };

  
      onMounted(fetchAllWinners);
  
      const handleImageError = (winnerIndex) => {
        terms.value.forEach(term => {
          term.winners.forEach((winner, index) => {
            if (index === winnerIndex) {
              winner.imageLoadError = true;
            }
          });
        });
      };
      return { terms, handleImageError };
    }
  };
  </script>

<style scoped>
.Leaderboard {
  display: flex;
  flex-direction: column;
  align-items: center; 
  margin: 300px;
  margin-top: 150px;
  padding: 20px;
  background-color: #f8f9fa;
  border-radius: 16px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
</style>