const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.deleteUserByEmail = functions.https.onCall(async (data, context) => {
    const email = data.email;

    if (!context.auth) {
        throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
    }

    try {
        const userRecord = await admin.auth().getUserByEmail(email);
        await admin.auth().deleteUser(userRecord.uid);
        return { message: `Successfully deleted user with email: ${email}` };
    } catch (error) {
        throw new functions.https.HttpsError('unknown', error.message, error);
    }
});
