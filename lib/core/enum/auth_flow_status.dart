enum AuthFlowStatus {
  uninitialized, // belum dicek
  notLoggedIn,   // belum login
  incompleteData, // login tapi belum isi data
  ready,         // login & data lengkap
}
