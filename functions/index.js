const admin = require("firebase-admin");
const axios = require("axios");
const functions = require("firebase-functions");
admin.initializeApp(functions.config().firebase);

let ref = admin.database().ref();

exports.updateItem = functions.https.onRequest((request, response) => {
  return ref.child("API_KEY").once("value", (snapshot) => {
    const API_KEY = snapshot.val();
    return axios.get(`https://api.meh.com/1/current.json?apikey=${API_KEY}`).then((res) => {
      ref.child("deal").set(res.data.deal);
      ref.child("info").set({
        id: res.data.deal.id,
        title: res.data.deal.title,
        description: res.data.deal.features,
        photos: res.data.deal.photos,
        items: res.data.deal.items
      });
      ref.child("settings").set({
        accentColor: res.data.deal.theme.accentColor,
        backgroundColor: res.data.deal.theme.backgroundColor,
        foreground: res.data.dealtheme.foreground
      });
      response.send("Completed.");
      return true;
    }).catch((err) => {
      console.error("Error fetching meh data...", err);
      return err;
    })
  });
});

exports.sendDealUpdate = functions.database.ref("deal").onUpdate((change, context) => {
  const deal = change.after.val();
  const tokens = [];
  const payload = {
    notification: {
      title: "Check out this new deal!",
      body: deal.title,
      content_available: "true"
    }
  };

  return admin.database().ref("/notifications").once("value", (snapshot) => {
    snapshot.forEach(function (childSnapshot) {
      if (childSnapshot.val()) {
        tokens.push(childSnapshot.key);
      }
    });

    return admin.messaging().sendToDevice(tokens, payload).then((res) => {
      console.log("Successfully sent message:", JSON.stringify(res));
      return true;
    }).catch((err) => {
      console.log("Error sending message:", JSON.stringify(err));
      return err;
    });
  });
});