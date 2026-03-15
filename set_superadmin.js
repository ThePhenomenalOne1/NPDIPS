const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccount.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function setSuperadmin() {
  // Find user by email
  const snapshot = await db.collection('users')
    .where('email', '==', 'portialin@raza.com')
    .limit(1)
    .get();

  if (snapshot.empty) {
    console.error('No user found with email portialin@raza.com');
    process.exit(1);
  }

  const docRef = snapshot.docs[0].ref;
  const before = snapshot.docs[0].data();
  console.log(`Found user: ${before.name} (${before.email}) — current role: ${before.role}`);

  await docRef.update({
    role: 'Superadmin',
    permissions: ['all'],
  });

  console.log('✅ Role updated to Superadmin successfully.');
  process.exit(0);
}

setSuperadmin().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
