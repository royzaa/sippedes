

const functions = require("firebase-functions");


const admin = require("firebase-admin");


admin.initializeApp();
const db = admin.firestore();
exports.sendPushNotification = functions.firestore
    .document("civil/{nik}/history/{id}")
    .onCreate(async (snapshot) => {
      const letterSnapshot = snapshot.data();
      const querySnapshot = await db.collection("civil")
          .doc(letterSnapshot.nik)
          .collection("tokens")
          .get();
      const tokens = querySnapshot.docs.map((snap) => snap.id);
      return admin.messaging()
          .sendToDevice(tokens, {notification: {
            title: letterSnapshot.letterName,
            body: "Pengajuan untuk" + " " + letterSnapshot.letterName +
              " " + "sudah berstatus" + " " + letterSnapshot.progressStatus,
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          }});
    });

exports.sendPushNotificationWhenUpdate = functions.firestore
    .document("civil/{nik}/history/{id}")
    .onUpdate(async (change, context) => {
      const letterSnapshot = change.after.data();
      if (letterSnapshot.progressStatus != "Terkirim") {
        const querySnapshot = await db.collection("civil")
            .doc(letterSnapshot.nik)
            .collection("tokens")
            .get();
        const tokens = querySnapshot.docs.map((snap) => snap.id);
        return admin.messaging().sendToDevice(tokens, {notification: {
          title: letterSnapshot.data().letterName,
          body: "Pengajuan untuk" + " " + letterSnapshot.data().letterName +
          " " + "sudah berstatus" + " " + letterSnapshot.data().progressStatus,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        }});
      }
    });
