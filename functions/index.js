const admin = require("firebase-admin");
const axios = require("axios");
const functions = require("firebase-functions");

admin.initializeApp(functions.config().firebase);

const ref = admin.database().ref();

const sendNewDealNotification = (deal) => {
  const payload = {
    notification: {
      title: "Check out this new deal!",
      body: deal,
      content_available: "true"
    }
  };

  return sendNotification(payload);
};

const sendDealSoldoutNotification = (deal) => {
  const payload = {
    notification: {
      title: "The current deal has sold out!",
      body: `There are no more ${deal}'s left!`,
      content_available: "true"
    }
  };

  return sendNotification(payload);
};

const sendNotification = (payload) => {
  let tokens = [];

  return admin.database().ref("/notifications").once("value", (snapshot) => {
    snapshot.forEach(function (childSnapshot) {
      if (childSnapshot.val()) {
        tokens.push(childSnapshot.key);
      }
    });

    return admin.messaging().sendToDevice(tokens, payload).then((res) => {
      console.log("Successfully sent message:", JSON.stringify(res));
    }).catch((err) => {
      console.log("Error sending message:", JSON.stringify(err));
      return err;
    });
  });
};

exports.updateItem = functions.https.onRequest((request, response) => {
  return ref.child("API_KEY").once("value", (snapshot) => {
    const API_KEY = snapshot.val();
    return axios.get(`https://api.meh.com/1/current.json?apikey=${API_KEY}`).then((res) => {
      return ref.child("currentDeal").once("value").then((snapshot) => {
        ref.child(`previousDeal/${snapshot.child("id").val()}`).update(snapshot.val());
        return ref.child(`previousDeal/${snapshot.child("id").val()}/date`).once("value").then(childSnapshot => {
          if (!childSnapshot.exists()) {
            ref.child(`previousDeal/${snapshot.child("id").val()}/date`).set(new Date().getTime());
          }
          ref.child("deal").set(res.data.deal);
          Object.keys(res.data).forEach(key => ref.child(`currentDeal/${key}`).set(res.data[key]));
          response.send("Updated.");
          return true;
        });
      });
    }).catch((err) => {
      console.error("Error fetching meh data...", err);
      return err;
    })
  });
});

exports.sendDealUpdate = functions.database.ref("deal").onUpdate((change, context) => {
  const previousDeal = change.before.val();
  const deal = change.after.val();

  if (previousDeal.title === deal.title) {
    return true;
  } else if (!previousDeal.soldOutAt && deal.soldOutAt) {
    return sendDealSoldoutNotification(deal.title);
  } else {
    return sendNewDealNotification(deal.title);
  }
});