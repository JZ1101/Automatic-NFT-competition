<template>
  <div>
    <h1>About the Project</h1>
    <p>This is a decentralized application for NFT competition.</p>
    <p>It allows artists to upload their NFT artworks and art enthusiasts to vote for their favorite artworks.</p>
    <h2>General rules for the competition</h2>
    <p>The competition will last for a year, with minimum 52 terms in total, and each term with a period of 7 days</p>
    <p>Each term has a topic in rolling sequence: Freestyle, Animals, News</p>
    <p>When the term finishes the reward will be distributed to the owner of the top 3 artwork and the maintainor who successfully trigger the end term Function</p>
    <p>The reward is: 5 GA tokens for first place, 3 GA for second place, 2 GA for the third place, and 1 GA for the maintainor</p>
    <p>The ranking for the artwork is ranked by the votes received in descending sequence, if votes are equal the artwork uploaded ealier wins</p>
    <p></p>
    <h2>Rules for voters</h2>
    <p>Each user can only vote once for each artwork</p>
    <p>Users may vote for multiple artworks in a term</p>
    <h2>Rules for artists</h2>
    <p>Artist can only upload their owned NFTs</p>
    <p>Only one token in each Contract(collection) is allowed</p>
    <h2>Transaction and contract detials</h2>
    <h3><a href="https://sepolia.etherscan.io/address/0x3561Ee1b93a3B585544be44e50c8cf7AD92b2ca7">Competition Contract</a></h3>
    <h3><a href="https://sepolia.etherscan.io/address/0x1195127e1E5DDd81b33A8764a5762C71132c8A7F">Reward Contract</a></h3>
  </div>
</template>
<style scoped> 
  h1 {
    margin-top: 80px;
  }
</style>