/* eslint-disable max-len */

const functions = require("firebase-functions");


const admin = require("firebase-admin");


admin.initializeApp();
exports.sendPushNotification = functions.firestore.document("civil/{nik}/history/{id}").onCreate((snapshot, context) => {
  return admin.messaging().sendToTopic("letter", {notification: {
    title: snapshot.data().letterName,
    body: "Pengajuan untuk" + " " + snapshot.data().letterName + " " + "sudah berstatus" + " " + snapshot.data().progressStatus,
    clickAction: "FLUTTER_NOTIFICATION_CLICK",
  }});
});

exports.sendPushNotificationWhenUpdate = functions.firestore.document("civil/{nik}/history/{id}").onUpdate((change, context) => {
  return admin.messaging().sendToTopic("letter", {notification: {
    title: change.after.data().letterName,
    body: "Pengajuan untuk" + " " + change.after.data().letterName + " " + "sudah berstatus" + " " + change.after.data().progressStatus,
    clickAction: "FLUTTER_NOTIFICATION_CLICK",
  }});
});
