const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
var XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest;

var db = admin.database();
var ref = db.ref();

exports.updateItem = functions.https.onRequest((request, response) => {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() { 
        if (this.readyState == 4 && this.status == 200) { 
            var res = JSON.parse(xhttp.responseText);
            
            ref.child('info').set({
                id: res['deal']['id'],
                title: res['deal']['title'],
                description: res['deal']['features'],
                photos: res['deal']['photos'],
                items: res['deal']['items']
            });
            ref.child('settings').set({
                accentColor: res['deal']['theme']['accentColor'],
                backgroundColor: res['deal']['theme']['backgroundColor'],
                foreground: res['deal']['theme']['foreground']
            });
        }
    };
    xhttp.open('GET', 'https://api.meh.com/1/current.json?apikey=KEY', true);
    xhttp.send();
    response.send('Updated.');
});

exports.sendDealUpdate = functions.database.ref('/info').onUpdate(event => {
    const info = event.data.val();
    const tokens = [];
    var payload = {
            notification: {
                title: 'Check out this new deal!',
                body: info.title,
                content_available: 'true'
            }
    };
    
    admin.database().ref(`/notifications`).once('value', (snapshot) => {
        snapshot.forEach(function (token) {
            if (token.val()) {
                admin.messaging().sendToDevice(token.key, payload).then(function (response) {
                    console.log("Successfully sent message:", JSON.stringify(response));
                }).catch(function (error) {
                    console.log("Error sending message:", JSON.stringify(error));
                });
            }
        });
        
        return true;
    });
    
    return 'No devices.';
})