use dep::std;
use dep::std::hash::poseidon::bn254;

// Verify the final game outcome (win, loss, or draw)
fn verifyHomeAuth(homeAuth: [Field; 2], AuthHash : Field)  {
    let homeAuthent = bn254::hash_2(homeAuth);
    assert(AuthHash == homeAuthent);
}

fn main(homeAuth: [Field; 2],  AuthHash: pub Field) {
    verifyHomeAuth(homeAuth, AuthHash);
}

#[test]
fn test_main() {
   let  homeAuth = [1,2];
    let AuthHash = 0x115cc0f5e7d690413df64c6b9662e9cf2a3617f2743245519e19607a4417189a;
    main(homeAuth, AuthHash);
}
